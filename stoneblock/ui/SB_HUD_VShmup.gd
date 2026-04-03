class_name SB_HUD_VShmup
extends Control

## ⚡ SB_HUD_VShmup : Gère l'affichage de l'énergie du joueur pour le mode VShmup.
## Ce composant est désormais centralisé dans StoneBlock Core.

@export var design_width: float = 1280.0

@onready var energy_bar: SB_SpriteProgressBar = %EnergyBar
@onready var shield_bar: SB_SpriteProgressBar = get_node_or_null("%ShieldBar")
@onready var health_bar: SB_SpriteProgressBar = get_node_or_null("%HealthBar")

var player: Node = null
var gamemode: Node = null

@onready var score_label: Label = get_node_or_null("%ScoreLabel")
@onready var combo_label: Label = get_node_or_null("%ComboLabel")
@onready var coin_label: Label = get_node_or_null("%CoinLabel")

func _ready() -> void:
	# Connexion au redimensionnement de la fenêtre pour zoomer le HUD
	get_viewport().size_changed.connect(_update_scaling)
	_update_scaling()
	
	# On cherche le joueur et le gamemode
	_find_player()
	_find_gamemode()

func _update_scaling() -> void:
	# Zoom global proportionnel sans casser ton placement
	var s = 1.0
	if get_viewport():
		s = get_viewport().size.x / design_width
	
	self.scale = Vector2(s, s)

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
	
	# Mise à jour du Combo (Désactivé au profit de l'IP-066 : Texte Flottant sur l'ennemi)
	if combo_label:
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
