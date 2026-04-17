extends Node3D

## ⚔️ SB_Armory_Logic : Gère les achats et améliorations d'armes/munitions.

@onready var gold_label: Label3D = $Label_Gold_Total

# Références aux cartes (organisées par catégories)
@onready var weapon_cards = {
	"rapid_fire":    $Cards/Weapons/Card_Rapid,
	"split_shot":    $Cards/Weapons/Card_Split,
	"multiple_shot": $Cards/Weapons/Card_Multiple,
	"oriented_shot": $Cards/Weapons/Card_Oriented,
	"rotative_shot": $Cards/Weapons/Card_Rotative
}

@onready var ammo_cards = {
	"beam_shot":      $Cards/Ammos/Card_Beam,
	"ricochet_shot":  $Cards/Ammos/Card_Ricochet,
	"explosive_shot": $Cards/Ammos/Card_Explosive,
	"homing_shot":    $Cards/Ammos/Card_Homing,
	"laser_shot":     $Cards/Ammos/Card_Laser
}

@onready var weapon_buttons = {
	"rapid_fire":    $Buttons/Weapons/BTN_Rapid,
	"split_shot":    $Buttons/Weapons/BTN_Split,
	"multiple_shot": $Buttons/Weapons/BTN_Multiple,
	"oriented_shot": $Buttons/Weapons/BTN_Oriented,
	"rotative_shot": $Buttons/Weapons/BTN_Rotative
}

@onready var ammo_buttons = {
	"beam_shot":      $Buttons/Ammos/BTN_Beam,
	"ricochet_shot":  $Buttons/Ammos/BTN_Ricochet,
	"explosive_shot": $Buttons/Ammos/BTN_Explosive,
	"homing_shot":    $Buttons/Ammos/BTN_Homing,
	"laser_shot":     $Buttons/Ammos/BTN_Laser
}

const DONUT_FLASH_SCENE = preload("res://stoneblock/visual/bloom/SB_DonutFlash.tscn")
const GOLD_ICON = preload("res://assets/icon_gold.png")

const COLOR_BUY = Color("#1c527c")     # Bleu Hangar
const COLOR_UPGRADE = Color("#2d5a1c") # Vert Hangar

func _ready() -> void:
	print("[SB_Armory_Logic] >>> DÉMARRAGE DE LA LOGIQUE")
	
	if SB_GameDatas.instance:
		print("[SB_Armory_Logic] SB_GameDatas trouvé. Connexion gold_changed.")
		if not SB_GameDatas.instance.gold_changed.is_connected(_on_gold_changed):
			SB_GameDatas.instance.gold_changed.connect(_on_gold_changed)
		_update_gold_display(SB_GameDatas.instance.get_value("gold"))
	else:
		print("[SB_Armory_Logic] WARNING : SB_GameDatas.instance est NUL. Mode dégradé (Test).")
	
	# Configuration initiale des boutons avec BIND (plus sûr pour les boucles)
	for id in weapon_buttons:
		var btn = weapon_buttons[id]
		if btn: 
			btn.pressed.connect(_on_upgrade_pressed.bind("weapon", id))
		else:
			print("[SB_Armory_Logic] ERROR : Bouton Arme introuvable pour '", id, "'")
		
	for id in ammo_buttons:
		var btn = ammo_buttons[id]
		if btn: 
			btn.pressed.connect(_on_upgrade_pressed.bind("ammo", id))
		else:
			print("[SB_Armory_Logic] ERROR : Bouton Munition introuvable pour '", id, "'")
	
	_update_all_states()
	print("[SB_Armory_Logic] >>> INITIALISATION TERMINÉE")

func _on_upgrade_pressed(category: String, item_id: String) -> void:
	if not SB_GameDatas.instance: return
	
	var stats = SB_GameDatas.instance.get_item_stats(category, item_id)
	var is_unlocked = stats.get("unlocked", false)
	# Fallback Rapid Fire (Supprimé pour progression réelle)
	
	var xp = stats.get("xp", 0)
	var rarity = stats.get("rarity", 0)
	var price = 500 # Prix par défaut
	
	# Calcul du prix (doit matcher avec _update_item_ui)
	if not is_unlocked: 
		price = 500 if category == "weapon" else 1000
	elif xp < 100:
		price = 250 * (rarity + 1)
	elif rarity < 2:
		price = 1000 * (rarity + 1)
	else:
		return # Max atteint
		
	# Vérification Or
	if not SB_GameDatas.instance.can_afford(price):
		print("[SB_Armory_Logic] Fonds insuffisants pour ", item_id)
		return
		
	# Paiement
	SB_GameDatas.instance.spend_gold(price)
	
	var card = weapon_cards.get(item_id) if category == "weapon" else ammo_cards.get(item_id)
	
	# 1. DÉBLOCAGE
	if not is_unlocked:
		SB_GameDatas.instance.unlock_armory_item(category, item_id)
		if card: _spawn_donut_flash(card.global_position, 4096, Color.WHITE, 0.6)
	
	# 2. AMÉLIORATION
	elif xp < 100:
		SB_GameDatas.instance.add_item_xp(category, item_id, 20)
		if card: _spawn_donut_flash(card.global_position, 1024, _get_rarity_color(rarity), 0.2)
	
	# 3. PROMOTION
	elif rarity < 2:
		SB_GameDatas.instance.promote_item(category, item_id)
		if card: _spawn_donut_flash(card.global_position, 2048, _get_rarity_color(rarity + 1), 0.4)
	
	if card: card.bump()
	_update_all_states()

func _get_rarity_color(rarity: int) -> Color:
	match rarity:
		0: return Color("#19CC00") # Commune
		1: return Color("#002AB0") # Rare
		2: return Color("#A66000") # Légendaire
	return Color.WHITE

func _spawn_donut_flash(pos: Vector3, layers: int, color: Color, duration: float) -> void:
	var donut = DONUT_FLASH_SCENE.instantiate()
	add_child(donut)
	donut.global_position = pos
	donut.setup(layers, color, duration)

func _on_gold_changed(new_amount: int) -> void:
	_update_gold_display(new_amount)
	_update_all_states()

func _update_all_states() -> void:
	# Mise à jour des cartes et boutons Armes
	for id in weapon_cards:
		_update_item_ui("weapon", id, weapon_cards[id], weapon_buttons[id])
		
	# Mise à jour des cartes et boutons Munitions
	for id in ammo_cards:
		_update_item_ui("ammo", id, ammo_cards[id], ammo_buttons[id])

func _update_item_ui(category: String, id: String, card, btn) -> void:
	var stats = {"unlocked": false, "xp": 0, "rarity": 0}
	if SB_GameDatas.instance:
		stats = SB_GameDatas.instance.get_item_stats(category, id)
	else:
		# Mode test si pas de GameDatas
		pass
	
	var is_unlocked = stats.get("unlocked", false)
	var xp = stats.get("xp", 0)
	var rarity = stats.get("rarity", 0)

	# 1. Mise à jour de la carte
	if card:
		card.is_enabled = is_unlocked
		if is_unlocked:
			card.rarity = rarity
			card.quality_points = xp
			card._update_card()
		
	# 2. Mise à jour du bouton
	if btn:
		btn.currency_icon = GOLD_ICON
		if not is_unlocked:
			btn.text = "ACHETER"
			btn.price = 500 if category == "weapon" else 1000
			btn.is_enabled = true
			btn.tint_normal = COLOR_BUY
		else:
			# État possédé -> On passe en VERT (Comme le hangar)
			btn.tint_normal = COLOR_UPGRADE
			
			if xp < 100:
				btn.text = "AMÉLIORER"
				btn.price = 250 * (rarity + 1)
				btn.is_enabled = true
			elif rarity < 2:
				var target_rarity_name = "RARE" if rarity == 0 else "LÉGENDAIRE"
				btn.text = "VERS " + target_rarity_name
				btn.price = 1000 * (rarity + 1)
				btn.is_enabled = true
			else:
				btn.text = "MAXIMUM"
				btn.price = 0
				btn.is_enabled = false
				btn.currency_icon = null
				btn.tint_disabled = Color(0.5, 0.5, 0.5)
		
		btn._update_ui()

func _update_gold_display(amount: int) -> void:
	if gold_label: gold_label.text = str(amount)
