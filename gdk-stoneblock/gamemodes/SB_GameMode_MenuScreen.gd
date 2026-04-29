@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
extends SB_2_World
class_name SB_GameMode_MenuScreen

## 🚀 SB_GameMode_MenuScreen : Orchestrateur pour les menus 3D premium.
## Gère le rendu multi-couches (Viewports) et la qualité dynamique sans logique de combat.

@export_tool_button("GENERATE_STRUCTURE", "res://gdk-stoneblock/assets/icons/SB_Core.svg")
var init_trigger = _on_init_prerequisites

@export var use_own_worlds: bool = true

# --- Configuration des Caméras ---
@export_group("Background Camera")
@export var bg_orientation: SB_CameraManager_VShmup.CameraOrientation = SB_CameraManager_VShmup.CameraOrientation.FRONT_VIEW
@export_enum("PERSPECTIVE:0", "ORTHOGONAL:1") var bg_projection: int = 0
@export var bg_camera_distance: float = 352.0
@export var bg_camera_size_fov: float = 75.0

@export_group("Mainground Camera")
@export var mg_orientation: SB_CameraManager_VShmup.CameraOrientation = SB_CameraManager_VShmup.CameraOrientation.FRONT_VIEW
@export_enum("PERSPECTIVE:0", "ORTHOGONAL:1") var mg_projection: int = 1
@export var mg_camera_distance: float = 100.0
@export var mg_camera_size_fov: float = 540.0

# --- Chargement du Contenu ---
@export_group("Content")
@export_file("*.tscn") var background_scene: String = ""
@export_file("*.tscn") var mainground_scene: String = ""

@export_group("Orientation Overrides")
@export_file("*.tscn") var background_landscape_scene: String = ""
@export_file("*.tscn") var background_portrait_scene: String = ""
@export_file("*.tscn") var mainground_landscape_scene: String = ""
@export_file("*.tscn") var mainground_portrait_scene: String = ""


# --- Crochets Viewport (Hook) ---
@export_group("Viewports (Hook)")
@export var background_viewport: SubViewport
@export var mainground_viewport: SubViewport

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

	# Création des managers (réutilisation des outils VShmup pour la cohérence)
	camera_manager = SB_CameraManager_VShmup.new()
	camera_manager.name = "CameraManager"
	add_child(camera_manager)
	
	viewport_manager = SB_ViewportManager.new()
	viewport_manager.name = "ViewportManager"
	add_child(viewport_manager)

func _load_content() -> void:
	var bg_to_load = background_scene
	var mg_to_load = mainground_scene
	
	if SB_Core.instance:
		var orient = SB_Core.instance.get_current_orientation()
		if orient == SB_Core.SBOrientation.LANDSCAPE:
			if not background_landscape_scene.is_empty(): bg_to_load = background_landscape_scene
			if not mainground_landscape_scene.is_empty(): mg_to_load = mainground_landscape_scene
		elif orient == SB_Core.SBOrientation.PORTRAIT:
			if not background_portrait_scene.is_empty(): bg_to_load = background_portrait_scene
			if not mainground_portrait_scene.is_empty(): mg_to_load = mainground_portrait_scene

	if not bg_to_load.is_empty() and background_viewport:
		var bg_res = load(bg_to_load)
		if bg_res: background_viewport.add_child(bg_res.instantiate())
			
	if not mg_to_load.is_empty() and mainground_viewport:
		var mg_res = load(mg_to_load)
		if mg_res: mainground_viewport.add_child(mg_res.instantiate())


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
		null, null,
		quality_config
	)
	viewport_manager.apply_initial_scaling()
	
	# Config des Caméras
	var bg_cam = background_viewport.get_camera_3d() if background_viewport else null
	var mg_cam = mainground_viewport.get_camera_3d() if mainground_viewport else null
	
	camera_manager.initialize(bg_cam, mg_cam, null, null, null, null)
	
	# Application des projections avec orientation
	camera_manager.apply_settings_to_camera(bg_cam, bg_projection, bg_camera_distance, bg_camera_size_fov, bg_orientation)
	camera_manager.apply_settings_to_camera(mg_cam, mg_projection, mg_camera_distance, mg_camera_size_fov, mg_orientation)
	
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

# --- Auto-Setup (Editor Only) ---

func _on_init_prerequisites() -> void:
	if not Engine.is_editor_hint(): return
	
	print("[SB_MenuScreen] Initialisation de la structure technique...")
	
	# 1. Création de la couche Viewports
	var v_layer = _get_or_create_node(self, "Viewports_Layer", "CanvasLayer")
	v_layer.layer = 0
	
	# 2. Background Stack
	var bg_v_cont = _get_or_create_node(v_layer, "BackgroundViewportContainer", "SubViewportContainer")
	bg_v_cont.stretch = true
	bg_v_cont.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var bg_vp = _get_or_create_node(bg_v_cont, "BackgroundViewport", "SubViewport")
	bg_vp.transparent_bg = false # OPAQUE pour voir la couleur de l'environnement
	bg_vp.own_world_3d = use_own_worlds
	
	_get_or_create_node(bg_vp, "WorldEnvironment", "WorldEnvironment")
	var bg_cam = _get_or_create_node(bg_vp, "Background_Camera", "Camera3D")
	bg_cam.cull_mask = 1 # Voit seulement Layer 1
	background_viewport = bg_vp
	
	# 3. Mainground Stack
	var mg_v_cont = _get_or_create_node(v_layer, "MaingroundViewportContainer", "SubViewportContainer")
	mg_v_cont.stretch = true
	mg_v_cont.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var mg_vp = _get_or_create_node(mg_v_cont, "MaingroundViewport", "SubViewport")
	mg_vp.transparent_bg = true
	mg_vp.own_world_3d = use_own_worlds
	
	_get_or_create_node(mg_vp, "WorldEnvironment", "WorldEnvironment")
	var mg_cam = _get_or_create_node(mg_vp, "Mainground_Camera", "Camera3D")
	mg_cam.cull_mask = 1 # Voit seulement Layer 1 (Exclut le Bloom 11, 12, 13)
	mainground_viewport = mg_vp

	notify_property_list_changed()
	print("[SB_MenuScreen] Structure minimale générée avec succès. Pensez à enregistrer la scène (Ctrl+S).")

func _get_or_create_node(parent: Node, node_name: String, node_type: String) -> Node:
	var existing = parent.get_node_or_null(node_name)
	if existing: return existing
	
	var new_node: Node
	match node_type:
		"CanvasLayer": new_node = CanvasLayer.new()
		"SubViewportContainer": new_node = SubViewportContainer.new()
		"SubViewport": new_node = SubViewport.new()
		"Camera3D": new_node = Camera3D.new()
		"WorldEnvironment": new_node = WorldEnvironment.new()
		"Node": new_node = Node.new()
		_: new_node = Node.new()
		
	new_node.name = node_name
	parent.add_child(new_node)
	new_node.owner = get_tree().edited_scene_root
	return new_node
