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

@export_group("Banking (Tilt)")
@export var max_bank_angle: float = 25.0 # Degrés
@export var bank_speed: float = 5.0

@export var horizontal_limit: float = 25.0
@export var vertical_limit: float = 18.0

@export_group("Combat")
@export var projectile_scene: PackedScene = preload("res://stoneblock/projectiles/SB_Projectile_VShmup.tscn")
@export var fire_rate: float = 0.1 # Secondes entre deux tirs
@export var fire_action: String = "ui_accept"

# --- État ---
var velocity: Vector2 = Vector2.ZERO
var target_bank: float = 0.0
var current_bank: float = 0.0
var _last_fire_time: float = 0.0
var _pivot_ref: Node3D

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	_handle_movement(delta)
	_handle_banking(delta)
	_handle_firing()
	_apply_constraints()

func _handle_movement(delta: float) -> void:
	# Récupération des entrées
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_dir.length() > 0:
		velocity = velocity.lerp(input_dir * movement_speed, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, damping * delta)
	
	# Le mouvement est désormais RELATIF au Pivot (qui gère le scroll Z)
	position.x += velocity.x * delta
	position.z += velocity.y * delta

func _handle_banking(delta: float) -> void:
	# L'inclinaison est basée sur la vélocité horizontale (X)
	target_bank = -velocity.x / movement_speed * deg_to_rad(max_bank_angle)
	current_bank = lerp(current_bank, target_bank, bank_speed * delta)
	
	# Application de la rotation sur l'axe Z (roulis)
	rotation.z = current_bank

func _apply_constraints() -> void:
	# Recherche du Pivot s'il n'est pas encore trouvé
	if not _pivot_ref:
		var gm = get_parent()
		while gm and not gm is SB_GameMode_VShmup:
			gm = gm.get_parent()
		if gm:
			_pivot_ref = gm.camera_pivot

	if not _pivot_ref: return
	
	# Limiter la position globale par rapport à la position globale du Pivot
	var pivot_pos = _pivot_ref.global_position
	
	global_position.x = clamp(global_position.x, pivot_pos.x - horizontal_limit, pivot_pos.x + horizontal_limit)
	global_position.z = clamp(global_position.z, pivot_pos.z - vertical_limit, pivot_pos.z + vertical_limit)

func _handle_firing() -> void:
	if Input.is_action_pressed(fire_action):
		var now = Time.get_ticks_msec() / 1000.0
		if now - _last_fire_time > fire_rate:
			fire()
			_last_fire_time = now

## Méthode pour tirer
func fire() -> void:
	if not projectile_scene: return
	
	var bullet = projectile_scene.instantiate()
	# Ajouter le projectile au parent du vaisseau (ou via le GameMode)
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = Vector3(0, 0, -1) # Vers le haut
