@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Animation.svg")
class_name SB_Rotate3D
extends SB_4_Gameplay

## 🔄 SB_Rotate3D : Rotation d'objets 3D.
## Supporte la rotation continue (idle) et la rotation animée (barrel roll).

@export_group("Continuous Rotation")
## Vitesse de rotation par axe (en degrés par seconde).
@export var rotation_speed: Vector3 = Vector3(0, 90, 0)
## Si vrai, la rotation continue est active.
@export var active: bool = true

@export_group("Animation (One Shot)")
## Si vrai, la rotation se fait via une animation précise déclenchée par start().
@export var one_shot: bool = false
## Durée de l'animation en secondes.
@export var duration: float = 0.5
## Rotation totale à effectuer (en degrés). Ex: 360 sur Z pour un tonneau.
@export var animation_degrees: Vector3 = Vector3(0, 0, 360)

@export_group("Target")
## Le nœud à faire tourner. Si vide, utilise le parent.
@export var target_node: Node3D

func _ready() -> void:
	if not target_node and get_parent() is Node3D:
		target_node = get_parent()

func start() -> void:
	if not target_node: return
	
	if one_shot:
		var tween = create_tween()
		var rot_rad = Vector3(
			deg_to_rad(animation_degrees.x),
			deg_to_rad(animation_degrees.y),
			deg_to_rad(animation_degrees.z)
		)
		var target_rot = target_node.rotation + rot_rad
		
		tween.tween_property(target_node, "rotation", target_rot, duration)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	if one_shot or not active or not target_node:
		return
		
	# Conversion des degrés en radians pour la rotation continue
	var rot_rad = Vector3(
		deg_to_rad(rotation_speed.x),
		deg_to_rad(rotation_speed.y),
		deg_to_rad(rotation_speed.z)
	)
	
	target_node.rotate_x(rot_rad.x * delta)
	target_node.rotate_y(rot_rad.y * delta)
	target_node.rotate_z(rot_rad.z * delta)
