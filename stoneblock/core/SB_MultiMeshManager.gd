@tool
extends Node3D
class_name SB_MultiMeshManager

## 🚀 SB_MultiMeshManager : Centralise le rendu des objets identiques (Ennemis, Projectiles).
## Réduit drastiquement les Draw Calls en utilisant MultiMeshInstance3D.

# Dictionnaire des MultiMeshes actifs. Clé : RID_Mesh + RID_Mat + LayerMask
var _mm_instances: Dictionary = {}

# Registre des objets enregistrés. Clé : Instance ID de l'objet, Valeur : { "mm_inst": MultiMeshInstance3D, "index": int }
var _registry: Dictionary = {}

# Liste des index libres par MultiMesh. Clé : RID du MultiMeshInstance3D, Valeur : Array d'indices
var _free_indices: Dictionary = {}

static var instance: SB_MultiMeshManager

func _enter_tree() -> void:
	instance = self

func _exit_tree() -> void:
	if instance == self:
		instance = null

## Enregistre un objet pour le rendu MultiMesh.
## Retourne l'instance MultiMeshInstance3D utilisée, ou null en cas d'échec.
func register(obj: Node3D, mesh: Mesh, material: Material = null, layer_mask: int = 1) -> MultiMeshInstance3D:
	if not mesh: return null
	
	# La clé inclut désormais le matériau pour préserver les couleurs (ex: Scouts - IP-115)
	var mat_id = material.get_rid().get_id() if material else 0
	var key = str(mesh.get_rid().get_id()) + "_" + str(mat_id) + "_" + str(layer_mask)
	var mm_inst: MultiMeshInstance3D
	
	if not _mm_instances.has(key):
		mm_inst = _create_multimesh_instance(mesh, material, layer_mask)
		_mm_instances[key] = mm_inst
		_free_indices[mm_inst.get_rid()] = []
		_resize_multimesh(mm_inst, 64) # Réserve initiale
	else:
		mm_inst = _mm_instances[key]
	
	var mm = mm_inst.multimesh
	var mm_rid = mm_inst.get_rid()
	var index: int
	
	if not _free_indices[mm_rid].is_empty():
		index = _free_indices[mm_rid].pop_back()
	else:
		index = mm.visible_instance_count
		if index >= mm.instance_count:
			_resize_multimesh(mm_inst, mm.instance_count * 2)
		mm.visible_instance_count += 1
	
	_registry[obj.get_instance_id()] = { "mm_inst": mm_inst, "index": index }
	
	# Initialisation
	mm.set_instance_transform(index, obj.global_transform)
	# Par défaut, pas de flash (Custom Data .x = intensité, .yzw = couleur ou autre)
	mm.set_instance_custom_data(index, Color(0, 0, 0, 0)) 
	
	return mm_inst

## Met à jour le transform d'un objet.
func update_transform(obj: Node3D) -> void:
	var id = obj.get_instance_id()
	if not _registry.has(id): return
	
	var data = _registry[id]
	data["mm_inst"].multimesh.set_instance_transform(data["index"], obj.global_transform)

## Définit l'intensité et la couleur du flash pour une instance (IP-115).
## Le shader doit utiliser INSTANCE_CUSTOM pour lire ces valeurs.
func set_instance_flash(obj: Node3D, intensity: float, color: Color = Color.WHITE) -> void:
	var id = obj.get_instance_id()
	if not _registry.has(id): return
	
	var data = _registry[id]
	# On stocke l'intensité dans le canal R de la custom data (Color est utilisé comme vec4)
	var custom = Color(intensity, color.r, color.g, color.b)
	data["mm_inst"].multimesh.set_instance_custom_data(data["index"], custom)

## Retire un objet du rendu MultiMesh.
func unregister(obj: Node3D) -> void:
	var id = obj.get_instance_id()
	if not _registry.has(id): return
	
	var data = _registry[id]
	var mm_inst = data["mm_inst"]
	var index = data["index"]
	
	# On cache l'instance
	mm_inst.multimesh.set_instance_transform(index, Transform3D().scaled(Vector3.ZERO))
	
	_free_indices[mm_inst.get_rid()].append(index)
	_registry.erase(id)

func _create_multimesh_instance(mesh: Mesh, material: Material, layer_mask: int) -> MultiMeshInstance3D:
	var mm_inst = MultiMeshInstance3D.new()
	mm_inst.name = "MM_" + (mesh.resource_name if mesh.resource_name else "Vessel")
	add_child(mm_inst)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true # Requis pour le flash !
	mm.mesh = mesh
	mm_inst.multimesh = mm
	
	if material:
		mm_inst.material_override = material
		
	mm_inst.layers = layer_mask
	return mm_inst

## Optimisation du redimensionnement via buffer direct (plus rapide que get_instance_transform en boucle)
func _resize_multimesh(mm_inst: MultiMeshInstance3D, new_size: int) -> void:
	var mm = mm_inst.multimesh
	var old_count = mm.instance_count
	
	# En Godot 4, changer instance_count sur un MultiMesh préserve les données existantes.
	# Mais on doit s'assurer que les nouvelles instances sont "cachées" (scale 0)
	mm.instance_count = new_size
	
	for i in range(old_count, new_size):
		mm.set_instance_transform(i, Transform3D().scaled(Vector3.ZERO))
		mm.set_instance_custom_data(i, Color(0, 0, 0, 0))

func set_instance_color(obj: Node3D, color: Color) -> void:
	var id = obj.get_instance_id()
	if not _registry.has(id): return
	
	var data = _registry[id]
	var mm = data["mm_inst"].multimesh
	if mm.use_colors:
		mm.set_instance_color(data["index"], color)
