@tool
extends Node
class_name SB_ViewportManager_VShmup

## 🚀 SB_ViewportManager_VShmup : Gère les SubViewports et la résolution dynamique.
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
	_ui_vc: SubViewportContainer, _ui_vp: SubViewport,
	_config: SB_QualityConfig = null
) -> void:
	quality_config = _config
	if not quality_config:
		quality_config = SB_QualityConfig.new()
		# On n'ajoute pas l'enfant pour éviter les pollutions persistantes, 
		# le config servira de conteneur de données par défaut.
		
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
	_apply_scale(background_viewport, quality_config.bg_max_scale)
	_apply_scale(mainground_viewport, quality_config.mg_max_scale)
	_apply_scale(bloom_long_viewport, quality_config.bloom_max_scale)
	_apply_scale(bloom_med_viewport, quality_config.bloom_max_scale)
	_apply_scale(bloom_short_viewport, quality_config.bloom_max_scale)
	
	_target_bg = quality_config.bg_max_scale
	_target_mg = quality_config.mg_max_scale
	_target_bl = quality_config.bloom_max_scale
	
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
		_timer_bg = quality_config.bg_quality_cadence
		_target_bg = _calculate_stepped_target(_target_bg, smoothed_fps, quality_config.bg_min_fps, quality_config.bg_target_fps, quality_config.bg_min_scale, quality_config.bg_max_scale, quality_config.bg_quality_step)
	
	if _timer_mg <= 0:
		_timer_mg = quality_config.mg_quality_cadence
		_target_mg = _calculate_stepped_target(_target_mg, smoothed_fps, quality_config.mg_min_fps, quality_config.mg_target_fps, quality_config.mg_min_scale, quality_config.mg_max_scale, quality_config.mg_quality_step)
	
	if _timer_bl <= 0:
		_timer_bl = quality_config.bl_quality_cadence
		
		# 1. Calcul de la cible idéale sur l'échelle complète [MinScale - MaxScale]
		# On utilise toujours le max absolu (config) pour que le ratio par rapport aux FPS reste correct.
		_target_bl = _calculate_stepped_target(
			_target_bl, 
			smoothed_fps, 
			quality_config.bloom_min_fps, 
			quality_config.bloom_target_fps, 
			quality_config.bloom_min_scale, 
			quality_config.bloom_max_scale, 
			quality_config.bl_quality_step
		)
		
		# 2. Application du plafond de sécurité (Ratchet)
		# On bride la cible pour qu'elle ne dépasse jamais la valeur verrouillée.
		if quality_config.bloom_lock_on_degrade:
			_target_bl = minf(_target_bl, _bloom_locked_max_scale)
			
		_update_bloom_quality_stepping(_target_bl)
		
		# Gestion du timer et du compteur de chutes (Hits)
		var is_degraded = _target_bl < quality_config.bloom_max_scale - 0.001
		
		# --- Logique de Sécurité Bloom (Cliquet / Ratchet) ---
		var current_rank = _get_bloom_mode_rank(_current_bloom_mode_name)
		var is_below_ultra = current_rank < 3 # 3 = Ultra
		
		if quality_config.bloom_lock_on_degrade:
			# 1. Gestion des Hits (Détection des chutes de palier)
			if current_rank < _bloom_last_mode_rank:
				_bloom_hit_counter += 1
				var ts = Time.get_ticks_msec() / 1000.0
				if SB_Core.instance:
					SB_Core.instance.log_msg("[%s] BLOOM : Chute (%s -> %s). Hit %d/%d" % [str(ts), _bloom_last_mode_name, _current_bloom_mode_name, _bloom_hit_counter, quality_config.bloom_lock_max_hits], "info")
				
				# Verrouillage si trop de chutes
				if _bloom_hit_counter >= quality_config.bloom_lock_max_hits:
					if _target_bl < _bloom_locked_max_scale - 0.001:
						_bloom_locked_max_scale = _target_bl
						if SB_Core.instance:
							SB_Core.instance.log_msg("[%s] SÉCURITÉ BLOOM : Verrouillage HITS à %.2f" % [str(ts), _bloom_locked_max_scale], "warning")
			
			# 2. Gestion du Timer (Uniquement pour les modes dégradés sous l'Ultra)
			if is_below_ultra:
				# Si on change de mode (ex: Balanced -> Fast), on reset le timer pour attendre la stabilisation
				if _current_bloom_mode_name != _bloom_last_mode_name:
					_bloom_lock_timer = 0.0
				
				_bloom_lock_timer += quality_config.bl_quality_cadence
				if _bloom_lock_timer >= quality_config.bloom_lock_delay:
					if _target_bl < _bloom_locked_max_scale - 0.001:
						_bloom_locked_max_scale = _target_bl
						_bloom_lock_timer = 0.0 # Reset après lock pour éviter le spam
						var ts = Time.get_ticks_msec() / 1000.0
						if SB_Core.instance:
							SB_Core.instance.log_msg("[%s] SÉCURITÉ BLOOM : Verrouillage TIMER à %.2f (Stable %s)" % [str(ts), _bloom_locked_max_scale, _current_bloom_mode_name], "warning")
			else:
				# En mode Ultra, on laisse le timer à 0, pas de verrouillage de résolution
				_bloom_lock_timer = 0.0
				
		# Sauvegarde de l'état pour le prochain cycle
		_bloom_last_mode_rank = current_rank
		_bloom_last_mode_name = _current_bloom_mode_name
	
	# [IP-024] PROTECTION AU DÉMARRAGE : Forçage qualité maximale
	if _time_elapsed < quality_config.startup_delay:
		_target_bg = quality_config.bg_max_scale
		_target_mg = quality_config.mg_max_scale
		_target_bl = quality_config.bloom_max_scale
	
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
				var msg = "PERF: %.1f FPS | MG Target: %.2f | MinMG: %.2f" % [smoothed_fps, _target_mg, quality_config.mg_min_scale]
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
		var final_v = clampf(current - step, min_s, max_s)
		# print("[DynamicRes] DÉGRADATION: %.2f -> %.2f (Cible idéale: %.2f)" % [current, final_v, ideal_snapped])
		return final_v
	elif ideal_snapped > current + 0.001:
		var final_v = clampf(current + step, min_s, max_s)
		# print("[DynamicRes] RÉCUPÉRATION: %.2f -> %.2f (Cible idéale: %.2f)" % [current, final_v, ideal_snapped])
		return final_v
	
	return current

func _smooth_update_scale(vp: SubViewport, target_scale: float, delta: float) -> void:
	if not vp: return
	var current_scale = vp.scaling_3d_scale
	
	if abs(current_scale - target_scale) < 0.001:
		vp.scaling_3d_scale = target_scale
		return
		
	# Lerp vers la cible pour éviter les flashs de résolution
	# On utilise le delta réel ici car cette fonction est appelée chaque frame
	var new_scale = lerpf(current_scale, target_scale, quality_config.interpolation_smoothness * delta)
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
	if not bloom_config or not quality_config.bloom_enabled: return
	
	# Déduction des paliers de qualité basés sur les seuils configurés
	var q_ultra = 2 # BlurQuality.ULTRA
	var q_balanced = 1 # BlurQuality.BALANCED
	var q_fast = 0 # BlurQuality.FAST
	
	var target_q = q_ultra
	var enable_bloom = true
	
	if target_scale >= quality_config.min_bloom_ultra - 0.001:
		target_q = q_ultra
		_current_bloom_mode_name = "Ultra"
	elif target_scale >= quality_config.min_bloom_balanced - 0.001:
		target_q = q_balanced
		_current_bloom_mode_name = "Balanced"
	elif target_scale >= quality_config.min_bloom_fast - 0.001:
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

func _get_bloom_mode_rank(mode_name: String) -> int:
	match mode_name:
		"Ultra": return 3
		"Balanced": return 2
		"Fast": return 1
		"OFF": return 0
	return 3
