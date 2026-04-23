@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_Bloom_Theme
extends SB_BaseStyle

## 🌈 SB_Bloom_Theme : Définition des paramètres de Bloom pour le ThemeManager.

enum BlurQuality { FAST = 0, BALANCED = 1, ULTRA = 2 }

@export_group("Configuration Globale")
@export var bloom_enabled: bool = true

@export_group("Bloom Long (Layer 11)")
@export var bloom_long_enabled: bool = true
@export var bloom_long_quality: BlurQuality = BlurQuality.BALANCED
@export_range(0.0, 8.0, 0.01) var bloom_long_intensity: float = 0.6
@export_range(0.0, 30.0, 0.01) var bloom_long_radius: float = 11.5
@export var bloom_long_tint: Color = Color.WHITE
@export_range(0.0, 4.0, 0.01) var bloom_long_saturation: float = 0.6
@export_subgroup("Long Oscillation")
@export var bloom_long_oscillate: bool = true
@export var bloom_long_min_radius: float = 3.0
@export var bloom_long_max_radius: float = 20.0
@export var bloom_long_pulse_frequency: float = 1.0

@export_group("Bloom Medium (Layer 12)")
@export var bloom_med_enabled: bool = true
@export var bloom_med_quality: BlurQuality = BlurQuality.BALANCED
@export_range(0.0, 8.0, 0.01) var bloom_med_intensity: float = 0.5
@export_range(0.0, 30.0, 0.01) var bloom_med_radius: float = 8.5
@export var bloom_med_tint: Color = Color.WHITE
@export_range(0.0, 4.0, 0.01) var bloom_med_saturation: float = 0.5
@export_subgroup("Med Oscillation")
@export var bloom_med_oscillate: bool = true
@export var bloom_med_min_radius: float = 2.0
@export var bloom_med_max_radius: float = 15.0
@export var bloom_med_pulse_frequency: float = 0.9

@export_group("Bloom Short (Layer 13)")
@export var bloom_short_enabled: bool = true
@export var bloom_short_quality: BlurQuality = BlurQuality.BALANCED
@export_range(0.0, 8.0, 0.01) var bloom_short_intensity: float = 0.4
@export_range(0.0, 30.0, 0.01) var bloom_short_radius: float = 5.5
@export var bloom_short_tint: Color = Color.WHITE
@export_range(0.0, 4.0, 0.01) var bloom_short_saturation: float = 0.4
@export_subgroup("Short Oscillation")
@export var bloom_short_oscillate: bool = true
@export var bloom_short_min_radius: float = 1.0
@export var bloom_short_max_radius: float = 10.0
@export var bloom_short_pulse_frequency: float = 0.8

@export_group("Glow Natif Godot")
@export var enable_native_glow: bool = false

func _init() -> void:
	target_class_name = "SB_BloomConfig"
