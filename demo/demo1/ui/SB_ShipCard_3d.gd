@tool
class_name SB_ShipCard_3d
extends Node3D

## 🛸 SB_ShipCard_3d : Version 3D de la fiche vaisseau (Diegetic UI).
## Gère l'affichage multi-couches (Socle, Ship, Deco) sur des MeshInstances.

enum Rarity { COMMUNE, RARE, LEGENDAIRE }

const RARITY_COLORS: Dictionary = {
	Rarity.COMMUNE:    Color("#19CC00"), # Vert émeraude profond premium
	Rarity.RARE:       Color("#002AB0"), # Bleu électrique profond (saturé)
	Rarity.LEGENDAIRE: Color("#A66000"), # Ambre profond pour Jaune néon
}

const STAR_COLORS: Dictionary = {
	Rarity.COMMUNE:    Color("#81C784"), # Vert clair
	Rarity.RARE:       Color("#64B5F6"), # Bleu clair
	Rarity.LEGENDAIRE: Color("#FFEE58"), # Jaune clair
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

void fragment() {
    float mask = step(UV.x, progress);
    vec3 bg_color = vec3(0.01, 0.01, 0.01);
    vec3 fill_color = color.rgb;
    
    vec3 final_color = mix(bg_color, fill_color, mask);
    ALBEDO = final_color;
    EMISSION = fill_color * emission_energy * mask;
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
@export_group("Données Vaisseau")
@export_group("Stats & Infos")
@export var ship_name: String = "Viper X-1":
	set(v): ship_name = v; _update_card()
@export var ship_class: String = "Chasseur Léger":
	set(v): ship_class = v; _update_card()
@export var stat_health: int = 100:
	set(v): stat_health = v; _update_card()
@export var stat_shield: int = 50:
	set(v): stat_shield = v; _update_card()
@export var stat_energy: int = 40:
	set(v): stat_energy = v; _update_card()

@export_group("Armes & Upgrades")
@export var weapon_1_name: String = "VIDE":
	set(v): weapon_1_name = v; _update_card()
@export var weapon_2_name: String = "—":
	set(v): weapon_2_name = v; _update_card()
@export var weapon_3_name: String = "—":
	set(v): weapon_3_name = v; _update_card()
@export var ultimate_name: String = "—":
	set(v): ultimate_name = v; _update_card()

@export_group("Evolution")
@export var quality_points: int = 0:
	set(v): quality_points = v; _update_card()
@export var stats_bonus: float = 1.0:
	set(v): stats_bonus = v; _update_card()

@export_group("Global")
@export var rarity: Rarity = Rarity.COMMUNE:
	set(v): rarity = v; _update_card()
@export var is_enabled: bool = true:
	set(v): is_enabled = v; _update_card()

@export_group("Textures par Rareté (Layer 2 - Deco)")
@export var texture_bg_commune: Texture2D:
	set(v): texture_bg_commune = v; _update_card()
@export var texture_bg_rare: Texture2D:
	set(v): texture_bg_rare = v; _update_card()
@export var texture_bg_legendaire: Texture2D:
	set(v): texture_bg_legendaire = v; _update_card()

@export_group("Layer 0 - Socle")
@export var ship_socle_texture: Texture2D:
	set(v): ship_socle_texture = v; _update_card()
@export var ship_socle_offset: Vector2 = Vector2.ZERO:
	set(v): ship_socle_offset = v; _update_card()
@export var ship_socle_scale: float = 1.0:
	set(v): ship_socle_scale = v; _update_card()

@export_group("Layer 1 - Vaisseau")
@export var ship_texture: Texture2D:
	set(v): ship_texture = v; _update_card()
@export var ship_offset: Vector2 = Vector2.ZERO:
	set(v): ship_offset = v; _update_card()
@export var ship_scale: float = 1.0:
	set(v): ship_scale = v; _update_card()

@export_group("Layer 2 - Décoration / Rareté")
@export var ship_decoration_texture: Texture2D:
	set(v): ship_decoration_texture = v; _update_card()
@export var ship_decoration_offset: Vector2 = Vector2.ZERO:
	set(v): ship_decoration_offset = v; _update_card()
@export var ship_decoration_scale: float = 1.0:
	set(v): ship_decoration_scale = v; _update_card()

@export_group("Global")
@export var card_scale: float = 1.0:
	set(v): card_scale = v; _update_card()

@export_group("Effets Bloom (Layer 12)")
@export var bloom_socle: bool = false:
	set(v): bloom_socle = v; _update_card()
@export var bloom_ship: bool = false:
	set(v): bloom_ship = v; _update_card()
@export var bloom_deco: bool = true:
	set(v): bloom_deco = v; _update_card()
@export var bloom_text_multiplier: float = 2.0:
	set(v): bloom_text_multiplier = v; _update_card()

# ── Références Internes ───────────────────────────────────────
@onready var _mesh_socle: MeshInstance3D = get_node_or_null("Layer0_Socle")
@onready var _mesh_ship: MeshInstance3D = get_node_or_null("Layer1_Ship")
@onready var _mesh_deco: MeshInstance3D = get_node_or_null("Layer2_Deco")

# Références Textes
@onready var _lbl_class: Label3D = get_node_or_null("Labels/Label_Class")
@onready var _lbl_name: Label3D = get_node_or_null("Labels/Label_Name")
@onready var _lbl_health: Label3D = get_node_or_null("Labels/Stats/Health/Value")
@onready var _lbl_shield: Label3D = get_node_or_null("Labels/Stats/Shield/Value")
@onready var _lbl_energy: Label3D = get_node_or_null("Labels/Stats/Energy/Value")
@onready var _lbl_weapon1: Label3D = get_node_or_null("Labels/Weapons/W1/Value")
@onready var _lbl_weapon2: Label3D = get_node_or_null("Labels/Weapons/W2/Value")
@onready var _lbl_weapon3: Label3D = get_node_or_null("Labels/Weapons/W3/Value")
@onready var _lbl_ultimate: Label3D = get_node_or_null("Labels/Ultimate/Value")
@onready var _lbl_rarity_type: Label3D = get_node_or_null("Labels/Label_Rarity_Type")
@onready var _lbl_stars: Label3D = get_node_or_null("Labels/Label_Stars")
@onready var _lbl_quality: Label3D = get_node_or_null("Labels/Label_Quality")
@onready var _mesh_bar: MeshInstance3D = get_node_or_null("Labels/ProgressBar")

# ── Matériaux ────────────────────────────────────────────────
var _mat_socle: ShaderMaterial
var _mat_ship: ShaderMaterial
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
	_mat_ship = _create_ui_material(_mesh_ship)
	_mat_deco = _create_ui_material(_mesh_deco)
	
	if _mesh_bar:
		_mat_bar = ShaderMaterial.new()
		_mat_bar.shader = Shader.new()
		_mat_bar.shader.code = BAR_SHADER
		_mesh_bar.mesh = QuadMesh.new()
		_mesh_bar.mesh.size = Vector2(0.28, 0.008)
		_mesh_bar.material_override = _mat_bar

func _create_ui_material(mesh: MeshInstance3D) -> ShaderMaterial:
	if not mesh: return null
	var mat = ShaderMaterial.new()
	mat.shader = Shader.new()
	mat.shader.code = DESATURATION_SHADER
	
	mesh.material_override = mat
	return mat

func _build_stars(count: int) -> String:
	var s = ""
	for i in range(3):
		s += "★" if i < count else "☆"
	return s

func _update_card() -> void:
	if not is_inside_tree(): return
	if not _mat_socle: _init_materials()
	
	# --- Layer 0 : Socle ---
	if _mat_socle:
		_mat_socle.set_shader_parameter("albedo_texture", ship_socle_texture)
		_mat_socle.set_shader_parameter("saturation", 1.0 if is_enabled else 0.0)
		_mat_socle.set_shader_parameter("albedo_color", Color.WHITE if is_enabled else Color(0.4, 0.4, 0.4))
		_mat_socle.set_shader_parameter("emission_energy", 1.5 if is_enabled else 0.0)
	if _mesh_socle:
		_mesh_socle.position.x = ship_socle_offset.x * 0.001
		_mesh_socle.position.z = ship_socle_offset.y * 0.001
		_mesh_socle.scale = Vector3.ONE * ship_socle_scale
		_mesh_socle.visible = ship_socle_texture != null
		_mesh_socle.layers = 2049 if (bloom_socle and is_enabled) else 1

	# --- Layer 1 : Ship ---
	if _mat_ship:
		_mat_ship.set_shader_parameter("albedo_texture", ship_texture)
		_mat_ship.set_shader_parameter("saturation", 1.0 if is_enabled else 0.0)
		_mat_ship.set_shader_parameter("albedo_color", Color.WHITE if is_enabled else Color(0.4, 0.4, 0.4))
		_mat_ship.set_shader_parameter("emission_energy", 1.5 if is_enabled else 0.0)
	if _mesh_ship:
		_mesh_ship.position.x = ship_offset.x * 0.001
		_mesh_ship.position.z = ship_offset.y * 0.001
		_mesh_ship.scale = Vector3.ONE * ship_scale
		_mesh_ship.visible = ship_texture != null
		_mesh_ship.layers = 2049 if (bloom_ship and is_enabled) else 1

	# --- Layer 2 : Deco / Rareté ---
	var rarity_tex: Texture2D = null
	match rarity:
		Rarity.COMMUNE: rarity_tex = texture_bg_commune
		Rarity.RARE: rarity_tex = texture_bg_rare
		Rarity.LEGENDAIRE: rarity_tex = texture_bg_legendaire
			
	var final_deco_tex = rarity_tex if rarity_tex != null else ship_decoration_texture
	
	if _mat_deco:
		_mat_deco.set_shader_parameter("albedo_texture", final_deco_tex)
		_mat_deco.set_shader_parameter("saturation", 1.0 if is_enabled else 0.0)
		_mat_deco.set_shader_parameter("albedo_color", Color.WHITE if is_enabled else Color(0.4, 0.4, 0.4))
		_mat_deco.set_shader_parameter("emission_energy", 1.5 if is_enabled else 0.0)
	if _mesh_deco:
		_mesh_deco.position.x = ship_decoration_offset.x * 0.001
		_mesh_deco.position.z = ship_decoration_offset.y * 0.001
		_mesh_deco.scale = Vector3.ONE * ship_decoration_scale
		_mesh_deco.visible = final_deco_tex != null
		_mesh_deco.layers = 2049 if (bloom_deco and is_enabled) else 1
	
	# --- Textes & Labels ---
	if _lbl_class: _lbl_class.text = ship_class
	if _lbl_name: _lbl_name.text = ship_name
	
	if _lbl_rarity_type: _lbl_rarity_type.text = RARITY_NAMES.get(rarity, "")
	if _lbl_stars: _lbl_stars.text = _build_stars(int(rarity) + 1)
	if _lbl_quality: _lbl_quality.text = "QUALITÉ : %d / 100 PTS" % quality_points
	
	# Application XP au shader de la barre
	if _mat_bar:
		_mat_bar.set_shader_parameter("progress", float(quality_points) / 100.0)
		_mat_bar.set_shader_parameter("color", RARITY_COLORS.get(rarity, Color.WHITE))
	
	# Stats avec bonus multiplicateur
	if _lbl_health: _lbl_health.text = str(int(stat_health * stats_bonus))
	if _lbl_shield: _lbl_shield.text = str(int(stat_shield * stats_bonus))
	if _lbl_energy: _lbl_energy.text = str(int(stat_energy * stats_bonus))
	
	if _lbl_weapon1: _lbl_weapon1.text = weapon_1_name
	if _lbl_weapon2: _lbl_weapon2.text = weapon_2_name if rarity >= Rarity.RARE else "BLOQUÉ"
	if _lbl_weapon3: _lbl_weapon3.text = weapon_3_name if rarity >= Rarity.LEGENDAIRE else "BLOQUÉ"
	
	if _lbl_ultimate: _lbl_ultimate.text = ultimate_name if rarity >= Rarity.LEGENDAIRE else "BLOQUÉ"
	
	# --- Coloration HDR & Bloom (Wow effect) ---
	var label_color: Color = RARITY_COLORS.get(rarity, Color.WHITE)
	if not is_enabled:
		label_color = Color("#777777") # Gris moyen désaturé
		
	var labels_root = get_node_or_null("Labels")
	if labels_root:
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
	
	# Scale global de l'objet
	scale = Vector3.ONE * card_scale

## 🎯 Effet de "Bump" (Feedback visuel punchy)
func bump() -> void:
	var tween = create_tween()
	var base_vec = Vector3.ONE * card_scale
	var target_vec = base_vec * 1.25
	
	# Grossissement rapide (0.1s)
	tween.tween_property(self, "scale", target_vec, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Retour à la normale (0.2s)
	tween.tween_property(self, "scale", base_vec, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
