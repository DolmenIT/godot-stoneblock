extends Control

## 🎨 MockupEditor : Racine de l'outil de mockup.
## Version 'Silk Smooth' : Lissage exponentiel (EMA) et interpolation haute fidélité.

const LAYER_SCENE = preload("res://demo/demo2/SB_CanvasLayer3D.tscn")

@onready var sidebar_left: SB_Box = %SidebarLeft
@onready var sidebar_right: SB_Box = %SidebarRight
@onready var canvas_area: SubViewportContainer = %CanvasArea
@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera_pitch_pivot: Node3D = %CameraPitchPivot
@onready var camera: Camera3D = %Camera3D
@onready var layers_container: Node3D = %Layers
@onready var layers_pivot: Node3D = %LayersPivot
@onready var world_3d: Node3D = %World3D
@onready var cursor_3d: MeshInstance3D = %Cursor3D
@onready var side_indicator: Label3D = %SideIndicator

@onready var left_content: Control = %LeftContent
@onready var right_content: Control = %RightContent
@onready var btn_left: SB_Button = %ToggleLeft
@onready var btn_right: SB_Button = %ToggleRight
@onready var btn_brush_tools: SB_Button = %BtnBrushTools
@onready var btn_eraser: SB_Button = %BtnEraser
@onready var btn_clear: SB_Button = %BtnClear
@onready var brush_menu: Control = %BrushMenu

# --- État de l'UI ---
var left_expanded: bool = true
var right_expanded: bool = true

# --- État du dessin (Silk Smooth) ---
var active_layer: SB_CanvasLayer3D = null
var is_drawing: bool = false
var is_eraser_mode: bool = false
var brush_size: float = 0.5 # mm
var brush_color: Color = Color.BLACK
var brush_softness: float = 0.1
var brush_grain: float = 0.0
var last_paint_uv: Vector2 = Vector2(-1.0, -1.0) 

# Lissage de pression par EMA (Exponential Moving Average)
var smoothed_pressure: float = 1.0 
var last_paint_pressure: float = 1.0
const SMOOTHING_FACTOR: float = 0.15 # Entre 0 (rien) et 1 (direct). 0.15 est très soyeux.

var drawing_start_pos: Vector2 = Vector2.ZERO # Pour l'anti-paté au mouvement

# --- État de la navigation (Stable Euler Orbit) ---
var is_panning: bool = false
var is_orbiting: bool = false
var is_looking_around: bool = false
var rotation_center: Vector3 = Vector3.ZERO

var orbit_yaw: float = 0.0
var orbit_pitch: float = -PI/2.0
var orbit_distance: float = 15.0

var orbit_sensitivity: float = 0.005
var pan_sensitivity: float = 0.015
var zoom_speed: float = 1.0

func _ready() -> void:
	_setup_visual_helpers()
	_update_sidebars()
	_add_new_layer("Paper A4 Landscape")
	_apply_orbit()
	
	# --- Setup Menu Brosses ---
	btn_brush_tools.pressed.connect(_on_btn_brush_tools_pressed)
	btn_eraser.pressed.connect(_on_btn_eraser_pressed)
	btn_clear.pressed.connect(_on_btn_clear_pressed)
	brush_menu.brush_selected.connect(_on_brush_selected)
	
	_update_tool_ui()

func _setup_visual_helpers() -> void:
	var sphere = SphereMesh.new()
	sphere.radius = 0.05
	sphere.height = 0.1
	cursor_3d.mesh = sphere
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	cursor_3d.set_surface_override_material(0, mat)

func _process(_delta: float) -> void:
	_update_rotation_center()
	_update_side_indicator()
	
	# --- DESSIN CONTINU ---
	var is_nav = is_panning or is_orbiting or is_looking_around or Input.is_key_pressed(KEY_SPACE)
	if is_drawing and active_layer and not is_nav:
		_handle_drawing(get_viewport().get_mouse_position())

func _input(event: InputEvent) -> void:
	# États globaux pour la frame
	var space_pressed = Input.is_key_pressed(KEY_SPACE)
	var is_nav = is_panning or is_orbiting or is_looking_around or space_pressed

	# --- 0. TACTILE (Doigts uniquement) ---
	if event is InputEventScreenTouch:
		is_drawing = false
		is_panning = false
		if event.pressed:
			is_orbiting = true
		else:
			is_orbiting = false
		return

	if event is InputEventScreenDrag:
		is_drawing = false
		orbit_yaw -= event.relative.x * orbit_sensitivity
		orbit_pitch -= event.relative.y * orbit_sensitivity
		orbit_pitch = clamp(orbit_pitch, -PI + 0.01, PI - 0.01)
		_apply_orbit()
		return

	# --- 1. SOURIS / STYLET ---

	# --- Navigation ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			orbit_distance = max(1.0, orbit_distance - zoom_speed)
			_apply_orbit()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			orbit_distance = min(100.0, orbit_distance + zoom_speed)
			_apply_orbit()
			return
		
		var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
		if (space_pressed and event.button_index == MOUSE_BUTTON_LEFT) or (shift_pressed and event.button_index == MOUSE_BUTTON_MIDDLE):
			is_panning = event.pressed
			return

		if event.button_index == MOUSE_BUTTON_MIDDLE and not shift_pressed:
			if event.pressed and event.double_click:
				_reset_view_to_fit()
				return
			
			if event.pressed:
				_recenter_pivot_to_target()
			is_orbiting = event.pressed
			return
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not event.pressed: 
				camera_pivot.global_position = rotation_center
				orbit_distance = camera.global_position.distance_to(rotation_center)
				camera.rotation = Vector3.ZERO
				_recenter_pivot_to_target()
			is_looking_around = event.pressed
			return

	if event is InputEventMouseMotion:
		# Lissage exponentiel (EMA) de la pression
		var raw_pressure = event.pressure if event.pressure > 0 else 1.0
		smoothed_pressure = lerp(smoothed_pressure, raw_pressure, SMOOTHING_FACTOR)
		
		if is_panning:
			var move_vec = Vector3(-event.relative.x, event.relative.y, 0) * pan_sensitivity * (orbit_distance * 0.1)
			camera_pivot.translate_object_local(move_vec)
			return
		
		if is_orbiting:
			orbit_yaw -= event.relative.x * orbit_sensitivity
			orbit_pitch -= event.relative.y * orbit_sensitivity
			orbit_pitch = clamp(orbit_pitch, -PI + 0.01, PI - 0.01)
			_apply_orbit()
			return
		
		if is_looking_around:
			camera.rotate_y(-event.relative.x * orbit_sensitivity)
			camera.rotate_x(-event.relative.y * orbit_sensitivity)
			return

	# --- Dessin 3D ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos_global = get_global_mouse_position()
		# Fermetures automatiques des menus si clic ailleurs
		if brush_menu.visible and mouse_pos_global.distance_to(btn_brush_tools.global_position + btn_brush_tools.size/2.0) > 100:
			if not brush_menu.get_global_rect().has_point(mouse_pos_global):
				brush_menu.close()
				
		if not is_nav:
			is_drawing = event.pressed
			if is_drawing:
				drawing_start_pos = get_viewport().get_mouse_position()
				# Départ à pression max (bridé par le moteur au premier point)
				smoothed_pressure = 1.0 
				last_paint_pressure = 1.0
			else:
				last_paint_uv = Vector2(-1.0, -1.0)
				if active_layer:
					active_layer.stop_painting()
			return

func _handle_drawing(mouse_pos: Vector2) -> void:
	var local_mouse_pos = mouse_pos - canvas_area.global_position
	
	var from = camera.project_ray_origin(local_mouse_pos)
	var to = from + camera.project_ray_normal(local_mouse_pos) * 1000.0
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_node = result.collider.get_parent()
		if hit_node is SB_CanvasLayer3D:
			var local_pos = hit_node.to_local(result.position)
			var curr_uv = hit_node.get_uv_from_local(local_pos)
			
			# Anti-Paté par distance
			var pressure_to_apply = smoothed_pressure
			if mouse_pos.distance_to(drawing_start_pos) < 5.0:
				pressure_to_apply = min(pressure_to_apply, 0.15)
			
			var prev_uv = last_paint_uv
			if prev_uv.x < 0:
				prev_uv = curr_uv
				last_paint_pressure = pressure_to_apply # Synchro initiale
			
			# Choix de la couleur selon le mode
			var paint_color = Color.WHITE if is_eraser_mode else brush_color
			
			# Peinture avec interpolation de pression (prev -> curr) et styles
			hit_node.paint(curr_uv, prev_uv, brush_size, pressure_to_apply, last_paint_pressure, paint_color, brush_softness, brush_grain)
			
			last_paint_uv = curr_uv
			last_paint_pressure = pressure_to_apply

# --- Helpers ---

func _add_new_layer(_layer_name: String) -> void:
	if not layers_container: return
	var new_layer = LAYER_SCENE.instantiate()
	layers_container.add_child(new_layer)
	new_layer.position.y = (layers_container.get_child_count() - 1) * 0.05
	active_layer = new_layer

func _update_rotation_center() -> void:
	if is_orbiting: return
	var viewport_center = canvas_area.size / 2.0
	var from = camera.project_ray_origin(viewport_center)
	var dir = camera.project_ray_normal(viewport_center)
	if not active_layer: return
	var plane = Plane(active_layer.global_transform.basis.y, active_layer.global_position)
	var intersection = plane.intersects_ray(from, dir)
	if intersection:
		rotation_center = intersection
		cursor_3d.global_position = intersection

func _update_side_indicator() -> void:
	if not active_layer or not side_indicator: return
	var dot = (-camera.global_transform.basis.z).dot(active_layer.global_transform.basis.y)
	if dot < 0:
		side_indicator.text = "FRONT"
		side_indicator.modulate = Color(0.1, 0.6, 1.0, 1.0)
	else:
		side_indicator.text = "BACK"
		side_indicator.modulate = Color(1.0, 0.4, 0.2, 1.0)

func _apply_orbit() -> void:
	if not camera_pivot: return
	camera_pivot.rotation = Vector3(0, orbit_yaw, 0)
	camera_pitch_pivot.rotation = Vector3(orbit_pitch, 0, 0)
	camera.position = Vector3(0, 0, orbit_distance)
	camera.rotation = Vector3.ZERO

func _recenter_pivot_to_target() -> void:
	camera_pivot.global_position = rotation_center

func _reset_view_to_fit() -> void:
	var sheet_w = 29.7
	var sheet_h = 21.0
	if active_layer:
		sheet_w = active_layer.physical_size_mm.x / 10.0
		sheet_h = active_layer.physical_size_mm.y / 10.0
	var fov_rad = deg_to_rad(camera.fov)
	var aspect = float(canvas_area.size.x) / float(canvas_area.size.y)
	var dist_h = (sheet_h / 2.0) / tan(fov_rad / 2.0)
	var fov_h_rad = 2.0 * atan(tan(fov_rad / 2.0) * aspect)
	var dist_w = (sheet_w / 2.0) / tan(fov_h_rad / 2.0)
	var target_dist = max(dist_h, dist_w) * 1.1
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "orbit_yaw", 0.0, 0.5)
	tw.tween_property(self, "orbit_pitch", -PI/2.0, 0.5)
	tw.tween_property(self, "orbit_distance", target_dist, 0.5)
	tw.tween_property(camera_pivot, "global_position", Vector3.ZERO, 0.5)
	tw.connect("finished", func(): _apply_orbit())

func toggle_left() -> void:
	left_expanded = !left_expanded
	left_content.visible = left_expanded
	btn_left.text = "<<" if left_expanded else ">>"
	_animate_sidebar(sidebar_left, 250 if left_expanded else 50)

func toggle_right() -> void:
	right_expanded = !right_expanded
	right_content.visible = right_expanded
	btn_right.text = ">>" if right_expanded else "<<"
	_animate_sidebar(sidebar_right, 200 if right_expanded else 50)

func _animate_sidebar(panel: Control, target_width: float) -> void:
	var tw = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "custom_minimum_size:x", target_width, 0.3)

func _update_sidebars() -> void:
	sidebar_left.custom_minimum_size.x = 250 if left_expanded else 50
	sidebar_right.custom_minimum_size.x = 200 if right_expanded else 50
	left_content.visible = left_expanded
	right_content.visible = right_expanded

# --- Callbacks Brush Studio ---

func _on_btn_brush_tools_pressed() -> void:
	if brush_menu.visible:
		brush_menu.close()
	else:
		brush_menu.open()

func _on_brush_selected(data: Dictionary) -> void:
	print("[BRUSH] Sélection : ", data.name)
	btn_brush_tools.text = data.name
	is_eraser_mode = false
	
	# Application des réglages
	var settings = data.settings
	brush_size = settings.size
	brush_softness = settings.softness
	brush_grain = settings.grain
	_update_tool_ui()

func _on_btn_eraser_pressed() -> void:
	is_eraser_mode = !is_eraser_mode
	if is_eraser_mode: brush_menu.close()
	_update_tool_ui()

func _on_btn_clear_pressed() -> void:
	if active_layer:
		active_layer.clear_canvas()

func _update_tool_ui() -> void:
	# Feedback visuel sur les boutons
	btn_brush_tools.modulate = Color.WHITE if not is_eraser_mode else Color(0.5, 0.5, 0.5)
	btn_eraser.modulate = Color.CYAN if is_eraser_mode else Color.WHITE
	
	# Si on est en gomme, on change le texte pour clarifier
	if is_eraser_mode:
		btn_eraser.text = "GOMME (Active)"
	else:
		btn_eraser.text = "Gomme"
