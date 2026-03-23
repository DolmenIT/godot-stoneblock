@tool
class_name SB_LookAt
extends Node

## 👁️ SB_LookAt : Oriente le nœud parent vers une cible.
## Très utile pour les caméras, les tourelles ou les yeux de personnages.

@export_group("Cible")
## Le nœud 3D à regarder.
@export var target: Node3D
## Offset optionnel par rapport à la position de la cible.
@export var target_offset: Vector3 = Vector3.ZERO

@export_group("Suivi")
## Si vrai, le suivi sera fluide au lieu d'instantané.
@export var smooth: bool = false
## Vitesse du lissage (plus c'est haut, plus c'est rapide).
@export var lerp_speed: float = 5.0
## Désactiver pour ne pas orienter l'axe Y (garde l'objet droit).
@export var use_y_axis: bool = true

func _process(delta: float) -> void:
	if not target: return
	
	var parent = get_parent() as Node3D
	if not parent: return
	
	var target_pos = target.global_position + target_offset
	
	if not smooth:
		parent.look_at(target_pos)
	else:
		_smooth_look_at(parent, target_pos, delta)

func _smooth_look_at(parent: Node3D, target_pos: Vector3, delta: float) -> void:
	# On regarde temporairement la cible pour obtenir la rotation finale
	var original_transform = parent.global_transform
	parent.look_at(target_pos)
	var target_transform = parent.global_transform
	parent.global_transform = original_transform
	
	# Interpolation sphérique (Slerp) pour un mouvement fluide
	var q_from = parent.global_transform.basis.get_rotation_quaternion()
	var q_to = target_transform.basis.get_rotation_quaternion()
	var q_result = q_from.slerp(q_to, lerp_speed * delta)
	
	parent.global_basis = Basis(q_result)
