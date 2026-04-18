@tool
extends Node
class_name SB_BloomManager

## ⚙️ SB_BloomManager : Moteur technique du Bloom Sélectif StoneBlock.
## Gère le partage du monde 3D et la synchronisation des caméras.

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
	print("SB_BloomManager : _ready démarré.")
	setup_bloom_viewports()
	find_bloom_cameras()
	
	# Connexion au signal de pré-rendu pour une synchronisation parfaite (Zéro Latence)
	RenderingServer.frame_pre_draw.connect(_sync_everything)

func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(_sync_everything):
		RenderingServer.frame_pre_draw.disconnect(_sync_everything)

## Synchronisation totale (Optique + Taille + Config).
## Appelé par RenderingServer.frame_pre_draw juste avant le rendu.
func _sync_everything() -> void:
	if not is_inside_tree() or not main_viewport: return
	
	# Récupération dynamique de la caméra active du viewport (Auto-réparation)
	var active_cam = main_camera
	if not active_cam or not is_instance_valid(active_cam):
		active_cam = main_viewport.get_camera_3d()
		
	if not active_cam: return
	
	# 1. Synchronisation de la taille du Viewport (Pixel-Perfect)
	var target_size = main_viewport.size
	for container in [bloom_long_container, bloom_med_container, bloom_short_container]:
		if container:
			var vp = container.get_child(0) as SubViewport if container.get_child_count() > 0 else null
			if vp and vp.size != target_size:
				vp.size = target_size
	
	# 2. Synchronisation des caméras
	if bloom_cameras.is_empty():
		find_bloom_cameras()
	
	for b_cam in bloom_cameras:
		if is_instance_valid(b_cam):
			# Synchronisation totale sur la caméra ACTIVE
			b_cam.global_transform = active_cam.global_transform
			b_cam.projection = active_cam.projection
			b_cam.fov = active_cam.fov
			b_cam.size = active_cam.size
			b_cam.near = active_cam.near
			b_cam.far = active_cam.far
			b_cam.h_offset = active_cam.h_offset
			b_cam.v_offset = active_cam.v_offset
			
			# Correction spécifique pour l'orthogonalité
			if active_cam.projection == Camera3D.PROJECTION_ORTHOGONAL:
				b_cam.size = active_cam.size
	
	# 3. Plus besoin de link_with_config à chaque frame (IP-109)
	# Le lien est maintenu tant que les containers existent.

## Initialise le partage du monde 3D (World3D).
func setup_bloom_viewports() -> void:
	if not is_inside_tree(): return
	
	# SÉCURITÉ : Auto-réparation si on pointe sur le mauvais Viewport
	if not main_viewport or "BloomViewport" in main_viewport.name:
		var root = get_tree().root
		var real_main = root.find_child("MaingroundViewport", true, false) as SubViewport
		if real_main:
			print("SB_BloomManager : Branchement erroné détecté. Auto-correction vers " + real_main.name)
			main_viewport = real_main
		else:
			push_error("SB_BloomManager : IMPOSSIBLE de trouver le MaingroundViewport dans la scène !")
			return
	
	# Tentative d'acquisition du monde
	var main_world = main_viewport.get_world_3d()
	if not main_world:
		main_world = main_viewport.find_world_3d()
	
	if not main_world:
		print("SB_BloomManager : World3D non disponible sur " + str(main_viewport.name) + ". Tentative différée...")
		get_tree().create_timer(0.2).timeout.connect(setup_bloom_viewports)
		return
		
	print("SB_BloomManager : World3D trouvé sur " + str(main_viewport.name) + " !")
	
	# Configuration spécifique pour chaque container
	_setup_container(bloom_long_container, main_world, 1024)  # Layer 11
	_setup_container(bloom_med_container, main_world, 2048)   # Layer 12
	_setup_container(bloom_short_container, main_world, 4096)  # Layer 13
	
	print("SB_BloomManager : World3D partagé avec succès sur tous les containers.")
	
	# Mise à jour du BloomConfig s'il existe
	_link_with_config()

func _link_with_config() -> void:
	var root = get_tree().root
	var config = root.find_child("BloomConfig", true, false) as SB_BloomConfig
	if not config:
		# Essai sur l'Edited Scene Root si on est en Tool (au cas où)
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
		
		# On force les caméras à n'écouter QUE leur mask respectif
		var cams = vp.find_children("", "Camera3D", true)
		for c in cams:
			c.cull_mask = mask
			# Pour le debug : si c'est la caméra que MiniView affiche, on veut qu'elle voit !

## Trouve et liste les caméras de bloom dans les containers.
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
		print("SB_BloomManager : %d caméras de bloom trouvées et synchronisées." % bloom_cameras.size())
	elif not Engine.is_editor_hint():
		print("SB_BloomManager : ATTENTION - Aucune caméra de bloom trouvée dans les containers.")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not main_viewport: warnings.append("Veuillez assigner le Main Viewport.")
	if not main_camera: warnings.append("Veuillez assigner la Main Camera.")
	return warnings
