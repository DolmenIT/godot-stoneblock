@tool
@icon("res://stoneblock/icons/SB_PlayerController3D.svg")
class_name SB_PlayerController3D
extends CharacterBody3D

## 🏃 SB_PlayerController3D : Contrôleur de personnage 3D minimaliste.
## Gère les déplacements, le saut et la gravité.

@export_group("Movement")
## Vitesse de déplacement maximale.
@export var speed: float = 7.0
## Force d'accélération au sol.
@export var acceleration: float = 40.0
## Force d'accélération en l'air.
@export var air_acceleration: float = 10.0
## Force de freinage.
@export var friction: float = 20.0

@export_group("Jump")
## Puissance du saut.
@export var jump_velocity: float = 6.0
## Gravité personnalisée (si 0, utilise la gravité projet).
@export var custom_gravity: float = 0.0

@export_group("Constraint")
## Si vrai, verrouille le mouvement sur l'axe X (Side-scroller).
@export var lock_z_axis: bool = false

@export_group("Visuals")
## Le modèle 3D à orienter vers le mouvement.
@export var model: Node3D
## Vitesse de rotation du modèle.
@export var rotation_speed: float = 12.0

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if custom_gravity > 0:
		_gravity = custom_gravity

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	# Gravité
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# Saut
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Inputs (Mode Side-scroller par défaut)
	var move_input := 0.0
	var direction := Vector3.ZERO
	
	if lock_z_axis:
		move_input = Input.get_axis("ui_left", "ui_right")
		direction = Vector3(move_input, 0, 0).normalized()
	else:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var target_accel = acceleration if is_on_floor() else air_acceleration

	if direction:
		velocity.x = move_toward(velocity.x, direction.x * speed, target_accel * delta)
		if not lock_z_axis:
			velocity.z = move_toward(velocity.z, direction.z * speed, target_accel * delta)
		else:
			velocity.z = 0
			# Verrouillage position Z pour éviter les dérives
			global_position.z = move_toward(global_position.z, 0, delta * 10.0)
		
			# Orientation du modèle vers la direction du mouvement
			if model:
				var target_basis = Basis.looking_at(direction, Vector3.UP)
				model.basis = model.basis.slerp(target_basis, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	move_and_slide()
