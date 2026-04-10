extends Control

## 🎨 MockupEditor : Racine de l'outil de mockup.
## Gère le dessin GPU sur calques 3D avec navigation stable (Euler Orbit).

const LAYER_SCENE = preload("res://demo/demo2/SB_CanvasLayer3D.tscn")

@onready var sidebar_left: PanelContainer = %SidebarLeft
@onready var sidebar_right: PanelContainer = %SidebarRight
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
@onready var btn_left: Button = %ToggleLeft
@onready var btn_right: Button = %ToggleRight

# État de l'UI
var left_expanded: bool = true
var right_expanded: bool = true

# État du dessin
var active_layer: SB_CanvasLayer3D = null
var is_drawing: bool = false
var brush_size: float = 0.05
var brush_color: Color = Color.WHITE

# État de la navigation (Stable Euler Orbit)
var is_panning: bool = false
var is_orbiting: bool = false
var is_looking_around: bool = false
var rotation_center: Vector3 = Vector3.ZERO

# Angles d'Euler pour une rotation sans flip
var orbit_yaw: float = 0.0
var orbit_pitch: float = -PI/2.0 # Vue de dessus par défaut
var orbit_distance: float = 15.0

# Monitoring pour debug
var _last_yaw: float = 0.0
var _last_pitch: float = 0.0

var orbit_sensitivity: float = 0.005
var pan_sensitivity: float = 0.015
var zoom_speed: float = 1.0

func _ready() -> void:
	_setup_visual_helpers()
	_update_sidebars()
	_add_new_layer("Paper A4 Landscape")
	
	# Initialisation de la vue stable et du monitoring
	_last_yaw = orbit_yaw
	_last_pitch = orbit_pitch
	_apply_orbit()

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

func _input(event: InputEvent) -> void:
	var alt_pressed = Input.is_key_pressed(KEY_ALT)
	var space_pressed = Input.is_key_pressed(KEY_SPACE)

	# --- Navigation ---
	if event is InputEventMouseButton:
		# Zoom (Molette)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			orbit_distance = max(1.0, orbit_distance - zoom_speed)
			print("[NAV] Zoom IN | Dist: %.2f" % orbit_distance)
			_apply_orbit()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			orbit_distance = min(100.0, orbit_distance + zoom_speed)
			print("[NAV] Zoom OUT | Dist: %.2f" % orbit_distance)
			_apply_orbit()
			return
		
		# Panoramique (Espace + Clic Gauche OU Shift + Bouton Milieu)
		var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
		if (space_pressed and event.button_index == MOUSE_BUTTON_LEFT) or (shift_pressed and event.button_index == MOUSE_BUTTON_MIDDLE):
			is_panning = event.pressed
			return

		# Orbite (Bouton Milieu)
		if event.button_index == MOUSE_BUTTON_MIDDLE and not shift_pressed:
			if event.pressed:
				if event.double_click:
					print("[NAV] Double-Click detected -> Reset View to Fit")
					_reset_view_to_fit()
					return
				
				print("[NAV] Orbit START | Pivot: %s | Cam: %s" % [camera_pivot.global_position, camera.global_position])
				_recenter_pivot_to_target()
			else:
				print("[NAV] Orbit END")
			is_orbiting = event.pressed
			return
		
		# Regarder autour
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed: 
				print("[NAV] LookAround START")
			else: 
				print("[NAV] LookAround END -> Moving pivot to look target & resetting camera")
				# 1. On déplace le pivot mondial sur le point que l'on regarde actuellement
				camera_pivot.global_position = rotation_center
				
				# 2. On calcule la nouvelle distance (car on s'est peut-être approché/éloigné du centre)
				orbit_distance = camera.global_position.distance_to(rotation_center)
				
				# 3. On remet la caméra à zéro et on laisse les pivots gérer la vue
				camera.rotation = Vector3.ZERO
				
				# 4. On s'assure que les variables internes sont à jour (via Recentre)
				_recenter_pivot_to_target()
			
			is_looking_around = event.pressed
			return

	if event is InputEventMouseMotion:
		if is_panning:
			var move_vec = Vector3(-event.relative.x, event.relative.y, 0) * pan_sensitivity * (orbit_distance * 0.1)
			camera_pivot.translate_object_local(move_vec)
			return
		
		if is_orbiting:
			orbit_yaw -= event.relative.x * orbit_sensitivity
			orbit_pitch -= event.relative.y * orbit_sensitivity
			orbit_pitch = clamp(orbit_pitch, -PI + 0.01, PI - 0.01) # Presque 360 vertical
			_apply_orbit()
			return
		
		if is_looking_around:
			camera.rotate_y(-event.relative.x * orbit_sensitivity)
			camera.rotate_x(-event.relative.y * orbit_sensitivity)
			return

	# --- Dessin 3D ---
	var is_nav = is_panning or is_orbiting or is_looking_around or space_pressed
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_nav:
			is_drawing = event.pressed
			if not is_drawing and active_layer:
				active_layer.stop_painting()

	if is_drawing and active_layer and not is_nav:
		_handle_drawing(get_viewport().get_mouse_position())

## ➕ Ajoute un nouveau calque 3D à la pile.
func _add_new_layer(_layer_name: String) -> void:
	var new_layer = LAYER_SCENE.instantiate()
	layers_container.add_child(new_layer)
	
	var index = layers_container.get_child_count() - 1
	new_layer.position.y = index * 0.05
	
	active_layer = new_layer

func _update_rotation_center() -> void:
	if is_orbiting: return
	
	var viewport_center = canvas_area.size / 2.0
	var from = camera.project_ray_origin(viewport_center)
	var dir = camera.project_ray_normal(viewport_center)
	
	if not active_layer: return
	var plane_normal = active_layer.global_transform.basis.y
	var plane_point = active_layer.global_position
	var plane = Plane(plane_normal, plane_point)
	
	var intersection = plane.intersects_ray(from, dir)
	if intersection:
		rotation_center = intersection
		cursor_3d.global_position = intersection

func _update_side_indicator() -> void:
	if not active_layer or not side_indicator: return
	var cam_forward = -camera.global_transform.basis.z
	var sheet_normal = active_layer.global_transform.basis.y
	var dot = cam_forward.dot(sheet_normal)
	
	if dot < 0:
		side_indicator.text = "FRONT"
		side_indicator.modulate = Color(0.1, 0.6, 1.0, 1.0)
	else:
		side_indicator.text = "BACK"
		side_indicator.modulate = Color(1.0, 0.4, 0.2, 1.0)

## ⚓ Applique les angles d'Euler aux pivots de manière stable.
func _apply_orbit() -> void:
	# --- DEBUG LOG ---
	var yaw_diff = abs(angle_difference(_last_yaw, orbit_yaw))
	var pitch_diff = abs(angle_difference(_last_pitch, orbit_pitch))
	
	if yaw_diff > 1.5 or pitch_diff > 1.5:
		print_debug("[NAV_LOG] Saut d'angle détecté ! YAW_DIFF: %.2f | PITCH_DIFF: %.2f" % [yaw_diff, pitch_diff])
		print_debug("   -> Yaw: %.2f (old: %.2f) | Pitch: %.2f (old: %.2f)" % [orbit_yaw, _last_yaw, orbit_pitch, _last_pitch])
	
	_last_yaw = orbit_yaw
	_last_pitch = orbit_pitch
	# -----------------

	camera_pivot.rotation = Vector3(0, orbit_yaw, 0)
	camera_pitch_pivot.rotation = Vector3(orbit_pitch, 0, 0)
	camera.position = Vector3(0, 0, orbit_distance)
	camera.rotation = Vector3.ZERO

## ⚓ Recentre le pivot sur la cible et synchronise les angles intelligemment.
func _recenter_pivot_to_target() -> void:
	var old_cam_pos = camera.global_position
	var diff = old_cam_pos - rotation_center
	
	print("[NAV] Recentre Pivot -> Target: %s" % rotation_center)
	print("   -> Current Yaw: %.4f | Pitch: %.4f" % [orbit_yaw, orbit_pitch])
	
	# 1. Mise à jour de la distance
	orbit_distance = diff.length()
	
	# 2. Synchronisation de sécurité (Normalement désuet grâce au transfert en amont)
	if camera.rotation.length() > 0.01:
		print("   -> Syncing orientation (Residual rotation detected!)")
		var horizontal_diff = Vector2(diff.x, diff.z)
		if horizontal_diff.length() > 0.1:
			var new_yaw = atan2(diff.x, diff.z)
			if abs(angle_difference(orbit_yaw, new_yaw)) < PI / 4.0:
				orbit_yaw = new_yaw
		orbit_pitch = atan2(-diff.y, horizontal_diff.length())
	
	# 3. Déplacer le pivot
	camera_pivot.global_position = rotation_center
	
## 🎯 Remet la vue à plat et zoom pour ajuster la feuille à l'écran.
func _reset_view_to_fit() -> void:
	# 1. Calcul de la distance optimale (Fov math)
	# Feuille A4 : 14.14 x 10.0
	var sheet_w = 14.14
	var sheet_h = 10.0
	var fov_rad = deg_to_rad(camera.fov)
	
	# Ratio du viewport
	var aspect = float(canvas_area.size.x) / float(canvas_area.size.y)
	
	# Calcul de la distance nécessaire pour la hauteur et la largeur
	var dist_h = (sheet_h / 2.0) / tan(fov_rad / 2.0)
	# Pour la largeur, on doit tenir compte du FOV horizontal (dépendant de l'aspect)
	var fov_h_rad = 2.0 * atan(tan(fov_rad / 2.0) * aspect)
	var dist_w = (sheet_w / 2.0) / tan(fov_h_rad / 2.0)
	
	# On prend la distance la plus grande + une petite marge de 10%
	var target_dist = max(dist_h, dist_w) * 1.1
	
	# 2. Animation fluide vers les valeurs cibles
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	tw.tween_property(self, "orbit_yaw", 0.0, 0.5)
	tw.tween_property(self, "orbit_pitch", -PI/2.0, 0.5)
	tw.tween_property(self, "orbit_distance", target_dist, 0.5)
	tw.tween_property(camera_pivot, "global_position", Vector3.ZERO, 0.5)
	
	# Mise à jour continue pendant l'animation
	tw.connect("finished", func(): _apply_orbit())
	# On force l'update visuelle via process pendant que le tween tourne
	var update_timer = get_tree().create_timer(0.5)
	while update_timer.time_left > 0:
		_apply_orbit()
		await get_tree().process_frame

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
			var uv_x = (local_pos.x + 7.07) / 14.14
			var uv_y = (local_pos.z + 5.0) / 10.0
			
			hit_node.paint(Vector2(uv_x, uv_y), brush_size, 1.0, brush_color)

# --- UI Helpers ---

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

func _animate_sidebar(panel: PanelContainer, target_width: float) -> void:
	var tw = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "custom_minimum_size:x", target_width, 0.3)
	
func _update_sidebars() -> void:
	sidebar_left.custom_minimum_size.x = 250 if left_expanded else 50
	sidebar_right.custom_minimum_size.x = 200 if right_expanded else 50
	left_content.visible = left_expanded
	right_content.visible = right_expanded
