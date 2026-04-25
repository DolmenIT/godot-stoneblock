@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
extends SB_Manager
class_name SB_ViewportManager

## 🚀 SB_ViewportManager : Gère les SubViewports et la résolution dynamique.
## Ce composant est basé sur l'architecture de Cosmic HyperSquad.

# --- Configuration
var quality_config: SB_QualityConfig = null

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
var smoothed_fps: float = 60.0
var _time_elapsed: float = 0.0

var _timer_bg: float = 0.0
var _timer_mg: float = 0.0
var _timer_bl: float = 0.0

var _target_bg: float = 1.0
var _target_mg: float = 1.0
var _target_bl: float = 1.0
var _current_bloom_mode_name: String = "Ultra"
var _bloom_lock_timer: float = 0.0
var _bloom_locked_max_scale: float = 2.0
var _bloom_hit_counter: int = 0
var _bloom_last_mode_rank: int = 3 # Ultra par défaut
var _bloom_last_mode_name: String = "Ultra"

func initialize(
	_bg_vc: SubViewportContainer, _bg_vp: SubViewport,
	_mg_vc: SubViewportContainer, _mg_vp: SubViewport,
	_bl_long_vc: SubViewportContainer, _bl_long_vp: SubViewport,
	_bl_med_vc: SubViewportContainer, _bl_med_vp: SubViewport,
	_bl_short_vc: SubViewportContainer, _bl_short_vp: SubViewport,
	_ui_vc: SubViewportContainer = null, _ui_vp: SubViewport = null,
	_config: SB_QualityConfig = null
) -> void:
	quality_config = _config
	# Si quality_config est null, on utilisera le fallback statique dans update_dynamic_resolution
		
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
	
	# Initialisation de l'état (Source Globale)
	if SB_QualityManager.instance:
		smoothed_fps = SB_QualityManager.instance.smoothed_fps
		_bloom_locked_max_scale = SB_QualityManager.instance.bloom_locked_max_scale
		_bloom_hit_counter = SB_QualityManager.instance.bloom_hit_counter
	else:
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
	var standards = SB_QualityManager.instance
	var bg_val = standards.bg_max_scale if standards else 1.0
	var mg_val = standards.mg_max_scale if standards else 1.0
	var bl_val = standards.bloom_max_scale if standards else 1.0

	_apply_scale(background_viewport, bg_val)
	_apply_scale(mainground_viewport, mg_val)
	_apply_scale(bloom_long_viewport, bl_val)
	_apply_scale(bloom_med_viewport, bl_val)
	_apply_scale(bloom_short_viewport, bl_val)
	
	_target_bg = bg_val
	_target_mg = mg_val
	_target_bl = bl_val
	
	# L'UI reste à 1.0 par défaut pour la lisibilité
	if ui_viewport: ui_viewport.scaling_3d_scale = 1.0

func update_dynamic_resolution() -> void:
	# 1. RÉCUPÉRATION DES RÉFÉRENCES
	var delta = get_process_delta_time()
	var standards = SB_QualityManager.instance
	var local = quality_config
	if not local: local = SB_QualityConfig.instance
	
	if not standards:
		# Sans manager global, on fige tout à 1.0 par sécurité
		_target_bg = 1.0
		_target_mg = 1.0
		_target_bl = 1.0
		_apply_scale(background_viewport, 1.0)
		_apply_scale(mainground_viewport, 1.0)
		_apply_scale(bloom_long_viewport, 1.0)
		_apply_scale(bloom_med_viewport, 1.0)
		_apply_scale(bloom_short_viewport, 1.0)
		return

	# 2. ÉTAT DE PERFORMANCE (Source Globale)
	smoothed_fps = standards.smoothed_fps
	_bloom_locked_max_scale = standards.bloom_locked_max_scale
	_bloom_hit_counter = standards.bloom_hit_counter
	
	# --- [MASTER TOGGLE] ---
	var is_dynamic = standards.enable_quality_manager if standards else false
	
	if is_dynamic:
		_time_elapsed += delta
		
		# 3. CALCUL DES CIBLES DYNAMIQUES (Standards)
		_timer_bg -= delta
		_timer_mg -= delta
		_timer_bl -= delta
		
		if _timer_bg <= 0:
			_timer_bg = standards.bg_quality_cadence
			_target_bg = _calculate_stepped_target(_target_bg, smoothed_fps, standards.bg_min_fps, standards.bg_target_fps, standards.bg_min_scale, standards.bg_max_scale, standards.bg_quality_step)
		
		if _timer_mg <= 0:
			_timer_mg = standards.mg_quality_cadence
			_target_mg = _calculate_stepped_target(_target_mg, smoothed_fps, standards.mg_min_fps, standards.mg_target_fps, standards.mg_min_scale, standards.mg_max_scale, standards.mg_quality_step)
		
		if _timer_bl <= 0:
			_timer_bl = standards.bl_quality_cadence
			
			_target_bl = _calculate_stepped_target(
				_target_bl, 
				smoothed_fps, 
				standards.bloom_min_fps, 
				standards.bloom_target_fps, 
				standards.bloom_min_scale, 
				minf(standards.bloom_max_scale, _bloom_locked_max_scale), 
				standards.bl_quality_step
			)
			
			if standards.bloom_lock_on_degrade:
				_target_bl = minf(_target_bl, _bloom_locked_max_scale)
				
			var current_rank = _get_bloom_mode_rank(_current_bloom_mode_name)
			var is_below_ultra = current_rank < 3 # 3 = Ultra
			
			if standards.bloom_lock_on_degrade:
				if current_rank < _bloom_last_mode_rank:
					_bloom_hit_counter += 1
					if _bloom_hit_counter >= standards.bloom_lock_max_hits:
						if _target_bl < _bloom_locked_max_scale - 0.001:
							_bloom_locked_max_scale = _target_bl
							standards.update_bloom_lock(_bloom_locked_max_scale, _bloom_hit_counter)
				
				if is_below_ultra:
					if _current_bloom_mode_name != _bloom_last_mode_name: _bloom_lock_timer = 0.0
					_bloom_lock_timer += standards.bl_quality_cadence
					if _bloom_lock_timer >= standards.bloom_lock_delay:
						if _target_bl < _bloom_locked_max_scale - 0.001:
							_bloom_locked_max_scale = _target_bl
							_bloom_lock_timer = 0.0
							standards.update_bloom_lock(_bloom_locked_max_scale, _bloom_hit_counter)
				else:
					_bloom_lock_timer = 0.0
					
			_bloom_last_mode_rank = current_rank
			_bloom_last_mode_name = _current_bloom_mode_name

		# --- [PROTECTION AU DÉMARRAGE] ---
		if _time_elapsed < standards.startup_delay:
			_target_bg = standards.bg_max_scale
			_target_mg = standards.mg_max_scale
			_target_bl = standards.bloom_max_scale

		# --- [MANUAL OVERRIDES] (Local) ---
		# Ils s'appliquent seulement si le manager est actif
		if local.force_bg_scale: _target_bg = local.forced_bg_scale
		if local.force_mg_scale: _target_mg = local.forced_mg_scale
		if local.force_bloom_scale: _target_bl = local.forced_bloom_scale

	else:
		# --- [MANAGER OFF] ---
		# Tout est forcé à la résolution native
		_target_bg = 1.0
		_target_mg = 1.0
		_target_bl = 1.0

	# --- [MISE À JOUR QUALITÉ BLOOM] ---
	_update_bloom_quality_stepping(_target_bl)
	
	# 4. MISE À JOUR INDICATEURS DEBUG (Toutes les 15 frames pour la fluidité de lecture)
	if Engine.get_frames_drawn() % 15 == 0:
		if SB_Core.instance:
			SB_Core.instance.set_debug_value("Smooth FPS", "%.1f" % smoothed_fps)
			SB_Core.instance.set_debug_value("BG Scale", "%.2f" % _target_bg)
			SB_Core.instance.set_debug_value("MG Scale", "%.2f" % _target_mg)
			SB_Core.instance.set_debug_value("Bloom Scale", "%.2f" % _target_bl)
			SB_Core.instance.set_debug_value("Bloom Mode", _current_bloom_mode_name)
			
			# Logs console plus espacés pour ne pas saturer
			if Engine.get_frames_drawn() % 120 == 0:
				var msg = "PERF: %.1f FPS | MG Target: %.2f | MinMG: %.2f" % [smoothed_fps, _target_mg, standards.mg_min_scale]
				SB_Core.instance.log_msg(msg, "info")
	
	# 5. Application avec lissage (Smoothness)
	_smooth_update_scale(background_viewport, _target_bg, delta, standards.interpolation_smoothness)
	_smooth_update_scale(mainground_viewport, _target_mg, delta, standards.interpolation_smoothness)
	
	# --- [GESTION DU RENDU DU BLOOM] ---
	# Si le Bloom est désactivé (standards.bloom_enabled), on fige physiquement les viewports.
	_update_bloom_visibility(standards.bloom_enabled)
	
	if standards.bloom_enabled:
		_smooth_update_scale(bloom_long_viewport, _target_bl, delta, standards.interpolation_smoothness)
		_smooth_update_scale(bloom_med_viewport, _target_bl, delta, standards.interpolation_smoothness)
		_smooth_update_scale(bloom_short_viewport, _target_bl, delta, standards.interpolation_smoothness)

func _update_bloom_visibility(active: bool) -> void:
	# UPDATE_ALWAYS si actif, UPDATE_DISABLED si on veut figer le rendu (Gain GPU total)
	var mode = SubViewport.UPDATE_ALWAYS if active else SubViewport.UPDATE_DISABLED
	
	if bloom_long_viewport and bloom_long_viewport.render_target_update_mode != mode:
		bloom_long_viewport.render_target_update_mode = mode
		if bloom_long_viewport_container: bloom_long_viewport_container.visible = active
		
	if bloom_med_viewport and bloom_med_viewport.render_target_update_mode != mode:
		bloom_med_viewport.render_target_update_mode = mode
		if bloom_med_viewport_container: bloom_med_viewport_container.visible = active
		
	if bloom_short_viewport and bloom_short_viewport.render_target_update_mode != mode:
		bloom_short_viewport.render_target_update_mode = mode
		if bloom_short_viewport_container: bloom_short_viewport_container.visible = active

func _calculate_stepped_target(current: float, fps: float, min_f: float, target_f: float, min_s: float, max_s: float, step: float) -> float:
	# Si les FPS sont stables ou au-dessus de la cible, on tend vers la qualité max
	var t = clampf((fps - min_f) / (target_f - min_f), 0.0, 1.0)
	# Arrondi au palier le plus proche
	var ideal_snapped = snappedf(lerpf(min_s, max_s, t), step)
	
	# Limitation à un seul palier (step) de changement par cycle pour éviter les bonds visuels
	if ideal_snapped < current - 0.001: 
		var final_v = clampf(current - step, min_s, max_s)
		# print("[DynamicRes] DÉGRADATION: %.2f -> %.2f (Cible idéale: %.2f)" % [current, final_v, ideal_snapped])
		return final_v
	elif ideal_snapped > current + 0.001:
		var final_v = clampf(current + step, min_s, max_s)
		# print("[DynamicRes] RÉCUPÉRATION: %.2f -> %.2f (Cible idéale: %.2f)" % [current, final_v, ideal_snapped])
		return final_v
	
	return current

func _smooth_update_scale(vp: SubViewport, target_scale: float, delta: float, smoothness: float) -> void:
	if not vp: return
	var current_scale = vp.scaling_3d_scale
	
	if abs(current_scale - target_scale) < 0.001:
		vp.scaling_3d_scale = target_scale
		return
		
	# Lerp vers la cible pour éviter les flashs de résolution
	var new_scale = lerpf(current_scale, target_scale, smoothness * delta)
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
	var standards = SB_QualityManager.instance
	var local = quality_config
	if not local: local = SB_QualityConfig.instance
	
	if not standards: return
		
	if not bloom_config: return
	if not standards.bloom_enabled:
		_current_bloom_mode_name = "OFF"
		return
	
	# Déduction des paliers de qualité basés sur les seuils configurés
	var q_ultra = 2 # BlurQuality.ULTRA
	var q_balanced = 1 # BlurQuality.BALANCED
	var q_fast = 0 # BlurQuality.FAST
	
	var target_q = q_ultra
	var enable_bloom = true
	
	if target_scale >= standards.min_bloom_ultra - 0.001:
		target_q = q_ultra
		_current_bloom_mode_name = "Ultra"
	elif target_scale >= standards.min_bloom_balanced - 0.001:
		target_q = q_balanced
		_current_bloom_mode_name = "Balanced"
	elif target_scale >= standards.min_bloom_fast - 0.001:
		target_q = q_fast
		_current_bloom_mode_name = "Fast"
	else:
		# En dessous du seuil Fast, on désactive le Bloom
		target_q = q_fast
		enable_bloom = false
		_current_bloom_mode_name = "OFF"
	
	# --- [MANUAL BLOOM MODE OVERRIDE] (Local) ---
	# On ne l'applique que si le manager global est actif
	if standards.enable_quality_manager and local.force_bloom_mode:
		var forced_mode = local.forced_bloom_mode # BloomMode enum
		# forced_mode: 0=OFF, 1=FAST, 2=BALANCED, 3=ULTRA (selon l'enum SB_QualityConfig)
		# target_q: 0=FAST, 1=BALANCED, 2=ULTRA (selon SB_ViewportManager)
		
		match forced_mode:
			0: # OFF
				enable_bloom = false
				_current_bloom_mode_name = "OFF (Forced)"
			1: # FAST
				enable_bloom = true
				target_q = q_fast
				_current_bloom_mode_name = "Fast (Forced)"
			2: # BALANCED
				enable_bloom = true
				target_q = q_balanced
				_current_bloom_mode_name = "Balanced (Forced)"
			3: # ULTRA
				enable_bloom = true
				target_q = q_ultra
				_current_bloom_mode_name = "Ultra (Forced)"
			
	# Application au module BloomConfig
	if bloom_config.has_method("set_bloom_enabled"):
		bloom_config.call("set_bloom_enabled", enable_bloom)
	elif "bloom_enabled" in bloom_config:
		bloom_config.set("bloom_enabled", enable_bloom)
		
	# Mise à jour des qualités individuelles si le bloom est actif
	if enable_bloom:
		bloom_config.set("bloom_long_quality", target_q)
		bloom_config.set("bloom_med_quality", target_q)
		bloom_config.set("bloom_short_quality", target_q)

func _get_bloom_mode_rank(mode_name: String) -> int:
	match mode_name:
		"Ultra": return 3
		"Balanced": return 2
		"Fast": return 1
		"OFF": return 0
	return 3
