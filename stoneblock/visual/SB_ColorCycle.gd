@tool
class_name SB_ColorCycle
extends Node

## 🌈 SB_ColorCycle : Fait varier la couleur d'un MeshInstance3D de manière cyclique.
## Supporte le cycle arc-en-ciel (HSL) ou une liste de couleurs définie.

@export_group("Cycle Settings")
## Vitesse du cycle (en secondes pour un tour complet).
@export var cycle_duration: float = 3.0
## Intensité de la couleur (multiplicateur).
@export var intensity: float = 1.0

@export_group("Target")
## Le MeshInstance3D à colorer. Si vide, utilise le parent.
@export var mesh_instance: MeshInstance3D

var _elapsed_time: float = 0.0

func _ready() -> void:
	if not mesh_instance and get_parent() is MeshInstance3D:
		mesh_instance = get_parent()

func _process(delta: float) -> void:
	if not mesh_instance:
		return
		
	_elapsed_time += delta
	var t = fmod(_elapsed_time / cycle_duration, 1.0)
	
	# Création d'une couleur arc-en-ciel via HSL
	var color = Color.from_hsv(t, 0.8, 0.9)
	color *= intensity
	
	# Application au matériau (premier slot)
	var mat = mesh_instance.get_active_material(0)
	if mat is StandardMaterial3D:
		mat.albedo_color = color
	elif mat is ShaderMaterial:
		mat.set_shader_parameter("albedo", color)
