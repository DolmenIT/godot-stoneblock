@tool
class_name SB_ShipCard
extends SB_Button

## 🛸 SB_ShipCard : Composant de fiche technique de vaisseau (650x950)
## Gère l'affichage des statistiques, de l'armement et de la progression qualité.

# ── Rareté (3 paliers) ───────────────────────────────────────
enum Rarity { COMMUNE, RARE, LEGENDAIRE }

const RARITY_COLORS: Dictionary = {
	Rarity.COMMUNE:    Color("#2E7D32"), # Vert foncé
	Rarity.RARE:       Color("#1565C0"), # Bleu foncé
	Rarity.LEGENDAIRE: Color("#E65100"), # Jaune/Orange foncé
}

const STAR_COLORS: Dictionary = {
	Rarity.COMMUNE:    Color("#81C784"), # Vert clair
	Rarity.RARE:       Color("#64B5F6"), # Bleu clair
	Rarity.LEGENDAIRE: Color("#FFEE58"), # Jaune clair
}

const RARITY_NAMES: Dictionary = {
	Rarity.COMMUNE:    "Rareté commune",
	Rarity.RARE:       "Rareté rare",
	Rarity.LEGENDAIRE: "Rareté légendaire",
}

# ── Signal ───────────────────────────────────────────────────
signal card_selected

# ── Exports ──────────────────────────────────────────────────
@export_group("Vaisseau")
@export var ship_name: String = "Viper X-1":
	set(v):
		ship_name = v
		if is_inside_tree(): _update_card()

@export var ship_class: String = "Chasseur Léger":
	set(v):
		ship_class = v
		if is_inside_tree(): _update_card()



@export var rarity: Rarity = Rarity.COMMUNE:
	set(v):
		rarity = v
		if is_inside_tree(): _update_card()

@export_group("Textures par Rareté")
@export var texture_bg_commune: Texture2D
@export var texture_bg_rare: Texture2D
@export var texture_bg_legendaire: Texture2D

@export_group("Layout - Socle (Layer 0)")
@export var ship_socle_texture: Texture2D:
	set(v):
		ship_socle_texture = v
		if is_inside_tree(): _update_card()
@export var ship_socle_offset: Vector2 = Vector2.ZERO:
	set(v):
		ship_socle_offset = v
		if is_inside_tree(): _update_card()
@export var ship_socle_scale: float = 1.0:
	set(v):
		ship_socle_scale = v
		if is_inside_tree(): _update_card()

@export_group("Layout - Vaisseau (Layer 1)")
@export var ship_texture: Texture2D:
	set(v):
		ship_texture = v
		if is_inside_tree(): _update_card()
@export var ship_offset: Vector2 = Vector2.ZERO:
	set(v):
		ship_offset = v
		if is_inside_tree(): _update_card()
@export var ship_scale: float = 1.0:
	set(v):
		ship_scale = v
		if is_inside_tree(): _update_card()

@export_group("Layout - Décoration (Layer 2)")
@export var ship_decoration_texture: Texture2D:
	set(v):
		ship_decoration_texture = v
		if is_inside_tree(): _update_card()
@export var ship_decoration_offset: Vector2 = Vector2.ZERO:
	set(v):
		ship_decoration_offset = v
		if is_inside_tree(): _update_card()
@export var ship_decoration_scale: float = 1.0:
	set(v):
		ship_decoration_scale = v
		if is_inside_tree(): _update_card()

@export_group("Amélioration")
## Score de qualité actuel (0 à 100)
@export_range(0, 100) var quality_points: int = 0:
	set(v):
		quality_points = clampi(v, 0, 100)
		if is_inside_tree(): _update_card()

## Valeur gagnée par dépense d'argent (Demo context)
@export var points_per_upgrade: int = 10

@export_group("Statistiques")
@export_range(0, 1000) var stat_health: int = 100:
	set(v):
		stat_health = v
		if is_inside_tree(): _update_card()

@export_range(0, 1000) var stat_shield: int = 50:
	set(v):
		stat_shield = v
		if is_inside_tree(): _update_card()

@export_range(0, 1000) var stat_energy: int = 40:
	set(v):
		stat_energy = v
		if is_inside_tree(): _update_card()

@export_group("État")
@export var is_locked: bool = false:
	set(v):
		is_locked = v
		if is_inside_tree(): _update_card()

@export var is_selected: bool = false:
	set(v):
		is_selected = v
		if is_inside_tree(): _update_card()

# ── Références internes ───────────────────────────────────────
@onready var _label_rarity: Label     = %LabelRarity
@onready var _label_name: Label       = %LabelShipName
@onready var _label_stars: Label      = %LabelStars
@onready var _label_class: Label      = %LabelShipClass
@onready var _label_health: Label     = %LabelStatHealth
@onready var _label_shield_stat: Label = %LabelStatShield
@onready var _label_energy: Label     = %LabelStatEnergy

# Titres secondaires à colorer
@onready var _label_stat_title_health: Label = %LabelStatTitleHealth
@onready var _label_stat_title_shield: Label = %LabelStatTitleShield
@onready var _label_stat_title_energy: Label = %LabelStatTitleEnergy
@onready var _label_weapon1_title: Label     = %LabelWeapon1Title
@onready var _label_weapon2_title: Label     = %LabelWeapon2Title
@onready var _label_weapon3_title: Label     = %LabelWeapon3Title
@onready var _label_upgrade1_title: Label    = %LabelUpgrade1Title
@onready var _label_upgrade2_title: Label    = %LabelUpgrade2Title
@onready var _label_upgrade3_title: Label    = %LabelUpgrade3Title
@onready var _label_ultimate_title: Label    = %LabelUltimateTitle

# Progression
@onready var _label_quality_pts: Label = %LabelQualityPoints
@onready var _progress_bar_quality: TextureProgressBar = %ProgressBarQuality

# Slots
@onready var _slot_1: Control         = %WeaponSlot1
@onready var _slot_2: Control         = %WeaponSlot2
@onready var _slot_3: Control         = %WeaponSlot3
@onready var _ultimate_slot: Control  = %UltimateSlot
@onready var _lock_overlay: ColorRect = %LockOverlay

# Couches de fond isolées
@onready var _socle_layer: TextureRect = get_node_or_null("BG_Layer_Root/SocleLayer")
@onready var _ship_layer: TextureRect = get_node_or_null("BG_Layer_Root/ShipLayer")
@onready var _deco_layer: TextureRect = get_node_or_null("BG_Layer_Root/DecorationLayer")

# ── Lifecycle ─────────────────────────────────────────────────
func _ready() -> void:
	# Active le zoom visuel pur de SB_Button pour ne pas briser notre layout strict !
	disable_physical_stretch = true
	text = ""
	
	super._ready()
	clip_contents = true
	_update_card()
	pressed.connect(_on_card_pressed)

# ── Mise à jour de l'affichage ────────────────────────────────
func _update_card() -> void:
	if not is_inside_tree(): return

	var rarity_name: String = RARITY_NAMES.get(rarity, "Rareté commune")
	var star_color: Color = STAR_COLORS.get(rarity, Color("#FFD700"))
	
	# Nombre d'étoiles = Index de rareté + 1
	var star_level: int = int(rarity) + 1

	# Teinte globale de la carte (15% de la couleur de rareté foncée)
	self.modulate = Color.WHITE.lerp(RARITY_COLORS.get(rarity, Color.WHITE), 0.15)

	# Mise à jour de la décoration (Cadre) selon la rareté
	var custom_deco: Texture2D = null
	match rarity:
		Rarity.COMMUNE: custom_deco = texture_bg_commune
		Rarity.RARE: custom_deco = texture_bg_rare
		Rarity.LEGENDAIRE: custom_deco = texture_bg_legendaire

	# Ne plus utiliser le shader de SB_Button, l'image du bouton reste null
	if normal_texture != null: normal_texture = null
	if hover_texture != null: hover_texture = null
	if pressed_texture != null: pressed_texture = null



	# Gestion de la barre de qualité
	if _progress_bar_quality:
		_progress_bar_quality.value = quality_points
		_progress_bar_quality.tint_progress = star_color
	
	if _label_quality_pts:
		_label_quality_pts.text = "Qualité : %d / 100 pts" % quality_points

	# Tous les textes prennent la couleur des étoiles
	var labels_to_color = [
		_label_name, _label_class, _label_rarity, _label_stars,
		_label_health, _label_shield_stat, _label_energy,
		_label_stat_title_health, _label_stat_title_shield, _label_stat_title_energy,
		_label_weapon1_title, _label_weapon2_title, _label_weapon3_title,
		_label_upgrade1_title, _label_upgrade2_title, _label_upgrade3_title,
		_label_ultimate_title, _label_quality_pts
	]
	
	for l in labels_to_color:
		if l: l.add_theme_color_override("font_color", star_color)

	# Textes dynamiques
	if _label_name:   _label_name.text   = ship_name
	if _label_class:  _label_class.text  = ship_class
	if _label_rarity: _label_rarity.text = rarity_name
	if _label_stars:  _label_stars.text  = _build_stars(star_level)
	
	if _label_health:      _label_health.text      = str(stat_health)
	if _label_shield_stat:  _label_shield_stat.text  = str(stat_shield)
	if _label_energy:      _label_energy.text      = str(stat_energy)

	# Slots d'armes actifs selon rareté
	# Commune: 1 slot | Rare: 2 slots | Leg: 3 slots
	_apply_slot(_slot_1, true) 
	_apply_slot(_slot_2, rarity >= Rarity.RARE)
	_apply_slot(_slot_3, rarity >= Rarity.LEGENDAIRE)
	_apply_slot(_ultimate_slot, rarity >= Rarity.LEGENDAIRE)

	# État verrouillé
	if _lock_overlay:
		_lock_overlay.visible = is_locked

	# --- MISE À JOUR DES COUCHES DE FOND ISOLÉES ---
	if _socle_layer:
		_socle_layer.texture = ship_socle_texture
		_socle_layer.position = ship_socle_offset
		_socle_layer.scale = Vector2.ONE * ship_socle_scale
		_socle_layer.visible = ship_socle_texture != null
		
	if _ship_layer:
		_ship_layer.texture = ship_texture
		_ship_layer.position = ship_offset
		_ship_layer.scale = Vector2.ONE * ship_scale
		_ship_layer.visible = ship_texture != null
	
	
	if _deco_layer:
		var final_deco = custom_deco if custom_deco != null else ship_decoration_texture
		_deco_layer.texture = final_deco
		_deco_layer.position = ship_decoration_offset
		_deco_layer.scale = Vector2.ONE * ship_decoration_scale
		_deco_layer.visible = final_deco != null

func _process(delta: float) -> void:
	super._process(delta)
	
	var sys_scale = 1.0
	var is_ed = Engine.is_editor_hint()
	if not is_ed and SB_Core.instance != null:
		sys_scale = SB_Core.instance.get_ui_scale()
	elif not is_ed and get_viewport() != null:
		sys_scale = float(get_viewport().size.y) / 540.0
		
	# Le scale visuel prend le relais ! On laisse la taille statique pour que le Wrapper ne tremble pas au survol.
	var p = get_parent()
	if p is Control and "Wrapper" in p.name:
		p.custom_minimum_size = custom_minimum_size * (base_scale * sys_scale)
	
	if is_ed:
		scale = Vector2.ONE * base_scale

# ── Helpers ──────────────────────────────────────────────────
func _build_stars(count: int) -> String:
	var s = ""
	for i in range(3):
		s += "★" if i < count else "☆"
	return s

func _apply_slot(slot: Control, active: bool) -> void:
	if not slot: return
	var bg = slot.get_node_or_null("SlotBg")
	var label = slot.get_node_or_null("SlotLabel")
	
	if bg:
		# On utilise les constantes de couleur du script
		bg.color = Color(0.12, 0.12, 0.12, 0.9) if active else Color(0.04, 0.04, 0.04, 0.6)
	
	if label:
		label.visible = active # Ou "VIDE" vs "—"
		if not active:
			label.visible = true
			label.text = "—"

func _on_card_pressed() -> void:
	card_selected.emit()
	print("[SB_ShipCard] Sélectionné : ", ship_name)
