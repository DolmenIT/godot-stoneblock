@tool
extends Node
class_name SB_Input_TouchMouse

## 🖱️ SB_Input_TouchMouse : Composant No-Code pour le contrôle tactile et souris.
## Effectue un raycast sur un plan virtuel et transmet la position 3D à une cible.

@export_group("Target")
## Nom du nœud cible à piloter (ex: "Player_VShmup").
@export var target_name: String = "Player_VShmup"
## Nom de la méthode à appeler sur la cible (ex: "_on_raycast_hit").
@export var target_method: String = "_on_raycast_hit"
## Nom de la méthode de tir à appeler sur la cible (ex: "set_firing").
@export var fire_method: String = "set_firing"

@export_group("Configuration")
## Hauteur Y du plan virtuel de détection.
@export var plane_height: float = 0.0
## Si vrai, traite les clics souris comme des inputs de déplacement.
@export var use_mouse: bool = true
## Si vrai, traite les événements tactiles comme des inputs de déplacement.
@export var use_touch: bool = true

@export_group("Camera")
## Nom de la caméra à utiliser pour le raycast (si vide, cherche "Mainground_Camera").
@export var camera_name: String = "Mainground_Camera"

@export_group("Debug Visuals")
## Si vrai, affiche un plan semi-transparent pour visualiser la zone de détection.
@export var show_debug_plane: bool = false:
	set(v):
		show_debug_plane = v
		if Engine.is_editor_hint(): _update_debug_plane()
## Couleur du plan de debug.
@export var debug_plane_color: Color = Color(0, 1, 0, 0.1)
## Taille du plan de debug.
@export var debug_plane_size: Vector2 = Vector2(500, 500)

var _camera_cached: Camera3D
var _target_cached: Node
var _is_dragging: bool = false
var _last_screen_pos: Vector2 = Vector2.ZERO
var _debug_mesh: MeshInstance3D

# Cache d'états (Inspiration SB_Input_Gamepad)
var _last_fire_state: bool = false

func _ready() -> void:
	_find_references()
	_update_debug_plane()

func _exit_tree() -> void:
	if _debug_mesh:
		_debug_mesh.queue_free()

func _find_references() -> void:
	# Recherche de la caméra
	if camera_name != "":
		# On cherche d'abord dans la scène courante (via owner ou scène active)
		var root = owner
		if not root and get_tree():
			root = get_tree().current_scene
		if not root and get_tree():
			root = get_tree().root
			
		if root:
			_camera_cached = root.find_child(camera_name, true, false)
	
	if not _camera_cached:
		_camera_cached = get_viewport().get_camera_3d()
		
	# Recherche de la cible
	if target_name != "":
		var root = owner
		if not root and get_tree():
			root = get_tree().current_scene
		if not root and get_tree():
			root = get_tree().root

		if root:
			_target_cached = root.find_child(target_name, true, false)
			if _target_cached:
				# print("[TouchMouse] Cible trouvée: ", _target_cached.name)
				if "use_external_input" in _target_cached:
					_target_cached.use_external_input = true
			else:
				print("[TouchMouse] ERREUR: Cible non trouvée: ", target_name)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if show_debug_plane: _update_debug_plane()
		return
		
	if show_debug_plane:
		_update_debug_plane()
		
	if _is_dragging:
		_process_input(_last_screen_pos)
		_dispatch_fire(true)
	else:
		_dispatch_fire(false)
		# On arrête le mouvement piloté par cible dès qu'on relâche
		_stop_movement()

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	
	var screen_pos = Vector2.ZERO
	var input_detected = false
	
	# Gestion Souris
	if use_mouse and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
			_dispatch_fire(_is_dragging) # <-- TIR
			if _is_dragging:
				screen_pos = event.position
				input_detected = true
				
	elif use_mouse and event is InputEventMouseMotion and _is_dragging:
		screen_pos = event.position
		input_detected = true
		
	# Gestion Tactile
	if use_touch and event is InputEventScreenTouch:
		_is_dragging = event.pressed
		if _is_dragging:
			screen_pos = event.position
			input_detected = true
			
	elif use_touch and event is InputEventScreenDrag:
		screen_pos = event.position
		input_detected = true
		
	if input_detected:
		_last_screen_pos = screen_pos
		_process_input(screen_pos)

func _process_input(_unused_pos: Vector2) -> void:
	if not _camera_cached:
		_find_references()
		if not _camera_cached: return
		
	# On utilise la position de souris relative au viewport de la caméra 
	# pour éviter les décalages de coordonnées entre Root et SubViewport.
	var local_pos = _camera_cached.get_viewport().get_mouse_position()
	
	var world_pos = _calculate_raycast(local_pos)
	if world_pos != Vector3.ZERO:
		# if show_debug_plane:
		# 	print("[TouchMouse] Hit! Screen: ", local_pos, " -> World: ", world_pos)
		_dispatch_to_target(world_pos)

func _dispatch_fire(active: bool) -> void:
	if not _target_cached:
		_find_references()
		if not _target_cached: return
		
	if _target_cached.has_method(fire_method):
		if _last_fire_state != active:
			_last_fire_state = active
			_target_cached.call(fire_method, active)

func _stop_movement() -> void:
	if not _target_cached: return
	# print("[TouchMouse] Stop Movement")
	# On appelle explicitement l'arrêt du mouvement pour annuler le flag _has_target_pos
	if _target_cached.has_method("stop_touch_movement"):
		_target_cached.call("stop_touch_movement")

func _calculate_raycast(screen_pos: Vector2) -> Vector3:
	# Utilisation des méthodes natives (Fonctionne pour Ortho et Perspective)
	var from = _camera_cached.project_ray_origin(screen_pos)
	var dir = _camera_cached.project_ray_normal(screen_pos)
	
	var plane_point = Vector3(0, plane_height, 0)
	var plane_normal = Vector3.UP
	
	var denom = plane_normal.dot(dir)
	if abs(denom) > 0.0001:
		var t = plane_normal.dot(plane_point - from) / denom
		if t >= 0 or _camera_cached.projection == Camera3D.PROJECTION_ORTHOGONAL:
			return from + dir * t
				
	return Vector3.ZERO

func _dispatch_to_target(pos: Vector3) -> void:
	if not _target_cached:
		_find_references()
		if not _target_cached: return
		
	if _target_cached.has_method(target_method):
		_target_cached.call(target_method, pos)

func _update_debug_plane() -> void:
	if not show_debug_plane:
		if _debug_mesh:
			_debug_mesh.visible = false
		return
		
	if not _camera_cached:
		_find_references()

	if not _debug_mesh:
		_debug_mesh = MeshInstance3D.new()
		_debug_mesh.name = "DebugPlaneVisual"
		
		# On attache le mesh au parent de la caméra pour qu'il soit dans le bon SubViewport
		if _camera_cached:
			_camera_cached.get_parent().add_child(_debug_mesh)
		else:
			add_child(_debug_mesh)
		
		var mesh = PlaneMesh.new()
		var mat = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_debug_mesh.mesh = mesh
		_debug_mesh.material_override = mat
	
	# Gestion du changement de parent si nécessaire (en cas de re-find de caméra)
	if _camera_cached and _debug_mesh.get_parent() != _camera_cached.get_parent():
		_debug_mesh.get_parent().remove_child(_debug_mesh)
		_camera_cached.get_parent().add_child(_debug_mesh)
	
	_debug_mesh.visible = true
	
	# Adaptation à la taille de la caméra
	var final_size = debug_plane_size
	if _camera_cached:
		if _camera_cached.projection == Camera3D.PROJECTION_ORTHOGONAL:
			var vp_size = get_viewport().get_visible_rect().size
			var aspect = vp_size.x / vp_size.y if vp_size.y > 0 else 1.0
			final_size = Vector2(_camera_cached.size * aspect, _camera_cached.size)
			_debug_mesh.global_position = Vector3(_camera_cached.global_position.x, plane_height, _camera_cached.global_position.z)
		else:
			# Perspective : on laisse la taille manuelle ou on pourrait calculer le frustum à plane_height
			_debug_mesh.global_position = Vector3(0, plane_height, 0)
	else:
		_debug_mesh.global_position = Vector3(0, plane_height, 0)
	
	_debug_mesh.mesh.size = final_size
	_debug_mesh.material_override.albedo_color = debug_plane_color
