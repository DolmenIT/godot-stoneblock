@tool
@icon("res://stoneblock/icons/SB_BloomSelector3D.svg")
extends Node
class_name SB_BloomConfig

## ⚡ SB_BloomConfig : Contrôle simplifié du Bloom Sélectif via Shader Gaussian Blur.
## Résout les problèmes de rendu sur fond transparent en appliquant le flou directement sur le container.

## Activation globale du système de Bloom.
@export var bloom_enabled: bool = true:
	set(v):
		bloom_enabled = v
		_apply()

@export_group("Debug")
## Affiche ou masque les miniatures de débug en bas à gauche.
@export var debug_show_mini_views: bool = true:
	set(v):
		debug_show_mini_views = v
		_update_mini_views()

@export_group("Bloom Gaussian (Long - Layer 11)")
## Activer cette couche.
@export var bloom_long_enabled: bool = true:
	set(v): bloom_long_enabled = v; _apply()
## Luminosité globale du halo LONG.
@export_range(0.0, 8.0, 0.01) var bloom_long_intensity: float = 1.0:
	set(v):
		bloom_long_intensity = v
		_apply()
## Rayon du flou LONG (Réacteurs).
@export_range(0.0, 20.0, 0.01) var bloom_long_radius: float = 12.0:
	set(v):
		bloom_long_radius = v
		_apply()

@export_group("Bloom Gaussian (Med - Layer 12)")
## Activer cette couche.
@export var bloom_med_enabled: bool = true:
	set(v): bloom_med_enabled = v; _apply()
## Luminosité globale du halo MEDIUM.
@export_range(0.0, 8.0, 0.01) var bloom_med_intensity: float = 1.0:
	set(v):
		bloom_med_intensity = v
		_apply()
## Rayon du flou MEDIUM (Projectiles).
@export_range(0.0, 20.0, 0.01) var bloom_med_radius: float = 5.0:
	set(v):
		bloom_med_radius = v
		_apply()

@export_group("Bloom Gaussian (Short - Layer 13)")
## Activer cette couche.
@export var bloom_short_enabled: bool = true:
	set(v): bloom_short_enabled = v; _apply()
## Luminosité globale du halo SHORT.
@export_range(0.0, 8.0, 0.01) var bloom_short_intensity: float = 1.0:
	set(v):
		bloom_short_intensity = v
		_apply()
## Rayon du flou SHORT (Pickups).
@export_range(0.0, 20.0, 0.01) var bloom_short_radius: float = 2.0:
	set(v):
		bloom_short_radius = v
		_apply()

# --- Interne ---
# --- Interne ---
var _ready_done: bool = false
var _material_long: ShaderMaterial = null
var _material_med: ShaderMaterial = null
var _material_short: ShaderMaterial = null

func _ready() -> void:
	_ready_done = true
	_resolve_material()
	_apply()
	_update_mini_views()

func _update_mini_views() -> void:
	if not is_inside_tree(): return
	var root = get_tree().root
	for child in root.find_children("", "CanvasLayer", true, false):
		if "BloomMini" in child.name:
			child.visible = debug_show_mini_views

func _resolve_material() -> void:
	var root = get_tree().edited_scene_root if Engine.is_editor_hint() and get_tree().edited_scene_root else get_tree().root
	
	var c_long = _find_child_recursive(root, "BloomLongContainer") as SubViewportContainer
	var c_med = _find_child_recursive(root, "BloomMedContainer") as SubViewportContainer
	var c_short = _find_child_recursive(root, "BloomShortContainer") as SubViewportContainer

	if c_long: _material_long = c_long.material as ShaderMaterial
	if c_med: _material_med = c_med.material as ShaderMaterial
	if c_short: _material_short = c_short.material as ShaderMaterial

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
	
	if not _material_long or not _material_med or not _material_short:
		_resolve_material()
	
	var b_on = bloom_enabled
	if _material_long:
		_material_long.set_shader_parameter("blur_radius", bloom_long_radius if (b_on and bloom_long_enabled) else 0.0)
		_material_long.set_shader_parameter("bloom_intensity", bloom_long_intensity if (b_on and bloom_long_enabled) else 0.0)
	if _material_med:
		_material_med.set_shader_parameter("blur_radius", bloom_med_radius if (b_on and bloom_med_enabled) else 0.0)
		_material_med.set_shader_parameter("bloom_intensity", bloom_med_intensity if (b_on and bloom_med_enabled) else 0.0)
	if _material_short:
		_material_short.set_shader_parameter("blur_radius", bloom_short_radius if (b_on and bloom_short_enabled) else 0.0)
		_material_short.set_shader_parameter("bloom_intensity", bloom_short_intensity if (b_on and bloom_short_enabled) else 0.0)

## Optionnel : support de compatibilité pour le GameMode s'il appelle apply_to
func apply_to(_env: Environment) -> void:
	# On ignore l'environnement car on utilise le shader
	_apply()

func _resolve_and_apply() -> void:
	_resolve_material()
	_apply()
