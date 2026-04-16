@tool
@icon("res://stoneblock/icons/SB_BloomSelector3D.svg")
extends Node
class_name SB_BloomConfig

## ⚡ SB_BloomConfig : Contrôle simplifié du Bloom Sélectif (Version Épurée).

enum BlurQuality { FAST = 0, BALANCED = 1, ULTRA = 2 }

const SHADER_ADD = preload("res://stoneblock/shaders/SB_BloomBlur.gdshader")
const MINI_VIEW_SCRIPT = preload("res://stoneblock/visual/bloom/debug/SB_BloomMiniView.gd")

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
@export_subgroup("Long Oscillation")
@export var bloom_long_oscillate: bool = false
@export var bloom_long_min_radius: float = 4.0
@export var bloom_long_max_radius: float = 12.0
@export var bloom_long_pulse_frequency: float = 0.66
@export var bloom_long_tint: Color = Color.WHITE:
	set(v): bloom_long_tint = v; _apply()
@export_range(0.0, 4.0, 0.01) var bloom_long_saturation: float = 1.0:
	set(v): bloom_long_saturation = v; _apply()

@export_group("Bloom Medium (Layer 12)")
@export var bloom_med_enabled: bool = true:
	set(v): bloom_med_enabled = v; _apply()
@export var bloom_med_quality: BlurQuality = BlurQuality.BALANCED:
	set(v): bloom_med_quality = v; _apply()
@export_range(0.0, 8.0, 0.01) var bloom_med_intensity: float = 1.0:
	set(v): bloom_med_intensity = v; _apply()
@export_range(0.0, 20.0, 0.01) var bloom_med_radius: float = 4.0:
	set(v): bloom_med_radius = v; _apply()
@export_subgroup("Med Oscillation")
@export var bloom_med_oscillate: bool = false
@export var bloom_med_min_radius: float = 2.0
@export var bloom_med_max_radius: float = 8.0
@export var bloom_med_pulse_frequency: float = 1.0
@export var bloom_med_tint: Color = Color.WHITE:
	set(v): bloom_med_tint = v; _apply()
@export_range(0.0, 4.0, 0.01) var bloom_med_saturation: float = 1.0:
	set(v): bloom_med_saturation = v; _apply()

@export_group("Bloom Short (Layer 13)")
@export var bloom_short_enabled: bool = true:
	set(v): bloom_short_enabled = v; _apply()
@export var bloom_short_quality: BlurQuality = BlurQuality.FAST:
	set(v): bloom_short_quality = v; _apply()
@export_range(0.0, 8.0, 0.01) var bloom_short_intensity: float = 1.0:
	set(v): bloom_short_intensity = v; _apply()
@export_range(0.0, 20.0, 0.01) var bloom_short_radius: float = 2.0:
	set(v): bloom_short_radius = v; _apply()
@export_subgroup("Short Oscillation")
@export var bloom_short_oscillate: bool = false
@export var bloom_short_min_radius: float = 1.0
@export var bloom_short_max_radius: float = 4.0
@export var bloom_short_pulse_frequency: float = 2.0
@export var bloom_short_tint: Color = Color.WHITE:
	set(v): bloom_short_tint = v; _apply()
@export_range(0.0, 4.0, 0.01) var bloom_short_saturation: float = 1.0:
	set(v): bloom_short_saturation = v; _apply()

@export_group("Glow Natif Godot")
@export var enable_native_glow: bool = false:
	set(v): enable_native_glow = v; _apply()

var _time: float = 0.0

var _ready_done: bool = false
var _material_long: ShaderMaterial = null
var _material_med: ShaderMaterial = null
var _material_short: ShaderMaterial = null

func _ready() -> void:
	_ready_done = true
	_resolve_material()
	_apply()
	_update_mini_views()

func _process(delta: float) -> void:
	if not bloom_enabled: return
	
	var needs_update = bloom_long_oscillate or bloom_med_oscillate or bloom_short_oscillate
	if not needs_update: return
	
	_time += delta
	
	if bloom_long_oscillate and _material_long:
		var val = _get_pulse_value(_time, bloom_long_pulse_frequency, bloom_long_min_radius, bloom_long_max_radius)
		_material_long.set_shader_parameter("blur_radius", val)
		
	if bloom_med_oscillate and _material_med:
		var val = _get_pulse_value(_time, bloom_med_pulse_frequency, bloom_med_min_radius, bloom_med_max_radius)
		_material_med.set_shader_parameter("blur_radius", val)
		
	if bloom_short_oscillate and _material_short:
		var val = _get_pulse_value(_time, bloom_short_pulse_frequency, bloom_short_min_radius, bloom_short_max_radius)
		_material_short.set_shader_parameter("blur_radius", val)

func _get_pulse_value(t: float, frequency: float, v_min: float, v_max: float) -> float:
	var wave = (sin(t * (2.0 * PI * frequency)) + 1.0) / 2.0
	return lerp(v_min, v_max, wave)

func _update_mini_views() -> void:
	if not is_inside_tree() or not get_tree() or Engine.is_editor_hint(): return
	
	var root = get_tree().root
	var containers = ["BloomLongContainer", "BloomMedContainer", "BloomShortContainer"]
	var labels = ["BLOOM LONG (L11)", "BLOOM MED (L12)", "BLOOM SHORT (L13)"]
	
	for i in range(containers.size()):
		var m_name = "BloomMini_" + str(i)
		var existing = root.find_child(m_name, true, false)
		
		if debug_show_mini_views and not existing:
			# Création dynamique de la vue de debug
			var mini = CanvasLayer.new()
			mini.name = m_name
			# CRUCIAL : On passe sur le Layer 300 pour être devant TOUT (Hangar = 100)
			mini.layer = 300
			mini.set_script(MINI_VIEW_SCRIPT)
			
			# Configuration via le script
			mini.bloom_container_name = containers[i]
			mini.label_text = labels[i]
			mini.vertical_stack_index = i
			mini.width_divisor = 6.0
			
			root.add_child(mini)
			existing = mini
			
		if existing:
			existing.visible = debug_show_mini_views

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
	_apply_to_mat(_material_long, b_on and bloom_long_enabled, bloom_long_intensity, bloom_long_radius, bloom_long_quality, bloom_long_tint, bloom_long_saturation)
	_apply_to_mat(_material_med, b_on and bloom_med_enabled, bloom_med_intensity, bloom_med_radius, bloom_med_quality, bloom_med_tint, bloom_med_saturation)
	_apply_to_mat(_material_short, b_on and bloom_short_enabled, bloom_short_intensity, bloom_short_radius, bloom_short_quality, bloom_short_tint, bloom_short_saturation)

func _apply_to_mat(mat: ShaderMaterial, active: bool, intensity: float, radius: float, quality: int, tint: Color, saturation: float) -> void:
	if not is_instance_valid(mat): return
	
	mat.set_shader_parameter("blur_mode", int(quality))
	mat.set_shader_parameter("blur_radius", radius if active else 0.0)
	mat.set_shader_parameter("bloom_intensity", intensity if active else 0.0)
	mat.set_shader_parameter("bloom_tint", tint)
	mat.set_shader_parameter("saturation", saturation)

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
