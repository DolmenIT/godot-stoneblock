@tool
class_name SB_Core
extends Node

## 🚀 SB_Core : Le Gestionnaire Persistant du GDK StoneBlock.
## Ce composant remplace l'ancien Autoload. Il gère le cycle de vie, les transitions 
## de scènes par "swap" d'enfants, et la console de debug.

# --- Accès Statique (Pattern Singleton sans Autoload) ---
static var instance: SB_Core

# --- Énumérations & Signaux ---
enum State { INIT, LOADING, WAITING, READY, PAUSED, ERROR }
enum SBOrientation { LANDSCAPE, PORTRAIT, UNKNOWN }

signal state_changed(new_state: State)
signal orientation_changed(new_orientation: SBOrientation)
signal progress_updated(percent: float)
signal resource_loaded(path: String, resource: Object)
signal message_logged(text: String, type: String)
signal stats_updated(stats: Dictionary)

# --- Variables d'Export (Style Unreal) ---
## Activer l'écran de splash StoneBlock au démarrage.
@export var use_stoneblock_splash: bool = true
## Chemin vers la scène à charger automatiquement au démarrage.
@export_file("*.tscn") var next_scene_path: String = ""
## Chemin vers la scène de chargement (Splash screen / Progress bar).
@export_file("*.tscn") var loading_scene_path: String = ""


## Orientation forcée au démarrage (Mobile).
@export var initial_orientation: SBOrientation = SBOrientation.LANDSCAPE


## Activer l'Anti-Aliasing optimisé pour mobile (MSAA 2x + FXAA).
@export var use_anti_aliasing: bool = true
## Optimiser automatiquement les réglages pour les plateformes mobiles.
@export var auto_optimize_mobile: bool = true
## Afficher un compteur de FPS en haut à droite.
@export var show_fps_counter: bool = false

@export_group("Performance & Async")
## Intervalle de mise à jour de la boucle de jeu (en secondes).
var tick_rate: float = 0.016 # ~60 FPS
## Activer le chargement multi-threadé pour les scènes lourdes.
var use_threaded_loading: bool = true

# --- Variables Internes ---
var _current_state: State = State.INIT
var _current_loading_path: String = ""
var _tick_timer: float = 0.0
var _start_time: float = 0.0
var _log_history: Array[Dictionary] = []

var _last_logged_progress: int = -1
var _is_scene_ready: bool = false
var _pending_instance: Node = null
var _use_inner_progress: bool = false
var _fps_label: Label
var _current_orientation: SBOrientation = SBOrientation.UNKNOWN
var _min_display_time_current: float = 0.0
var _loader_shown: bool = false
var _use_loading_screen_current: bool = true
var _preloaded_resources: Dictionary = {} # Path -> Resource
var _pending_preloads: Array[String] = []
var is_mobile: bool = false
var _stats: Dictionary = {
	"magie": 0, 
	"score": 0, 
	"combo_max": 0,
	"unlocked_ships": ["phantom_jet"],
	"unlocked_powerups": ["triple_shot"],
	"selected_ship": "phantom_jet",
	"selected_powerup": "triple_shot"
}
## Données de niveau persistantes pour la scène active (configurées par SB_Redirect).
var level_data: Dictionary = {} 

@export_group("Core Internal (Auto-Config)")
## Chemin vers la scène contenant les visuels et la structure par défaut.
var core_template_path: String = "res://stoneblock/core/SB_Core.tscn"
## Chemin du fichier de sauvegarde des statistiques.
const SAVE_STATS_PATH = "user://game_stats.json"

@onready var loading_layer: CanvasLayer = get_node_or_null("Loading_Layer")
@onready var active_scene_container: Node = $Active_Scene if has_node("Active_Scene") else self

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		instance = self
		process_mode = PROCESS_MODE_ALWAYS

func _ready() -> void:
	# Système d'Auto-Peuplement (Pour le mode "Node Root Minimaliste")
	if not Engine.is_editor_hint():
		if not has_node("Active_Scene") and not core_template_path.is_empty():
			_apply_core_template()
		
		# Récupération tardive de la scène active après peuplement
		active_scene_container = get_node_or_null("Active_Scene")
		if not active_scene_container: active_scene_container = self
	log_msg("Core StoneBlock initialisé (Mode Persistant).", "success")
	_start_time = Time.get_ticks_msec() / 1000.0
	_set_state(State.INIT)
	
	if Engine.is_editor_hint():
		_editor_setup()
		return
	if not use_stoneblock_splash:
		log_msg("Mode Direct Boot actif (Splash désactivé).", "info")
		load_scene_async(next_scene_path, false, 0.0, false)
	else:
		_set_state(State.READY)
	
	# Chargement des statistiques persistantes
	load_stats()
	
	# Détection Mobile & Optimisation (IP-051)
	is_mobile = OS.has_feature("mobile")
	if is_mobile and auto_optimize_mobile:
		use_anti_aliasing = false
		log_msg("Mode Mobile détecté : Optimisations automatiques actives.", "info")
	
	# Initialisation de l'orientation (IP-037)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	if initial_orientation != SBOrientation.UNKNOWN:
		force_orientation(initial_orientation)
	_check_orientation()
	_apply_rendering_settings()
	_toggle_fps_counter(show_fps_counter)

## Amorce le préchargement d'une scène en arrière-plan.
func preload_scene(path: String) -> void:
	if path.is_empty() or _preloaded_resources.has(path): return
	if _pending_preloads.has(path): return
	
	log_msg("Préchargement : " + path, "info")
	_pending_preloads.append(path)
	ResourceLoader.load_threaded_request(path)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
		
	_tick_timer += delta
	if _tick_timer >= tick_rate:
		_on_tick(_tick_timer)
		_tick_timer = 0.0
		
	if _current_state == State.LOADING or _current_state == State.WAITING:
		_update_loading_status()
		
	_update_pending_preloads()
	_update_fps_counter()

func _update_pending_preloads() -> void:
	if _pending_preloads.is_empty(): return
	var i = _pending_preloads.size() - 1
	while i >= 0:
		var path = _pending_preloads[i]
		var status = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var res = ResourceLoader.load_threaded_get(path)
			_preloaded_resources[path] = res
			_pending_preloads.remove_at(i)
			log_msg("Préchargement TERMINÉ : " + path, "success")
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			_pending_preloads.remove_at(i)
			log_msg("ÉCHEC préchargement : " + path, "error")
		i -= 1

## Charge une scène de manière asynchrone par remplacement d'enfant (Swap).
func load_scene_async(path: String, use_inner: bool = false, override_display: float = -1.0, use_loader: bool = true) -> void:
	if path.is_empty(): return
	
	_current_loading_path = path
	_use_inner_progress = use_inner
	_min_display_time_current = override_display
	_start_time = Time.get_ticks_msec() / 1000.0
	_last_logged_progress = 0
	_is_scene_ready = false
	_pending_instance = null
	_loader_shown = false
	_use_loading_screen_current = use_loader
	
	log_msg("Chargement vers : " + path, "info")
	
	if _use_loading_screen_current and not loading_scene_path.is_empty():
		_perform_loader_setup(loading_scene_path)
		_loader_shown = true
		
		# Masquage récursif (inclut les CanvasLayer qui ignorent le visible du parent)
		if active_scene_container: _set_node_visibility_recursive(active_scene_container, false)
		if has_node("Core_Scene"): _set_node_visibility_recursive(get_node("Core_Scene"), false)
	
	_set_state(State.LOADING)
	ResourceLoader.load_threaded_request(path)

func _perform_loader_setup(ls_path: String) -> void:
	if not FileAccess.file_exists(ls_path): return
	var loading_scene = load(ls_path)
	if loading_scene:
		var ls_instance = loading_scene.instantiate()
		# On ajoute l'écran de chargement au Loading_Layer (priorité haute)
		if loading_layer:
			loading_layer.add_child(ls_instance)
		else:
			get_tree().root.add_child(ls_instance)
		log_msg("Transition affichée.", "info")

func log_msg(text: String, type: String = "info") -> void:
	var prefix = "[SB_Core] "
	if type == "error": prefix = "[ERREUR] "
	elif type == "success": prefix = "[SUCCÈS] "
	print(prefix + text)
	_log_history.append({"text": text, "type": type, "time": Time.get_time_string_from_system()})
	if _log_history.size() > 100: _log_history.remove_at(0)
	message_logged.emit(text, type)

func report_progress(percent: float) -> void:
	var final_percent = percent
	if _use_inner_progress: final_percent = 20.0 + (percent * 0.8)
	progress_updated.emit(final_percent)

func report_ready() -> void:
	_is_scene_ready = true
	log_msg("Scène prête.", "success")

func get_log_history() -> Array[Dictionary]:
	return _log_history

func add_stat(key: String, value: int) -> void:
	if not _stats.has(key): _stats[key] = 0
	_stats[key] += value
	stats_updated.emit(_stats)
	log_msg("Stat added: %s = %d (total: %d)" % [key, value, _stats[key]], "info")
	save_stats()

func set_stat(key: String, value) -> void:
	_stats[key] = value
	stats_updated.emit(_stats)
	log_msg("Stat set: %s = %s" % [key, str(value)], "info")
	save_stats()

func get_stats() -> Dictionary:
	return _stats

func get_stat(key: String, default: int = 0) -> int:
	return _stats.get(key, default)

## Enregistre les statistiques sur le disque au format JSON.
func save_stats() -> void:
	var file = FileAccess.open(SAVE_STATS_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(_stats)
		file.store_string(json_string)
		file.close()
		# On n'affiche pas de log à chaque save pour éviter de polluer la console en combat
	else:
		log_msg("Erreur lors de la sauvegarde des stats !", "error")

## Charge les statistiques depuis le disque.
func load_stats() -> void:
	if not FileAccess.file_exists(SAVE_STATS_PATH):
		return
		
	var file = FileAccess.open(SAVE_STATS_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var loaded_stats = json.get_data()
			if loaded_stats is Dictionary:
				# On fusionne pour garder les clés par défaut si nouvelles
				for key in loaded_stats:
					_stats[key] = loaded_stats[key]
				log_msg("Statistiques chargées avec succès.", "success")
				stats_updated.emit(_stats)
		file.close()

# --- Gestion de l'Orientation (IP-037) ---

func get_current_orientation() -> SBOrientation:
	return _current_orientation

## Alterne manuellement entre Portrait (9:16) et Paysage (16:9). Utile pour le debug Desktop.
func toggle_orientation() -> void:
	var current_size = DisplayServer.window_get_size()
	var new_size = Vector2i(current_size.y, current_size.x)
	_smart_resize_and_center(new_size)

## Force une orientation spécifique (Mobile)
func force_orientation(target: SBOrientation) -> void:
	# 1. Réglage système (Uniquement sur Mobile)
	if OS.has_feature("mobile"):
		var ds_orient = DisplayServer.SCREEN_LANDSCAPE if target == SBOrientation.LANDSCAPE else DisplayServer.SCREEN_PORTRAIT
		DisplayServer.screen_set_orientation(ds_orient)
	
	# 2. Réglage Visuel (Desktop Debug pour le confort de test)
	if OS.has_feature("pc") and not Engine.is_editor_hint():
		# On vérifie si on n'est pas dans un mode "Embed" où le resize est impossible
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN: return
		
		var current_size = DisplayServer.window_get_size()
		# On utilise une vérification d'aspect ratio plus robuste
		var is_currently_portrait = current_size.y > current_size.x
		
		if (target == SBOrientation.PORTRAIT and not is_currently_portrait) or \
		   (target == SBOrientation.LANDSCAPE and is_currently_portrait):
			var new_size = Vector2i(current_size.y, current_size.x)
			_smart_resize_and_center(new_size)

func _on_viewport_size_changed() -> void:
	_check_orientation()

func _check_orientation() -> void:
	var size = get_viewport().size
	var new_orient = SBOrientation.LANDSCAPE if size.x >= size.y else SBOrientation.PORTRAIT
	
	if new_orient != _current_orientation:
		_current_orientation = new_orient
		var orient_name = "LANDSCAPE" if _current_orientation == SBOrientation.LANDSCAPE else "PORTRAIT"
		log_msg("Orientation changée : " + orient_name, "info")

## Gère intelligemment le redimensionnement et le centrage sur Desktop (Debug).
func _smart_resize_and_center(target_size: Vector2i) -> void:
	if Engine.is_editor_hint() or not OS.has_feature("pc"): return
	
	var window = get_window()
	var screen_id = window.current_screen
	var screen_size = DisplayServer.screen_get_size(screen_id)
	
	# Correction des dimensions pour ne pas dépasser (marge de 100px)
	var margin = 100
	var max_w = screen_size.x - margin
	var max_h = screen_size.y - margin
	
	var final_size = Vector2(target_size)
	var ratio = 1.0
	if final_size.x > max_w:
		ratio = min(ratio, max_w / final_size.x)
	if final_size.y > max_h:
		ratio = min(ratio, max_h / final_size.y)
	
	DisplayServer.window_set_size(Vector2i(final_size * ratio))
	window.move_to_center()
	log_msg("Desktop Window : " + str(DisplayServer.window_get_size()) + " (centrée)", "success")
	orientation_changed.emit(_current_orientation)

# --- Fonctions Privées ---

func _set_state(new_state: State) -> void:
	_current_state = new_state
	state_changed.emit(_current_state)

func _update_loading_status() -> void:
	if _current_state == State.WAITING:
		if _is_scene_ready: _complete_transition(_pending_instance)
		return
		
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(_current_loading_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var percent = progress[0] * 100.0
			progress_updated.emit(percent)
		
		ResourceLoader.THREAD_LOAD_LOADED:
			var current_time = Time.get_ticks_msec() / 1000.0
			var wait_time = 1.0 if use_stoneblock_splash else 0.0
			wait_time = max(wait_time, _min_display_time_current)
			if (current_time - _start_time) < wait_time: return
				
			var res = ResourceLoader.load_threaded_get(_current_loading_path)
			if res is PackedScene:
				var instance_node = res.instantiate()
				if _use_inner_progress:
					_pending_instance = instance_node
					_set_state(State.WAITING)
				else:
					_complete_transition(instance_node)
		
		ResourceLoader.THREAD_LOAD_FAILED:
			_set_state(State.ERROR)
			log_msg("Échec : " + _current_loading_path, "error")

func _complete_transition(new_instance: Node) -> void:
	if not new_instance: return
	
	# Suppression de l'ancienne scène (enfant de active_scene_container)
	for child in active_scene_container.get_children():
		if child is Node3D or child is Control: # On évite de supprimer les composants internes
			child.queue_free()
	
	# Réaffichage de la scène
	if active_scene_container:
		_set_node_visibility_recursive(active_scene_container, true)
		active_scene_container.add_child(new_instance)
	
	_set_state(State.READY)
	resource_loaded.emit(_current_loading_path, new_instance)
	log_msg("Transition terminée : " + _current_loading_path, "success")
	
	# Nettoyage visuel de l'intro (on supprime tout le bloc Core_Scene)
	if has_node("Core_Scene"):
		get_node("Core_Scene").queue_free()
	
	# Nettoyage éventuel du loader manuel (layer ou root)
	if loading_layer:
		for child in loading_layer.get_children():
			child.queue_free()
	
	var root = get_tree().root
	for child in root.get_children():
		var c_name = child.name.to_lower()
		if "loading" in c_name or "splash" in c_name:
			child.queue_free()

func _on_tick(_delta: float) -> void:
	if Input.is_key_pressed(KEY_F11):
		# Debounce simple pour éviter les toggles en boucle (0.5s)
		var now = Time.get_ticks_msec() / 1000.0
		if now - _start_time > 0.5:
			toggle_orientation()
			_start_time = now

func _apply_core_template() -> void:
	if core_template_path.is_empty(): return
	var template_scene = load(core_template_path)
	if not template_scene: return
	
	var temp_instance = template_scene.instantiate()
	# On transfère tous les enfants du template vers ce nœud
	for child in temp_instance.get_children():
		# Filtrage : On ignore la scène d'intro si demandée
		if not use_stoneblock_splash and (child.name == "Core_Scene" or "Splash" in child.name):
			log_msg("Filtrage du Template : Bloc Intro ignoré.", "info")
			continue
			
		temp_instance.remove_child(child)
		child.owner = null # On retire l'ancien owner du template pour éviter les warnings
		
		# On injecte les paramètres AVANT d'ajouter à l'arbre pour éviter les race conditions dans _ready()
		_propagate_to_node(child)
		for sub_child in get_all_children(child):
			_propagate_to_node(sub_child)
			
		add_child(child)
		child.owner = self # Nouvel owner définitif
	temp_instance.queue_free()
	log_msg("Structure interne auto-configurée via le template.", "success")

func _propagate_to_node(node: Node) -> void:
	if node is SB_Preload:
		var cleaned_list : PackedStringArray = []
		# On ne garde que les scènes personnalisées de l'utilisateur
		for p in node.preload_scenes:
			if not ("scene_loading" in p or "menu_principal" in p or "loading_scene" in p):
				cleaned_list.append(p)
		
		# On injecte les nouveaux chemins du Core (Source de vérité)
		if not loading_scene_path.is_empty() and not cleaned_list.has(loading_scene_path):
			cleaned_list.append(loading_scene_path)
		if not next_scene_path.is_empty() and not cleaned_list.has(next_scene_path):
			cleaned_list.append(next_scene_path)
		
		node.preload_scenes = cleaned_list
	
	if node is SB_Redirect:
		if node.target_scene.is_empty():
			node.target_scene = next_scene_path

## Fonction utilitaire pour récupérer tous les enfants récursivement
func get_all_children(node: Node) -> Array:
	var nodes : Array = []
	for child in node.get_children():
		nodes.append(child)
		if child.get_child_count() > 0:
			nodes.append_array(get_all_children(child))
	return nodes

func _set_node_visibility_recursive(node: Node, v: bool) -> void:
	if node is CanvasLayer or node is Control or node is Node3D:
		node.visible = v
	
	for child in node.get_children():
		_set_node_visibility_recursive(child, v)

func _apply_rendering_settings() -> void:
	if Engine.is_editor_hint(): return
	
	var viewport = get_viewport()
	if use_anti_aliasing:
		viewport.msaa_3d = Viewport.MSAA_2X
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		log_msg("Qualité : Anti-Aliasing Activé (MSAA 2x + FXAA)", "success")
	else:
		viewport.msaa_3d = Viewport.MSAA_DISABLED
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		log_msg("Qualité : Anti-Aliasing Désactivé", "info")

func _toggle_fps_counter(active: bool) -> void:
	if active:
		if _fps_label: return
		var cl = CanvasLayer.new()
		cl.name = "SB_Debug_Layer"
		cl.layer = 128
		add_child(cl)
		
		_fps_label = Label.new()
		_fps_label.name = "FPS_Counter"
		_fps_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 10)
		_fps_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		_fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_fps_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		_fps_label.add_theme_constant_override("shadow_outline_size", 2)
		cl.add_child(_fps_label)
	else:
		if has_node("SB_Debug_Layer"):
			get_node("SB_Debug_Layer").queue_free()
		_fps_label = null

func _update_fps_counter() -> void:
	if not _fps_label: return
	_fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _editor_setup() -> void: pass
