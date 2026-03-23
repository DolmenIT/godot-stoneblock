@tool
class_name SB_Rotate3D
extends Node

## 🔄 SB_Rotate3D : Rotation continue simple pour objets 3D.
## Idéal pour des pickups, des éléments de décor ou des démos.

@export_group("Rotation Settings")
## Vitesse de rotation par axe (en degrés par seconde).
@export var rotation_speed: Vector3 = Vector3(0, 90, 0)
## Si vrai, la rotation est active.
@export var active: bool = true

@export_group("Target")
## Le nœud à faire tourner. Si vide, utilise le parent.
@export var target_node: Node3D

func _ready() -> void:
	if not target_node and get_parent() is Node3D:
		target_node = get_parent()

func _process(delta: float) -> void:
	if not active or not target_node:
		return
		
	# Conversion des degrés en radians pour la rotation
	var rot_rad = Vector3(
		deg_to_rad(rotation_speed.x),
		deg_to_rad(rotation_speed.y),
		deg_to_rad(rotation_speed.z)
	)
	
	target_node.rotate_x(rot_rad.x * delta)
	target_node.rotate_y(rot_rad.y * delta)
	target_node.rotate_z(rot_rad.z * delta)
