@tool
@icon("res://gdk-stoneblock/assets/icons/SB_UI.svg")
extends Node3D
class_name SB_ScreenAnchor3D

signal size_changed


## ⚓ SB_ScreenAnchor3D : Ancre un objet 3D aux bords de l'écran.
## Utilise exclusivement les unités 3D pour les offsets et détecte automatiquement la taille du contenu.

enum AlignPoint {
	TOP_LEFT, TOP_CENTER, TOP_RIGHT,
	CENTER_LEFT, CENTER, CENTER_RIGHT,
	BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT
}

enum UpdateMode { ONCE, ON_RESIZE, CONTINUOUS }
enum YDirection { NORMAL_Y, INVERSED_Y }

@export_group("Anchor Settings")
## Point d'ancrage sur l'écran ou la référence.
@export var anchor: AlignPoint = AlignPoint.CENTER:
	set(v): anchor = v; _update_position()
## Point pivot de l'objet lui-même.
@export var pivot: AlignPoint = AlignPoint.CENTER:
	set(v): pivot = v; _update_position()
## Décalage 3D en unités locales.
@export var offset_3d: Vector2 = Vector2.ZERO:
	set(v): offset_3d = v; _update_position()
## Nœud de référence (si vide, utilise l'écran).
@export var reference_node: Node = null:
	set(v): 
		_disconnect_ref(reference_node)
		reference_node = v
		_connect_ref(reference_node)
		_current_depth = -1.0 
		_update_position()

@export_group("Shared Settings")
## Système de coordonnées Y (Inversed = Y- Haut, Normal = Y+ Haut).
@export var y_direction: YDirection = YDirection.INVERSED_Y:
	set(v): y_direction = v; _update_position()

@export_group("Behavior")
## Mode de mise à jour de la position.
@export var update_mode: UpdateMode = UpdateMode.ON_RESIZE

## Si vrai, le node s'orientera face à la caméra.
@export var follow_camera_rotation: bool = false:
	set(v): follow_camera_rotation = v; _update_position()

func _disconnect_ref(node: Node) -> void:
	if node and node.has_signal("size_changed"):
		if node.size_changed.is_connected(_update_position):
			node.size_changed.disconnect(_update_position)

func _connect_ref(node: Node) -> void:
	if node and node.has_signal("size_changed"):
		if not node.size_changed.is_connected(_update_position):
			node.size_changed.connect(_update_position)

## Caméra spécifique (optionnel). Si vide, utilise la caméra active du viewport.
@export var manual_camera: Camera3D = null:
	set(v): manual_camera = v; _update_position()

var _current_depth: float = -1.0

## API pour le chaînage d'ancres (permet à une autre ancre de nous utiliser comme référence)
func get_anchor_pos(factor: Vector2) -> Vector3:
	var aabb = _get_combined_aabb(self)
	var px = aabb.position.x + (factor.x * aabb.size.x)
	var py = aabb.position.y + ((1.0 - factor.y) * aabb.size.y)
	return Vector3(px, py, 0)

func _ready() -> void:
	if not Engine.is_editor_hint():
		get_viewport().size_changed.connect(_on_viewport_size_changed)
		
		# On attend que la scène soit bien stabilisée (caméra, orientation SB_Core, taille viewport)
		# Faire plusieurs frames permet de s'assurer qu'on attrape le moment où tout est prêt
		_initial_sync_process()
	else:
		_update_position.call_deferred()

func _initial_sync_process() -> void:
	# On fait 3 tentatives sur les 3 premières frames pour garantir le placement
	for i in range(3):
		_update_position()
		await get_tree().process_frame
	
	# Une dernière tentative après un court délai pour être ultra sûr (cas des Viewports lents)
	await get_tree().create_timer(0.1).timeout
	_update_position()

func _process(_delta: float) -> void:
	if update_mode == UpdateMode.CONTINUOUS or Engine.is_editor_hint():
		_update_position()

func _on_viewport_size_changed() -> void:
	if update_mode == UpdateMode.ON_RESIZE or update_mode == UpdateMode.CONTINUOUS:
		_update_position()

var _is_updating: bool = false

func _update_position() -> void:
	if not is_inside_tree(): return
	if _is_updating: return
	_is_updating = true
	
	if reference_node and is_instance_valid(reference_node):
		_update_reference_anchoring(reference_node)
	else:
		_update_screen_anchoring()
		
	size_changed.emit()
	_is_updating = false


func _update_reference_anchoring(ref_node: Node) -> void:
	if not is_instance_valid(ref_node): return
	
	var anchor_factor = _get_align_factor(anchor)
	var pivot_factor = _get_align_factor(pivot)
	
	# 1. Calcul de la boîte englobante locale (AABB) relative au node lui-même
	var aabb = _get_combined_aabb(self)
	
	# 2. Position de l'ancre sur la référence (en local 3D de la référence)
	var anchor_local_pos = Vector3.ZERO
	if ref_node.has_method("get_anchor_pos"):
		anchor_local_pos = ref_node.get_anchor_pos(anchor_factor)
	else:
		# Fallback : On calcule l'AABB du nœud de référence pour trouver ses bords
		var ref_aabb = _get_combined_aabb(ref_node, ref_node)
		var ax = ref_aabb.position.x + (anchor_factor.x * ref_aabb.size.x)
		var ay = ref_aabb.position.y + ((1.0 - anchor_factor.y) * ref_aabb.size.y)
		anchor_local_pos = Vector3(ax, ay, 0)
	
	# 3. Calcul du point pivot de l'objet (en local 3D du node lui-même)
	var pivot_x = aabb.position.x + (pivot_factor.x * aabb.size.x)
	var pivot_y = aabb.position.y + ((1.0 - pivot_factor.y) * aabb.size.y)
	var pivot_point_local = Vector3(pivot_x, pivot_y, 0)
	
	# 4. Calcul de la nouvelle position globale
	var world_anchor_pos = ref_node.global_transform * anchor_local_pos
	var world_pivot_offset = global_transform.basis * pivot_point_local
	
	global_position = world_anchor_pos - world_pivot_offset
	
	# 5. Application de l'offset 3D (dans le référentiel de la référence)
	var _basis = ref_node.global_transform.basis
	var y_mult = 1.0 if y_direction == YDirection.NORMAL_Y else -1.0
	var offset = offset_3d
	global_position += _basis.x * offset.x
	global_position += _basis.y * (offset.y * y_mult)

func _update_screen_anchoring() -> void:
	var camera = _get_active_camera()
	if not camera:
		# Fallback : Si vraiment rien, on ne bouge pas
		return
	
	# Taille du viewport : En jeu on prend le vrai, en éditeur on prend la config projet
	var viewport_size: Vector2
	if Engine.is_editor_hint():
		viewport_size = Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")
		)
		if viewport_size == Vector2.ZERO: viewport_size = Vector2(1920, 1080)
	else:
		viewport_size = get_viewport().get_visible_rect().size
		
	var screen_anchor_pos = _get_align_pixel_pos(anchor, viewport_size)
	
	# 1. Calcul de la taille réelle à l'écran (pixels) pour le pivot
	var screen_size = _calculate_screen_size(camera)
	var pivot_factor = _get_align_factor(pivot)
	var pivot_displacement = (pivot_factor - Vector2(0.5, 0.5)) * screen_size
	
	# 2. Position écran de base (Ancre - Pivot)
	var final_screen_pos = screen_anchor_pos - pivot_displacement
	
	# 3. Projection initiale
	if _current_depth < 0:
		var cam_space_pos = camera.global_transform.affine_inverse() * global_position
		_current_depth = -cam_space_pos.z
		if _current_depth < 0.1: _current_depth = 10.0
	
	var world_pos = camera.project_position(final_screen_pos, _current_depth)
	
	# 4. Application de l'offset 3D (dans le référentiel de la caméra)
	var _basis = camera.global_transform.basis
	var y_mult = 1.0 if y_direction == YDirection.NORMAL_Y else -1.0
	var offset = offset_3d
	world_pos += _basis.x * offset.x
	world_pos += _basis.y * (offset.y * y_mult)
	
	global_position = world_pos
	
	if follow_camera_rotation:
		global_rotation = camera.global_rotation

func _get_active_camera() -> Camera3D:
	if manual_camera: return manual_camera
	
	# En éditeur, on cherche d'abord la caméra du jeu dans la scène
	if Engine.is_editor_hint():
		var game_cam = _find_editor_camera()
		if game_cam: return game_cam
	
	# En jeu (ou secours éditeur), on prend la caméra active du viewport
	return get_viewport().get_camera_3d()

func _find_editor_camera() -> Camera3D:
	if not is_inside_tree(): return null
	# On cherche dans l'arbre de scène actuel (celui édité)
	# On évite get_tree().root qui contient l'éditeur lui-même
	var root = get_tree().edited_scene_root
	if not root: return null
	
	return root.find_child("*Camera*", true, false) as Camera3D

func _get_align_factor(p: AlignPoint) -> Vector2:
	match p:
		AlignPoint.TOP_LEFT: return Vector2(0, 0)
		AlignPoint.TOP_CENTER: return Vector2(0.5, 0)
		AlignPoint.TOP_RIGHT: return Vector2(1, 0)
		AlignPoint.CENTER_LEFT: return Vector2(0, 0.5)
		AlignPoint.CENTER: return Vector2(0.5, 0.5)
		AlignPoint.CENTER_RIGHT: return Vector2(1, 0.5)
		AlignPoint.BOTTOM_LEFT: return Vector2(0, 1)
		AlignPoint.BOTTOM_CENTER: return Vector2(0.5, 1)
		AlignPoint.BOTTOM_RIGHT: return Vector2(1, 1)
	return Vector2(0.5, 0.5)

func _get_align_pixel_pos(p: AlignPoint, size: Vector2) -> Vector2:
	var factor = _get_align_factor(p)
	return size * factor

func _calculate_screen_size(camera: Camera3D) -> Vector2:
	var aabb = _get_combined_aabb(self)
	if aabb.size == Vector3.ZERO:
		return Vector2.ZERO
		
	var corners = [
		aabb.position,
		aabb.position + Vector3(aabb.size.x, 0, 0),
		aabb.position + Vector3(0, aabb.size.y, 0),
		aabb.position + Vector3(0, 0, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, aabb.size.y, 0),
		aabb.position + Vector3(aabb.size.x, 0, aabb.size.z),
		aabb.position + Vector3(0, aabb.size.y, aabb.size.z),
		aabb.position + aabb.size
	]
	
	var min_2d = Vector2(999999, 999999)
	var max_2d = Vector2(-999999, -999999)
	
	for c in corners:
		var p2d = camera.unproject_position(global_transform * c)
		min_2d.x = minf(min_2d.x, p2d.x)
		min_2d.y = minf(min_2d.y, p2d.y)
		max_2d.x = maxf(max_2d.x, p2d.x)
		max_2d.y = maxf(max_2d.y, p2d.y)
		
	return max_2d - min_2d

func _get_combined_aabb(node: Node, relative_to: Node = null) -> AABB:
	if relative_to == null: relative_to = self
	var combined = AABB()
	var first = true
	var stack = [node]
	while stack.size() > 0:
		var current = stack.pop_back()
		if current is VisualInstance3D:
			var aabb = current.get_aabb()
			var local_to_rel = relative_to.global_transform.affine_inverse() * current.global_transform
			var transformed_aabb = local_to_rel * aabb
			if first:
				combined = transformed_aabb
				first = false
			else:
				combined = combined.merge(transformed_aabb)
		for child in current.get_children():
			stack.push_back(child)
	return combined
