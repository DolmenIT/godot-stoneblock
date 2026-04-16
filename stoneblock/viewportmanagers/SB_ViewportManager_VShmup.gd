@tool
extends Node
class_name SB_ViewportManager_VShmup

## 🚀 SB_ViewportManager_VShmup : Gère les SubViewports et la résolution dynamique.
## Ce composant est basé sur l'architecture de Cosmic HyperSquad.

# --- Configuration (Injectée par le GameMode) ---
var startup_delay: float = 2.0
var interpolation_smoothness: float = 2.0

var bg_target_fps: float = 60.0
var bg_min_fps: float = 30.0
var background_max_scale: float = 1.0
var background_min_scale: float = 1.0
var bg_cadence: float = 1.0
var bg_step: float = 0.1

var mg_target_fps: float = 60.0
var mg_min_fps: float = 30.0
var mainground_max_scale: float = 1.0
var mainground_min_scale: float = 1.0
var mg_cadence: float = 1.0
var mg_step: float = 0.1

var bloom_target_fps: float = 60.0
var bloom_min_fps: float = 30.0
var bloom_max_scale: float = 0.5
var bloom_min_scale: float = 0.5
var bl_cadence: float = 1.0
var bl_step: float = 0.1

# --- Références ---
var background_viewport_container: SubViewportContainer
var background_viewport: SubViewport
var mainground_viewport_container: SubViewportContainer
var mainground_viewport: SubViewport
var bloom_long_viewport_container: SubViewportContainer
var bloom_long_viewport: SubViewport
var bloom_med_viewport_container: SubViewportContainer
var bloom_med_viewport: SubViewport
var bloom_short_viewport_container: SubViewportContainer
var bloom_short_viewport: SubViewport
var ui_viewport_container: SubViewportContainer
var ui_viewport: SubViewport

# --- État Interne ---
var fps_history: Array[float] = []
var fps_history_size: int = 15 # Fenêtre de lissage (~0.25s à 60fps)
var _frame_counter: int = 0
var _update_interval: int = 5 # Fréquence de mise à jour (tous les 5 frames)
var _time_elapsed: float = 0.0

var _timer_bg: float = 0.0
var _timer_mg: float = 0.0
var _timer_bl: float = 0.0

var _target_bg: float = 1.0
var _target_mg: float = 1.0
var _target_bl: float = 1.0

func initialize(
	_bg_vc: SubViewportContainer, _bg_vp: SubViewport,
	_mg_vc: SubViewportContainer, _mg_vp: SubViewport,
	_bl_long_vc: SubViewportContainer, _bl_long_vp: SubViewport,
	_bl_med_vc: SubViewportContainer, _bl_med_vp: SubViewport,
	_bl_short_vc: SubViewportContainer, _bl_short_vp: SubViewport,
	_ui_vc: SubViewportContainer, _ui_vp: SubViewport
) -> void:
	background_viewport_container = _bg_vc
	background_viewport = _bg_vp
	mainground_viewport_container = _mg_vc
	mainground_viewport = _mg_vp
	
	bloom_long_viewport_container = _bl_long_vc
	bloom_long_viewport = _bl_long_vp
	bloom_med_viewport_container = _bl_med_vc
	bloom_med_viewport = _bl_med_vp
	bloom_short_viewport_container = _bl_short_vc
	bloom_short_viewport = _bl_short_vp
	
	ui_viewport_container = _ui_vc
	ui_viewport = _ui_vp
	
	# Désactivation sélective du Bloom sur Mobile (IP-051/054)
	if SB_Core.instance and SB_Core.instance.is_mobile and SB_Core.instance.auto_optimize_mobile:
		var bloom_vps = [bloom_long_viewport, bloom_med_viewport, bloom_short_viewport]
		var bloom_vcs = [bloom_long_viewport_container, bloom_med_viewport_container, bloom_short_viewport_container]
		
		for i in range(bloom_vps.size()):
			if bloom_vcs[i]: bloom_vcs[i].visible = false
			if bloom_vps[i]: bloom_vps[i].render_target_update_mode = SubViewport.UPDATE_DISABLED
			
		SB_Core.instance.log_msg("Performance : Rendu GPU Bloom STOPPÉ (Mobile).", "info")

	# Configuration automatique
	var containers = [
		background_viewport_container, mainground_viewport_container, 
		bloom_long_viewport_container, bloom_med_viewport_container, bloom_short_viewport_container,
		ui_viewport_container
	]
	for container in containers:
		if container: container.stretch = true
	
	var viewports = [
		background_viewport, mainground_viewport, 
		bloom_long_viewport, bloom_med_viewport, bloom_short_viewport,
		ui_viewport
	]
	for vp in viewports:
		if vp: vp.scaling_3d_mode = SubViewport.SCALING_3D_MODE_BILINEAR

func apply_initial_scaling() -> void:
	_apply_scale(background_viewport, background_max_scale)
	_apply_scale(mainground_viewport, mainground_max_scale)
	_apply_scale(bloom_long_viewport, bloom_max_scale)
	_apply_scale(bloom_med_viewport, bloom_max_scale)
	_apply_scale(bloom_short_viewport, bloom_max_scale)
	# L'UI reste à 1.0 par défaut pour la lisibilité
	if ui_viewport: ui_viewport.scaling_3d_scale = 1.0

func update_dynamic_resolution() -> void:
	var delta = get_process_delta_time()
	_time_elapsed += delta
	
	# 1. Mise à jour de l'historique FPS
	fps_history.append(Engine.get_frames_per_second())
	if fps_history.size() > fps_history_size:
		fps_history.pop_front()
	
	_frame_counter += 1
	if _frame_counter < _update_interval: return
	_frame_counter = 0
	
	# 2. Calcul de la moyenne glissante (Hystérésis naturelle)
	var avg_fps = 0.0
	for f in fps_history: avg_fps += f
	avg_fps /= fps_history.size()
	
	# 3. Mise à jour des cibles par calque avec cadence et granularité
	var update_delta = delta * _update_interval
	
	_update_layer_target("bg", avg_fps, update_delta)
	_update_layer_target("mg", avg_fps, update_delta)
	_update_layer_target("bl", avg_fps, update_delta)
	
	# [IP-024] PROTECTION AU DÉMARRAGE : Forçage qualité maximale
	if _time_elapsed < startup_delay:
		_target_bg = background_max_scale
		_target_mg = mainground_max_scale
		_target_bl = bloom_max_scale
	
	# 4. Application avec lissage (Smoothness)
	_smooth_update_scale(background_viewport, _target_bg, update_delta)
	_smooth_update_scale(mainground_viewport, _target_mg, update_delta)
	_smooth_update_scale(bloom_long_viewport, _target_bl, update_delta)
	_smooth_update_scale(bloom_med_viewport, _target_bl, update_delta)
	_smooth_update_scale(bloom_short_viewport, _target_bl, update_delta)

func _update_layer_target(layer: String, avg_fps: float, delta: float) -> void:
	match layer:
		"bg":
			_timer_bg -= delta
			if _timer_bg <= 0:
				_timer_bg = bg_cadence
				_target_bg = _calculate_stepped_target(_target_bg, avg_fps, bg_min_fps, bg_target_fps, background_min_scale, background_max_scale, bg_step)
		"mg":
			_timer_mg -= delta
			if _timer_mg <= 0:
				_timer_mg = mg_cadence
				_target_mg = _calculate_stepped_target(_target_mg, avg_fps, mg_min_fps, mg_target_fps, mainground_min_scale, mainground_max_scale, mg_step)
		"bl":
			_timer_bl -= delta
			if _timer_bl <= 0:
				_timer_bl = bl_cadence
				_target_bl = _calculate_stepped_target(_target_bl, avg_fps, bloom_min_fps, bloom_target_fps, bloom_min_scale, bloom_max_scale, bl_step)

func _calculate_stepped_target(current: float, fps: float, min_f: float, target_f: float, min_s: float, max_s: float, step: float) -> float:
	var t = clampf((fps - min_f) / (target_f - min_f), 0.0, 1.0)
	# Arrondi au palier le plus proche
	var ideal_snapped = snappedf(lerpf(min_s, max_s, t), step)
	
	# Limitation à un seul palier (step) de changement
	if ideal_snapped < current - 0.01: # Petite marge d'erreur flottante
		return current - step
	elif ideal_snapped > current + 0.01:
		return current + step
	
	return current

func _smooth_update_scale(vp: SubViewport, target_scale: float, delta: float) -> void:
	if not vp: return
	var current_scale = vp.scaling_3d_scale
	
	# Lerp vers la cible pour éviter les flashs de résolution
	var new_scale = lerpf(current_scale, target_scale, interpolation_smoothness * delta)
	_apply_scale(vp, new_scale)

func _apply_scale(vp: SubViewport, scale_val: float) -> void:
	if not vp: return
	vp.scaling_3d_scale = clampf(scale_val, 0.1, 2.0)
