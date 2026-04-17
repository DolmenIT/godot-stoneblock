extends Node3D

## 🏛️ SB_Hangar_Logic : Gère les données dynamiques du Hangar.

@onready var gold_label: Label3D = $Label_Gold_Total
@onready var gold_icon: Sprite3D = $Icon_Gold_Total

# Références aux Navires
@onready var cards = {
	"Scout MK-1": $Cards_Root/Card_Commune,
	"Viper X-1": $Cards_Root/Card_Rare,
	"Titan S-9": $Cards_Root/Card_Legendaire
}

@onready var buttons = {
	"Scout MK-1": $Buttons_Root/BTN_Ameliorer,
	"Viper X-1": $Buttons_Root/BTN_Acheter_2,
	"Titan S-9": $Buttons_Root/BTN_Acheter_3
}

@onready var price_labels = {
	"Viper X-1": $Cards_Root/Label_Price_Rare,
	"Titan S-9": $Cards_Root/Label_Price_Legendary
}

func _ready() -> void:
	if SB_GameDatas.instance:
		SB_GameDatas.instance.gold_changed.connect(_on_gold_changed)
		_update_gold_display(SB_GameDatas.instance.get_value("gold"))
	
	# Configuration initiale des boutons
	for ship_id in buttons:
		var btn = buttons[ship_id]
		if btn:
			btn.pressed.connect(func(): _on_ship_btn_pressed(ship_id))
	
	_update_all_states()

const DONUT_FLASH_SCENE = preload("res://stoneblock/visual/bloom/SB_DonutFlash.tscn")

func _on_ship_btn_pressed(ship_id: String) -> void:
	var stats = SB_GameDatas.instance.get_item_stats("ship", ship_id)
	var owned_ships = SB_GameDatas.instance.get_value("inventory", {}).keys()
	var card = cards.get(ship_id)
	
	print("[SB_Hangar_Logic] Clic sur: ", ship_id, " | Possédé: ", owned_ships.has(ship_id), " | Card Node: ", card != null)
	
	if not owned_ships.has(ship_id):
		# ACHAT -> SHORT Bloom (Net/Sharp), 0.6s
		SB_GameDatas.instance.unlock_ship(ship_id)
		if card:
			_spawn_donut_flash(card.global_position, 4096, Color.WHITE, 0.6)
			card.bump()
		_update_all_states()
	else:
		# AMÉLIORATION / SAUT
		var xp = stats.get("xp", 0)
		var rarity = stats.get("rarity", 0)
		
		if xp < 100:
			# Palier d'amélioration (+20% XP) -> LONG Bloom (0.2s)
			SB_GameDatas.instance.add_item_xp("ship", ship_id, 20)
			var rarity_color = Color("#19CC00")
			if rarity == 1: rarity_color = Color("#002AB0")
			if rarity == 2: rarity_color = Color("#A66000")
			
			if card:
				_spawn_donut_flash(card.global_position, 1024, rarity_color, 0.2)
				card.bump()
			_update_all_states()
		elif xp >= 100 and rarity < 2:
			# Saut de rareté -> MEDIUM Bloom, 0.4s
			var old_rarity = rarity
			SB_GameDatas.instance.promote_item("ship", ship_id)
			
			var rarity_color = Color("#002AB0") # Vers Rare
			if old_rarity == 1: rarity_color = Color("#A66000") # Vers Légendaire
			
			if card:
				_spawn_donut_flash(card.global_position, 2048, rarity_color, 0.4)
				card.bump()
			_update_all_states()

func _spawn_donut_flash(pos: Vector3, layers: int, color: Color, duration: float) -> void:
	print("[SB_Hangar_Logic] Spawn Donut à ", pos, " sur calques ", layers, " (durée ", duration, ")")
	var donut = DONUT_FLASH_SCENE.instantiate()
	add_child(donut)
	donut.global_position = pos
	donut.setup(layers, color, duration)

func _on_gold_changed(new_amount: int) -> void:
	_update_gold_display(new_amount)
	_update_all_states()

func _update_all_states() -> void:
	var inventory = {}
	if SB_GameDatas.instance:
		inventory = SB_GameDatas.instance.get_value("inventory", {})
		
	for ship_id in cards:
		var is_owned = inventory.has(ship_id)
		var card = cards[ship_id]
		var btn = buttons[ship_id]
		var price_lbl = price_labels.get(ship_id)
		
		var stats = inventory.get(ship_id, {"rarity": 0, "xp": 0, "stats_bonus": 1.0})
		
		# 1. Mise à jour de la carte
		if card:
			card.is_enabled = is_owned
			if is_owned:
				card.rarity = stats["rarity"]
				card.quality_points = stats["xp"]
				card.stats_bonus = stats["stats_bonus"]
			
		# 2. Mise à jour du bouton
		if btn:
			if is_owned:
				var xp = stats.get("xp", 0)
				var rarity = stats.get("rarity", 0)
				
				if xp < 100:
					btn.text = "AMÉLIORER"
					btn.price = 500
				elif rarity < 2:
					btn.text = "SAUT COMMUNE" if rarity == 0 else "SAUT RARE"
					if rarity == 0: btn.text = "VERS RARE"
					if rarity == 1: btn.text = "VERS LÉGENDAIRE"
					btn.price = 1000
				else:
					btn.text = "MAXIMUM"
					btn.price = 0
					btn.is_enabled = false
				
				btn.tint_normal = Color(0.4, 0.8, 0.2)
			else:
				btn.text = "ACHETER"
				# Le prix d'achat initial reste celui de la scène
			
			btn._update_ui()
			
		# 3. Mise à jour du label de prix sous la carte
		if price_lbl:
			price_lbl.visible = not is_owned

func _update_gold_display(amount: int) -> void:
	if gold_label:
		gold_label.text = str(amount)
	
	if gold_icon:
		gold_icon.position.x = (gold_label.text.length() * 0.05) + 0.1
