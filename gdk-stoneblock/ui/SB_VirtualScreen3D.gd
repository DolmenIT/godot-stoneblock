@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Viewport.svg")
extends Node3D
class_name SB_VirtualScreen3D

signal size_changed

## 📺 SB_VirtualScreen3D : Définit un plan de travail virtuel pour l'interface 3D.
## Les SB_ScreenAnchor3D peuvent s'y référer pour se placer.

@export var size: Vector2 = Vector2(88, 50):
	set(v): 
		size = v
		_update_gizmo()
		# Notifier les abonnés distants
		size_changed.emit()
		
		# Notifier les ancres enfants du changement de taille
		for child in get_children():
			if child.has_method("_update_position"):
				child._update_position()

@export_group("Responsivity")
## Si vrai, s'adapte automatiquement à l'écran en jeu (reste fixe dans l'éditeur).
@export var auto_fit_screen: bool = false

@export_group("Editor")
## Couleur du cadre dans l'éditeur.
@export var border_color: Color = Color(0.2, 0.6, 1.0, 0.5):
	set(v): border_color = v; _update_gizmo()

var _gizmo_mesh: MeshInstance3D

func _ready() -> void:
	_update_gizmo()

func _process(_delta: float) -> void:
	if auto_fit_screen and not Engine.is_editor_hint():
		_update_fit()

func _update_fit() -> void:
	var cam = get_viewport().get_camera_3d()
	if not cam: return
	
	var screen_rect = get_viewport().get_visible_rect()
	var aspect = screen_rect.size.x / screen_rect.size.y
	
	if cam.projection == Camera3D.PROJECTION_ORTHOGONAL:
		var h = cam.size
		var w = h * aspect
		if size != Vector2(w, h):
			size = Vector2(w, h)
	else:
		var dist = global_position.distance_to(cam.global_position)
		var h = 2.0 * dist * tan(deg_to_rad(cam.fov) / 2.0)
		var w = h * aspect
		if size != Vector2(w, h):
			size = Vector2(w, h)

func _update_gizmo() -> void:
	# Suppression propre de l'ancien gizmo s'il existe
	var old = get_node_or_null("EditorGizmo")
	if old: 
		old.free()
		_gizmo_mesh = null
		
	if not Engine.is_editor_hint():
		return

	_gizmo_mesh = MeshInstance3D.new()
	_gizmo_mesh.name = "EditorGizmo"
	_gizmo_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_gizmo_mesh.set_meta("_edit_lock_", true)
	_gizmo_mesh.position = Vector3.ZERO # On s'assure qu'il n'y a aucun décalage
	add_child(_gizmo_mesh)
	
	
	var mesh = ImmediateMesh.new()
	_gizmo_mesh.mesh = mesh
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = border_color
	mat.no_depth_test = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var w = size.x / 2.0
	var h = size.y / 2.0
	var d = min(w, h) * 0.1 # Taille des coins (10%)
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	
	# Coin Haut-Gauche
	mesh.surface_add_vertex(Vector3(-w, h, 0)); mesh.surface_add_vertex(Vector3(-w + d, h, 0))
	mesh.surface_add_vertex(Vector3(-w, h, 0)); mesh.surface_add_vertex(Vector3(-w, h - d, 0))
	
	# Coin Haut-Droit
	mesh.surface_add_vertex(Vector3(w, h, 0)); mesh.surface_add_vertex(Vector3(w - d, h, 0))
	mesh.surface_add_vertex(Vector3(w, h, 0)); mesh.surface_add_vertex(Vector3(w, h - d, 0))
	
	# Coin Bas-Gauche
	mesh.surface_add_vertex(Vector3(-w, -h, 0)); mesh.surface_add_vertex(Vector3(-w + d, -h, 0))
	mesh.surface_add_vertex(Vector3(-w, -h, 0)); mesh.surface_add_vertex(Vector3(-w, -h + d, 0))
	
	# Coin Bas-Droit
	mesh.surface_add_vertex(Vector3(w, -h, 0)); mesh.surface_add_vertex(Vector3(w - d, -h, 0))
	mesh.surface_add_vertex(Vector3(w, -h, 0)); mesh.surface_add_vertex(Vector3(w, -h + d, 0))
	
	# Flèche indicateur de "Haut" (Inversée pour rester dans l'AABB)
	mesh.surface_add_vertex(Vector3(-1, h - 0.5, 0)); mesh.surface_add_vertex(Vector3(0, h, 0))
	mesh.surface_add_vertex(Vector3(0, h, 0)); mesh.surface_add_vertex(Vector3(1, h - 0.5, 0))
	
	mesh.surface_end()
	
	# Forcer l'AABB exacte sur l'instance pour que la sélection soit parfaite
	_gizmo_mesh.custom_aabb = AABB(Vector3(-w, -h, -0.01), Vector3(size.x, size.y, 0.02))

func get_anchor_pos(anchor_factor: Vector2) -> Vector3:
	var x = (anchor_factor.x - 0.5) * size.x
	var y = (0.5 - anchor_factor.y) * size.y
	return Vector3(x, y, 0)
