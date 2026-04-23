@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends MeshInstance3D
class_name SB_VideoPlayer3D

## 📽️ SB_VideoPlayer3D : Affiche une vidÃ©o sur une surface 3D.
## Supporte le Bloom, le partage de mÃ©moire et l'aperÃ§u Ã©diteur.

enum PlaybackMode { INDIVIDUAL, SHARED }

## Le fichier vidÃ©o (.ogv ou .webm).
@export var video_stream: VideoStream:
	set(v):
		video_stream = v
		_refresh_playback()

@export_group("Playback")
## INDIVIDUAL : IndÃ©pendant (permet des dÃ©calages). SHARED : PartagÃ© (synchro parfaite, trÃ¨s lÃ©ger).
@export var playback_mode: PlaybackMode = PlaybackMode.INDIVIDUAL:
	set(v):
		playback_mode = v
		_refresh_playback()

## Si vrai, la vidÃ©o boucle indÃ©finiment.
@export var auto_loop: bool = true
## Si vrai, lance la vidÃ©o dÃ¨s qu'elle est prÃªte.
@export var auto_play_on_ready: bool = true
## DÃ©lai avant de lancer la vidÃ©o (INDIVIDUAL uniquement).
@export var start_delay: float = 0.0
## Volume sonore de la vidÃ©o (0.0 Ã  1.0).
@export_range(0, 1) var audio_volume: float = 1.0:
	set(v):
		audio_volume = v
		if _video_player: _video_player.volume_db = linear_to_db(v)

@export_group("Visual")
@export var size: Vector2 = Vector2(16, 9):
	set(v):
		size = v
		_update_mesh()
@export var unshaded: bool = true:
	set(v):
		unshaded = v
		_update_material()
@export var preview_in_editor: bool = false:
	set(v):
		preview_in_editor = v
		_refresh_playback()

# REGISTRE STATIQUE pour le partage (IP-109)
static var _shared_viewports: Dictionary = {} # Key: VideoStream, Value: SubViewport

var _viewport: SubViewport
var _video_player: VideoStreamPlayer

func _ready() -> void:
	_refresh_playback()
	_update_mesh()

func _refresh_playback() -> void:
	if not is_inside_tree(): return
	_setup_internal_player()
	_update_material()
	
	if Engine.is_editor_hint():
		if preview_in_editor and _video_player:
			_video_player.play()
	else:
		if auto_play_on_ready and _video_player:
			if start_delay > 0 and playback_mode == PlaybackMode.INDIVIDUAL:
				get_tree().create_timer(start_delay).timeout.connect(_video_player.play)
			else:
				_video_player.play()

func _setup_internal_player() -> void:
	# 1. Nettoyage
	if _viewport and _viewport.get_parent() == self:
		_viewport.queue_free()
	_viewport = null
	_video_player = null
	
	if not video_stream: return

	# 2. Cas du mode SHARED
	if playback_mode == PlaybackMode.SHARED:
		if _shared_viewports.has(video_stream) and is_instance_valid(_shared_viewports[video_stream]):
			_viewport = _shared_viewports[video_stream]
			# On rÃ©cupÃ¨re le lecteur interne pour le volume
			_video_player = _viewport.get_child(0)
		else:
			# On crée le premier exemplaire partagÃ©
			_viewport = _create_new_viewport()
			_shared_viewports[video_stream] = _viewport
			# Note: Le viewport partagÃ© doit Ãªtre dans l'arbre, on le met sur le premier qui l'a crÃ©Ã©
			add_child(_viewport)
			_video_player = _viewport.get_child(0)
	else:
		# 3. Cas du mode INDIVIDUAL
		_viewport = _create_new_viewport()
		add_child(_viewport)
		_video_player = _viewport.get_child(0)

func _create_new_viewport() -> SubViewport:
	var vp = SubViewport.new()
	vp.name = "VideoViewport_" + str(video_stream.resource_path.get_file().get_basename())
	vp.size = Vector2i(1280, 720) # Résolution équilibrée
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	var player = VideoStreamPlayer.new()
	player.expand = true
	player.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	player.stream = video_stream
	player.volume_db = linear_to_db(audio_volume)
	player.finished.connect(func(): if auto_loop: player.play())
	vp.add_child(player)
	
	return vp

func _update_mesh() -> void:
	var q_mesh = QuadMesh.new()
	q_mesh.size = size
	mesh = q_mesh

func _update_material() -> void:
	var mat = StandardMaterial3D.new()
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED if unshaded else StandardMaterial3D.SHADING_MODE_PER_PIXEL
	if _viewport:
		mat.albedo_texture = _viewport.get_texture()
	mat.emission_enabled = true
	mat.emission = Color.WHITE
	set_surface_override_material(0, mat)
