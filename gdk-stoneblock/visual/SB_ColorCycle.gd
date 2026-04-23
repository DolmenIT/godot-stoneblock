@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_ColorCycle
extends SB_2_World

## 🌈 SB_ColorCycle : Fait varier la couleur d'un MeshInstance3D de manière cyclique.
## Supporte le cycle arc-en-ciel (HSL) ou une liste de couleurs définie.

@export_group("Cycle Settings")
## Vitesse du cycle (en secondes pour un tour complet).
@export var cycle_duration: float = 3.0
## Intensité de la couleur (multiplicateur).
@export var intensity: float = 1.0

@export_group("Target")
## Le nœud à colorer (Mesh ou parent d'un groupe de Meshes). Si vide, utilise le parent.
@export var target_node: Node3D

var _meshes: Array[MeshInstance3D] = []
var _elapsed_time: float = 0.0

func _ready() -> void:
	if not target_node and get_parent() is Node3D:
		target_node = get_parent()
	
	_refresh_mesh_cache()

func _refresh_mesh_cache() -> void:
	_meshes.clear()
	if not target_node: return
	
	if target_node is MeshInstance3D:
		_meshes.append(target_node)
	
	# Recherche récursive des maillages enfants (pour les modèles complexes)
	_find_meshes_recursive(target_node)

func _find_meshes_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			_meshes.append(child)
		_find_meshes_recursive(child)

func _process(delta: float) -> void:
	if _meshes.is_empty():
		return
		
	_elapsed_time += delta
	var t = fmod(_elapsed_time / cycle_duration, 1.0)
	
	# Création d'une couleur arc-en-ciel via HSL
	var color = Color.from_hsv(t, 0.8, 0.9)
	color *= intensity
	
	# Application à tous les maillages trouvés
	for mesh in _meshes:
		if not is_instance_valid(mesh): continue
		
		for i in range(mesh.get_surface_override_material_count()):
			var mat = mesh.get_active_material(i)
			_apply_color_to_material(mat, color)

func _apply_color_to_material(mat: Material, color: Color) -> void:
	if mat is StandardMaterial3D:
		mat.albedo_color = color
		# Si l'intensité est > 1, on active l'émission pour faire briller
		if intensity > 1.0:
			mat.emission_enabled = true
			mat.emission = color
			mat.emission_energy_multiplier = intensity
	elif mat is ShaderMaterial:
		# On tente les paramètres courants (silencieux si inexistant en Godot 4)
		mat.set_shader_parameter("albedo", color)
		mat.set_shader_parameter("base_color", color)
		
		# Support de l'émission dans les shaders StoneBlock
		mat.set_shader_parameter("emission_color", color)
		mat.set_shader_parameter("emission_energy", intensity)
		mat.set_shader_parameter("intensity", intensity)
