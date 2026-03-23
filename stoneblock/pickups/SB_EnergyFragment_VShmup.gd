extends Area3D
class_name SB_EnergyFragment_VShmup

## 💎 SB_EnergyFragment_VShmup : Fragment d'énergie bleu (loot).
## Attiré par le joueur et restaure 1% d'énergie.

@export var energy_value: float = 1.0
@export var float_speed: float = 2.0
@export var magnet_speed: float = 25.0
@export var magnet_range: float = 8.0 
@export var friction: float = 0.95 # Pour ralentir après l'éjection

var velocity: Vector3 = Vector3.ZERO
var _player_ref: Node3D = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Recherche du joueur
	_player_ref = get_tree().root.find_child("Player_VShmup", true, false)
	
	# Rotation aléatoire initiale
	rotation_degrees = Vector3(randf_range(0, 360), randf_range(0, 360), randf_range(0, 360))

func _process(delta: float) -> void:
	# Application de la vélocité actuelle (éjection + friction)
	global_position += velocity * delta
	velocity *= friction
	
	if _player_ref and is_instance_valid(_player_ref):
		var dist = global_position.distance_to(_player_ref.global_position)
		
		# Auto-collecte si très proche
		if dist < 1.0:
			_collect(_player_ref)
			return
			
		if dist < magnet_range:
			# Magnétisme (s'ajoute à la vélocité)
			var dir = (_player_ref.global_position - global_position).normalized()
			velocity = lerp(velocity, dir * magnet_speed, 5.0 * delta)
			# Rotation rapide
			rotate_y(10 * delta)
		else:
			# Petit mouvement lent
			rotate_x(delta)
			rotate_y(delta * 0.5)

func _on_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		_collect(body)

func _on_area_entered(area: Area3D) -> void:
	if area.name.contains("Player"):
		_collect(area)

func _collect(target: Node) -> void:
	if target.has_method("add_energy"):
		target.add_energy(energy_value)
	
	# TODO: Petit son ou effet
	queue_free()
