@tool
extends Node
class_name SB_ViewportManager_VShmup

## 🚀 SB_ViewportManager_VShmup : Gère les SubViewports et la résolution dynamique.
## Ce composant est basé sur l'architecture de Cosmic HyperSquad.

# --- Configuration ---
@export_group("Resolution Scaling")
@export var background_max_scale: float = 1.0
@export var background_min_scale: float = 1.0
@export var mainground_max_scale: float = 1.0
@export var mainground_min_scale: float = 1.0
@export var bloom_max_scale: float = 0.5
@export var bloom_min_scale: float = 0.5
@export var ui_max_scale: float = 1.0
@export var ui_min_scale: float = 1.0

@export var target_fps: float = 60.0
@export var min_fps: float = 30.0

# --- Références ---
var background_viewport_container: SubViewportContainer
var background_viewport: SubViewport
var mainground_viewport_container: SubViewportContainer
var mainground_viewport: SubViewport
var bloom_viewport_container: SubViewportContainer
var bloom_viewport: SubViewport
var ui_viewport_container: SubViewportContainer
var ui_viewport: SubViewport

var _frame_counter: int = 0
var _update_interval: int = 10 

func initialize(
	_bg_vc: SubViewportContainer, _bg_vp: SubViewport,
	_mg_vc: SubViewportContainer, _mg_vp: SubViewport,
	_bl_vc: SubViewportContainer, _bl_vp: SubViewport,
	_ui_vc: SubViewportContainer, _ui_vp: SubViewport
) -> void:
	background_viewport_container = _bg_vc
	background_viewport = _bg_vp
	mainground_viewport_container = _mg_vc
	mainground_viewport = _mg_vp
	bloom_viewport_container = _bl_vc
	bloom_viewport = _bl_vp
	ui_viewport_container = _ui_vc
	ui_viewport = _ui_vp
	
	# Configuration automatique du redimensionnement
	if background_viewport_container: background_viewport_container.stretch = true
	if mainground_viewport_container: mainground_viewport_container.stretch = true
	if bloom_viewport_container: bloom_viewport_container.stretch = true
	if ui_viewport_container: ui_viewport_container.stretch = true
	
	# Mode de scaling Bilinéaire pour la performance
	if background_viewport: background_viewport.scaling_3d_mode = SubViewport.SCALING_3D_MODE_BILINEAR
	if mainground_viewport: mainground_viewport.scaling_3d_mode = SubViewport.SCALING_3D_MODE_BILINEAR
	if bloom_viewport: bloom_viewport.scaling_3d_mode = SubViewport.SCALING_3D_MODE_BILINEAR
	if ui_viewport: ui_viewport.scaling_3d_mode = SubViewport.SCALING_3D_MODE_BILINEAR

func apply_initial_scaling() -> void:
	_apply_scale(background_viewport, background_max_scale)
	_apply_scale(mainground_viewport, mainground_max_scale)
	_apply_scale(bloom_viewport, bloom_max_scale)
	_apply_scale(ui_viewport, ui_max_scale)

func update_dynamic_resolution() -> void:
	_frame_counter += 1
	if _frame_counter < _update_interval: return
	_frame_counter = 0
	
	var current_fps = Engine.get_frames_per_second()
	var t = clampf((current_fps - min_fps) / (target_fps - min_fps), 0.0, 1.0)
	
	_update_viewport_scale(background_viewport, background_min_scale, background_max_scale, t)
	_update_viewport_scale(mainground_viewport, mainground_min_scale, mainground_max_scale, t)
	_update_viewport_scale(bloom_viewport, bloom_min_scale, bloom_max_scale, t)
	_update_viewport_scale(ui_viewport, ui_min_scale, ui_max_scale, t)

func _update_viewport_scale(vp: SubViewport, min_s: float, max_s: float, t: float) -> void:
	if not vp: return
	var new_scale = lerpf(min_s, max_s, t)
	_apply_scale(vp, new_scale)

func _apply_scale(vp: SubViewport, scale_val: float) -> void:
	if not vp: return
	vp.scaling_3d_scale = clampf(scale_val, 0.1, 2.0)
