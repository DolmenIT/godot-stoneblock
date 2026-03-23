@tool
class_name SB_Button
extends Button

## 🔘 SB_Button : Bouton StoneBlock modulaire.
## Déclenche automatiquement tous les composants enfants possédant une méthode start() au clic.

@export_group("Visuals (StyleBox)")
## Texture pour l'état normal.
@export var normal_texture: Texture2D:
	set(v): normal_texture = v; _update_styles()
## Texture pour le survol (hover).
@export var hover_texture: Texture2D:
	set(v): hover_texture = v; _update_styles()
## Texture pour le clic (pressed).
@export var pressed_texture: Texture2D:
	set(v): pressed_texture = v; _update_styles()

@export_subgroup("9-Slice Settings")
## Marge de découpe à gauche.
@export var slice_margin_left: float = 100:
	set(v): slice_margin_left = v; _update_styles()
## Marge de découpe à droite.
@export var slice_margin_right: float = 100:
	set(v): slice_margin_right = v; _update_styles()
## Marge de découpe en haut.
@export var slice_margin_top: float = 20:
	set(v): slice_margin_top = v; _update_styles()
## Marge de découpe en bas.
@export var slice_margin_bottom: float = 20:
	set(v): slice_margin_bottom = v; _update_styles()
## Marge "vide/transparente" présente dans l'image autour du bouton (à ignorer).
@export var empty_margin: float = 10:
	set(v): empty_margin = v; _update_styles()
## Mode d'étirement horizontal.
@export_enum("Stretch:0", "Tile (Repeat):1", "Tile Fit:2") var axis_stretch_horizontal: int = 0:
	set(v): axis_stretch_horizontal = v; _update_styles()
## Mode d'étirement vertical.
@export_enum("Stretch:0", "Tile (Repeat):1", "Tile Fit:2") var axis_stretch_vertical: int = 0:
	set(v): axis_stretch_vertical = v; _update_styles()
## Si vrai, force la hauteur minimale du bouton pour correspondre à la texture (moins l'empty_margin).
@export var match_texture_height: bool = false:
	set(v): match_texture_height = v; _update_styles()


# Shader avec support du Cross-Fade (Fondu enchaîné)
const SB_BUTTON_SHADER = """
shader_type canvas_item;

uniform sampler2D tex_from;
uniform sampler2D tex_to;
uniform float mix_weight : hint_range(0.0, 1.0) = 0.0;
uniform float padding = 10.0;
uniform float slice_w = 100.0;
uniform vec2 real_size;
uniform vec2 tex_size;

void fragment() {
	float h_useful = tex_size.y - 2.0 * padding;
	float ratio = real_size.y / h_useful;
	
	float s_w = (slice_w + padding) * ratio;
	
	float x = UV.x * real_size.x;
	float target_uv_x = 0.0;
	
	if (x < s_w) {
		target_uv_x = (padding + (x / ratio)) / tex_size.x;
	} else if (x > real_size.x - s_w) {
		float dist_right = real_size.x - x;
		target_uv_x = (tex_size.x - padding - (dist_right / ratio)) / tex_size.x;
	} else {
		float center_w_orig = tex_size.x - 2.0 * (slice_w + padding);
		float center_w_now = real_size.x - 2.0 * s_w;
		float local_x = x - s_w;
		target_uv_x = (padding + slice_w + (local_x / center_w_now) * center_w_orig) / tex_size.x;
	}
	
	float y = UV.y * real_size.y;
	float target_uv_y = (padding + (y / real_size.y) * h_useful) / tex_size.y;
	
	vec4 col_from = texture(tex_from, vec2(target_uv_x, target_uv_y));
	vec4 col_to = texture(tex_to, vec2(target_uv_x, target_uv_y));
	
	COLOR = mix(col_from, col_to, mix_weight);
}
"""

@export_subgroup("Transitions")
## Durée des transitions (secondes).
@export var transition_duration: float = 0.15
## Augmentation de taille au survol (en pixels).
@export var hover_scale_px: float = 4.0
## Diminution de taille au clic (en pixels).
@export var pressed_scale_px: float = -4.0

var _last_state: String = ""
var _tex_from: Texture2D
var _tex_to: Texture2D
var _mix_weight: float = 1.0

func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	# Centre du bouton pour le scale
	pivot_offset = size / 2.0
	resized.connect(func(): pivot_offset = size / 2.0)
	
	# Désactiver les styles par défaut
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	
	_tex_to = normal_texture
	_tex_from = normal_texture
	_update_styles()

func _update_styles() -> void:
	if not normal_texture: return
		
	var bg = get_node_or_null("_sb_shader_bg")
	if not bg:
		bg = ColorRect.new()
		bg.name = "_sb_shader_bg"
		bg.show_behind_parent = true
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var mat = ShaderMaterial.new()
		mat.shader = Shader.new()
		mat.shader.code = SB_BUTTON_SHADER
		bg.material = mat
		add_child(bg)
	
	# Détection de l'état
	var current_state = "normal"
	var target_tex = normal_texture
	var target_scale = Vector2.ONE
	
	if is_pressed() and pressed_texture: 
		current_state = "pressed"
		target_tex = pressed_texture
		var s = (size.y + pressed_scale_px) / size.y if size.y > 0 else 1.0
		target_scale = Vector2(s, s)
	elif is_hovered() and hover_texture: 
		current_state = "hover"
		target_tex = hover_texture
		var s = (size.y + hover_scale_px) / size.y if size.y > 0 else 1.0
		target_scale = Vector2(s, s)
	
	# Animation si l'état change
	if current_state != _last_state:
		_last_state = current_state
		
		# On prépare le fondu
		_tex_from = _tex_to # On part de là où on était
		_tex_to = target_tex
		_mix_weight = 0.0
		
		var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "scale", target_scale, transition_duration)
		tw.tween_property(self, "_mix_weight", 1.0, transition_duration)
	
	bg.material.set_shader_parameter("tex_from", _tex_from)
	bg.material.set_shader_parameter("tex_to", _tex_to)
	bg.material.set_shader_parameter("mix_weight", _mix_weight)
	bg.material.set_shader_parameter("padding", empty_margin)
	bg.material.set_shader_parameter("slice_w", slice_margin_left)
	bg.material.set_shader_parameter("real_size", size)
	bg.material.set_shader_parameter("tex_size", normal_texture.get_size())

func _process(_delta: float) -> void:
	if normal_texture:
		_update_styles()

func _on_pressed() -> void:
	# Propagation de l'action à tous les enfants (Fondus, Redirects, Sons, etc.)
	for child in get_children():
		if child.has_method("start"):
			child.start()
