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
var bloom_enabled: bool = true

# --- Seuils de Qualité Bloom ---
var min_bloom_ultra: float = 0.75
var min_bloom_balanced: float = 0.50
var min_bloom_fast: float = 0.25

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

## Référence optionnelle pour le contrôle de la qualité graphique du Bloom
var bloom_config: Node = null

# --- État Interne ---
var fps_history: Array[float] = []
var fps_history_size: int = 60 # Fenêtre élargie pour un lissage plus stable
var smoothed_fps: float = 60.0
var _frame_counter: int = 0
var _update_interval: int = 5 # Polling FPS toutes les 5 frames
var _time_elapsed: float = 0.0

var _timer_bg: float = 0.0
var _timer_mg: float = 0.0
var _timer_bl: float = 0.0

var _target_bg: float = 1.0
var _target_mg: float = 1.0
var _target_bl: float = 1.0
var _current_bloom_mode_name: String = "Ultra"

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
	
	# Tentative de découverte automatique si les viewports sont null (Robustesse)
	background_viewport = _resolve_vp(background_viewport_container, background_viewport)
	mainground_viewport = _resolve_vp(mainground_viewport_container, mainground_viewport)
	bloom_long_viewport = _resolve_vp(bloom_long_viewport_container, bloom_long_viewport)
	bloom_med_viewport = _resolve_vp(bloom_med_viewport_container, bloom_med_viewport)
	bloom_short_viewport = _resolve_vp(bloom_short_viewport_container, bloom_short_viewport)
	ui_viewport = _resolve_vp(ui_viewport_container, ui_viewport)
	
	# Initialisation de l'état
	smoothed_fps = Engine.get_frames_per_second()
	if smoothed_fps < 1.0: smoothed_fps = 60.0
	
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
	
	_target_bg = background_max_scale
	_target_mg = mainground_max_scale
	_target_bl = bloom_max_scale
	
	# L'UI reste à 1.0 par défaut pour la lisibilité
	if ui_viewport: ui_viewport.scaling_3d_scale = 1.0

func update_dynamic_resolution() -> void:
	var delta = get_process_delta_time()
	_time_elapsed += delta
	
	# 1. Mise à jour de l'historique FPS (Mesure directe plus réactive que Engine.get_fps)
	var raw_fps = 1.0 / max(delta, 0.001)
	# Moyenne Exponentielle (EMA) : 0.2 pour une réaction plus rapide aux chutes
	smoothed_fps = lerpf(smoothed_fps, raw_fps, 0.2)
	
	# 2. Calcul des cibles avec cadence (Seulement toutes les X secondes)
	_timer_bg -= delta
	_timer_mg -= delta
	_timer_bl -= delta
	
	if _timer_bg <= 0:
		_timer_bg = bg_cadence
		_target_bg = _calculate_stepped_target(_target_bg, smoothed_fps, bg_min_fps, bg_target_fps, background_min_scale, background_max_scale, bg_step)
	
	if _timer_mg <= 0:
		_timer_mg = mg_cadence
		_target_mg = _calculate_stepped_target(_target_mg, smoothed_fps, mg_min_fps, mg_target_fps, mainground_min_scale, mainground_max_scale, mg_step)
	
	if _timer_bl <= 0:
		_timer_bl = bl_cadence
		_target_bl = _calculate_stepped_target(_target_bl, smoothed_fps, bloom_min_fps, bloom_target_fps, bloom_min_scale, bloom_max_scale, bl_step)
		_update_bloom_quality_stepping(_target_bl)
	
	# [IP-024] PROTECTION AU DÉMARRAGE : Forçage qualité maximale
	if _time_elapsed < startup_delay:
		_target_bg = background_max_scale
		_target_mg = mainground_max_scale
		_target_bl = bloom_max_scale
	
	# 3. MISE À JOUR INDICATEURS DEBUG (Toutes les 15 frames pour la fluidité de lecture)
	if Engine.get_frames_drawn() % 15 == 0:
		if SB_Core.instance:
			SB_Core.instance.set_debug_value("Smooth FPS", "%.1f" % smoothed_fps)
			SB_Core.instance.set_debug_value("BG Scale", "%.2f" % (background_viewport.scaling_3d_scale if background_viewport else 1.0))
			SB_Core.instance.set_debug_value("MG Scale", "%.2f" % (mainground_viewport.scaling_3d_scale if mainground_viewport else 1.0))
			SB_Core.instance.set_debug_value("Bloom Scale", "%.2f" % (bloom_long_viewport.scaling_3d_scale if bloom_long_viewport else 1.0))
			SB_Core.instance.set_debug_value("Bloom Mode", _current_bloom_mode_name)
			
			# Logs console plus espacés pour ne pas saturer
			if Engine.get_frames_drawn() % 120 == 0:
				var msg = "PERF: %.1f FPS | MG Target: %.2f | MinMG: %.2f" % [smoothed_fps, _target_mg, mainground_min_scale]
				SB_Core.instance.log_msg(msg, "info")
	
	# 4. Application avec lissage (Smoothness) : S'exécute CHAQUE FRAME pour une fluidité totale
	_smooth_update_scale(background_viewport, _target_bg, delta)
	_smooth_update_scale(mainground_viewport, _target_mg, delta)
	_smooth_update_scale(bloom_long_viewport, _target_bl, delta)
	_smooth_update_scale(bloom_med_viewport, _target_bl, delta)
	_smooth_update_scale(bloom_short_viewport, _target_bl, delta)

func _calculate_stepped_target(current: float, fps: float, min_f: float, target_f: float, min_s: float, max_s: float, step: float) -> float:
	# Si les FPS sont stables ou au-dessus de la cible, on tend vers la qualité max
	var t = clampf((fps - min_f) / (target_f - min_f), 0.0, 1.0)
	# Arrondi au palier le plus proche
	var ideal_snapped = snappedf(lerpf(min_s, max_s, t), step)
	
	# Limitation à un seul palier (step) de changement par cycle pour éviter les bonds visuels
	if ideal_snapped < current - 0.001: 
		return clampf(current - step, min_s, max_s)
	elif ideal_snapped > current + 0.001:
		return clampf(current + step, min_s, max_s)
	
	return current

func _smooth_update_scale(vp: SubViewport, target_scale: float, delta: float) -> void:
	if not vp: return
	var current_scale = vp.scaling_3d_scale
	
	if abs(current_scale - target_scale) < 0.001:
		vp.scaling_3d_scale = target_scale
		return
		
	# Lerp vers la cible pour éviter les flashs de résolution
	# On utilise le delta réel ici car cette fonction est appelée chaque frame
	var new_scale = lerpf(current_scale, target_scale, interpolation_smoothness * delta)
	_apply_scale(vp, new_scale)

func _apply_scale(vp: SubViewport, scale_val: float) -> void:
	if not vp: return
	vp.scaling_3d_scale = clampf(scale_val, 0.1, 2.0)

func _resolve_vp(container: SubViewportContainer, current_vp: SubViewport) -> SubViewport:
	if current_vp: return current_vp
	if not container: return null
	# Recherche du premier SubViewport enfant
	for child in container.get_children():
		if child is SubViewport:
			return child
	return null

func _update_bloom_quality_stepping(target_scale: float) -> void:
	if not bloom_config or not bloom_enabled: return
	
	# Déduction des paliers de qualité basés sur les seuils configurés
	var q_ultra = 2 # BlurQuality.ULTRA
	var q_balanced = 1 # BlurQuality.BALANCED
	var q_fast = 0 # BlurQuality.FAST
	
	var target_q = q_ultra
	var enable_bloom = true
	
	if target_scale >= min_bloom_ultra - 0.001:
		target_q = q_ultra
		_current_bloom_mode_name = "Ultra"
	elif target_scale >= min_bloom_balanced - 0.001:
		target_q = q_balanced
		_current_bloom_mode_name = "Balanced"
	elif target_scale >= min_bloom_fast - 0.001:
		target_q = q_fast
		_current_bloom_mode_name = "Fast"
	else:
		# En dessous du seuil Fast, on désactive le Bloom
		target_q = q_fast
		enable_bloom = false
		_current_bloom_mode_name = "OFF"
			
	# Application au module BloomConfig
	if bloom_config.get("bloom_enabled") != enable_bloom:
		bloom_config.set("bloom_enabled", enable_bloom)
		
	# Mise à jour des qualités individuelles si le bloom est actif
	if enable_bloom:
		bloom_config.set("bloom_long_quality", target_q)
		bloom_config.set("bloom_med_quality", target_q)
		bloom_config.set("bloom_short_quality", target_q)
