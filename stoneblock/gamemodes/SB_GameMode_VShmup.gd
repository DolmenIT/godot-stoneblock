@tool
extends Node
class_name SB_GameMode_VShmup

## 🚀 SB_GameMode_VShmup : Coordinateur principal du mode Shoot 'em Up vertical.
## Gère le défilement global, les viewports et les caméras parallax.

# --- Configuration ---
@export_group("Scrolling")
@export var main_camera_speed: float = 1.0
@export var use_dynamic_speed_zones: bool = true
@export var speed_zones: Array[Dictionary] = []

@export_group("Background Camera")
@export_enum("PERSPECTIVE:0", "ORTHOGONAL:1") var bg_projection: int = 1
@export var bg_camera_y: float = 100.0
@export var bg_camera_size: float = 100.0

@export_group("Mainground Camera")
@export_enum("PERSPECTIVE:0", "ORTHOGONAL:1") var mg_projection: int = 1
@export var mg_camera_y: float = 100.0
@export var mg_camera_size: float = 40.0
@export var map_limit_x: float = 125.0

@export_group("Camera Deadzone")
## Distance horizontale de "zone morte" (la caméra ne bouge pas si l'écart est inférieur à X).
@export var follow_deadzone_x: float = 10.0:
	set(v):
		follow_deadzone_x = v
		if camera_manager: camera_manager.follow_deadzone_x = v
## Afficher un rectangle semi-transparent matérialisant la deadzone.
@export var show_deadzone_visual: bool = true:
	set(v):
		show_deadzone_visual = v
		if camera_manager: camera_manager.show_deadzone_visual = v

## Facteur de vitesse de suivi de la caméra (Vitesse = Distance * Facteur).
@export var follow_speed_factor: float = 4.0:
	set(v):
		follow_speed_factor = v
		if camera_manager: camera_manager.follow_speed_factor = v

@export_group("Level Content (Defaults)")
@export_file("*.tscn") var default_background_scene: String = "res://demo/demo1/levels/level1/stage1/background.tscn"
@export_file("*.tscn") var default_mainground_scene: String = "res://demo/demo1/levels/level1/stage1/mainground.tscn"
@export_file("*.tscn") var default_ui_scene: String = "res://demo/demo1/hud/hud.tscn"

@export_group("Viewports (Hook)")
@export var background_viewport: SubViewport
@export var mainground_viewport: SubViewport
@export var bloom_viewport: SubViewport
@export var ui_viewport: SubViewport

@export_group("Enemies")
@export var enemy_scene: PackedScene = preload("res://stoneblock/enemies/SB_Enemy_VShmup.tscn")
@export var spawn_interval: float = 2.5 # Plus lent (2.5s)
@export var spawn_randomness: float = 0.3
@export var group_size_min: int = 1
@export var group_size_max: int = 2

# --- Modules ---
## Utiliser le placement manuel des ennemis dans la scène du niveau (Level Design).
## Si activé, le générateur aléatoire est mis en pause.
@export var use_manual_spawning: bool = true

var camera_manager: SB_CameraManager_VShmup
var viewport_manager: SB_ViewportManager_VShmup

# --- État Interne ---
var _spawn_timer: float = 0.0
var score: int = 0
var combo_level: int = 0
var combo_max: int = 0
var combo_timer: float = 0.0
var is_game_over: bool = false

@export var game_over_scene: PackedScene = preload("res://stoneblock/ui/SB_GameOver_VShmup.tscn")

@export_group("Quality & Performance")
@export var quality_startup_delay: float = 2.0
@export var interpolation_smoothness: float = 2.0

@export_subgroup("Background Quality")
@export var bg_target_fps: float = 60.0
@export var bg_min_fps: float = 30.0
@export_range(0.1, 1.0, 0.05) var bg_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var bg_min_scale: float = 1.0

@export_subgroup("Mainground Quality")
@export var mg_target_fps: float = 50.0
@export var mg_min_fps: float = 25.0
@export_range(0.1, 1.0, 0.05) var mg_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var mg_min_scale: float = 0.8

@export_subgroup("Bloom Quality")
@export var bloom_target_fps: float = 60.0
@export var bloom_min_fps: float = 40.0
@export_range(0.1, 1.0, 0.05) var bloom_max_scale: float = 0.5
@export_range(0.1, 1.0, 0.05) var bloom_min_scale: float = 0.25

# --- Références Scène ---

# --- État ---
var world_position_z: float = 0.0
var camera_pivot: Node3D
var world_scroll_pivot: Node3D
var player: CharacterBody3D

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	# Récupération des paramètres de niveau depuis le Core
	if SB_Core.instance and not SB_Core.instance.level_data.is_empty():
		var data = SB_Core.instance.level_data
		if data.has("scroll_speed"):
			main_camera_speed = data["scroll_speed"]
		SB_Core.instance.log_msg("SHMUP : Configuration du niveau appliquée.", "success")
	
	_setup_modules()
	_load_level_content()
	_initialize_game()

func _setup_modules() -> void:
	# Fallbacks pour les Viewports (si non assignés dans l'inspecteur)
	if not background_viewport:
		background_viewport = get_node_or_null("Viewports_Layer/BackgroundViewportContainer/BackgroundViewport")
	if not mainground_viewport:
		mainground_viewport = get_node_or_null("Viewports_Layer/MaingroundViewportContainer/MaingroundViewport")
	if not bloom_viewport:
		bloom_viewport = get_node_or_null("Viewports_Layer/BloomViewportContainer/BloomViewport")
	if not ui_viewport:
		ui_viewport = get_node_or_null("Viewports_Layer/UIViewportContainer/UIViewport")

	# Création ou récupération des managers
	camera_manager = get_node_or_null("CameraManager")
	if not camera_manager:
		camera_manager = SB_CameraManager_VShmup.new()
		camera_manager.name = "CameraManager"
		add_child(camera_manager)
	
	viewport_manager = get_node_or_null("ViewportManager")
	if not viewport_manager:
		viewport_manager = SB_ViewportManager_VShmup.new()
		viewport_manager.name = "ViewportManager"
		add_child(viewport_manager)

func _load_level_content() -> void:
	var bg_path = default_background_scene
	var mg_path = default_mainground_scene
	var ui_path = default_ui_scene
	
	if SB_Core.instance and not SB_Core.instance.level_data.is_empty():
		var data = SB_Core.instance.level_data
		if data.has("background_scene"): bg_path = data["background_scene"]
		if data.has("mainground_scene"): mg_path = data["mainground_scene"]
		if data.has("ui_scene"): ui_path = data["ui_scene"]
	
	# Chargement et instanciation
	if not bg_path.is_empty() and background_viewport:
		var bg_res = load(bg_path)
		if bg_res: background_viewport.add_child(bg_res.instantiate())
		
	if not ui_path.is_empty() and ui_viewport:
		var ui_res = load(ui_path)
		if ui_res: ui_viewport.add_child(ui_res.instantiate())
		
	if not mg_path.is_empty() and mainground_viewport:
		var mg_res = load(mg_path)
		if mg_res:
			var mg_instance = mg_res.instantiate()
			mainground_viewport.add_child(mg_instance)
			
			# Récupération dynamique du joueur
			player = mg_instance.get_node_or_null("Player_VShmup")
			if not player:
				# Recherche récursive si nécessaire
				for child in mg_instance.get_children():
					if child is CharacterBody3D:
						player = child
						break
			
			# Application des réglages du Workshop (IP-035)
			if player and player.has_method("apply_workshop_settings") and SB_Core.instance:
				var stats = SB_Core.instance.get_stats()
				var s_id = stats.get("selected_ship", "phantom_jet")
				var p_id = stats.get("selected_powerup", "triple_shot")
				player.apply_workshop_settings(s_id, p_id)
	
	if SB_Core.instance:
		SB_Core.instance.log_msg("Contenu du niveau chargé dynamiquement.", "success")

func _initialize_game() -> void:
	# Réinitialisation des statistiques de session (pas la magie/coins qui est persistante)
	if SB_Core.instance:
		SB_Core.instance.set_stat("score", 0)
		SB_Core.instance.set_stat("combo_max", 0)
	
	# Initialisation Viewports avec réglages de qualité
	viewport_manager.startup_delay = quality_startup_delay
	viewport_manager.interpolation_smoothness = interpolation_smoothness
	
	viewport_manager.bg_target_fps = bg_target_fps
	viewport_manager.bg_min_fps = bg_min_fps
	viewport_manager.background_max_scale = bg_max_scale
	viewport_manager.background_min_scale = bg_min_scale
	
	viewport_manager.mg_target_fps = mg_target_fps
	viewport_manager.mg_min_fps = mg_min_fps
	viewport_manager.mainground_max_scale = mg_max_scale
	viewport_manager.mainground_min_scale = mg_min_scale
	
	viewport_manager.bloom_target_fps = bloom_target_fps
	viewport_manager.bloom_min_fps = bloom_min_fps
	viewport_manager.bloom_max_scale = bloom_max_scale
	viewport_manager.bloom_min_scale = bloom_min_scale
	
	viewport_manager.initialize(
		get_node_or_null("Viewports_Layer/BackgroundViewportContainer"), background_viewport,
		get_node_or_null("Viewports_Layer/MaingroundViewportContainer"), mainground_viewport,
		get_node_or_null("Viewports_Layer/BloomViewportContainer"), bloom_viewport,
		get_node_or_null("Viewports_Layer/UIViewportContainer"), ui_viewport
	)
	viewport_manager.apply_initial_scaling()
	
	# Initialisation Caméras
	var bg_cam = background_viewport.get_camera_3d() if background_viewport else null
	var mg_cam = mainground_viewport.get_camera_3d() if mainground_viewport else null
	var bl_cam = bloom_viewport.get_camera_3d() if bloom_viewport else null
	var uiv_cam = ui_viewport.get_camera_3d() if ui_viewport else null
	
	camera_manager.main_camera_speed = main_camera_speed
	camera_manager.use_dynamic_speed_zones = use_dynamic_speed_zones
	camera_manager.speed_zones = speed_zones
	camera_manager.map_limit_x = map_limit_x
	camera_manager.follow_deadzone_x = follow_deadzone_x
	camera_manager.show_deadzone_visual = show_deadzone_visual
	camera_manager.follow_speed_factor = follow_speed_factor
	camera_manager.initialize(bg_cam, mg_cam, bl_cam, uiv_cam)
	
	# Récupération du Pivot
	camera_pivot = get_node_or_null("Viewports_Layer/MaingroundViewportContainer/MaingroundViewport/Camera_Pivot")
	
	# Création dynamique d'un pivot de défilement mondial (pour les projectiles)
	if not world_scroll_pivot:
		world_scroll_pivot = Node3D.new()
		world_scroll_pivot.name = "World_Scroll_Pivot"
		if camera_pivot:
			camera_pivot.get_parent().add_child.call_deferred(world_scroll_pivot)
		elif mainground_viewport:
			mainground_viewport.add_child.call_deferred(world_scroll_pivot)
	
	# Appliquer les réglages de projection (Bloom et UI suivent Mainground)
	camera_manager.apply_settings_to_camera(bg_cam, bg_projection, bg_camera_y, bg_camera_size)
	camera_manager.apply_settings_to_camera(mg_cam, mg_projection, mg_camera_y, mg_camera_size)
	camera_manager.apply_settings_to_camera(bl_cam, mg_projection, mg_camera_y, mg_camera_size)
	camera_manager.apply_settings_to_camera(uiv_cam, mg_projection, mg_camera_y, mg_camera_size)
	
	# Partage du World3D : le BloomViewport doit voir le même monde que le Mainground.
	# own_world_3d doit être FALSE, sinon Godot ignore l'assignation du world_3d partagé.
	if bloom_viewport and mainground_viewport:
		bloom_viewport.own_world_3d = false  # Sécurité : doit être false pour que world_3d soit accepté
		bloom_viewport.world_3d = mainground_viewport.find_world_3d()

	# Forcer le BloomConfig à se résoudre après init (la Bloom_Camera est dans l'arbre à ce stade).
	var bloom_config = get_node_or_null("BloomConfig") as SB_BloomConfig
	if bloom_config:
		bloom_config._resolve_and_apply()

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or is_game_over: return
	
	var scroll_delta = camera_manager.current_scroll_speed * delta
	world_position_z -= scroll_delta
	
	# Mise à jour du Pivot (Scroll Z)
	if camera_pivot:
		camera_pivot.position.z = world_position_z
	
	if world_scroll_pivot:
		world_scroll_pivot.position.z = world_position_z
		
		# Récupération du joueur (Sibling désormais)
		if player:
			# Le JOUEUR doit aussi scroller en Z car il n'est plus enfant du pivot
			player.position.z -= scroll_delta
			
			# Le PIVOT suit le JOUEUR horizontalement (Vitesse proportionnelle)
			var target_x = player.global_position.x
			var dist = target_x - camera_pivot.global_position.x
			camera_pivot.global_position.x += dist * follow_speed_factor * delta
			camera_pivot.global_position.x = clamp(camera_pivot.global_position.x, -camera_manager.map_limit_x, camera_manager.map_limit_x)
	
	# Déléguer aux managers (La caméra suit la position globale du pivot)
	var cam_follow_x = camera_pivot.global_position.x if camera_pivot else 0.0
	camera_manager.update_cameras(delta, world_position_z, cam_follow_x)
	viewport_manager.update_dynamic_resolution()
	
	# Gestion des ennemis et combo
	_handle_spawning(delta)
	_handle_combo(delta)

func _handle_combo(delta: float) -> void:
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_level = 0

func add_score_kill() -> void:
	# Augmentation du combo
	combo_level += 1
	combo_timer = 5.0 
	
	# Calcul des points (10 de base + 10% par niveau de combo supérieur à 1)
	var points = 10 * (1.0 + (combo_level - 1) * 0.1)
	score += int(points)
	
	# Mise à jour locale du combo max
	if combo_level > combo_max:
		combo_max = combo_level
	
	# Synchro avec le Core
	if SB_Core.instance:
		SB_Core.instance.add_stat("score", int(points))
		SB_Core.instance.set_stat("combo_max", combo_max)

func trigger_game_over() -> void:
	if is_game_over: return
	is_game_over = true
	
	# Affichage de l'UI de défaite
	if game_over_scene:
		var go = game_over_scene.instantiate()
		add_child(go)
		if go.has_method("set_results"):
			var final_score = score
			var final_combo = combo_max
			if SB_Core.instance:
				var stats = SB_Core.instance.get_stats()
				final_score = stats.get("score", score)
				final_combo = stats.get("combo_max", combo_max)
			go.set_results(final_score, final_combo)

func _handle_spawning(delta: float) -> void:
	if use_manual_spawning: return
	if not enemy_scene: return
	
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval * (1.0 + randf_range(-spawn_randomness, spawn_randomness))
		_spawn_enemy()

func _spawn_enemy() -> void:
	# Spawn par groupes
	var count = randi_range(group_size_min, group_size_max)
	var base_x = camera_pivot.global_position.x + randf_range(-25, 25)
	var spawn_z = camera_pivot.global_position.z - 45.0
	
	for i in range(count):
		var enemy = enemy_scene.instantiate()
		# Décalage horizontal au sein du groupe
		var offset_x = (i - (count-1)/2.0) * 4.0 
		var final_x = clamp(base_x + offset_x, -map_limit_x, map_limit_x)
		
		if mainground_viewport:
			mainground_viewport.add_child(enemy)
			enemy.global_position = Vector3(final_x, 0, spawn_z - (i * 2.0)) # Petit décalage en profondeur aussi
