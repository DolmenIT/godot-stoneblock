@tool
class_name SB_Core
extends Node3D

## 🚀 SB_Core : Le Gestionnaire Persistant du GDK StoneBlock.
## Ce composant remplace l'ancien Autoload. Il gère le cycle de vie, les transitions 
## de scènes par "swap" d'enfants, et la console de debug.

# --- Accès Statique (Pattern Singleton sans Autoload) ---
static var instance: SB_Core

# --- Énumérations & Signaux ---
enum State { INIT, LOADING, WAITING, READY, PAUSED, ERROR }

signal state_changed(new_state: State)
signal progress_updated(percent: float)
signal resource_loaded(path: String, resource: Resource)
signal message_logged(text: String, type: String)
signal stats_updated(stats: Dictionary)

# --- Variables d'Export (Style Unreal) ---
## Activer l'écran de splash StoneBlock au démarrage.
@export var use_stoneblock_splash: bool = true
## Chemin vers la scène à charger automatiquement au démarrage.
@export_file("*.tscn") var next_scene_path: String = ""
## Chemin vers la scène de chargement (Splash screen / Progress bar).
@export_file("*.tscn") var loading_scene_path: String = ""

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
var _min_display_time_current: float = 0.0
var _loader_shown: bool = false
var _use_loading_screen_current: bool = true
var _preloaded_resources: Dictionary = {} # Path -> Resource
var _pending_preloads: Array[String] = []
var _stats: Dictionary = {"magie": 0, "score": 0}
## Données de niveau persistantes pour la scène active (configurées par SB_Redirect).
var level_data: Dictionary = {} 

@export_group("Core Internal (Auto-Config)")
## Chemin vers la scène contenant les visuels et la structure par défaut.
var core_template_path: String = "res://stoneblock/core/SB_Core.tscn"

@onready var loading_layer: CanvasLayer = get_node_or_null("Loading_Layer")
@onready var active_scene_container: Node3D = $Active_Scene if has_node("Active_Scene") else self

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

func set_stat(key: String, value: int) -> void:
	_stats[key] = value
	stats_updated.emit(_stats)
	log_msg("Stat set: %s = %d" % [key, value], "info")

func get_stats() -> Dictionary:
	return _stats

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

func _on_tick(_delta: float) -> void: pass

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
		if node.target_scene.is_empty() or "menu" in node.target_scene.to_lower() or "splash" in node.target_scene.to_lower():
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

func _editor_setup() -> void: pass
