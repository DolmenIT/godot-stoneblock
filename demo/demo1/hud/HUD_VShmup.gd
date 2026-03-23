extends Control

## ⚡ HUD_VShmup : Gère l'affichage de l'énergie du joueur.

@onready var progress_bar: TextureProgressBar = $EnergyBar

var player: Node = null
var gamemode: Node = null

@onready var score_label: Label = get_node_or_null("%ScoreLabel")
@onready var combo_label: Label = get_node_or_null("%ComboLabel")

func _ready() -> void:
	# Configuration initiale : on garde la taille d'origine du texture
	progress_bar.nine_patch_stretch = false
	
	# Connexion au redimensionnement de la fenêtre
	get_viewport().size_changed.connect(_update_scaling)
	_update_scaling()
	
	# Offset du remplissage (foreground) par rapport au cadre
	progress_bar.texture_progress_offset = Vector2(24, 16)
	
	# On cherche le joueur et le gamemode
	_find_player()
	_find_gamemode()

func _update_scaling() -> void:
	if not progress_bar.texture_over: return
	
	# Taille d'origine de la texture de cadre
	var orig_size = progress_bar.texture_over.get_size()
	
	# Calcul du facteur d'échelle (20% de la largeur écran)
	var screen_width = get_viewport().size.x
	var target_width = max(200.0, screen_width * 0.2)
	var s = target_width / orig_size.x
	
	# On applique l'échelle uniformément
	progress_bar.scale = Vector2(s, s)
	
	# Pour centrer correctement une node avec une scale :
	# 1. On met le pivot au centre en haut
	progress_bar.pivot_offset = Vector2(orig_size.x / 2.0, 0)
	# 2. On utilise le preset de centrage Top
	progress_bar.anchors_preset = Control.PRESET_CENTER_TOP
	progress_bar.offset_top = 20
	# 3. Comme on a un pivot horizontal au milieu (0.5), l'offset_left doit être à 0
	# car le preset Center_Top met l'anchor_left à 0.5 et l'offset à -size/2
	# Mais avec le pivot, Godot 4 gère ça bien.

func _process(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		_find_player()
		return
	if not gamemode or not is_instance_valid(gamemode):
		_find_gamemode()
	
	if "energy" in player:
		progress_bar.value = player.energy
		if "energy_max" in player:
			progress_bar.max_value = player.energy_max
	
	# Mise à jour du Score (via GameMode)
	if gamemode and score_label:
		score_label.text = "SCORE: " + str(gamemode.get("score"))
	
	# Mise à jour du Combo
	if gamemode and combo_label:
		var c_lvl = gamemode.get("combo_level")
		if c_lvl > 1:
			combo_label.visible = true
			combo_label.text = "COMBO X" + str(c_lvl)
		else:
			combo_label.visible = false

func _find_player() -> void:
	player = get_tree().root.find_child("Player_VShmup", true, false)

func _find_gamemode() -> void:
	gamemode = get_tree().root.find_child("Demo1_Shmup", true, false)
