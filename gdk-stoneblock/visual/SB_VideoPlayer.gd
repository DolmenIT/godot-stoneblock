@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends VideoStreamPlayer
class_name SB_VideoPlayer

## 🎬 SB_VideoPlayer : Lecteur vidéo optimisé pour StoneBlock.
## GÃ¨re le plein Ã©cran automatique, le loop et les transitions.

## Le fichier vidÃ©o (.ogv ou .webm).
@export var video_stream: VideoStream:
	set(v):
		video_stream = v
		stream = v

@export_group("Playback")
## Si vrai, la vidÃ©o boucle indÃ©finiment.
@export var auto_loop: bool = true
## Si vrai, lance la vidÃ©o dÃ¨s qu'elle est prÃªte.
@export var auto_play_on_ready: bool = true
## Volume sonore de la vidÃ©o (0.0 Ã  1.0).
@export_range(0, 1) var audio_volume: float = 1.0:
	set(v):
		audio_volume = v
		volume_db = linear_to_db(v)

@export_group("Layout")
## Si vrai, force la vidéo à couvrir tout l'écran (Stretch).
@export var force_fullscreen: bool = true

func _ready() -> void:
	# Configuration de base
	expand = true
	if force_fullscreen:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Gestion du Loop
	finished.connect(_on_finished)
	
	if not Engine.is_editor_hint():
		if auto_play_on_ready:
			play()

func _on_finished() -> void:
	if auto_loop:
		play()
	else:
		print("[SB_VideoPlayer] Lecture terminÃ©e.")

## Permet de changer de vidéo avec une petite sécurité.
func change_video(new_stream: VideoStream) -> void:
	stop()
	stream = new_stream
	play()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if stream == null:
		warnings.append("Aucun flux vidéo (stream) n'est assigné.")
	return warnings
