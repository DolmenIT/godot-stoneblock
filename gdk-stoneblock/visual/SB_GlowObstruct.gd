@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_GlowObstruct
extends Node

## 🛡️ SB_GlowObstruct : Bloque la lumière du Bloom des objets situés derrière.
## Crée des duplicatas noirs (Unshaded Black) sur les calques 11, 12, 13 (bits 10, 11, 12).

@export var target_node: Node = null

const BLOOM_LAYERS = (1 << 10) | (1 << 11) | (1 << 12)

var _twins: Dictionary = {}

func _ready() -> void:
	if target_node == null:
		target_node = get_parent()
	_create_twins.call_deferred()

func _create_twins() -> void:
	if not is_inside_tree() or not is_instance_valid(target_node): return
	_clear_twins()
	
	var black_mat = StandardMaterial3D.new()
	black_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	black_mat.albedo_color = Color(0, 0, 0, 1) # Noir pur pour l'occlusion du bloom
	
	var meshes = _find_all_meshes(target_node)
	for mesh_inst in meshes:
		if is_instance_valid(mesh_inst) and mesh_inst.mesh:
			var twin = MeshInstance3D.new()
			twin.name = "Obstruct_" + str(mesh_inst.get_instance_id())
			twin.mesh = mesh_inst.mesh
			twin.material_override = black_mat
			twin.layers = BLOOM_LAYERS
			twin.global_transform = mesh_inst.global_transform
			add_child(twin)
			_twins[twin] = mesh_inst

func _find_all_meshes(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if not node: return result
	var stack = [node]
	while stack.size() > 0:
		var current = stack.pop_back()
		if current is MeshInstance3D:
			result.append(current)
		for child in current.get_children():
			stack.push_back(child)
	return result

func _process(_delta: float) -> void:
	# Synchronisation en temps réel des positions pour suivre les mouvements/animations
	var visible_state = true
	var p = get_parent()
	if p and p.has_method("is_visible_in_tree"):
		visible_state = p.is_visible_in_tree()
		
	for twin in _twins.keys():
		var orig = _twins[twin]
		if is_instance_valid(twin) and is_instance_valid(orig):
			twin.global_transform = orig.global_transform
			twin.visible = visible_state and orig.is_visible_in_tree()
		else:
			if is_instance_valid(twin):
				twin.queue_free()
			_twins.erase(twin)

func _exit_tree() -> void:
	_clear_twins()

func _clear_twins() -> void:
	for twin in _twins.keys():
		if is_instance_valid(twin):
			twin.queue_free()
	_twins.clear()
