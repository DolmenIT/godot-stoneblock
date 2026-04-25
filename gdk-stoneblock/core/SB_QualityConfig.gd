@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
extends SB_Config
class_name SB_QualityConfig

## ⚙️ SB_QualityConfig : Contrôles d'instance pour la qualité et la résolution.
## Ce node permet de forcer des paramètres spécifiques pour une scène donnée.

# --- Accès Statique (Singleton Optionnel) ---
static var instance: SB_QualityConfig

# --- Global Quality ---
enum DisplayPreset { VERY_LOW, LOW, MEDIUM, ULTRA, CUSTOM }
enum EffectPreset { VERY_LOW, LOW, MEDIUM, ULTRA, CUSTOM }
enum BloomMode { OFF, FAST, BALANCED, ULTRA }

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		instance = self

## Qualité de l'affichage (Echelles de résolution).
@export var display_preset: DisplayPreset = DisplayPreset.CUSTOM:
	set(v):
		display_preset = v
		_apply_display_preset(v)

## Qualité des effets visuels (Flous, Bloom, etc).
@export var effect_preset: EffectPreset = EffectPreset.CUSTOM:
	set(v):
		effect_preset = v
		_apply_effect_preset(v)


@export_group("Scales Overrides")
@export var force_bg_scale: bool = false
@export_range(0.1, 1.0, 0.01) var forced_bg_scale: float = 1.0

@export var force_mg_scale: bool = false
@export_range(0.1, 1.0, 0.01) var forced_mg_scale: float = 1.0

@export var force_bloom_scale: bool = false
@export_range(0.1, 1.0, 0.01) var forced_bloom_scale: float = 1.0

@export_group("Effects Overrides")
@export var force_bloom_mode: bool = false
@export var forced_bloom_mode: BloomMode = BloomMode.ULTRA


func _apply_display_preset(p: DisplayPreset) -> void:
	if p == DisplayPreset.CUSTOM:
		return
		
	match p:
		DisplayPreset.VERY_LOW:
			force_bg_scale = true
			forced_bg_scale = 0.6
			force_mg_scale = true
			forced_mg_scale = 0.7
		DisplayPreset.LOW:
			force_bg_scale = true
			forced_bg_scale = 0.7
			force_mg_scale = true
			forced_mg_scale = 0.8
		DisplayPreset.MEDIUM:
			force_bg_scale = true
			forced_bg_scale = 0.8
			force_mg_scale = true
			forced_mg_scale = 0.9
		DisplayPreset.ULTRA:
			force_bg_scale = true
			forced_bg_scale = 1.0
			force_mg_scale = true
			forced_mg_scale = 1.0
			
	notify_property_list_changed()

func _apply_effect_preset(p: EffectPreset) -> void:
	if p == EffectPreset.CUSTOM:
		return
		
	match p:
		EffectPreset.VERY_LOW:
			force_bloom_scale = true
			forced_bloom_scale = 0.5
			force_bloom_mode = true
			forced_bloom_mode = BloomMode.OFF
		EffectPreset.LOW:
			force_bloom_scale = true
			forced_bloom_scale = 0.6
			force_bloom_mode = true
			forced_bloom_mode = BloomMode.FAST
		EffectPreset.MEDIUM:
			force_bloom_scale = true
			forced_bloom_scale = 0.7
			force_bloom_mode = true
			forced_bloom_mode = BloomMode.BALANCED
		EffectPreset.ULTRA:
			force_bloom_scale = true
			forced_bloom_scale = 1.0
			force_bloom_mode = true
			forced_bloom_mode = BloomMode.ULTRA
			
	notify_property_list_changed()
