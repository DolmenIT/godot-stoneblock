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
var viewport_manager: SB_ViewportManager_VShmup

# --- Qualité & Performance ---
@export_group("Quality & Performance")
@export var startup_delay: float = 2.5
@export var interpolation_smoothness: float = 5.0

@export_subgroup("Background Quality")
@export var bg_target_fps: float = 60.0
@export var bg_min_fps: float = 30.0
@export_range(0.1, 1.0, 0.05) var bg_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var bg_min_scale: float = 0.5
@export var bg_quality_cadence: float = 1.0
@export var bg_quality_step: float = 0.25

@export_subgroup("Mainground Quality")
@export var mg_target_fps: float = 60.0
@export var mg_min_fps: float = 30.0
@export_range(0.1, 1.0, 0.05) var mg_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var mg_min_scale: float = 0.75
@export var mg_quality_cadence: float = 1.0
@export var mg_quality_step: float = 0.25

@export_subgroup("Bloom Quality")
@export var bloom_target_fps: float = 60.0
@export var bloom_min_fps: float = 30.0
@export_range(0.1, 1.0, 0.05) var bloom_max_scale: float = 1.0
@export_range(0.1, 1.0, 0.05) var bloom_min_scale: float = 0.25
@export var bl_quality_cadence: float = 1.0
@export var bl_quality_step: float = 0.25

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
	
	viewport_manager = SB_ViewportManager_VShmup.new()
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
	# Config du ViewportManager (Dynamic Resolution)
	viewport_manager.startup_delay = startup_delay
	viewport_manager.interpolation_smoothness = interpolation_smoothness
	
	var m_scale = 1.0
	var m_fps = 1.0
	if SB_Core.instance and SB_Core.instance.is_mobile:
		m_scale = 0.5 # Facteur mobile standard
		m_fps = 0.75
	
	viewport_manager.bg_target_fps = bg_target_fps
	viewport_manager.bg_min_fps = bg_min_fps * m_fps
	viewport_manager.background_max_scale = bg_max_scale
	viewport_manager.background_min_scale = bg_min_scale * m_scale
	viewport_manager.bg_cadence = bg_quality_cadence
	viewport_manager.bg_step = bg_quality_step
	
	viewport_manager.mg_target_fps = mg_target_fps
	viewport_manager.mg_min_fps = mg_min_fps * m_fps
	viewport_manager.mainground_max_scale = mg_max_scale
	viewport_manager.mainground_min_scale = mg_min_scale * m_scale
	viewport_manager.mg_cadence = mg_quality_cadence
	viewport_manager.mg_step = mg_quality_step
	
	viewport_manager.bloom_target_fps = bloom_target_fps
	viewport_manager.bloom_min_fps = bloom_min_fps * m_fps
	viewport_manager.bloom_max_scale = bloom_max_scale
	viewport_manager.bloom_min_scale = bloom_min_scale * m_scale
	viewport_manager.bl_cadence = bl_quality_cadence
	viewport_manager.bl_step = bl_quality_step
	
	viewport_manager.initialize(
		get_node_or_null("Viewports_Layer/BackgroundViewportContainer"), background_viewport,
		get_node_or_null("Viewports_Layer/MaingroundViewportContainer"), mainground_viewport,
		null, null, null, null, null, null, # Bloom (optionnel ici, géré par BloomConfig)
		get_node_or_null("Viewports_Layer/UIViewportContainer"), ui_viewport
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
	
	# Initialisation du BloomConfig s'il existe
	var bloom_config = get_node_or_null("BloomConfig") as SB_BloomConfig
	if bloom_config:
		bloom_config._resolve_and_apply()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# Mise à jour de la résolution dynamique uniquement
	if viewport_manager:
		viewport_manager.update_dynamic_resolution()
	
	# Pas de scrolling Z ni de suivi X ici, on reste statique ou orchestré par le contenu lui-même.
