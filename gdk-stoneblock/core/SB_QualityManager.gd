@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
extends SB_Manager
class_name SB_QualityManager

## 🚀 SB_QualityManager : Gestionnaire de performance global et persistant.
## Ce composant centralise le calcul des FPS et la gestion du "Ratchet" (verrouillage) 
## pour assurer une cohérence de fluidité à travers toutes les scènes.

# --- Accès Statique (Singleton Optionnel) ---
static var instance: SB_QualityManager

## Si décoché, tout le système de résolution dynamique est désactivé globalement.
@export var enable_quality_manager: bool = true

# --- Paramètres de Configuration Globale (Source de Vérité) ---
# (Les standards de FPS, échelles et cadences sont définis ci-dessous)

@export_group("Global Quality Standards")
@export var startup_delay: float = 1.0
@export var interpolation_smoothness: float = 1.0

@export_group("Background Standard")
@export var bg_target_fps: float = 60.0
@export var bg_min_fps: float = 30.0
@export_range(0.1, 1.0, 0.05) var bg_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var bg_min_scale: float = 0.5
@export var bg_quality_cadence: float = 0.1
@export var bg_quality_step: float = 0.01

@export_group("Mainground Standard")
@export var mg_target_fps: float = 60.0
@export var mg_min_fps: float = 25.0
@export_range(0.1, 1.0, 0.05) var mg_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var mg_min_scale: float = 0.75
@export var mg_quality_cadence: float = 0.1
@export var mg_quality_step: float = 0.01

@export_group("Bloom Standard")
@export var bloom_enabled: bool = true
@export var bloom_target_fps: float = 60.0
@export var bloom_min_fps: float = 35.0
@export_range(0.1, 1.0, 0.05) var bloom_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var bloom_min_scale: float = 0.1
@export var bl_quality_cadence: float = 0.1
@export var bl_quality_step: float = 0.01

@export_group("Bloom Security (Ratchet)")
@export var bloom_lock_on_degrade: bool = true
@export var bloom_lock_delay: float = 3.0
@export var bloom_lock_max_hits: int = 3

@export_subgroup("Bloom Cascade Thresholds")
@export_range(0.1, 1.0, 0.01) var min_bloom_ultra: float = 0.7
@export_range(0.1, 1.0, 0.01) var min_bloom_balanced: float = 0.45
@export_range(0.1, 1.0, 0.01) var min_bloom_fast: float = 0.15

@export_group("Mobile Performance Defaults")
## Désactive physiquement le MSAA (Gain GPU majeur).
@export var disable_msaa: bool = true
## Désactive les ombres Omni/Spot (Gain GPU).
@export var disable_positional_shadows: bool = true

# --- [DÉTECTION MATÉRIELLE] (IP-139) ---
var _hardware_bloom_capable: bool = true
var _hardware_score: int = 0

func is_hardware_bloom_capable() -> bool:
	return _hardware_bloom_capable

func _detect_hardware_performance() -> void:
	_hardware_score = 0
	var details = ""
	
	# 1. Analyse de la RAM (Poids : 30 pts)
	var ram_gb = float(OS.get_memory_info()["physical"]) / (1024.0 * 1024.0 * 1024.0)
	var ram_score = 0
	if ram_gb >= 7.5: ram_score = 30
	elif ram_gb >= 3.5: ram_score = 15
	_hardware_score += ram_score
	details += "RAM: %dGo (+%d) " % [int(ram_gb), ram_score]
	
	# 2. Analyse du CPU (Poids : 20 pts)
	var cores = OS.get_processor_count()
	var core_score = 0
	if cores >= 8: core_score = 20
	elif cores >= 6: core_score = 10
	_hardware_score += core_score
	details += "| CPU: %d cores (+%d) " % [cores, core_score]
	
	# 3. Analyse du GPU (Poids : 50 pts)
	var gpu_name = RenderingServer.get_video_adapter_name().to_lower()
	var gpu_score = 40 # Base standard
	
	# Blacklist (Mali G5x, Adreno 61x)
	var is_weak = false
	if "mali-g5" in gpu_name or "adreno 61" in gpu_name:
		is_weak = true
		gpu_score = 0
	
	# Whitelist (Adreno 7xx, 8xx, 630+, 640+, 650+, 660+, Mali G7x)
	if not is_weak:
		if "adreno" in gpu_name:
			if "7" in gpu_name or "8" in gpu_name or "63" in gpu_name or "64" in gpu_name or "65" in gpu_name or "66" in gpu_name:
				gpu_score = 60
		elif "mali-g7" in gpu_name:
			gpu_score = 50
	
	_hardware_score += gpu_score
	details += "| GPU: %s (+%d) " % [gpu_name, gpu_score]
	
	# 4. Analyse de la Résolution (Malus Fill-rate)
	var screen_size = DisplayServer.screen_get_size()
	var pixel_count = screen_size.x * screen_size.y
	if pixel_count > 2500000: 
		_hardware_score -= 30 # Malus augmenté car c'est vraiment le tueur de perfs
		details += "| RES: %dx%d (-30) " % [screen_size.x, screen_size.y]
	
	# Décision finale
	_hardware_bloom_capable = _hardware_score >= 55 # Seuil remonté à 55 pour être plus prudent
	
	if SB_Core.instance:
		var status = "CAPABLE" if _hardware_bloom_capable else "LIMITED"
		SB_Core.instance.log_msg("[Quality] " + details + " | FINAL SCORE: " + str(_hardware_score) + " | Bloom: " + status, "info")

# --- État de Performance Global ---
var smoothed_fps: float = 60.0

# --- État de Sécurité Bloom (Persistant dans la session) ---
var bloom_locked_max_scale: float = 2.0
var bloom_hit_counter: int = 0

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		instance = self

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	# Initialisation propre avec les FPS par défaut du moteur
	smoothed_fps = Engine.get_frames_per_second()
	if smoothed_fps < 1.0: smoothed_fps = 60.0
	
	# Détection matérielle (IP-139)
	_detect_hardware_performance()
	
	# Chargement de l'état persistant si SB_Core est là
	_load_persistent_state()
	
	print("[SB_QualityManager] Initialisé. Score Hardware: %d | Bloom Capable: %s" % [_hardware_score, str(_hardware_bloom_capable)])

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# Source unique de vérité pour les FPS (Standard Projet)
	smoothed_fps = Engine.get_frames_per_second()

func _load_persistent_state() -> void:
	# On évite d'utiliser SB_Core.instance s'il n'est pas encore prêt, 
	# SB_Core étant souvent le root du manager.
	var core = get_node("/root/SB_Core") if has_node("/root/SB_Core") else null
	if not core and SB_Core.instance: core = SB_Core.instance
	
	if core:
		bloom_locked_max_scale = core.get_stat("perf_bloom_lock_scale", 2.0)
		bloom_hit_counter = core.get_stat("perf_bloom_hits", 0)
		# On récupère l'état d'activation (défaut true)
		bloom_enabled = core.get_stat("perf_bloom_enabled", true)

func update_bloom_lock(new_lock: float, hits: int) -> void:
	bloom_locked_max_scale = new_lock
	bloom_hit_counter = hits
	
	# SÉCURITÉ MOBILE (IP-116/117) : Désactivation si le verrou est trop bas
	if bloom_locked_max_scale <= 0.15:
		if bloom_enabled:
			bloom_enabled = false
			if SB_Core.instance:
				SB_Core.instance.log_msg("DÉSACTIVATION GLOBALE DU BLOOM (Performance critique)", "warning")
	
	# Sauvegarde dans SB_Core si présent
	if SB_Core.instance:
		SB_Core.instance.set_stat("perf_bloom_lock_scale", bloom_locked_max_scale)
		SB_Core.instance.set_stat("perf_bloom_hits", bloom_hit_counter)
		SB_Core.instance.set_stat("perf_bloom_enabled", bloom_enabled)
