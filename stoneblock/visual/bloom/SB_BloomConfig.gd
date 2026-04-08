@tool
@icon("res://stoneblock/icons/SB_BloomSelector3D.svg")
extends Node
class_name SB_BloomConfig

## ⚡ SB_BloomConfig : Contrôle simplifié du Bloom Sélectif (Version Épurée).

enum BlurQuality { FAST = 0, BALANCED = 1, ULTRA = 2 }

const SHADER_ADD = preload("res://stoneblock/shaders/SB_BloomBlur.gdshader")

@export var bloom_enabled: bool = true:
	set(v): bloom_enabled = v; _apply()

@export_group("Debug")
@export var debug_show_mini_views: bool = true:
	set(v): debug_show_mini_views = v; _update_mini_views()

@export_group("Bloom Long (Layer 11)")
@export var bloom_long_enabled: bool = true:
	set(v): bloom_long_enabled = v; _apply()
@export var bloom_long_quality: BlurQuality = BlurQuality.ULTRA:
	set(v): bloom_long_quality = v; _apply()
@export_range(0.0, 8.0, 0.01) var bloom_long_intensity: float = 1.0:
	set(v): bloom_long_intensity = v; _apply()
@export_range(0.0, 20.0, 0.01) var bloom_long_radius: float = 8.0:
	set(v): bloom_long_radius = v; _apply()

@export_group("Bloom Medium (Layer 12)")
@export var bloom_med_enabled: bool = true:
	set(v): bloom_med_enabled = v; _apply()
@export var bloom_med_quality: BlurQuality = BlurQuality.BALANCED:
	set(v): bloom_med_quality = v; _apply()
@export_range(0.0, 8.0, 0.01) var bloom_med_intensity: float = 1.0:
	set(v): bloom_med_intensity = v; _apply()
@export_range(0.0, 20.0, 0.01) var bloom_med_radius: float = 4.0:
	set(v): bloom_med_radius = v; _apply()

@export_group("Bloom Short (Layer 13)")
@export var bloom_short_enabled: bool = true:
	set(v): bloom_short_enabled = v; _apply()
@export var bloom_short_quality: BlurQuality = BlurQuality.FAST:
	set(v): bloom_short_quality = v; _apply()
@export_range(0.0, 8.0, 0.01) var bloom_short_intensity: float = 1.0:
	set(v): bloom_short_intensity = v; _apply()
@export_range(0.0, 20.0, 0.01) var bloom_short_radius: float = 2.0:
	set(v): bloom_short_radius = v; _apply()

@export_group("Glow Natif Godot")
@export var enable_native_glow: bool = false:
	set(v): enable_native_glow = v; _apply()

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
	if not is_inside_tree() or not get_tree(): return
	var root = get_tree().root
	for child in root.find_children("", "CanvasLayer", true, false):
		if "BloomMini" in child.name:
			child.visible = debug_show_mini_views

func _resolve_material() -> void:
	if not is_inside_tree() or not get_tree(): return
	var config_root = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().root
	if not config_root: return
	
	var c_long = config_root.find_child("BloomLongContainer", true, false) as SubViewportContainer
	var c_med = config_root.find_child("BloomMedContainer", true, false) as SubViewportContainer
	var c_short = config_root.find_child("BloomShortContainer", true, false) as SubViewportContainer

	if c_long: _material_long = c_long.material as ShaderMaterial
	if c_med: _material_med = c_med.material as ShaderMaterial
	if c_short: _material_short = c_short.material as ShaderMaterial

func assign_materials(long: ShaderMaterial, med: ShaderMaterial, short: ShaderMaterial) -> void:
	_material_long = long
	_material_med = med
	_material_short = short
	_resolve_material()
	_apply_internal()

func _apply() -> void:
	_apply_internal()
	_apply_to_env()

func _apply_internal() -> void:
	if not _ready_done: return
	if not _material_long or not _material_med or not _material_short:
		_resolve_material()
	
	var b_on = bloom_enabled
	
	# Mise à jour simplifiée
	_apply_to_mat(_material_long, b_on and bloom_long_enabled, bloom_long_intensity, bloom_long_radius, bloom_long_quality)
	_apply_to_mat(_material_med, b_on and bloom_med_enabled, bloom_med_intensity, bloom_med_radius, bloom_med_quality)
	_apply_to_mat(_material_short, b_on and bloom_short_enabled, bloom_short_intensity, bloom_short_radius, bloom_short_quality)

func _apply_to_mat(mat: ShaderMaterial, active: bool, intensity: float, radius: float, quality: int) -> void:
	if not is_instance_valid(mat): return
	
	mat.set_shader_parameter("blur_mode", int(quality))
	mat.set_shader_parameter("blur_radius", radius if active else 0.0)
	mat.set_shader_parameter("bloom_intensity", intensity if active else 0.0)

func _apply_to_env() -> void:
	if not is_inside_tree() or not get_tree(): return
	var root = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().root
	if not root: return
	
	var mg_v = root.find_child("MaingroundViewport", true, false)
	if mg_v is SubViewport:
		mg_v.transparent_bg = true
		mg_v.use_hdr_2d = false 
	
	var env_n = root.find_child("WorldEnvironment", true, false)
	if env_n and env_n.environment:
		var env = env_n.environment
		env.glow_enabled = enable_native_glow
		env.background_mode = Environment.BG_CANVAS
		env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
		env.tonemap_exposure = 1.0
		env.ambient_light_energy = 1.0

func _resolve_and_apply() -> void:
	_resolve_material()
	_apply()
