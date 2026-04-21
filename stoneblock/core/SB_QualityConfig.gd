@tool
@icon("res://stoneblock/icons/SB_QualityConfig.svg")
extends Node
class_name SB_QualityConfig

## ⚙️ SB_QualityConfig : Centralisation des réglages de performance et qualité.
## Ce node permet de piloter la résolution dynamique et les paliers de Bloom.

# --- Global Quality ---
@export_group("Global Quality")
@export var startup_delay: float = 1.0
@export var interpolation_smoothness: float = 1.0

# --- Background Quality ---
@export_group("Background Quality")
@export var bg_target_fps: float = 60.0
@export var bg_min_fps: float = 30.0
@export_range(0.1, 1.0, 0.05) var bg_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var bg_min_scale: float = 0.5
@export var bg_quality_cadence: float = 0.1
@export var bg_quality_step: float = 0.01

# --- Mainground Quality ---
@export_group("Mainground Quality")
@export var mg_target_fps: float = 60.0
@export var mg_min_fps: float = 25.0
@export_range(0.1, 1.0, 0.05) var mg_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var mg_min_scale: float = 0.75
@export var mg_quality_cadence: float = 0.1
@export var mg_quality_step: float = 0.01

# --- Bloom Quality ---
@export_group("Bloom Quality")
@export var bloom_enabled: bool = true
@export var bloom_target_fps: float = 60.0
@export var bloom_min_fps: float = 40.0
@export_range(0.1, 1.0, 0.05) var bloom_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var bloom_min_scale: float = 0.25
@export var bl_quality_cadence: float = 0.1
@export var bl_quality_step: float = 0.01

@export_subgroup("Bloom Security (Ratchet)")
@export var bloom_lock_on_degrade: bool = true
@export var bloom_lock_delay: float = 3.0
@export var bloom_lock_max_hits: int = 3

@export_subgroup("Bloom Cascade Thresholds")
@export_range(0.1, 1.0, 0.01) var min_bloom_ultra: float = 0.75
@export_range(0.1, 1.0, 0.01) var min_bloom_balanced: float = 0.50
@export_range(0.1, 1.0, 0.01) var min_bloom_fast: float = 0.25
