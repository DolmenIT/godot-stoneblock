@tool
@icon("res://stoneblock/icons/SB_BloomSelector3D.svg")
extends Node
class_name SB_BloomConfig

## ⚡ SB_BloomConfig : Contrôle simplifié du Bloom Sélectif via Shader Gaussian Blur.
## Résout les problèmes de rendu sur fond transparent en appliquant le flou directement sur le container.

@export var bloom_enabled: bool = true:
	set(v):
		bloom_enabled = v
		_apply()

@export_group("Bloom Gaussian")
## Luminosité globale du halo (multiplicateur final).
@export_range(0.0, 8.0, 0.1) var bloom_intensity: float = 3.0:
	set(v):
		bloom_intensity = v
		_apply()

## Rayon du flou en pixels (0.0 = net, 20.0 = très large).
@export_range(0.0, 20.0, 0.1) var bloom_radius: float = 1.2:
	set(v):
		bloom_radius = v
		_apply()

# --- Interne ---
var _ready_done: bool = false
var _shader_material: ShaderMaterial = null

func _ready() -> void:
	_ready_done = true
	_resolve_material()
	_apply()

func _resolve_material() -> void:
	var container: SubViewportContainer = null
	
	if Engine.is_editor_hint():
		var root = get_tree().edited_scene_root if get_tree().edited_scene_root else get_parent()
		container = _find_child_recursive(root, "BloomViewportContainer") as SubViewportContainer
	else:
		container = get_tree().root.find_child("BloomViewportContainer", true, false) as SubViewportContainer

	if container:
		_shader_material = container.material as ShaderMaterial

func _find_child_recursive(node: Node, name: String) -> Node:
	if node.name == name:
		return node
	for child in node.get_children():
		var result = _find_child_recursive(child, name)
		if result:
			return result
	return null

func _apply() -> void:
	if not _ready_done:
		return
	
	if not _shader_material:
		_resolve_material()
	
	if _shader_material:
		_shader_material.set_shader_parameter("blur_radius", bloom_radius if bloom_enabled else 0.0)
		_shader_material.set_shader_parameter("bloom_intensity", bloom_intensity if bloom_enabled else 0.0)

## Optionnel : support de compatibilité pour le GameMode s'il appelle apply_to
func apply_to(_env: Environment) -> void:
	# On ignore l'environnement car on utilise le shader
	_apply()

func _resolve_and_apply() -> void:
	_resolve_material()
	_apply()
