@tool
extends Node3D
class_name SB_Projectile_VShmup

## 🚀 SB_Projectile_VShmup : Base pour les projectiles (alliés ou ennemis).
## Gère le mouvement, les trajectoires oscillantes et l'auto-destruction.

# --- Configuration ---
@export_group("Movement")
@export var speed: float = 50.0
@export var direction: Vector3 = Vector3(0, 0, -1) # Par défaut vers le haut en Top-Down

@export_group("Oscillation")
@export var use_oscillation: bool = false
@export var frequency: float = 2.0
@export var amplitude: float = 2.0

@export_group("Cleanup")
@export var life_time: float = 5.0 # Secondes
@export var distance_limit: float = 100.0

# --- État ---
var _spawn_time: float = 0.0
var _spawn_position: Vector3 = Vector3.ZERO
var _total_time: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_spawn_time = Time.get_ticks_msec() / 1000.0
	_spawn_position = global_position

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	_total_time += delta
	_update_movement(delta)
	_check_cleanup()

func _update_movement(delta: float) -> void:
	# Mouvement de base (Linéaire)
	var movement = direction * speed * delta
	global_position += movement
	
	# Oscillation (Latérale par rapport à la direction)
	if use_oscillation:
		var offset = sin(_total_time * PI * 2 * frequency) * amplitude
		# Calculer le vecteur perpendiculaire à la direction (sur le plan XZ)
		var perp = Vector3(-direction.z, 0, direction.x).normalized()
		global_position += perp * offset * delta

func _check_cleanup() -> void:
	# Auto-destruction après certain temps
	if _total_time > life_time:
		queue_free()
	
	# Auto-destruction après certaine distance
	if global_position.distance_to(_spawn_position) > distance_limit:
		queue_free()
