@tool
@icon("res://stoneblock/icons/SB_Move3D.svg")
class_name SB_Trail3D
extends Node3D

## Génère une traînée rectangulaire (ribbon) dans le sillage de l'objet suivi.
## Ajouter comme enfant du Node3D animé (ou assigner target_node manuellement).
## La traînée est en espace monde : elle persiste même si l'objet change de direction.

@export_group("Target")
## Nœud 3D à suivre. Si vide, utilise le parent.
@export var target_node: Node3D

@export_group("Trail")
## Largeur du ruban près du vaisseau (extrémité récente).
@export_range(0.0, 10.0, 0.01, "suffix:m") var trail_width_near: float = 0.2
## Largeur du ruban loin du vaisseau (extrémité ancienne).
@export_range(0.0, 10.0, 0.01, "suffix:m") var trail_width_far: float = 4.0
## Distance minimale de déplacement avant d'ajouter un nouveau point.
@export_range(0.01, 5.0, 0.01, "suffix:m") var min_point_distance: float = 0.05
## Nombre maximum de points conservés (contrôle la longueur de la traînée).
@export_range(4, 2000, 1) var max_points: int = 300
## Vider la traînée automatiquement quand la séquence redémarre (recommandé).
@export var auto_clear: bool = true
## Décalage du point d'origine en espace LOCAL du vaisseau.
## Ex : Vector3(0, 0, 1) = 1m derrière si -Z est l'avant du modèle.
@export var spawn_offset: Vector3 = Vector3(-0.2, -0.2, 0.0)

@export_group("Appearance")
## Couleur et opacité du ruban. Alpha < 1 active la transparence.
@export var trail_color: Color = Color(1.0, 1.0, 1.0, 0.85):
	set(v):
		trail_color = v
		if _mat:
			(_mat as ShaderMaterial).set_shader_parameter("base_color", v)

## Forme du gradient bord→centre : 1.0 = linéaire, 2.0 = doux (recommandé), 4.0+ = concentré.
@export_range(0.5, 8.0, 0.1) var edge_softness: float = 0.5:
	set(v): edge_softness = v; if _mat: (_mat as ShaderMaterial).set_shader_parameter("edge_softness", v)

## Force du bloom émis (plus élevé = contour plus flou/lumineux dans le bloom).
@export_range(0.0, 8.0, 0.1) var emission_strength: float = 2.5:
	set(v): emission_strength = v; if _mat: (_mat as ShaderMaterial).set_shader_parameter("emission_strength", v)

## Estompe la traînée à partir de la queue (alpha 0 → 1 du plus ancien au plus récent).
@export var fade_tail: bool = false

## Durée en secondes avant qu'un point disparaisse complètement (0 = pas de fade temporel).
@export_range(0.0, 30.0, 0.1, "suffix:s") var fade_duration: float = 3.0

## Axe "haut" utilisé pour orienter la largeur du ruban.
## Laisser Vector3.UP pour un ruban horizontal (condensation d'avion, etc.).
@export var up_axis: Vector3 = Vector3.UP

@export_group("Bloom")
## Active le bloom sélectif sur le trail.
@export var bloom_enabled: bool = true:
	set(v): bloom_enabled = v; _apply_render_layers()
## Numéro du calque de rendu bloom (11 = Story, 10 = Standard global). Voir SB_BloomSelector3D.
@export_range(1, 20) var bloom_layer_index: int = 11:
	set(v): bloom_layer_index = v; _apply_render_layers()

# ── Internes ────────────────────────────────────────────────────────────────
var _points: PackedVector3Array   ## Positions monde de chaque point
var _rights: PackedVector3Array   ## Vecteurs "droite" normalisés à chaque point
var _ages: PackedFloat32Array     ## Âge de chaque point en secondes

var _mesh_instance: MeshInstance3D
var _mesh: ImmediateMesh
var _mat: ShaderMaterial

# ── Init ─────────────────────────────────────────────────────────────────────

func _ready() -> void:
	if not target_node and get_parent() is Node3D:
		target_node = get_parent()
	_setup_mesh()

func _setup_mesh() -> void:
	if _mesh_instance:
		return

	_mesh = ImmediateMesh.new()

	var shader := load("res://shaders/spatial/trail_ribbon.gdshader") as Shader
	_mat = ShaderMaterial.new()
	_mat.shader = shader
	_mat.set_shader_parameter("edge_softness", edge_softness)
	_mat.set_shader_parameter("emission_strength", emission_strength)

	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "TrailMesh"
	_mesh_instance.mesh = _mesh
	_mesh_instance.material_override = _mat
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# top_level = true → le mesh est en espace monde indépendant du parent
	_mesh_instance.top_level = true
	_mesh_instance.global_transform = Transform3D.IDENTITY
	add_child(_mesh_instance)
	_apply_render_layers()

# ── API Publique ─────────────────────────────────────────────────────────────

## Applique les Render Layers 3D au mesh (bloom sélectif).
## Appel automatique au démarrage et quand les exports bloom changent.
func _apply_render_layers() -> void:
	if not _mesh_instance:
		return
	# Layer 1 = rendu standard (toujours actif)
	var mask: int = 1
	if bloom_enabled:
		mask |= (1 << (bloom_layer_index - 1))
	_mesh_instance.layers = mask

## Efface toute la traînée.
func clear() -> void:
	_points.clear()
	_rights.clear()
	_ages.clear()
	if _mesh:
		_mesh.clear_surfaces()

# ── Process ──────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not target_node or not _mesh:
		return

	if fade_duration > 0.0:
		_age_points(delta)
	_try_add_point()
	_rebuild_mesh()

# ── Logique interne ──────────────────────────────────────────────────────────

func _try_add_point() -> void:
	# Position avec offset en espace local du vaisseau → converti en espace monde
	var pos: Vector3 = target_node.global_transform * spawn_offset

	if _points.size() == 0:
		# Premier point : direction inconnue, on utilisera le vecteur suivant
		_points.append(pos)
		_rights.append(Vector3.RIGHT)  # temporaire, corrigé au 2e point
		_ages.append(0.0)
		return

	var diff: Vector3 = pos - _points[-1]
	var dist: float = diff.length()

	if dist < min_point_distance:
		# Pas assez de mouvement : on met à jour la position du dernier point
		_points[-1] = pos
		return

	var move_dir: Vector3 = diff / dist  # normalisé
	var right: Vector3 = _compute_right(move_dir)

	# Mettre à jour le right du point précédent avec la direction réelle
	if _rights.size() > 0:
		_rights[-1] = right

	_points.append(pos)
	_rights.append(right)
	_ages.append(0.0)

	# Limiter la longueur de la traînée (pare-feu, le fade temporel gère l'expiration)
	while _points.size() > max_points:
		_points.remove_at(0)
		_rights.remove_at(0)
		_ages.remove_at(0)


func _compute_right(move_dir: Vector3) -> Vector3:
	## Calcule le vecteur "droite" du ruban, perpendiculaire à move_dir et à up_axis.
	var up: Vector3 = up_axis.normalized()

	# Fallback si move_dir est quasi-parallèle à up
	if abs(move_dir.dot(up)) > 0.98:
		if abs(move_dir.dot(Vector3.FORWARD)) < 0.98:
			up = Vector3.FORWARD
		else:
			up = Vector3.RIGHT

	return move_dir.cross(up).normalized()


## Incrémente l'âge de chaque point et supprime ceux qui ont dépassé fade_duration.
func _age_points(delta: float) -> void:
	var i := 0
	while i < _ages.size():
		_ages[i] += delta
		if _ages[i] >= fade_duration:
			_points.remove_at(i)
			_rights.remove_at(i)
			_ages.remove_at(i)
		else:
			i += 1


func _rebuild_mesh() -> void:
	_mesh.clear_surfaces()
	var n: int = _points.size()
	if n < 2:
		return

	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(n - 1):
		var p0: Vector3 = _points[i]
		var p1: Vector3 = _points[i + 1]

		# Largeur interpolée selon l'âge : 0 = near (nouveau), 1 = far (vieux)
		var age_ratio0: float = clamp(_ages[i] / max(fade_duration, 0.001), 0.0, 1.0) if fade_duration > 0.0 else (1.0 - float(i) / float(n - 1))
		var age_ratio1: float = clamp(_ages[i + 1] / max(fade_duration, 0.001), 0.0, 1.0) if fade_duration > 0.0 else (1.0 - float(i + 1) / float(n - 1))
		var hw0: float = lerp(trail_width_near, trail_width_far, age_ratio0) * 0.5
		var hw1: float = lerp(trail_width_near, trail_width_far, age_ratio1) * 0.5

		var r0: Vector3 = _rights[i] * hw0
		var r1: Vector3 = _rights[i + 1] * hw1

		# 4 coins du quad
		var v_l0: Vector3 = p0 - r0   # gauche avant
		var v_r0: Vector3 = p0 + r0   # droite avant
		var v_l1: Vector3 = p1 - r1   # gauche arrière
		var v_r1: Vector3 = p1 + r1   # droite arrière

		# Couleur : combine fade_tail (position) et fade temporel (âge)
		var t0: float = float(i) / float(n - 1)        # 0..1 de la queue vers la tête
		var t1: float = float(i + 1) / float(n - 1)

		var age_factor0: float = 1.0
		var age_factor1: float = 1.0
		if fade_duration > 0.0 and _ages.size() > i + 1:
			age_factor0 = 1.0 - clamp(_ages[i] / fade_duration, 0.0, 1.0)
			age_factor1 = 1.0 - clamp(_ages[i + 1] / fade_duration, 0.0, 1.0)

		var pos_factor0: float = t0 if fade_tail else 1.0
		var pos_factor1: float = t1 if fade_tail else 1.0

		var alpha0: float = trail_color.a * age_factor0 * pos_factor0
		var alpha1: float = trail_color.a * age_factor1 * pos_factor1

		var c0 := Color(trail_color.r, trail_color.g, trail_color.b, alpha0)
		var c1 := Color(trail_color.r, trail_color.g, trail_color.b, alpha1)

		# UV : U = 0..1 (largeur), V = index normalisé (longueur)
		var uv0: float = float(i) / float(n - 1)
		var uv1: float = float(i + 1) / float(n - 1)

		# Triangle 1 : l0 → r0 → l1
		_mesh.surface_set_color(c0)
		_mesh.surface_set_uv(Vector2(0.0, uv0))
		_mesh.surface_add_vertex(v_l0)

		_mesh.surface_set_color(c0)
		_mesh.surface_set_uv(Vector2(1.0, uv0))
		_mesh.surface_add_vertex(v_r0)

		_mesh.surface_set_color(c1)
		_mesh.surface_set_uv(Vector2(0.0, uv1))
		_mesh.surface_add_vertex(v_l1)

		# Triangle 2 : r0 → r1 → l1
		_mesh.surface_set_color(c0)
		_mesh.surface_set_uv(Vector2(1.0, uv0))
		_mesh.surface_add_vertex(v_r0)

		_mesh.surface_set_color(c1)
		_mesh.surface_set_uv(Vector2(1.0, uv1))
		_mesh.surface_add_vertex(v_r1)

		_mesh.surface_set_color(c1)
		_mesh.surface_set_uv(Vector2(0.0, uv1))
		_mesh.surface_add_vertex(v_l1)

	_mesh.surface_end()
