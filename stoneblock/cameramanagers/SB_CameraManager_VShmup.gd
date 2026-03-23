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
@export var follow_smoothness: float = 2.0
## Limite horizontale de la "map" (la caméra s'arrête ici)
@export var map_limit_x: float = 50.0
## Décalage vertical pour placer le pivot/vaisseau (0.0 = Centre)
@export var vertical_view_offset: float = 0.0

# --- Références aux caméras ---
var background_camera: Camera3D
var mainground_camera: Camera3D
var bloom_camera: Camera3D
var ui_camera: Camera3D

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

func update_cameras(delta: float, world_position_z: float, player_x: float = 0.0) -> void:
	# Mise à jour de la position X (Suivi du joueur)
	if follow_player_x and mainground_camera:
		var target_x = clamp(player_x, -map_limit_x, map_limit_x)
		mainground_camera.position.x = lerp(mainground_camera.position.x, target_x, follow_smoothness * delta)
		if background_camera:
			background_camera.position.x = mainground_camera.position.x
	
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
