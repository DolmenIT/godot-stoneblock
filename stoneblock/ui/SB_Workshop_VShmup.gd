extends Control
class_name SB_Workshop_VShmup

## 🛠️ SB_Workshop_VShmup : Menu d'achat et de sélection (Vaisseaux & Powerups).

@onready var coin_label: Label = %CoinLabel
@onready var item_grid: GridContainer = %ItemGrid
@onready var ship_tab_btn: Button = %ShipTabButton
@onready var weapon_tab_btn: Button = %WeaponTabButton

var current_tab: String = "ships"

# Configuration des vaisseaux
var ships_data = {
	"phantom_jet": {"name": "Phantom Jet", "price": 0, "color": Color.SKY_BLUE, "desc": "Vaisseau de base équilibré."},
	"nexus_disk": {"name": "Nexus Disk", "price": 250, "color": Color.SEA_GREEN, "desc": "Plus agile mais moins blindé."},
	"storm_stalker": {"name": "Storm Stalker", "price": 750, "color": Color.ORANGE_RED, "desc": "Puissance de feu maximale."}
}

# Configuration des powerups
var weapons_data = {
	"triple_shot": {"name": "Triple Shot", "price": 0, "color": Color.GOLD, "desc": "Tir en éventail standard."},
	"dual_cannon": {"name": "Dual Cannon", "price": 150, "color": Color.HOT_PINK, "desc": "Tir frontal double puissant."},
	"heavy_laser": {"name": "Heavy Laser", "price": 400, "color": Color.PURPLE, "desc": "Laser continu massif."}
}

func _ready() -> void:
	if not SB_Core.instance:
		print("[Workshop] Erreur: SB_Core non trouvé.")
		return
		
	_refresh_ui()
	_on_tab_changed("ships")
	
	ship_tab_btn.pressed.connect(_on_tab_changed.bind("ships"))
	weapon_tab_btn.pressed.connect(_on_tab_changed.bind("weapons"))

func _refresh_ui() -> void:
	if coin_label:
		var coins = SB_Core.instance.get_stat("magie")
		coin_label.text = "QUARIUM COINS: " + str(coins)

func _on_tab_changed(tab: String) -> void:
	current_tab = tab
	# Mise à jour visuelle des onglets (optionnel: changer couleur)
	_rebuild_grid()

func _rebuild_grid() -> void:
	# Nettoyage de la grille
	for child in item_grid.get_children():
		child.queue_free()
	
	var data = ships_data if current_tab == "ships" else weapons_data
	var unlocked_key = "unlocked_ships" if current_tab == "ships" else "unlocked_powerups"
	var selected_key = "selected_ship" if current_tab == "ships" else "selected_powerup"
	
	var stats = SB_Core.instance.get_stats()
	var unlocked = stats.get(unlocked_key, [])
	var selected = stats.get(selected_key, "")
	
	for id in data:
		var item = data[id]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(200, 200)
		btn.text = "\n\n\n\n" + item["name"] # Placeholder text
		
		# Feedback d'état
		if id == selected:
			btn.text += "\n[ SÉLECTIONNÉ ]"
			btn.modulate = Color.GREEN
		elif id in unlocked:
			btn.text += "\n[ DÉBLOQUÉ ]"
			btn.modulate = Color.WHITE
		else:
			btn.text += "\nPROJET : " + str(item["price"])
			btn.modulate = Color.GRAY
			
		btn.pressed.connect(_on_item_pressed.bind(id, item))
		item_grid.add_child(btn)

func _on_item_pressed(id: String, item: Dictionary) -> void:
	var stats = SB_Core.instance.get_stats()
	var unlocked_key = "unlocked_ships" if current_tab == "ships" else "unlocked_powerups"
	var selected_key = "selected_ship" if current_tab == "ships" else "selected_powerup"
	
	var unlocked = stats.get(unlocked_key, [])
	var coins = stats.get("magie", 0)
	
	if id in unlocked:
		# Sélection
		SB_Core.instance.set_stat(selected_key, id)
	else:
		# Achat
		if coins >= item["price"]:
			SB_Core.instance.add_stat("magie", -item["price"])
			unlocked.append(id)
			SB_Core.instance.set_stat(unlocked_key, unlocked)
			SB_Core.instance.set_stat(selected_key, id) # Auto-sélection après achat
			SB_Core.instance.log_msg("Achat validé : " + item["name"], "success")
		else:
			SB_Core.instance.log_msg("Pas assez de Quarium !", "error")
	
	_refresh_ui()
	_rebuild_grid()

func _on_back_pressed() -> void:
	if SB_Core.instance:
		SB_Core.instance.load_scene_async("res://demo/demo1/10_menu_principal.tscn")
