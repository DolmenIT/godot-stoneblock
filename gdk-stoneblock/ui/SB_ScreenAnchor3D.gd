@tool
@icon("res://gdk-stoneblock/assets/icons/SB_UI.svg")
extends Node3D
class_name SB_ScreenAnchor3D

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
## Point d'ancrage sur l'écran (où l'objet doit se coller).
@export var anchor: AlignPoint = AlignPoint.CENTER:
	set(v): anchor = v; _update_position()

## Point de pivot sur l'objet (quelle partie de l'objet est collée à l'ancre).
@export var pivot: AlignPoint = AlignPoint.CENTER:
	set(v): pivot = v; _update_position()

## Système de coordonnées Y (Inversed = Y- Haut, Normal = Y+ Haut).
@export var y_direction: YDirection = YDirection.INVERSED_Y:
	set(v): y_direction = v; _update_position()

## Décalage en unités 3D depuis l'ancre (X=Droite).
@export var offset_3d: Vector2 = Vector2.ZERO:
	set(v): offset_3d = v; _update_position()

@export_group("Behavior")
## Mode de mise à jour de la position.
@export var update_mode: UpdateMode = UpdateMode.ON_RESIZE

## Si vrai, le node s'orientera face à la caméra.
@export var follow_camera_rotation: bool = false:
	set(v): follow_camera_rotation = v; _update_position()

@export_group("References")
## Écran virtuel de référence. Si défini, l'ancrage se fait sur ce plan au lieu du viewport.
@export var virtual_screen: SB_VirtualScreen3D = null:
	set(v): 
		virtual_screen = v
		_current_depth = -1.0 # Reset de la profondeur pour le mode écran
		_update_position()

## Caméra spécifique (optionnel). Si vide, utilise la caméra active du viewport.
@export var manual_camera: Camera3D = null:
	set(v): manual_camera = v; _update_position()

var _current_depth: float = -1.0

func _ready() -> void:
	if not Engine.is_editor_hint():
		get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	_update_position.call_deferred()

func _process(_delta: float) -> void:
	if update_mode == UpdateMode.CONTINUOUS or Engine.is_editor_hint():
		_update_position()

func _on_viewport_size_changed() -> void:
	if update_mode == UpdateMode.ON_RESIZE or update_mode == UpdateMode.CONTINUOUS:
		_update_position()

func _update_position() -> void:
	if not is_inside_tree(): return
	
	# En jeu, on utilise toujours l'ancrage écran réel.
	# Le VirtualScreen n'est utilisé que comme repère dans l'éditeur.
	if virtual_screen and Engine.is_editor_hint():
		_update_virtual_anchoring()
	else:
		_update_screen_anchoring()

func _update_virtual_anchoring() -> void:
	if not is_instance_valid(virtual_screen): return
	
	var anchor_factor = _get_align_factor(anchor)
	var pivot_factor = _get_align_factor(pivot)
	
	# 1. Calcul de la boîte englobante locale (AABB) relative au node lui-même
	var aabb = _get_combined_aabb(self)
	
	# 2. Position de l'ancre sur l'écran virtuel (en local 3D du VirtualScreen)
	var anchor_local_pos = virtual_screen.get_anchor_pos(anchor_factor)
	
	# 3. Calcul du point pivot de l'objet (en local 3D du node lui-même)
	# AABB position.y est le bas, position.y + size.y est le haut.
	# Pivot UI factor: 0 = Haut, 1 = Bas.
	var pivot_x = aabb.position.x + (pivot_factor.x * aabb.size.x)
	var pivot_y = aabb.position.y + ((1.0 - pivot_factor.y) * aabb.size.y)
	var pivot_point_local = Vector3(pivot_x, pivot_y, 0)
	
	# 4. Calcul de la nouvelle position globale
	# On veut que (global_pos + world_pivot_point) == world_anchor_pos
	# Donc global_pos = world_anchor_pos - world_pivot_point (par rapport à l'origine du node)
	
	var world_anchor_pos = virtual_screen.global_transform * anchor_local_pos
	var world_pivot_offset = global_transform.basis * pivot_point_local
	
	global_position = world_anchor_pos - world_pivot_offset
	
	# 5. Application de l'offset 3D (dans le référentiel du virtual screen)
	var _basis = virtual_screen.global_transform.basis
	var y_mult = 1.0 if y_direction == YDirection.NORMAL_Y else -1.0
	global_position += _basis.x * offset_3d.x
	global_position += _basis.y * (offset_3d.y * y_mult)

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
	world_pos += _basis.x * offset_3d.x
	world_pos += _basis.y * (offset_3d.y * y_mult)
	
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

func _get_combined_aabb(node: Node) -> AABB:
	var combined = AABB()
	var first = true
	var stack = [node]
	while stack.size() > 0:
		var current = stack.pop_back()
		if current is VisualInstance3D:
			var aabb = current.get_aabb()
			var local_to_anchor = self.global_transform.affine_inverse() * current.global_transform
			var transformed_aabb = local_to_anchor * aabb
			if first:
				combined = transformed_aabb
				first = false
			else:
				combined = combined.merge(transformed_aabb)
		for child in current.get_children():
			stack.push_back(child)
	return combined
