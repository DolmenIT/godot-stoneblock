@tool
extends Node3D
class_name SB_Player_VShmup

## 🚀 SB_Player_VShmup : Controleur du vaisseau joueur pour le mode SHMUP.
## Gère le mouvement, l'inclinaison (banking) et les limites de l'écran.

# --- Configuration ---
@export_group("Movement")
@export var movement_speed: float = 30.0
@export var acceleration: float = 10.0
@export var damping: float = 5.0

@export_group("Special Actions")
@export var dash_duration: float = 0.4
@export var dash_boost: float = 2.0
@export var dash_cooldown: float = 0.5

@export_group("Banking (Tilt)")
@export var max_bank_angle: float = 25.0 # Degrés
@export var bank_speed: float = 5.0

@export var horizontal_limit: float = 25.0
@export var vertical_limit: float = 18.0

@export_group("Combat")
@export var projectile_scene: PackedScene = preload("res://stoneblock/projectiles/SB_Projectile_VShmup.tscn")
@export var fire_rate: float = 0.1 # Secondes entre deux tirs
@export var fire_action: String = "ui_accept"
@export var use_external_input: bool = false # Si vrai, ignore le clavier interne

# --- État ---
var velocity: Vector2 = Vector2.ZERO
var external_input_vector: Vector2 = Vector2.ZERO
var is_external_firing: bool = false

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: float = 0.0
var cooldown_timer: float = 0.0
var target_bank: float = 0.0
var current_bank: float = 0.0
var _last_fire_time: float = 0.0
var _pivot_ref: Node3D

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# Mise à jour des timers de dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	
	_process_movement(delta)
	_process_visuals(delta)
	_handle_firing()

func _process_movement(delta: float) -> void:
	var input_vec = Vector2.ZERO
	if use_external_input:
		input_vec = external_input_vector
	else:
		input_vec.x = Input.get_axis("ui_left", "ui_right")
		input_vec.y = Input.get_axis("ui_up", "ui_down")
	
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
	
	# Application du boost de dash (uniquement latéralement)
	var final_speed = movement_speed # Changed from 'move_speed' to 'movement_speed'
	if is_dashing:
		input_vec.x = dash_direction # Force la direction du dash
		final_speed *= dash_boost
	
	global_position.x += input_vec.x * final_speed * delta
	global_position.z += input_vec.y * final_speed * delta # Z for forward/backward in 3D, not Y
	
	# Clamping horizontal (Camera relative)
	if not _pivot_ref:
		var gm = get_parent()
		while gm and not gm is SB_GameMode_VShmup:
			gm = gm.get_parent()
		if gm:
			_pivot_ref = gm.camera_pivot

	if not _pivot_ref: return
	
	var pivot_pos = _pivot_ref.global_position
	global_position.x = clamp(global_position.x, pivot_pos.x - horizontal_limit, pivot_pos.x + horizontal_limit)
	global_position.z = clamp(global_position.z, pivot_pos.z - vertical_limit, pivot_pos.z + vertical_limit)

func _process_visuals(delta: float) -> void:
	var mesh = get_node_or_null("Mesh")
	if not mesh: return
	
	# Inclinaison latérale (Banking léger)
	var input_x = Input.get_axis("ui_left", "ui_right") if not use_external_input else external_input_vector.x
	target_bank = -input_x * deg_to_rad(max_bank_angle)
	current_bank = lerp(current_bank, target_bank, bank_speed * delta)
	
	# Tonneau (Rotation 360 sur l'axe Forward/Z)
	var barrel_rot = 0.0
	if is_dashing:
		var progress = (dash_duration - dash_timer) / dash_duration
		barrel_rot = -dash_direction * progress * 360.0
	
	# Application combinée sur l'axe Z
	mesh.rotation_degrees.z = rad_to_deg(current_bank) + barrel_rot

func _handle_firing() -> void:
	var wants_to_fire = false
	if use_external_input:
		wants_to_fire = is_external_firing
	else:
		wants_to_fire = Input.is_action_pressed(fire_action)
		
	if wants_to_fire:
		var now = Time.get_ticks_msec() / 1000.0
		if now - _last_fire_time > fire_rate:
			fire()
			_last_fire_time = now

## API PUBLIQUE : Pilotage externe
func set_input_vector(vec: Vector2) -> void:
	external_input_vector = vec

func set_input_vector_x(val: float) -> void:
	external_input_vector.x = val

func set_input_vector_y(val: float) -> void:
	external_input_vector.y = val

func set_firing(active: bool) -> void:
	is_external_firing = active

func set_dash(active: bool) -> void:
	if not active or is_dashing or cooldown_timer > 0.0: return
	
	# Récupération de la direction actuelle (clavier ou externe)
	var input_x = Input.get_axis("ui_left", "ui_right") if not use_external_input else external_input_vector.x
	
	# Le tonneau ne se déclenche que si on bouge latéralement
	if abs(input_x) > 0.1:
		is_dashing = true
		dash_timer = dash_duration
		dash_direction = sign(input_x)
		cooldown_timer = dash_cooldown

## Méthode pour tirer
func fire() -> void:
	if not projectile_scene: return
	
	var bullet = projectile_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = Vector3(0, 0, -1)
