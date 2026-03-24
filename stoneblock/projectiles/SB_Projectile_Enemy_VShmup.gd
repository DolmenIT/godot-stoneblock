extends Area3D
class_name SB_Projectile_Enemy_VShmup

## ☄️ SB_Projectile_Enemy_VShmup : Projectile tiré par les ennemis.
## Inflige des dégâts au bouclier du joueur.

@export var speed: float = 40.0
@export var damage: float = 10.0
@export var direction: Vector3 = Vector3(0, 0, 1) # Vers le bas

var _total_time: float = 0.0
var _life_time: float = 5.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	_total_time += delta
	if _total_time > _life_time:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	# Si collision avec un projectile joueur (Contre-tir ?)
	if area.name.contains("Projectile") and not area is SB_Projectile_Enemy_VShmup:
		queue_free()
