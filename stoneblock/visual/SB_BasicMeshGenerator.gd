@tool
extends Node3D
class_name SB_BasicMeshGenerator

## 🎨 SB_BasicMeshGenerator : Générateur de mesh basique procédural.
## Permet de peupler une scène avec des meshs configurables (taille, rotation, position, couleur).

@export_group("Génération")
## Modèle de mesh à utiliser (Prism, Cube, Capsule, etc.).
@export var mesh_template: Mesh
## Nœud cible (ex: un plan) pour définir la zone de spawn. Si vide, utilise area_size.
@export var target_node: MeshInstance3D
## Couleur de base appliquée aux éléments.
@export var base_color: Color = Color(0.2, 0.4, 0.8, 1.0)
## Nombre d'éléments à générer.
@export var count: int = 50
## Zone de spawn manuelle (utilisée si target_node est vide).
@export var area_size: Vector3 = Vector3(200, 1, 5000)

@export_group("Variations")
## Si vrai, utilise une échelle uniforme basée sur min_scale.x et max_scale.x.
@export var uniform_scale: bool = true
## Échelle minimale (utilisé x si uniforme).
@export var min_scale: Vector3 = Vector3(5.0, 5.0, 5.0)
## Échelle maximale (utilisé x si uniforme).
@export var max_scale: Vector3 = Vector3(15.0, 15.0, 15.0)
@export var min_rotation: Vector3 = Vector3(0, 0, 0)
@export var max_rotation: Vector3 = Vector3(360, 360, 360)

@export_group("Actions")
## Cliquer pour générer les éléments dans l'éditeur.
@export var generate_now: bool = false : set = _set_generate_now
## Cliquer pour supprimer tous les éléments générés.
@export var clear_all: bool = false : set = _set_clear_all

func _ready() -> void:
	if not Engine.is_editor_hint():
		generate()

func _set_generate_now(val: bool) -> void:
	if val:
		generate()
		generate_now = false

func _set_clear_all(val: bool) -> void:
	if val:
		clear()
		clear_all = false

## Supprime tous les MeshInstance3D enfants du générateur.
func clear() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.queue_free()

## Génère les éléments selon la configuration.
func generate() -> void:
	if not mesh_template:
		push_warning("[SB_BasicMeshGenerator] Aucun mesh_template assigné.")
		return
	
	# Calcul de la zone de spawn
	var spawn_origin = Vector3.ZERO
	var spawn_size = area_size
	
	if target_node:
		var aabb = target_node.get_aabb()
		# On utilise la transform globale pour convertir l'AABB locale en zone mondiale par rapport au générateur
		var global_center = target_node.global_transform * aabb.get_center()
		spawn_origin = to_local(global_center)
		spawn_size = aabb.size * target_node.global_transform.basis.get_scale()
	
	# Matériau partagé
	var mat = StandardMaterial3D.new()
	mat.albedo_color = base_color
	
	clear()
	
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	
	for i in range(count):
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh_template
		mesh_instance.material_override = mat
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF # Optimisation BG
		
		# Position aléatoire dans la zone calculée
		var pos = spawn_origin + Vector3(
			rand.randf_range(-spawn_size.x / 2.0, spawn_size.x / 2.0),
			rand.randf_range(-spawn_size.y / 2.0, spawn_size.y / 2.0),
			rand.randf_range(-spawn_size.z / 2.0, spawn_size.z / 2.0)
		)
		mesh_instance.position = pos
		
		# Rotation aléatoire
		mesh_instance.rotation_degrees = Vector3(
			rand.randf_range(min_rotation.x, max_rotation.x),
			rand.randf_range(min_rotation.y, max_rotation.y),
			rand.randf_range(min_rotation.z, max_rotation.z)
		)
		
		# Taille aléatoire
		if uniform_scale:
			var s = rand.randf_range(min_scale.x, max_scale.x)
			mesh_instance.scale = Vector3(s, s, s)
		else:
			mesh_instance.scale = Vector3(
				rand.randf_range(min_scale.x, max_scale.x),
				rand.randf_range(min_scale.y, max_scale.y),
				rand.randf_range(min_scale.z, max_scale.z)
			)
		
		add_child(mesh_instance)
		# IMPORTANT : On ne définit PAS d'owner pour que ces nœuds 
		# ne soient JAMAIS enregistrés dans la scène .tscn.
	
	print("[SB_BasicMeshGenerator] %d éléments générés à la volée." % count)
