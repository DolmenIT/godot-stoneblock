@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_ViewportScrollContainer3D
extends Node3D

## 📜 SB_ViewportScrollContainer3D : Conteneur avec défilement et masquage précis via SubViewport.

enum HAlign { LEFT, CENTER, RIGHT }

@export_group("Layout")
## Aligne le contenu une seule fois en Top Center/Left/Right par rapport aux dimensions du Viewport.
@export var align_now: bool = false:
	set(v):
		if v:
			_update_editor_gizmo()
			_update_children_positions_in_editor()
			align_now = false
			notify_property_list_changed()

@export var view_size: Vector2 = Vector2(30.0, 15.0):
	set(v):
		view_size = v
		if Engine.is_editor_hint():
			_update_editor_gizmo()
			_update_children_positions_in_editor()
			_update_bg_visual()
			_update_border_visual()

@export var horizontal_alignment: HAlign = HAlign.CENTER:
	set(v):
		horizontal_alignment = v
		if Engine.is_editor_hint():
			_update_children_positions_in_editor()

@export var scroll_speed: float = 1.0
@export var inertia: float = 0.15

@export var top_margin: float = 0.5:
	set(v): top_margin = v; if Engine.is_editor_hint(): _update_children_positions_in_editor()
@export var bottom_margin: float = 0.5:
	set(v): bottom_margin = v; if Engine.is_editor_hint(): _update_children_positions_in_editor()


@export_group("Appearance")
@export var border_color: Color = Color(0.0, 0.7, 1.0, 0.8):
	set(v): border_color = v; _update_border_visual()
@export var bg_color: Color = Color(0.0, 0.0, 0.0, 0.0):
	set(v): bg_color = v; _update_bg_visual()

@export_group("Scrollbar Settings")
@export var show_scrollbar: bool = true:
	set(v): show_scrollbar = v; _update_scrollbar_visual()
@export var scrollbar_width: float = 0.2:
	set(v): scrollbar_width = v; _update_scrollbar_visual()
@export var scrollbar_margin: float = 0.2:
	set(v): scrollbar_margin = v; _update_scrollbar_visual()
@export var scrollbar_color: Color = Color(0.0, 0.7, 1.0, 0.8):
	set(v): scrollbar_color = v; _update_scrollbar_visual()

var _sub_viewport: SubViewport
var _camera: Camera3D
var _content: Node3D
var _sprite: Sprite3D
var _area: Area3D
var _gizmo_mesh: MeshInstance3D
var _scrollbar: MeshInstance3D
var _bg_mesh: MeshInstance3D
var _border_lines: Array[MeshInstance3D] = []

var _current_scroll_y: float = 0.0
var _target_scroll_y: float = 0.0
var _is_dragging: bool = false
var _last_drag_y: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_editor_gizmo()
		_update_children_positions_in_editor()
		_update_scrollbar_visual()
		_update_bg_visual()
		_update_border_visual()
		return
		
	if _gizmo_mesh:
		_gizmo_mesh.queue_free()
	
	# 1. Calcul de la résolution du Viewport basée sur la hauteur de l'écran
	var px_per_unit: float = 72.0
	if get_viewport():
		var screen_height = get_viewport().get_visible_rect().size.y
		if screen_height > 0:
			px_per_unit = screen_height / max(1.0, view_size.y)
	
	var width_px = int(view_size.x * px_per_unit)
	var height_px = int(view_size.y * px_per_unit)
	
	# 2. Création du SubViewport
	_sub_viewport = SubViewport.new()
	_sub_viewport.size = Vector2i(width_px, height_px)
	_sub_viewport.transparent_bg = true
	_sub_viewport.own_world_3d = true # Isolé du monde principal pour éviter d'être rendu 2 fois
	_sub_viewport.physics_object_picking = true # Activer la sélection des objets 3D !
	add_child(_sub_viewport)

	# Ajout d'une lumière directionnelle pour le monde isolé du Viewport
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 45, 0)
	light.light_energy = 1.2
	_sub_viewport.add_child(light)
	
	# 3. Conteneur interne pour les enfants
	_content = Node3D.new()
	_sub_viewport.add_child(_content)
	
	# Migration des enfants (ils conservent leur position locale calculée dans l'éditeur)
	var children = get_children().duplicate()
	for child in children:
		if child != _sub_viewport and child is Node3D and not child in _border_lines and child != _bg_mesh:
			remove_child(child)
			_content.add_child(child)
	
	# 4. Création de la Caméra du Viewport (Centrée exactement sur 0,0,15)
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = view_size.y
	_camera.position = Vector3(0, 0, 15)
	_sub_viewport.add_child(_camera)
	
	# 5. Sprite3D pour afficher le contenu masqué
	_sprite = Sprite3D.new()
	_sprite.texture = _sub_viewport.get_texture()
	_sprite.centered = true
	_sprite.pixel_size = view_size.y / height_px
	add_child(_sprite)
	
	# 6. Détection des clics et mouvements
	_area = Area3D.new()
	_sprite.add_child(_area)
	
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(view_size.x, view_size.y, 0.1)
	col.shape = box
	_area.add_child(col)
	
	_area.input_event.connect(_on_area_input_event)

	# 7. Création des bordures et fonds visuels de la zone de défilement
	_update_bg_visual()
	_update_border_visual()
	
	# 8. Affichage initial de l'ascenseur
	_update_scrollbar_visual()

func _create_border_line(pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh_inst = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh_inst.mesh = box
	var mat = StandardMaterial3D.new()
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mesh_inst.material_override = mat
	mesh_inst.position = pos
	add_child(mesh_inst)
	_border_lines.append(mesh_inst)

func _update_border_visual() -> void:
	for b in _border_lines:
		if is_instance_valid(b): b.queue_free()
	_border_lines.clear()
	
	if border_color.a <= 0.0: return
	
	_create_border_line(Vector3(0, view_size.y / 2.0, 0.02), Vector3(view_size.x, 0.05, 0.05), border_color)
	_create_border_line(Vector3(0, -view_size.y / 2.0, 0.02), Vector3(view_size.x, 0.05, 0.05), border_color)
	_create_border_line(Vector3(-view_size.x / 2.0, 0, 0.02), Vector3(0.05, view_size.y, 0.05), border_color)
	_create_border_line(Vector3(view_size.x / 2.0, 0, 0.02), Vector3(0.05, view_size.y, 0.05), border_color)

func _update_bg_visual() -> void:
	if bg_color.a <= 0.0:
		if _bg_mesh: _bg_mesh.visible = false
		return
		
	if not _bg_mesh:
		_bg_mesh = MeshInstance3D.new()
		var plane = QuadMesh.new()
		plane.size = view_size
		_bg_mesh.mesh = plane
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_bg_mesh.material_override = mat
		_bg_mesh.position.z = -0.01 # Juste derrière le Sprite3D
		add_child(_bg_mesh)
		
	_bg_mesh.visible = true
	_bg_mesh.mesh.size = view_size
	_bg_mesh.material_override.albedo_color = bg_color

func _get_combined_local_aabb(node: Node3D) -> AABB:
	var combined = AABB()
	var first = true
	var stack = [node]
	var origin_inv = node.global_transform.affine_inverse()
	while stack.size() > 0:
		var current = stack.pop_back()
		if current is VisualInstance3D:
			var aabb = current.get_aabb()
			var local_transform = origin_inv * current.global_transform
			var transformed_aabb = local_transform * aabb
			if first:
				combined = transformed_aabb
				first = false
			else:
				combined = combined.merge(transformed_aabb)
		for child in current.get_children():
			if child is Node3D:
				stack.push_back(child)
	return combined

func _get_content_height() -> float:
	if not _content: return 0.0
	var aabb = _get_combined_local_aabb(_content)
	if aabb.size == Vector3.ZERO: return 0.0
	return aabb.size.y + top_margin + bottom_margin

func _on_area_input_event(camera: Camera3D, event: InputEvent, click_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# Conversion de la position 3D locale en coordonnées 2D du Viewport
	var local_point = _sprite.to_local(click_position)
	var px = (local_point.x / view_size.x + 0.5) * _sub_viewport.size.x
	var py = (0.5 - local_point.y / view_size.y) * _sub_viewport.size.y
	
	# Redirection de l'événement vers le SubViewport en coordonnées locales
	var ev_copy = event.duplicate()
	if "position" in ev_copy:
		ev_copy.position = Vector2(px, py)
	if "global_position" in ev_copy:
		ev_copy.global_position = Vector2(px, py)
		
	_sub_viewport.push_input(ev_copy, true)
	
	# Gestion du scroll molette / drag directement ici
	var max_scroll = max(0.0, _get_content_height() - view_size.y)
	
	# 1. Drag tactile ou souris (Clic gauche enfoncé)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_last_drag_y = local_point.y
			else:
				_is_dragging = false
		elif event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_target_scroll_y = clamp(_target_scroll_y - scroll_speed, 0.0, max_scroll)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_target_scroll_y = clamp(_target_scroll_y + scroll_speed, 0.0, max_scroll)

	elif event is InputEventScreenTouch:
		if event.pressed:
			_is_dragging = true
			_last_drag_y = local_point.y
		else:
			_is_dragging = false

	elif _is_dragging and (event is InputEventMouseMotion or event is InputEventScreenDrag):
		var diff_y = local_point.y - _last_drag_y
		# Vu que l'axe Y local du sprite est positif vers le haut, drag vers le haut diminue diff_y.
		# On applique donc -diff_y pour faire défiler le contenu !
		_target_scroll_y = clamp(_target_scroll_y - diff_y, 0.0, max_scroll)
		_last_drag_y = local_point.y

func _input(event: InputEvent) -> void:
	# Sécurité globale : On arrête le drag dès que le clic/toucher est relâché
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_is_dragging = false
	elif event is InputEventScreenTouch and not event.pressed:
		_is_dragging = false

func _update_children_positions_in_editor() -> void:
	if not Engine.is_editor_hint(): return
	for child in get_children():
		if child is Node3D and child != _gizmo_mesh and child != _scrollbar and child != _bg_mesh and not child in _border_lines:
			var aabb = _get_combined_local_aabb(child)
			if aabb.size == Vector3.ZERO: continue
			
			var target_top = (view_size.y / 2.0) - top_margin
			var target_x = 0.0
			match horizontal_alignment:
				HAlign.LEFT: target_x = -view_size.x / 2.0
				HAlign.CENTER: target_x = 0.0
				HAlign.RIGHT: target_x = view_size.x / 2.0
			
			var child_top_y = aabb.position.y + aabb.size.y
			var child_left_x = aabb.position.x
			var child_right_x = aabb.position.x + aabb.size.x
			var child_center_x = aabb.position.x + (aabb.size.x / 2.0)
			
			var new_x = 0.0
			match horizontal_alignment:
				HAlign.LEFT: new_x = target_x - child_left_x
				HAlign.CENTER: new_x = target_x - child_center_x
				HAlign.RIGHT: new_x = target_x - child_right_x
				
			var new_y = target_top - child_top_y
			
			child.position = Vector3(new_x, new_y, child.position.z)

func _update_editor_gizmo() -> void:
	if not Engine.is_editor_hint():
		if _gizmo_mesh: _gizmo_mesh.queue_free()
		return
		
	if not _gizmo_mesh:
		_gizmo_mesh = get_node_or_null("EditorGizmo")
		if not _gizmo_mesh:
			_gizmo_mesh = MeshInstance3D.new()
			_gizmo_mesh.name = "EditorGizmo"
			_gizmo_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_gizmo_mesh.set_meta("_edit_lock_", true)
			add_child(_gizmo_mesh)
			
	_gizmo_mesh.visible = true
	var mesh = ImmediateMesh.new()
	_gizmo_mesh.mesh = mesh
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.0, 0.7, 1.0, 0.8) # Cyan néon
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var w = view_size.x / 2.0
	var h = view_size.y / 2.0
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	mesh.surface_add_vertex(Vector3(-w, h, 0)); mesh.surface_add_vertex(Vector3(w, h, 0))
	mesh.surface_add_vertex(Vector3(w, h, 0)); mesh.surface_add_vertex(Vector3(w, -h, 0))
	mesh.surface_add_vertex(Vector3(w, -h, 0)); mesh.surface_add_vertex(Vector3(-w, -h, 0))
	mesh.surface_add_vertex(Vector3(-w, -h, 0)); mesh.surface_add_vertex(Vector3(-w, h, 0))
	mesh.surface_end()

func _update_scrollbar_visual() -> void:
	if not show_scrollbar:
		if _scrollbar: _scrollbar.visible = false
		return
		
	var content_h = _get_content_height()
	if content_h <= view_size.y:
		if _scrollbar: _scrollbar.visible = false
		return
		
	if not _scrollbar:
		_scrollbar = MeshInstance3D.new()
		var box = BoxMesh.new()
		_scrollbar.mesh = box
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = scrollbar_color
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_scrollbar.material_override = mat
		_scrollbar.position.z = 0.05
		add_child(_scrollbar)
		
	_scrollbar.visible = true
	var ratio = _current_scroll_y / max(0.001, content_h - view_size.y)
	var elevator_h = clamp(view_size.y * (view_size.y / content_h) * 0.5, 1.0, view_size.y)
	
	_scrollbar.mesh.size = Vector3(scrollbar_width, elevator_h, 0.05)
	
	var travel = view_size.y - elevator_h
	var top_limit = view_size.y / 2.0 - elevator_h / 2.0
	_scrollbar.position.x = view_size.x / 2.0 + scrollbar_margin
	_scrollbar.position.y = top_limit - (ratio * travel)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_editor_gizmo()
		return
	
	# Interpolation du défilement
	_current_scroll_y = lerp(_current_scroll_y, _target_scroll_y, inertia)
	
	# On décale la caméra du viewport pour faire défiler le contenu !
	if _camera:
		_camera.position.y = -_current_scroll_y
		
	# Mise à jour visuelle de l'ascenseur
	_update_scrollbar_visual()
