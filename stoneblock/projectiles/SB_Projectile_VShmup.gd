@tool
extends Area3D
class_name SB_Projectile_VShmup

## 🚀 SB_Projectile_VShmup : Base pour les projectiles (alliés ou ennemis).
## Gère le mouvement, les trajectoires oscillantes et l'auto-destruction.

# --- Configuration ---
@export_group("Movement")
@export var speed: float = 50.0
@export var direction: Vector3 = Vector3(0, 0, -1) # Par défaut vers le haut en Top-Down
## Dégâts infligés à l'impact (1.0 par défaut).
@export var damage: float = 1.0

@export_group("Oscillation")
@export var use_oscillation: bool = false
@export var frequency: float = 2.0
@export var amplitude: float = 2.0

@export_group("Cleanup")
@export var life_time: float = 5.0 # Secondes
@export var distance_limit: float = 25.0

@export_group("Auto-Targeting Height")
## Si activé, le projectile s'ajuste en Y vers l'ennemi le plus proche dans la boîte de détection.
@export var auto_y_homing: bool = true
## Largeur totale (X) de la fenêtre de détection.
@export var homing_width: float = 1.0
## Profondeur (Z) de la fenêtre de détection devant le projectile.
@export var homing_depth: float = 10.0
## Hauteur totale (Y) de la fenêtre de détection.
@export var homing_height: float = 25.0
## Vitesse à laquelle le projectile se déplace en Y vers sa cible.
@export var homing_y_speed: float = 12.0
## Affiche la boîte de détection (Cyan transparent) pour le debug.
@export var debug_show_homing_box: bool = false

@export_group("VFX (Sprite Based)")
@export var bullet_color: Color = Color(1.0, 0.8, 0.2, 1.0) # Jaune/Orange par défaut
@export var bullet_scale: float = 1.0

@export_group("Bloom Sélectif")
## Si activé, ajoute le render layer du bloom sur le visuel et les fantômes.
@export var use_bloom: bool = true

enum BloomCategory { LONG = 11, MEDIUM = 12, SHORT = 13 }
## Catégorie de flou (Rayon différent dans BloomConfig).
@export var bloom_category: BloomCategory = BloomCategory.MEDIUM

# --- Nœuds VFX ---

# --- État ---
var _spawn_time: float = 0.0
var _spawn_position: Vector3 = Vector3.ZERO
var _total_time: float = 0.0
var _visual_node: Node3D
var _ghosts: Array[Node3D] = []
var _prev_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_spawn_time = Time.get_ticks_msec() / 1000.0
	_spawn_position = global_position
	_prev_pos = global_position
	
	# Détection du visuel principal
	if has_node("BulletVisual"):
		_visual_node = get_node("BulletVisual")
	elif has_node("MeshInstance3D"):
		_visual_node = get_node("MeshInstance3D")
	
	# Création des fantômes
	if _visual_node:
		for i in range(3):
			var ghost = _visual_node.duplicate()
			if ghost is AnimatedSprite3D:
				ghost.autoplay = ""
			add_child(ghost)
			# Dupliquer le matériau APRÈS add_child pour qu'il soit dans l'arbre
			if ghost.material_override:
				ghost.material_override = ghost.material_override.duplicate()
			_ghosts.append(ghost)
	
	# Appliquer les couleurs au prochain frame (nœuds garantis dans l'arbre)
	call_deferred("_apply_vfx_settings")

func _create_debug_box() -> void:
	print("[ProjectileDebug] Tentative de création de la boîte devant: ", direction)
	var mesh_inst = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(homing_width, homing_height, homing_depth)
	mesh_inst.mesh = box_mesh
	
	var mat = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0, 1, 0, 0.4) # Vert Fluorescent semi-transparent
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED # Visible de l'intérieur et de l'extérieur
	mesh_inst.material_override = mat
	
	add_child(mesh_inst)
	# On décale la boîte pour qu'elle soit DEVANT le projectile (milieu de la profondeur)
	mesh_inst.position = direction.normalized() * (homing_depth / 2.0)
	
	# Correction IP-078: Forcer les layers pour être visible par la caméra du Shmup
	if _visual_node and _visual_node is VisualInstance3D:
		mesh_inst.layers = _visual_node.layers
	else:
		# Fallback sur les layers du projet : 1, 11, 12, 13
		mesh_inst.layers = 1 | (1 << 10) | (1 << 11) | (1 << 12)

func _apply_vfx_settings() -> void:
	if not is_inside_tree(): return
	
	# Appliquer la couleur et la transparence
	if _visual_node:
		_set_node_color(_visual_node, bullet_color, 1.0)
	
	# Fantômes avec transparence dégressive (60%, 30%, 10%)
	var alphas = [0.6, 0.3, 0.1]
	for i in range(_ghosts.size()):
		_set_node_color(_ghosts[i], bullet_color, alphas[i])
	
	# Bloom sélectif : ajouter le render layer aux visuels
	_apply_bloom_layers()
	
	# Debug visualization
	if debug_show_homing_box:
		_create_debug_box()

func _apply_bloom_layers() -> void:
	if not use_bloom: return
	
	# Conversion de l'enum en masque binaire (bit shift)
	var bloom_mask: int = 1 << (int(bloom_category) - 1)
	
	# Visuel principal
	if _visual_node and _visual_node is VisualInstance3D:
		(_visual_node as VisualInstance3D).layers |= bloom_mask
		print("[Projectile] Bloom Layer appliqué: %d (mask: %d)" % [int(bloom_category), bloom_mask])
	
	# Fantômes (rémanances)
	for ghost in _ghosts:
		if ghost is VisualInstance3D:
			(ghost as VisualInstance3D).layers |= bloom_mask

func _set_node_color(node: Node, color: Color, alpha: float) -> void:
	var final_color = Color(color.r, color.g, color.b, alpha)
	
	if node is Sprite3D or node is AnimatedSprite3D:
		node.modulate = final_color
	
	elif node is MeshInstance3D:
		var mat = node.get_active_material(0)
		if mat:
			var new_mat = mat.duplicate()
			new_mat.albedo_color = final_color
			node.material_override = new_mat

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	_total_time += delta
	_update_movement(delta)
	_check_cleanup()

func _update_movement(delta: float) -> void:
	# Mémoriser la position avant le mouvement
	_prev_pos = global_position
	
	# Mouvement de base (Linéaire)
	var movement = direction * speed * delta
	global_position += movement
	
	# Oscillation (Latérale par rapport à la direction)
	if use_oscillation:
		var offset = sin(_total_time * PI * 2 * frequency) * amplitude
		var perp = Vector3(-direction.z, 0, direction.x).normalized()
		global_position += perp * offset * delta
	
	# Correction automatique de la hauteur (Y-Homing)
	if auto_y_homing:
		_apply_y_homing(delta)
	
	# Mise à jour des fantômes (position réelle, espacement doublé)
	var trail_vec = global_position - _prev_pos
	for i in range(_ghosts.size()):
		var factor = (i + 1) * 0.5
		_ghosts[i].global_transform.origin = global_position - trail_vec * factor
		_ghosts[i].global_transform.origin.y -= 0.001 * (i + 1)

func _check_cleanup() -> void:
	# Auto-destruction après certain temps
	if _total_time > life_time:
		queue_free()
	
	# Auto-destruction après certaine distance
	if global_position.distance_to(_spawn_position) > distance_limit:
		queue_free()

func _apply_y_homing(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty(): return
	
	var best_target: Node3D = null
	var min_dist_fwd: float = homing_depth
	
	var hw = homing_width / 2.0
	var hh = homing_height / 2.0
	
	for enemy in enemies:
		if not is_instance_valid(enemy): continue
		
		var diff = enemy.global_position - global_position
		
		# 1. Vérification "Devant" (Dot product avec la direction)
		# On utilise la direction normalisée pour obtenir la distance projetée
		var dist_fwd = diff.dot(direction.normalized())
		
		# Si l'ennemi est derrière ou trop loin devant
		if dist_fwd < 0 or dist_fwd > homing_depth: continue
		
		# 2. Vérification Latérale et Verticale (Boîte relative à l'axe de tir)
		# On calcule l'écart perpendiculaire à la trajectoire
		var lateral_offset = (diff - direction.normalized() * dist_fwd)
		
		if abs(lateral_offset.x) <= hw and abs(lateral_offset.y) <= hh:
			# Priorité à l'objet le plus proche sur la trajectoire (Z-first)
			if dist_fwd < min_dist_fwd:
				min_dist_fwd = dist_fwd
				best_target = enemy
	
	if best_target:
		# Interpolation fluide en Y vers la cible
		var target_y = best_target.global_position.y
		global_position.y = move_toward(global_position.y, target_y, homing_y_speed * delta)
