extends Label3D
class_name SB_FloatingText_VShmup

## ✉️ SB_FloatingText : Texte flottant (Version Caméra Orthographique).

@export_group("Animation Échelle")
@export var min_scale: float = 0.5 
@export var max_pop_scale: float = 1.8 
@export var final_scale: float = 1.1

@export_group("Animation Mouvement")
@export var duration: float = 1.0
@export var lift_height: float = 4.5 
@export var spread_angle: float = 45.0 

@export_group("Animation Rotation")
@export var use_orbital_rotation: bool = true
# L'inclinaison vers la caméra (X) pour la lisibilité depuis une vue plongeante
@export var camera_tilt_degrees: float = -60.0

var _start_pos: Vector3
var _target_angle: float

func _ready() -> void:
	# Le texte est indépendant pour éviter les problèmes de coordonnées
	top_level = true
	fixed_size = false
	render_priority = 100
	
	# Billboard désactivé pour permettre de pivoter manuellement sur l'axe Y
	billboard = BaseMaterial3D.BILLBOARD_DISABLED 
	
	# Inclinaison fixe vers la caméra sur l'axe X
	rotation_degrees.x = camera_tilt_degrees
	# On s'assure que Z (inclinaison latérale) reste à zéro
	rotation_degrees.z = 0 
	
	scale = Vector3.ONE * min_scale
	modulate.a = 0.0

## Initialisation appelée par l'ennemi (Position & Texte)
func setup(text_val: String, color_val: Color = Color("#FFCC00")) -> void:
	text = text_val
	modulate = color_val
	
	# Altitude initiale
	global_position.y += 4.5
	
	# Point pivot et angle cible
	_start_pos = global_position
	_target_angle = deg_to_rad(randf_range(-spread_angle, spread_angle))
	
	_start_animation()

func _start_animation() -> void:
	var tween = create_tween().set_parallel(true)
	
	# 1. Trajectoire en Arc (Mouvement orbital)
	tween.tween_method(_animate_trajectory, 0.0, 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 2. Pop Échelle
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector3.ONE * max_pop_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", Vector3.ONE * final_scale, 0.2)
	
	# 3. Fade
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	var fade_out = create_tween()
	fade_out.tween_interval(duration * 0.7)
	fade_out.tween_property(self, "modulate:a", 0.0, duration * 0.3)
	fade_out.tween_callback(queue_free)

## Calcul de la position et de la rotation sur l'axe Y à chaque frame
func _animate_trajectory(progress: float) -> void:
	var current_radius = progress * lift_height
	var current_angle = progress * _target_angle
	
	# Position sur l'arc (Plan X/Z du monde)
	var offset = Vector3(
		sin(current_angle) * current_radius,
		progress * 2.5, # Ascension sur Y
		-cos(current_angle) * current_radius
	)
	
	global_position = _start_pos + offset
	
	# ROTATION : Pivotement uniquement sur l'axe Y (Plan du sol)
	if use_orbital_rotation:
		# Inversion du signe pour s'aligner correctement sur la trajectoire (Sens horaire Godot)
		rotation_degrees.y = -rad_to_deg(current_angle)
