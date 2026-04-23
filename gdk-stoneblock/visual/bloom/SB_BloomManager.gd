@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends SB_Manager
class_name SB_BloomManager

## ⚙️ SB_BloomManager : Moteur technique du Bloom Sélectif StoneBlock.
## Gère le partage du monde 3D et la synchronisation des caméras.

@export_tool_button("GENERATE_STRUCTURE", "res://gdk-stoneblock/assets/icons/SB_Core.svg")
var generate_trigger = _on_init_structure

@export_group("Target Hook")
## Le Viewport principal du jeu (Mainground).
@export var main_viewport: SubViewport:
	set(v):
		main_viewport = v
		if is_inside_tree(): update_configuration_warnings()

## La caméra de jeu principale à synchroniser.
@export var main_camera: Camera3D:
	set(v):
		main_camera = v
		if is_inside_tree(): update_configuration_warnings()

@export_group("Bloom Containers")
## Container pour le Bloom LONG (Layer 11).
@export var bloom_long_container: SubViewportContainer
## Container pour le Bloom MED (Layer 12).
@export var bloom_med_container: SubViewportContainer
## Container pour le Bloom SHORT (Layer 13).
@export var bloom_short_container: SubViewportContainer

var bloom_cameras: Array[Camera3D] = []

func _ready() -> void:
	if Engine.is_editor_hint(): return
	print("SB_BloomManager : _ready dÃ©marrÃ©.")
	setup_bloom_viewports()
	find_bloom_cameras()
	
	# Connexion au signal de pré-rendu pour une synchronisation parfaite (Zéro Latence)
	RenderingServer.frame_pre_draw.connect(_sync_everything)

func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(_sync_everything):
		RenderingServer.frame_pre_draw.disconnect(_sync_everything)


## Synchronisation totale (Optique + Taille + Config).
## AppelÃ© par RenderingServer.frame_pre_draw juste avant le rendu.
func _sync_everything() -> void:
	if not is_inside_tree() or not main_viewport: return
	
	# RÃ©cupÃ©ration dynamique de la camÃ©ra active du viewport (Auto-rÃ©paration)
	var active_cam = main_camera
	if not active_cam or not is_instance_valid(active_cam):
		active_cam = main_viewport.get_camera_3d()
		
	if not active_cam: return
	
	# TEST NUCLÃ‰AIRE : On force l'isolation de la camÃ©ra principale
	active_cam.cull_mask = 1
	
	if Engine.get_frames_drawn() % 60 == 0:
		print("[SB_BloomManager] Sync on Cam: ", active_cam.name, " | Mask: ", active_cam.cull_mask)
	
	# 1. Synchronisation de la taille du Viewport (Pixel-Perfect)
	var target_size = main_viewport.size
	for container in [bloom_long_container, bloom_med_container, bloom_short_container]:
		if container:
			var vp = container.get_child(0) as SubViewport if container.get_child_count() > 0 else null
			if vp and vp.size != target_size:
				vp.size = target_size
	
	# 2. Synchronisation des camÃ©ras
	if bloom_cameras.is_empty():
		find_bloom_cameras()
	
	for b_cam in bloom_cameras:
		if is_instance_valid(b_cam):
			# Synchronisation totale sur la camÃ©ra ACTIVE
			b_cam.global_transform = active_cam.global_transform
			b_cam.projection = active_cam.projection
			b_cam.fov = active_cam.fov
			b_cam.size = active_cam.size
			b_cam.near = active_cam.near
			b_cam.far = active_cam.far
			b_cam.h_offset = active_cam.h_offset
			b_cam.v_offset = active_cam.v_offset
			
			# Correction spÃ©cifique pour l'orthogonalitÃ©
			if active_cam.projection == Camera3D.PROJECTION_ORTHOGONAL:
				b_cam.size = active_cam.size
	
	# 3. Plus besoin de link_with_config Ã  chaque frame (IP-109)
	# Le lien est maintenu tant que les containers existent.

## Initialise le partage du monde 3D (World3D).
func setup_bloom_viewports() -> void:
	if not is_inside_tree(): return
	
	# SÃ‰CURITÃ‰ : Auto-rÃ©paration si on pointe sur le mauvais Viewport
	if not main_viewport or "BloomViewport" in main_viewport.name:
		var root = get_tree().root
		var real_main = root.find_child("MaingroundViewport", true, false) as SubViewport
		if real_main:
			print("SB_BloomManager : Branchement erronÃ© dÃ©tectÃ©. Auto-correction vers " + real_main.name)
			main_viewport = real_main
		else:
			push_error("SB_BloomManager : IMPOSSIBLE de trouver le MaingroundViewport dans la scÃ¨ne !")
			return
	
	# Tentative d'acquisition du monde
	var main_world = main_viewport.get_world_3d()
	if not main_world:
		main_world = main_viewport.find_world_3d()
	
	if not main_world:
		print("SB_BloomManager : World3D non disponible sur " + str(main_viewport.name) + ". Tentative diffÃ©rÃ©e...")
		if not is_connected("timeout", setup_bloom_viewports):
			get_tree().create_timer(0.2).timeout.connect(setup_bloom_viewports)
		return
		
	print("SB_BloomManager : World3D trouvé sur " + str(main_viewport.name) + " !")
	
	# Configuration spÃ©cifique pour chaque container
	_setup_container(bloom_long_container, main_world, 1024)  # Layer 11
	_setup_container(bloom_med_container, main_world, 2048)   # Layer 12
	_setup_container(bloom_short_container, main_world, 4096)  # Layer 13
	
	print("SB_BloomManager : World3D partagÃ© avec succÃ¨s sur tous les containers.")
	
	# Mise Ã  jour du BloomConfig s'il existe
	_link_with_config()

func _link_with_config() -> void:
	var root = get_tree().root
	var config = root.find_child("BloomConfig", true, false) as SB_BloomConfig
	if not config:
		# Essai sur l'Edited Scene Root si on est en Tool (au cas oÃ¹)
		if Engine.is_editor_hint():
			config = get_tree().edited_scene_root.find_child("BloomConfig", true, false) as SB_BloomConfig
			
	if is_instance_valid(config):
		var m_long = bloom_long_container.material as ShaderMaterial if is_instance_valid(bloom_long_container) else null
		var m_med = bloom_med_container.material as ShaderMaterial if is_instance_valid(bloom_med_container) else null
		var m_short = bloom_short_container.material as ShaderMaterial if is_instance_valid(bloom_short_container) else null
		config.assign_materials(m_long, m_med, m_short)

func _setup_container(container: SubViewportContainer, world: World3D, mask: int) -> void:
	if not container: return
	var vp = container.get_child(0) as SubViewport if container.get_child_count() > 0 else null
	if vp:
		vp.own_world_3d = false
		vp.world_3d = world
		
		# SÃ‰CURITÃ‰ : On s'assure que la camÃ©ra du Viewport est bien celle qu'on va manipuler
		var cams = vp.find_children("", "Camera3D", true)
		for c in cams:
			c.cull_mask = mask
			print("[SB_BloomManager] Config Cam: ", c.name, " in ", vp.name, " Mask: ", c.cull_mask)


## Trouve et liste les camÃ©ras de bloom dans les containers.
func find_bloom_cameras() -> void:
	bloom_cameras.clear()
	for container in [bloom_long_container, bloom_med_container, bloom_short_container]:
		if container:
			var vp = container.get_child(0) as SubViewport if container.get_child_count() > 0 else null
			if vp:
				var cams = vp.find_children("", "Camera3D", true)
				for c in cams:
					bloom_cameras.append(c as Camera3D)
	
	if not bloom_cameras.is_empty():
		print("SB_BloomManager : %d camÃ©ras de bloom trouvÃ©es et synchronisÃ©es." % bloom_cameras.size())
	elif not Engine.is_editor_hint():
		print("SB_BloomManager : ATTENTION - Aucune camÃ©ra de bloom trouvÃ©e dans les containers.")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not main_viewport: warnings.append("Veuillez assigner le Main Viewport.")
	# On ne met plus la camÃ©ra en warning car elle est trouvÃ©e dynamiquement si nulle
	return warnings

# --- Auto-Setup Logic ---

func _on_init_structure() -> void:
	if not Engine.is_editor_hint(): return
	
	print("[SB_BloomManager] GÃ©nÃ©ration de la Bloom Stack...")
	
	# 1. Recherche des nœuds principaux si vides
	var root = get_tree().edited_scene_root
	if not main_viewport:
		main_viewport = root.find_child("MaingroundViewport", true, false) as SubViewport
	
	if not main_camera:
		main_camera = root.find_child("Mainground_Camera", true, false) as Camera3D
	
	# 2. CrÃ©ation de la couche Bloom
	var bloom_layer = _get_or_create_node(get_parent(), "Bloom_Layer", "CanvasLayer")
	bloom_layer.layer = 1
	
	# Chargement du shader de flou premium
	var bloom_shader = load("res://gdk-stoneblock/shaders/SB_BloomBlur.gdshader")
	
	# 3. CrÃ©ation des Viewports
	var configs = {
		"Long": {"mask": 1024, "var": "bloom_long_container"},
		"Med": {"mask": 2048, "var": "bloom_med_container"},
		"Short": {"mask": 4096, "var": "bloom_short_container"}
	}
	
	for mode in configs.keys():
		var cfg = configs[mode]
		var b_cont = _get_or_create_node(bloom_layer, "Bloom" + mode + "Container", "SubViewportContainer")
		b_cont.stretch = true
		
		var smat = ShaderMaterial.new()
		smat.shader = bloom_shader
		b_cont.material = smat
		b_cont.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		b_cont.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var b_vp = _get_or_create_node(b_cont, "Bloom" + mode + "Viewport", "SubViewport")
		b_vp.transparent_bg = true
		b_vp.own_world_3d = false # Important : partage le monde !
		
		var b_cam = _get_or_create_node(b_vp, "Bloom" + mode + "_Camera", "Camera3D")
		b_cam.cull_mask = cfg.mask
		
		# Assignation Ã  l'export
		set(cfg.var, b_cont)

	# 4. Isolation de la caméra principale (doit ne voir que le Layer 1)
	if main_camera:
		main_camera.cull_mask = 1
		print("[SB_BloomManager] Isolation de Mainground_Camera (Cull Mask = 1)")

	# 5. Bloom Config
	_get_or_create_node(get_parent(), "SB_BloomConfig", "SB_BloomConfig")
	
	notify_property_list_changed()
	print("[SB_BloomManager] Bloom Stack gÃ©nÃ©rÃ©e avec succÃ¨s.")

func _get_or_create_node(parent: Node, node_name: String, node_type: String) -> Node:
	var existing = parent.get_node_or_null(node_name)
	if existing: return existing
	
	var new_node: Node
	match node_type:
		"CanvasLayer": new_node = CanvasLayer.new()
		"SubViewportContainer": new_node = SubViewportContainer.new()
		"SubViewport": new_node = SubViewport.new()
		"Camera3D": new_node = Camera3D.new()
		"Node": new_node = Node.new()
		"SB_BloomConfig": new_node = SB_BloomConfig.new()
	
	if new_node:
		new_node.name = node_name
		parent.add_child(new_node)
		new_node.owner = get_tree().edited_scene_root
		
		# On le déplace juste en dessous du manager si c'est un frère
		if parent == get_parent():
			parent.move_child(new_node, get_index() + 1)
			
		return new_node
	return null
