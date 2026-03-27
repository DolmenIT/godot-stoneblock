extends Control

## ⚡ HUD_VShmup : Gère l'affichage de l'énergie du joueur.

@onready var energy_bar: TextureProgressBar = $EnergyBar
@onready var shield_bar: TextureProgressBar = get_node_or_null("ShieldBar")
@onready var health_bar: TextureProgressBar = get_node_or_null("HealthBar")

var player: Node = null
var gamemode: Node = null

@onready var score_label: Label = get_node_or_null("%ScoreLabel")
@onready var combo_label: Label = get_node_or_null("%ComboLabel")
@onready var coin_label: Label = get_node_or_null("%CoinLabel")

func _ready() -> void:
	# Configuration initiale
	energy_bar.nine_patch_stretch = false
	if shield_bar:
		shield_bar.nine_patch_stretch = false
		shield_bar.texture_progress_offset = Vector2(24, 16)
	if health_bar:
		health_bar.nine_patch_stretch = false
		health_bar.texture_progress_offset = Vector2(24, 16)
	
	# Connexion au redimensionnement de la fenêtre
	get_viewport().size_changed.connect(_update_scaling)
	_update_scaling()
	
	# Offset du remplissage (foreground) par rapport au cadre
	energy_bar.texture_progress_offset = Vector2(24, 16)
	
	# On cherche le joueur et le gamemode
	_find_player()
	_find_gamemode()

func _update_scaling() -> void:
	if not energy_bar.texture_over: return
	
	# Taille d'origine
	var orig_size = energy_bar.texture_over.get_size()
	
	# Calcul du facteur d'échelle
	var screen_width = get_viewport().size.x
	var target_width = max(200.0, screen_width * 0.2)
	var s = target_width / orig_size.x
	
	# Alignement Top-Left stable
	var margin = 20
	var spacing = 10
	var bar_height_scaled = orig_size.y * s
	
	# Superposition : Vie et Bouclier à la même position
	if health_bar:
		health_bar.scale = Vector2(s, s)
		health_bar.anchors_preset = Control.PRESET_TOP_LEFT
		health_bar.offset_left = margin
		health_bar.offset_top = margin
	
	if shield_bar:
		shield_bar.scale = Vector2(s, s)
		shield_bar.anchors_preset = Control.PRESET_TOP_LEFT
		shield_bar.offset_left = margin
		shield_bar.offset_top = margin
	
	energy_bar.scale = Vector2(s, s)
	energy_bar.anchors_preset = Control.PRESET_TOP_LEFT
	energy_bar.offset_left = margin
	
	# Énergie en dessous du bloc Vie/Bouclier
	energy_bar.offset_top = margin + bar_height_scaled + spacing

func _process(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		_find_player()
		return
	if not gamemode or not is_instance_valid(gamemode):
		_find_gamemode()
	
	if "energy" in player:
		energy_bar.value = player.energy
		energy_bar.max_value = player.energy_max
	
	if shield_bar and "shield" in player:
		shield_bar.value = player.shield
		shield_bar.max_value = player.shield_max
	
	if health_bar and "health" in player:
		health_bar.value = player.health
		health_bar.max_value = player.health_max
	
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
	
	# Mise à jour des Coins (via SB_Core)
	if coin_label and SB_Core.instance:
		var coins = SB_Core.instance.get_stat("magie")
		coin_label.text = "COINS: " + str(coins)
	elif coin_label:
		coin_label.text = "COINS: [N/A]" # Indique que le Core est manquant (test scène)

func _find_player() -> void:
	player = get_tree().root.find_child("Player_VShmup", true, false)

func _find_gamemode() -> void:
	gamemode = get_tree().root.find_child("Demo1_Shmup", true, false)
