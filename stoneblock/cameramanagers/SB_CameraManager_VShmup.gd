@tool
extends Node
class_name SB_CameraManager_VShmup

## 🚀 SB_CameraManager_VShmup : Gère les caméras parallax et les zones de vitesse.
## Ce composant est basé sur l'architecture de Cosmic HyperSquad.

# --- Configuration ---
@export_group("Scrolling")
@export var main_camera_speed: float = 1.0
@export var use_dynamic_speed_zones: bool = true
## Zones de vitesse dynamiques (Dictionary: start_z, end_z, speeds...)
@export var speed_zones: Array[Dictionary] = []

@export_group("Camera Follow (Horizontal)")
@export var follow_player_x: bool = true
## Facteur de vitesse de suivi (Vitesse = Distance * Facteur).
@export var follow_speed_factor: float = 4.0
## Distance horizontale de "zone morte" (la caméra ne bouge pas si l'écart est inférieur à X).
@export var follow_deadzone_x: float = 10.0:
	set(v):
		follow_deadzone_x = v
		_update_deadzone_visual()
## Afficher un rectangle semi-transparent matérialisant la deadzone.
@export var show_deadzone_visual: bool = true:
	set(v):
		show_deadzone_visual = v
		_update_deadzone_visual()

## Limite horizontale de la "map" (les BORDS de la caméra s'arrêtent ici)
@export var map_limit_x: float = 125.0
## Décalage vertical pour placer le pivot/vaisseau (0.0 = Centre)
@export var vertical_view_offset: float = 0.0

# --- Références aux caméras ---
var background_camera: Camera3D
var mainground_camera: Camera3D
var bloom_camera: Camera3D
var ui_camera: Camera3D

# --- Debug ---
var _deadzone_visual: MeshInstance3D

# --- État interne ---
var current_scroll_speed: float = 0.0
var mainground_camera_speed: float = 0.0
var background_camera_speed: float = 0.0
var bloom_camera_speed: float = 0.0
var ui_camera_speed: float = 0.0

var mainground_camera_target_speed: float = 0.0
var background_camera_target_speed: float = 0.0
var bloom_camera_target_speed: float = 0.0
var ui_camera_target_speed: float = 0.0

var current_smoothness: float = 2.0

var _shake_intensity: float = 0.0
var _shake_timer: float = 0.0

func initialize(
	_bg_cam: Camera3D, 
	_mg_cam: Camera3D, 
	_bl_cam: Camera3D, 
	_ui_cam: Camera3D
) -> void:
	background_camera = _bg_cam
	mainground_camera = _mg_cam
	bloom_camera = _bl_cam
	ui_camera = _ui_cam
	
	current_scroll_speed = abs(main_camera_speed)
	
	if use_dynamic_speed_zones:
		_calculate_dynamic_speeds(0.0)
		mainground_camera_speed = mainground_camera_target_speed
		background_camera_speed = background_camera_target_speed
		bloom_camera_speed = bloom_camera_target_speed
		ui_camera_speed = ui_camera_target_speed
	
	_update_deadzone_visual()

func _update_deadzone_visual() -> void:
	if not Engine.is_editor_hint() and not OS.is_debug_build(): 
		if _deadzone_visual: _deadzone_visual.visible = false
		return
		
	if not show_deadzone_visual or not mainground_camera:
		if _deadzone_visual: _deadzone_visual.visible = false
		return
		
	if not _deadzone_visual:
		_deadzone_visual = MeshInstance3D.new()
		_deadzone_visual.name = "Deadzone_Debug_Visual"
		_deadzone_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mainground_camera.add_child(_deadzone_visual)
		
		var mesh = PlaneMesh.new()
		_deadzone_visual.mesh = mesh
		
		var mat = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(0, 1, 1, 0.25) # Cyan 25% opacité
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_deadzone_visual.material_override = mat
		
	_deadzone_visual.visible = true
	# Dimensionnement
	var mesh = _deadzone_visual.mesh as PlaneMesh
	mesh.size = Vector2(follow_deadzone_x * 2, 200) # Hauteur arbitraire large
	
	# Positionnement au sol (Y=0) par rapport à la caméra
	_deadzone_visual.global_position = Vector3(mainground_camera.global_position.x, 0.1, mainground_camera.global_position.z)
	_deadzone_visual.rotation_degrees = Vector3.ZERO

func update_cameras(delta: float, world_position_z: float, player_x: float = 0.0) -> void:
	# Mise à jour de la position X (Suivi du joueur avec clamping des bords)
	if follow_player_x and mainground_camera:
		# Calcul de la demi-largeur visible pour le clamping
		var half_width = _get_camera_half_width(mainground_camera)
		
		# On réduit la limite de map par cette demi-largeur pour bloquer le BORD
		var effective_limit = max(0.0, map_limit_x - half_width)
		
		# --- Compensation Bullet Time (Caméra) ---
		var effective_delta = delta
		if Engine.time_scale < 1.0 and Engine.time_scale > 0:
			effective_delta = delta / Engine.time_scale
			
		var target_x = clamp(player_x, -effective_limit, effective_limit)
		
		# Application de la Deadzone
		var diff_x = target_x - mainground_camera.position.x
		if abs(diff_x) > follow_deadzone_x:
			# Si on sort de la zone, on calcule le point cible pour le bord de la caméra
			var shift_x = diff_x - sign(diff_x) * follow_deadzone_x
			var final_target_x = mainground_camera.position.x + shift_x
			
			# Vitesse proportionnelle à la distance ( move_toward pour la stabilité)
			var distance_to_join = abs(final_target_x - mainground_camera.position.x)
			var current_speed = distance_to_join * follow_speed_factor
			mainground_camera.position.x = mainground_camera.position.x + (final_target_x - mainground_camera.position.x) * follow_speed_factor * effective_delta
		
		# Mise à jour du visuel debug
		if _deadzone_visual and _deadzone_visual.visible:
			_deadzone_visual.global_position = Vector3(mainground_camera.global_position.x, 0.1, mainground_camera.global_position.z)
		
		if background_camera:
			# Si le background est en perspective ou a une taille différente, on recalcule son clamping
			var bg_half_width = _get_camera_half_width(background_camera)
			var bg_effective_limit = max(0.0, map_limit_x - bg_half_width)
			background_camera.position.x = clamp(mainground_camera.position.x, -bg_effective_limit, bg_effective_limit)
	
	if use_dynamic_speed_zones:
		_calculate_dynamic_speeds(world_position_z)
		_interpolate_camera_speeds(delta)
		current_scroll_speed = abs(mainground_camera_speed)
		
		# Mise à jour des positions
		if mainground_camera: mainground_camera.position.z = world_position_z + vertical_view_offset
		if background_camera: background_camera.position.z += background_camera_speed * delta
		
		# Sync Bloom and UI with Mainground
		if mainground_camera:
			if bloom_camera:
				_sync_camera(bloom_camera, mainground_camera)
			if ui_camera:
				_sync_camera(ui_camera, mainground_camera)
	else:
		current_scroll_speed = abs(main_camera_speed)
		if mainground_camera: mainground_camera.position.z = world_position_z + vertical_view_offset
		if background_camera: background_camera.position.z = world_position_z + vertical_view_offset
		
		# Sync Bloom and UI with Mainground
		if mainground_camera:
			if bloom_camera:
				_sync_camera(bloom_camera, mainground_camera)
			if ui_camera:
				_sync_camera(ui_camera, mainground_camera)
	
	# Application du Shake
	_process_shake(delta)

func _process_shake(delta: float) -> void:
	if _shake_timer > 0.0:
		# --- Compensation Bullet Time (Shake) ---
		var effective_delta = delta
		if Engine.time_scale < 1.0 and Engine.time_scale > 0:
			effective_delta = delta / Engine.time_scale

		_shake_timer -= effective_delta
		var offset = Vector2(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity)
		)
		if mainground_camera:
			mainground_camera.h_offset = offset.x
			mainground_camera.v_offset = offset.y
		# On réduit l'intensité progressivement (temps réel aussi)
		_shake_intensity = lerp(_shake_intensity, 0.0, 5.0 * effective_delta)
	else:
		if mainground_camera:
			mainground_camera.h_offset = 0
			mainground_camera.v_offset = 0

func add_shake(intensity: float, duration: float) -> void:
	_shake_intensity = max(_shake_intensity, intensity)
	_shake_timer = max(_shake_timer, duration)

func _calculate_dynamic_speeds(current_z: float) -> void:
	mainground_camera_target_speed = -abs(main_camera_speed)
	background_camera_target_speed = -abs(main_camera_speed)
	bloom_camera_target_speed = -abs(main_camera_speed)
	ui_camera_target_speed = -abs(main_camera_speed)
	current_smoothness = 2.0
	
	for zone in speed_zones:
		var start_z = zone.get("start_z", 0.0)
		var end_z = zone.get("end_z", -999999.0)
		
		if current_z <= start_z and current_z >= end_z:
			var zone_main_speed = zone.get("mainground_speed", -main_camera_speed)
			mainground_camera_target_speed = zone_main_speed
			background_camera_target_speed = zone.get("background_speed", zone_main_speed)
			bloom_camera_target_speed = zone.get("bloom_speed", zone_main_speed)
			ui_camera_target_speed = zone.get("ui_speed", zone_main_speed)
			current_smoothness = zone.get("smoothness", 2.0)
			break

func _interpolate_camera_speeds(delta: float) -> void:
	if current_smoothness <= 0.0:
		mainground_camera_speed = mainground_camera_target_speed
		background_camera_speed = background_camera_target_speed
		bloom_camera_speed = bloom_camera_target_speed
		ui_camera_speed = ui_camera_target_speed
	else:
		var lerp_factor = clamp(current_smoothness * delta, 0.0, 1.0)
		mainground_camera_speed = lerp(mainground_camera_speed, mainground_camera_target_speed, lerp_factor)
		background_camera_speed = lerp(background_camera_speed, background_camera_target_speed, lerp_factor)
		bloom_camera_speed = lerp(bloom_camera_speed, bloom_camera_target_speed, lerp_factor)
		ui_camera_speed = lerp(ui_camera_speed, ui_camera_target_speed, lerp_factor)

## Applique les paramètres de caméra (projection, position Y, taille).
func apply_settings_to_camera(camera: Camera3D, projection: int, y_pos: float, size: float) -> void:
	if not camera: return
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE if projection == 0 else Camera3D.PROJECTION_ORTHOGONAL
	camera.position.y = y_pos
	
	if camera.projection == Camera3D.PROJECTION_PERSPECTIVE:
		camera.fov = size
	else:
		camera.size = size

func _sync_camera(target: Camera3D, source: Camera3D) -> void:
	if not target or not source: return
	target.global_transform = source.global_transform
	target.projection = source.projection
	target.fov = source.fov
	target.size = source.size
	target.near = source.near
	target.far = source.far

func _get_camera_half_width(camera: Camera3D) -> float:
	if not camera or not camera.is_inside_tree(): return 0.0
	
	var viewport_size = camera.get_viewport().get_visible_rect().size
	var aspect = viewport_size.x / viewport_size.y if viewport_size.y > 0 else 1.0
	
	if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		return (camera.size * aspect) / 2.0
	else:
		# Perspective: On calcule la largeur à Y=0 (le sol)
		# On suppose que la caméra regarde vers le bas (-Y)
		var half_fov_rad = deg_to_rad(camera.fov) / 2.0
		return tan(half_fov_rad) * abs(camera.position.y) * aspect
