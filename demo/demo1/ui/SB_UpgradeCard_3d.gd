@tool
class_name SB_UpgradeCard_3d
extends Node3D

## 🃏 SB_UpgradeCard_3d : Carte d'amélioration pour l'Armurerie (Version Premium).
## Gère l'affichage multi-couches (Socle, Item, Deco) et les statistiques dynamiques.

enum Rarity { COMMUNE, RARE, LEGENDAIRE }
enum UpgradeType { WEAPON, PROJECTILE }

const RARITY_COLORS: Dictionary = {
	Rarity.COMMUNE:    Color("#19CC00"), # Vert
	Rarity.RARE:       Color("#002AB0"), # Bleu
	Rarity.LEGENDAIRE: Color("#A66000"), # Ambre/Jaune
}

const RARITY_NAMES: Dictionary = {
	Rarity.COMMUNE:    "RARETÉ COMMUNE",
	Rarity.RARE:       "RARETÉ RARE",
	Rarity.LEGENDAIRE: "RARETÉ LÉGENDAIRE",
}

const BAR_SHADER: String = """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float progress : hint_range(0.0, 1.0) = 0.5;
uniform vec4 color : source_color = vec4(1.0);
uniform float emission_energy = 2.0;
uniform float saturation : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float mask = step(UV.x, progress);
    vec3 bg_color = vec3(0.01, 0.01, 0.01);
    
    // Désaturation de la couleur de remplissage
    vec3 fill_color = color.rgb;
    float grey = dot(fill_color, vec3(0.299, 0.587, 0.114));
    fill_color = mix(vec3(grey), fill_color, saturation);
    
    vec3 final_color = mix(bg_color, fill_color, mask);
    ALBEDO = final_color;
    EMISSION = fill_color * emission_energy * mask * saturation;
    ALPHA = 0.9;
}
"""

const DESATURATION_SHADER: String = """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_texture : source_color;
uniform float saturation : hint_range(0.0, 1.0) = 1.0;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float emission_energy : hint_range(0.0, 5.0) = 1.0;

void fragment() {
	vec4 tex = texture(albedo_texture, UV) * albedo_color;
	float grey = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 final_color = mix(vec3(grey), tex.rgb, saturation);
	ALBEDO = final_color;
	EMISSION = final_color * emission_energy * saturation;
	ALPHA = tex.a;
}
"""

# ── Exports ──────────────────────────────────────────────────
@export_group("Données Upgrade")
@export var item_id: String = "rapid_fire":
	set(v): item_id = v; _update_card()
@export var upgrade_type: UpgradeType = UpgradeType.WEAPON:
	set(v): upgrade_type = v; _update_card()
@export var item_name: String = "RAPID FIRE":
	set(v): item_name = v; _update_card()
@export_multiline var item_description: String = "Augmente considérablement la cadence de tir.":
	set(v): item_description = v; _update_card()

@export_group("Stats")
@export var stat_1_value: int = 50:
	set(v): stat_1_value = v; _update_card()
@export var stat_2_value: int = 50:
	set(v): stat_2_value = v; _update_card()
@export var stat_3_value: int = 50:
	set(v): stat_3_value = v; _update_card()

@export_group("Evolution")
@export var quality_points: int = 0:
	set(v): quality_points = v; _update_card()
@export var stats_bonus: float = 1.0:
	set(v): stats_bonus = v; _update_card()

@export_group("Global")
@export var rarity: Rarity = Rarity.COMMUNE:
	set(v): rarity = v; _update_card()
@export var is_enabled: bool = false:
	set(v): is_enabled = v; _update_card()
@export var card_scale: float = 30.0:
	set(v): card_scale = v; _update_card()

@export_group("Textures par Rareté (Layer 2 - Deco)")
@export var texture_bg_commune: Texture2D = preload("res://assets/demo1/ship_card_green.png"):
	set(v): texture_bg_commune = v; _update_card()
@export var texture_bg_rare: Texture2D = preload("res://assets/demo1/ship_card_blue.png"):
	set(v): texture_bg_rare = v; _update_card()
@export var texture_bg_legendaire: Texture2D = preload("res://assets/demo1/ship_card_yellow.png"):
	set(v): texture_bg_legendaire = v; _update_card()

@export_group("Layer 0 - Socle")
@export var socle_texture: Texture2D = preload("res://assets/demo1/ship_card_background.png"):
	set(v): socle_texture = v; _update_card()
@export var socle_offset: Vector2 = Vector2.ZERO:
	set(v): socle_offset = v; _update_card()
@export var socle_scale: float = 1.0:
	set(v): socle_scale = v; _update_card()

@export_group("Layer 1 - Item")
@export var icon_texture: Texture2D = preload("res://assets/demo1/scout_light.png"):
	set(v): icon_texture = v; _update_card()
@export var item_offset: Vector2 = Vector2.ZERO:
	set(v): item_offset = v; _update_card()
@export var item_scale: float = 1.0:
	set(v): item_scale = v; _update_card()

@export_group("Layer 2 - Décoration / Défaut")
@export var decoration_texture: Texture2D = preload("res://assets/demo1/ship_card_green.png"):
	set(v): decoration_texture = v; _update_card()
@export var decoration_offset: Vector2 = Vector2.ZERO:
	set(v): decoration_offset = v; _update_card()
@export var decoration_scale: float = 1.0:
	set(v): decoration_scale = v; _update_card()

@export_group("Effets Bloom (Layer 12)")
@export var bloom_socle: bool = false:
	set(v): bloom_socle = v; _update_card()
@export var bloom_item: bool = false:
	set(v): bloom_item = v; _update_card()
@export var bloom_deco: bool = true:
	set(v): bloom_deco = v; _update_card()
@export var bloom_text_multiplier: float = 2.0:
	set(v): bloom_text_multiplier = v; _update_card()

# ── Références Internes ───────────────────────────────────────
@onready var _mesh_socle: MeshInstance3D = get_node_or_null("Layer0_Socle")
@onready var _mesh_item: MeshInstance3D = get_node_or_null("Layer1_Item")
@onready var _mesh_deco: MeshInstance3D = get_node_or_null("Layer2_Deco")

@onready var _lbl_class: Label3D = get_node_or_null("Labels/Label_Class")
@onready var _lbl_name: Label3D = get_node_or_null("Labels/Label_Name")
@onready var _lbl_description: Label3D = get_node_or_null("Labels/Label_Description")
@onready var _lbl_rarity_type: Label3D = get_node_or_null("Labels/Label_Rarity_Type")
@onready var _lbl_stars: Label3D = get_node_or_null("Labels/Label_Stars")
@onready var _lbl_quality: Label3D = get_node_or_null("Labels/Label_Quality")
@onready var _mesh_bar: MeshInstance3D = get_node_or_null("Labels/ProgressBar")

# Stats Nodes
@onready var _stat_1_node: Node3D = get_node_or_null("Labels/Stats/Health")
@onready var _stat_2_node: Node3D = get_node_or_null("Labels/Stats/Shield")
@onready var _stat_3_node: Node3D = get_node_or_null("Labels/Stats/Energy")

# ── Matériaux ────────────────────────────────────────────────
var _mat_socle: ShaderMaterial
var _mat_item: ShaderMaterial
var _mat_deco: ShaderMaterial
var _mat_bar: ShaderMaterial

var _cached_labels: Array[Label3D] = []

func _ready() -> void:
	_init_materials()
	_cache_ui_labels()
	_update_card()

func _cache_ui_labels() -> void:
	_cached_labels.clear()
	var labels_root = get_node_or_null("Labels")
	if labels_root:
		for lbl in labels_root.find_children("*", "Label3D", true):
			if lbl is Label3D:
				_cached_labels.append(lbl)

func _init_materials() -> void:
	_mat_socle = _create_ui_material(_mesh_socle)
	_mat_item = _create_ui_material(_mesh_item)
	_mat_deco = _create_ui_material(_mesh_deco)
	
	if _mesh_bar:
		_mat_bar = ShaderMaterial.new()
		_mat_bar.shader = Shader.new()
		_mat_bar.shader.code = BAR_SHADER
		_mesh_bar.material_override = _mat_bar

func _create_ui_material(mesh: MeshInstance3D) -> ShaderMaterial:
	if not mesh: return null
	var mat = ShaderMaterial.new()
	mat.shader = Shader.new()
	mat.shader.code = DESATURATION_SHADER
	mesh.material_override = mat
	return mat

func _update_card() -> void:
	if not is_inside_tree(): return
	if not _mat_socle: _init_materials()
	
	# --- Données réelles (SB_GameDatas) ---
	var saved_stats = {"rarity": int(rarity), "xp": quality_points, "stats_bonus": stats_bonus}
	if not Engine.is_editor_hint() and SB_GameDatas.instance:
		var category = "weapon" if upgrade_type == UpgradeType.WEAPON else "ammo"
		saved_stats = SB_GameDatas.instance.get_item_stats(category, item_id)
	
	var current_rarity = int(saved_stats.get("rarity", rarity))
	var current_xp = int(saved_stats.get("xp", quality_points))
	var current_bonus = float(saved_stats.get("stats_bonus", stats_bonus))

	# --- Layer 0 : Socle ---
	_update_layer(_mat_socle, _mesh_socle, socle_texture, bloom_socle, socle_offset, socle_scale)

	# --- Layer 1 : Item ---
	_update_layer(_mat_item, _mesh_item, icon_texture, bloom_item, item_offset, item_scale)

	# --- Layer 2 : Deco (Switch par rareté) ---
	var rarity_tex: Texture2D = null
	match current_rarity:
		Rarity.COMMUNE: rarity_tex = texture_bg_commune
		Rarity.RARE: rarity_tex = texture_bg_rare
		Rarity.LEGENDAIRE: rarity_tex = texture_bg_legendaire
			
	var final_deco_tex = rarity_tex if rarity_tex != null else decoration_texture
	_update_layer(_mat_deco, _mesh_deco, final_deco_tex, bloom_deco, decoration_offset, decoration_scale)

	# --- Textes & Labels ---
	if _lbl_class: _lbl_class.text = "UPGRADE ARME" if upgrade_type == UpgradeType.WEAPON else "UPGRADE PROJECTILE"
	if _lbl_name: _lbl_name.text = item_name
	if _lbl_description: _lbl_description.text = "PROPRIÉTÉS : " + item_description
	
	if _lbl_rarity_type: _lbl_rarity_type.text = RARITY_NAMES.get(current_rarity, "")
	if _lbl_stars:
		var s = ""
		for i in range(3): s += "★" if i <= current_rarity else "☆"
		_lbl_stars.text = s
	
	if _lbl_quality: _lbl_quality.text = "QUALITÉ : %d / 100 PTS" % current_xp
	
	if _mat_bar:
		_mat_bar.set_shader_parameter("progress", float(current_xp) / 100.0)
		_mat_bar.set_shader_parameter("color", RARITY_COLORS.get(current_rarity, Color.WHITE))
		_mat_bar.set_shader_parameter("saturation", 1.0 if is_enabled else 0.0)
		_mat_bar.set_shader_parameter("emission_energy", 2.0 if is_enabled else 0.0)
	
	if _mesh_bar:
		_mesh_bar.layers = 2049 if is_enabled else 1

	# --- Stats Dynamiques (mapping selon le type) ---
	_update_stat(_stat_1_node, "CADENCE" if upgrade_type == UpgradeType.WEAPON else "VITESSE", int(stat_1_value * current_bonus))
	_update_stat(_stat_2_node, "DÉGÂTS" if upgrade_type == UpgradeType.WEAPON else "PORTÉE", int(stat_2_value * current_bonus))
	_update_stat(_stat_3_node, "ÉNERGIE" if upgrade_type == UpgradeType.WEAPON else "TAILLE", int(stat_3_value * current_bonus))

	# --- Coloration HDR & Bloom ---
	var label_color: Color = RARITY_COLORS.get(current_rarity, Color.WHITE)
	if not is_enabled: label_color = Color("#777777")
		
	for lbl in _cached_labels:
		var has_pulse = lbl.get_script() != null and "outline_color" in lbl
		if has_pulse:
			var hdr = label_color * bloom_text_multiplier
			lbl.modulate = label_color
			lbl.set("outline_color", hdr)
			lbl.layers = 1 | 2048
		else:
			lbl.modulate = label_color
			lbl.outline_modulate = label_color
			lbl.layers = 1

	scale = Vector3.ONE * card_scale

func _update_layer(mat: ShaderMaterial, mesh: MeshInstance3D, tex: Texture2D, bloom_on: bool, offset: Vector2, node_scale: float) -> void:
	if mat:
		mat.set_shader_parameter("albedo_texture", tex)
		mat.set_shader_parameter("saturation", 1.0 if is_enabled else 0.0)
		mat.set_shader_parameter("albedo_color", Color.WHITE if is_enabled else Color(0.4, 0.4, 0.4))
		mat.set_shader_parameter("emission_energy", 1.5 if is_enabled else 0.0)
	if mesh:
		mesh.position.x = offset.x * 0.001
		mesh.position.z = offset.y * 0.001
		mesh.scale = Vector3.ONE * node_scale
		mesh.visible = tex != null
		if mesh.visible:
			mesh.layers = 2049 if (bloom_on and is_enabled) else 1
		else:
			mesh.layers = 0

func _update_stat(node: Node3D, title: String, value: int) -> void:
	if not node: return
	var lbl_title = node.get_node_or_null("Title")
	var lbl_value = node.get_node_or_null("Value")
	if lbl_title: lbl_title.text = title
	if lbl_value: lbl_value.text = str(value)

## 🎯 Effet de "Bump" (Feedback visuel punchy)
func bump() -> void:
	var tween = create_tween()
	var base_vec = Vector3.ONE * card_scale
	var target_vec = base_vec * 1.25
	
	# Grossissement rapide (0.1s)
	tween.tween_property(self, "scale", target_vec, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Retour à la normale (0.2s)
	tween.tween_property(self, "scale", base_vec, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
