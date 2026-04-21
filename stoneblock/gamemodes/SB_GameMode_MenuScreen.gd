@tool
extends Node
class_name SB_GameMode_MenuScreen

## 🚀 SB_GameMode_MenuScreen : Orchestrateur pour les menus 3D premium.
## Gère le rendu multi-couches (Viewports) et la qualité dynamique sans logique de combat.

# --- Configuration des Caméras ---
@export_group("Background Camera")
@export_enum("PERSPECTIVE:0", "ORTHOGONAL:1") var bg_projection: int = 1
@export var bg_camera_y: float = 200.0
@export var bg_camera_size: float = 200.0

@export_group("Mainground Camera")
@export_enum("PERSPECTIVE:0", "ORTHOGONAL:1") var mg_projection: int = 1
@export var mg_camera_y: float = 100.0
@export var mg_camera_size: float = 60.0

# --- Chargement du Contenu ---
@export_group("Content")
@export_file("*.tscn") var background_scene: String = "res://demo/demo1/levels/hangar/hangar_background.tscn"
@export_file("*.tscn") var mainground_scene: String = "res://demo/demo1/levels/hangar/hangar_3d_content.tscn"
@export_file("*.tscn") var ui_scene: String = ""

# --- Crochets Viewport (Hook) ---
@export_group("Viewports (Hook)")
@export var background_viewport: SubViewport
@export var mainground_viewport: SubViewport
@export var ui_viewport: SubViewport

# --- Managers ---
var camera_manager: SB_CameraManager_VShmup
var viewport_manager: SB_ViewportManager


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_setup_modules()
	_load_content()
	_initialize_orchestration()

func _setup_modules() -> void:
	# Fallbacks automatiques pour les Viewports
	if not background_viewport: background_viewport = get_node_or_null("Viewports_Layer/BackgroundViewportContainer/BackgroundViewport")
	if not mainground_viewport: mainground_viewport = get_node_or_null("Viewports_Layer/MaingroundViewportContainer/MaingroundViewport")
	if not ui_viewport: ui_viewport = get_node_or_null("Viewports_Layer/UIViewportContainer/UIViewport")

	# Création des managers (réutilisation des outils VShmup pour la cohérence)
	camera_manager = SB_CameraManager_VShmup.new()
	camera_manager.name = "CameraManager"
	add_child(camera_manager)
	
	viewport_manager = SB_ViewportManager.new()
	viewport_manager.name = "ViewportManager"
	add_child(viewport_manager)

func _load_content() -> void:
	if not background_scene.is_empty() and background_viewport:
		var bg_res = load(background_scene)
		if bg_res: background_viewport.add_child(bg_res.instantiate())
			
	if not mainground_scene.is_empty() and mainground_viewport:
		var mg_res = load(mainground_scene)
		if mg_res: mainground_viewport.add_child(mg_res.instantiate())
			
	if not ui_scene.is_empty() and ui_viewport:
		var ui_res = load(ui_scene)
		if ui_res: ui_viewport.add_child(ui_res.instantiate())

func _initialize_orchestration() -> void:
	# Recherche robuste du node de config QualityConfig
	var quality_config = find_child("SB_QualityConfig", true, false)
	if not quality_config:
		quality_config = find_child("QualityConfig", true, false)
	
	# Config du ViewportManager (Dynamic Resolution)
	viewport_manager.initialize(
		find_child("BackgroundViewportContainer", true, false), background_viewport,
		find_child("MaingroundViewportContainer", true, false), mainground_viewport,
		find_child("BloomLongContainer", true, false), find_child("BloomLongViewport", true, false),
		find_child("BloomMedContainer", true, false), find_child("BloomMedViewport", true, false),
		find_child("BloomShortContainer", true, false), find_child("BloomShortViewport", true, false),
		find_child("UIViewportContainer", true, false), ui_viewport,
		quality_config
	)
	viewport_manager.apply_initial_scaling()
	
	# Config des Caméras
	var bg_cam = background_viewport.get_camera_3d() if background_viewport else null
	var mg_cam = mainground_viewport.get_camera_3d() if mainground_viewport else null
	var uiv_cam = ui_viewport.get_camera_3d() if ui_viewport else null
	
	camera_manager.initialize(bg_cam, mg_cam, null, null, null, uiv_cam)
	
	# Application des projections
	camera_manager.apply_settings_to_camera(bg_cam, bg_projection, bg_camera_y, bg_camera_size)
	camera_manager.apply_settings_to_camera(mg_cam, mg_projection, mg_camera_y, mg_camera_size)
	camera_manager.apply_settings_to_camera(uiv_cam, mg_projection, mg_camera_y, mg_camera_size)
	
	# Initialisation du BloomConfig s'il existe (Recherche robuste)
	var bloom_config_node = get_node_or_null("SB_BloomConfig")
	if not bloom_config_node:
		bloom_config_node = get_node_or_null("BloomConfig")
		
	if bloom_config_node:
		viewport_manager.bloom_config = bloom_config_node
		if bloom_config_node.has_method("_resolve_and_apply"):
			bloom_config_node.call("_resolve_and_apply")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if viewport_manager:
		viewport_manager.update_dynamic_resolution()
	
	# Pas de scrolling Z ni de suivi X ici, on reste statique ou orchestré par le contenu lui-même.
