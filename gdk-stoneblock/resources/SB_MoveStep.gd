@tool
@icon("res://gdk-stoneblock/assets/icons/SB_UI.svg")
extends Resource
class_name SB_MoveStep

## Une Ã©tape de mouvement individuelle pour le composant SB_Move3D.

@export var start_time: float = 0.0
@export var end_time: float = 1.0
@export var start_position: Vector3 = Vector3.ZERO

@export var use_bezier: bool = false:
	set(v):
		use_bezier = v
		notify_property_list_changed()

var control_offset_1: Vector3 = Vector3.ZERO
var control_offset_2: Vector3 = Vector3.ZERO

@export var end_position: Vector3 = Vector3.ONE
@export var transition_type: Tween.TransitionType = Tween.TRANS_LINEAR
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

@export_group("Trajectory Alignment")
@export var align_with_trajectory: bool = false
@export var rotation_speed: float = 12.0
@export var use_model_front: bool = false
@export var banking_amount: float = 0.0
## Fraction de l'Ã©tape utilisÃ©e pour calculer la tangente locale (0.01=prÃ©cis, 1.0=ligne droite entre start/end).
## Valeur recommandÃ©e : 0.02 Ã  0.1. Mettre 1.0 ignore la courbure Bezier.
## Distance en unitÃ©s monde (mÃ¨tres) utilisÃ©e pour calculer la tangente de la trajectoire.
## 1.0 = look-ahead d'1 mÃ¨tre devant la position courante sur la courbe.
@export_range(0.01, 50.0, 0.01, "suffix:m") var look_ahead_distance: float = 1.0

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	if use_bezier:
		props.append({
			"name": "Bezier Controls",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP,
			"hint_string": "control_"
		})
		props.append({
			"name": "control_offset_1",
			"type": Variant.Type.TYPE_VECTOR3,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		props.append({
			"name": "control_offset_2",
			"type": Variant.Type.TYPE_VECTOR3,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	else:
		props.append({
			"name": "control_offset_1",
			"type": Variant.Type.TYPE_VECTOR3,
			"usage": PROPERTY_USAGE_STORAGE # Toujours stockÃ© mais pas affichÃ©
		})
		props.append({
			"name": "control_offset_2",
			"type": Variant.Type.TYPE_VECTOR3,
			"usage": PROPERTY_USAGE_STORAGE # Toujours stockÃ© mais pas affichÃ©
		})
	return props
