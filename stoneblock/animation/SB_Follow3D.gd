@tool
@icon("res://stoneblock/icons/SB_Follow3D.svg")
class_name SB_Follow3D
extends Node

## Permet à un objet 3D d'en suivre un autre à une distance précise.

@export_group("Target")
## Le nœud 3D à déplacer. Si vide, utilise le parent.
@export var target_node: Node3D
## L'objet à suivre.
@export var follow_target: Node3D

enum FollowMode { DISTANCE, OFFSET }

@export_group("Settings")
## Mode de suivi : DISTANCE (sphérique) ou OFFSET (décalage fixe).
@export var follow_mode: FollowMode = FollowMode.DISTANCE
## Décalage fixe (utilisé si mode = OFFSET).
@export var offset: Vector3 = Vector3(0, 2, 10)
## Distance maintenue avec la cible (utilisé si mode = DISTANCE).
@export var distance: float = 10.0
## Si vrai, garde la distance sur tous les axes (sphérique). Sinon, ignore l'axe Y.
@export var use_3d_distance: bool = true
## Vitesse de lissage du mouvement (0 = instantané).
@export var smooth_speed: float = 5.0
## Si vrai, l'objet regarde toujours la cible.
@export var look_at_target: bool = false

func _ready() -> void:
	if not target_node and get_parent() is Node3D:
		target_node = get_parent()
	
	# Initialiser l'offset si on est en mode OFFSET au départ
	if follow_mode == FollowMode.OFFSET and target_node and follow_target:
		offset = target_node.global_position - follow_target.global_position

func _process(delta: float) -> void:
	if not target_node or not follow_target:
		return
		
	var target_pos = follow_target.global_position
	var current_pos = target_node.global_position
	var desired_pos = Vector3.ZERO
	
	if follow_mode == FollowMode.DISTANCE:
		# Calcul de la direction basé sur la position actuelle
		var diff = current_pos - target_pos
		if not use_3d_distance:
			diff.y = 0
			
		var current_distance = diff.length()
		
		if current_distance == 0:
			diff = Vector3.BACK 
			current_distance = 0.001
			
		var direction = diff.normalized()
		desired_pos = target_pos + (direction * distance)
		
		if not use_3d_distance:
			desired_pos.y = current_pos.y
	else:
		# Mode OFFSET : Le décalage est constant (déplacement sur un plan)
		desired_pos = target_pos + offset

	# Application du mouvement
	if smooth_speed > 0:
		target_node.global_position = target_node.global_position.lerp(desired_pos, smooth_speed * delta)
	else:
		target_node.global_position = desired_pos
		
	# Orientation
	if look_at_target:
		target_node.look_at(target_pos)
