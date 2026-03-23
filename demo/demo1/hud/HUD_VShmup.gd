extends Control

## ⚡ HUD_VShmup : Gère l'affichage de l'énergie du joueur.

@onready var progress_bar: TextureProgressBar = $EnergyBar

var player: Node = null

func _ready() -> void:
	# Configuration de la taille et du centrage en code
	progress_bar.nine_patch_stretch = false
	progress_bar.layout_mode = 1 # Anchors
	progress_bar.anchors_preset = Control.PRESET_CENTER_TOP
	# Petit offset vertical pour ne pas coller au bord
	progress_bar.offset_top = 20
	
	# Offset du remplissage (foreground) par rapport au cadre
	progress_bar.texture_progress_offset = Vector2(24, 16)
	
	# On cherche le joueur par son nom "No-Code"
	_find_player()

func _process(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		_find_player()
		return
	
	if "energy" in player:
		progress_bar.value = player.energy
		if "energy_max" in player:
			progress_bar.max_value = player.energy_max

func _find_player() -> void:
	player = get_tree().root.find_child("Player_VShmup", true, false)
