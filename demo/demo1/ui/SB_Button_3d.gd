@tool
class_name SB_Button_3d
extends Node3D

## 🔘 SB_Button_3d : Composant hautement personnalisable
signal pressed
signal hovered(data: Dictionary)

@export_group("Thème & Styles")
## Nom de la classe de style dans le ThemeManager (ex: BTN_Play).
@export var style_class_name: String = "":
	set(v): 
		style_class_name = v
		_request_theme_refresh()
		_update_ui()

@export var metadata: Dictionary = {}

@export_group("Texte & Couleurs")
@export var text: String = "Button":
	set(v): text = v; _update_ui()
@export var font_size: int = 32:
	set(v): font_size = v; _update_ui()

@export_subgroup("Couleurs du Texte")
@export var text_color_normal: Color = Color.WHITE:
	set(v): text_color_normal = v; _update_ui()
@export var text_color_hover: Color = Color.WHITE:
	set(v): text_color_hover = v; _update_ui()
@export var text_color_pressed: Color = Color.WHITE:
	set(v): text_color_pressed = v; _update_ui()
@export var text_color_disabled: Color = Color(0.6, 0.6, 0.6):
	set(v): text_color_disabled = v; _update_ui()

@export_subgroup("Teintes du Bouton (Modulate)")
@export var tint_normal: Color = Color.WHITE:
	set(v): tint_normal = v; _update_ui()
@export var tint_hover: Color = Color.WHITE:
	set(v): tint_hover = v; _update_ui()
@export var tint_pressed: Color = Color.WHITE:
	set(v): tint_pressed = v; _update_ui()
@export var tint_disabled: Color = Color(0.4, 0.4, 0.4):
	set(v): tint_disabled = v; _update_ui()

@export_group("Textures (Style Nineslice)")
@export var use_only_normal_texture: bool = false:
	set(v): use_only_normal_texture = v; _update_ui()
@export var normal_texture: Texture2D:
	set(v): normal_texture = v; _update_ui()
@export var hover_texture: Texture2D:
	set(v): hover_texture = v; _update_ui()
@export var pressed_texture: Texture2D:
	set(v): pressed_texture = v; _update_ui()

@export_subgroup("Slice Margins")
@export var slice_margin_left: float = 32.0:
	set(v): slice_margin_left = v; _update_ui()
@export var slice_margin_top: float = 32.0:
	set(v): slice_margin_top = v; _update_ui()
@export var slice_margin_right: float = 32.0:
	set(v): slice_margin_right = v; _update_ui()
@export var slice_margin_bottom: float = 32.0:
	set(v): slice_margin_bottom = v; _update_ui()

@export_subgroup("Texture Cropping (Empty Margins)")
@export var crop_left: float = 10.0:
	set(v): crop_left = v; _update_ui()
@export var crop_top: float = 10.0:
	set(v): crop_top = v; _update_ui()
@export var crop_right: float = 10.0:
	set(v): crop_right = v; _update_ui()
@export var crop_bottom: float = 10.0:
	set(v): crop_bottom = v; _update_ui()

@export_group("Transitions & Animations")
@export var is_enabled: bool = true:
	set(v): is_enabled = v; _update_ui()
@export var transition_duration: float = 0.15

@export_subgroup("Echelles (Scale) par état")
@export var base_scale: float = 1.0:
	set(v): base_scale = v; _update_ui()
@export var hover_scale_factor: float = 1.1:
	set(v): hover_scale_factor = v; _update_ui()
@export var pressed_scale_factor: float = 0.95:
	set(v): pressed_scale_factor = v; _update_ui()




@export var target_scene: String = ""
@export var price: int = 0:
	set(v): price = v; _update_ui()
@export var currency_icon: Texture2D:
	set(v): currency_icon = v; _update_ui()
@export var auto_deduct: bool = true:
	set(v): auto_deduct = v; _update_ui()

@export_subgroup("Intensité Lumineuse (Pour Custom Bloom)")
@export var emission_energy_normal: float = 0.0:
	set(v): emission_energy_normal = v; _update_ui()
@export var emission_energy_hover: float = 1.5:
	set(v): emission_energy_hover = v; _update_ui()
@export var emission_energy_pressed: float = 3.75:
	set(v): emission_energy_pressed = v; _update_ui()

@export_subgroup("Layers (Cull Masks)")
@export_flags_3d_render var layer_normal: int = 1:
	set(v): layer_normal = v; _update_ui()
@export_flags_3d_render var layer_hover: int = 2049:
	set(v): layer_hover = v; _update_ui()
@export_flags_3d_render var layer_pressed: int = 3073:
	set(v): layer_pressed = v; _update_ui()
@export_flags_3d_render var layer_disabled: int = 1:
	set(v): layer_disabled = v; _update_ui()

# ── Shader 9-Slice Spatial ────────────────────────────────────
const SB_BUTTON_3D_SHADER: String = """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_texture : source_color;
uniform float saturation : hint_range(0.0, 1.0) = 1.0;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float emission_energy : hint_range(0.0, 5.0) = 1.0;

uniform vec4 slice_margins; // x: left, y: top, z: right, w: bottom
uniform vec2 real_size;
uniform vec2 tex_size;
uniform vec4 crop; // x: left, y: top, z: right, w: bottom

float get_uv(float pos, float size, float tex_size_full, float crop_start, float crop_end, float slice_start, float slice_end) {
	float useful_tex_size = tex_size_full - crop_start - crop_end;
	
	if (pos < slice_start) {
		// Region du coin : on prend les pixels de la texture 1:1 après le crop
		return (crop_start + pos) / tex_size_full;
	} else if (pos > size - slice_end) {
		// Region du coin opposé
		return (tex_size_full - crop_end - (size - pos)) / tex_size_full;
	} else {
		// Region centrale : ÉTIREMENT (Stretch)
		float center_real = max(size - slice_start - slice_end, 0.001);
		float center_tex = max(useful_tex_size - slice_start - slice_end, 0.001);
		float rel_pos = pos - slice_start;
		float stretched_pos = (rel_pos / center_real) * center_tex;
		return (crop_start + slice_start + stretched_pos) / tex_size_full;
	}
}

void fragment() {
	if (real_size.x <= 0.0 || real_size.y <= 0.0 || tex_size.x <= 0.0 || tex_size.y <= 0.0) {
		discard;
	}

	float tx = UV.x * real_size.x;
	float ty = UV.y * real_size.y;
	
	float target_x = get_uv(tx, real_size.x, tex_size.x, crop.x, crop.z, slice_margins.x, slice_margins.z);
	float target_y = get_uv(ty, real_size.y, tex_size.y, crop.y, crop.w, slice_margins.y, slice_margins.w);
	
	vec4 tex = texture(albedo_texture, vec2(target_x, target_y)) * albedo_color;
	float grey = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 final_color = mix(vec3(grey), tex.rgb, saturation);
	
	ALBEDO = final_color;
	EMISSION = final_color * emission_energy * saturation;
	ALPHA = tex.a;
}
"""

@onready var _mesh: MeshInstance3D = $Background
@onready var _label: Label3D = $Label
@onready var _area: Area3D = $Area3D
@onready var _price_display: Node3D = $PriceDisplay
@onready var _price_label: Label3D = $PriceDisplay/PriceLabel
@onready var _price_icon: Sprite3D = $PriceDisplay/PriceIcon

var _mat: ShaderMaterial
var _is_hovered: bool = false
var _is_pressed: bool = false
var _tween: Tween

var _current_emission: float = 0.0:
	set(v):
		_current_emission = v
		if _mat != null:
			_mat.set_shader_parameter("emission_energy", v)

func _ready() -> void:
	# 1. Initialisation Thème (IP-112)
	_request_theme_refresh()
	
	# 2. Initialisation Visuelle (Shader)
	if not _mesh: return
	_mat = ShaderMaterial.new()
	_mat.shader = Shader.new()
	_mat.shader.code = SB_BUTTON_3D_SHADER
	_mesh.material_override = _mat
	
	if not Engine.is_editor_hint():
		if _area:
			_area.mouse_entered.connect(_on_mouse_entered)
			_area.mouse_exited.connect(_on_mouse_exited)
			_area.input_event.connect(_on_input_event)
	
	_update_ui()

func _update_ui() -> void:
	if not is_inside_tree(): return
	if not _mat: return
	
	# --- CIBLES (Scale & Layers & Couleurs) ---
	var target_scale_val = base_scale
	var target_emission: float = emission_energy_normal
	var target_layer: int = layer_normal
	var target_tint: Color = tint_normal
	var target_text_color: Color = text_color_normal
	
	if not Engine.is_editor_hint() and is_enabled:
		if _is_pressed: 
			target_scale_val *= pressed_scale_factor
			target_emission = emission_energy_pressed
			target_layer = layer_pressed
			target_tint = tint_pressed
			target_text_color = text_color_pressed
		elif _is_hovered: 
			target_scale_val *= hover_scale_factor
			target_emission = emission_energy_hover
			target_layer = layer_hover
			# Auto-tint hover si non défini (plus clair)
			target_tint = tint_hover if tint_hover != Color.WHITE else tint_normal.lightened(0.2)
			target_text_color = text_color_hover
		
		# Cas Normal (si ni pressé ni survolé)
		if not _is_pressed and not _is_hovered:
			target_tint = tint_normal
	
	if not Engine.is_editor_hint() and is_enabled and _is_pressed:
		target_tint = tint_pressed if tint_pressed != Color.WHITE else tint_normal.darkened(0.2)
	elif Engine.is_editor_hint() and is_enabled:
		target_layer = layer_hover
		target_emission = emission_energy_hover
		
	if not is_enabled:
		target_layer = layer_disabled
		target_tint = tint_disabled
		target_text_color = text_color_disabled
		target_emission = 0.0

	# 1. Texture
	var target_tex = normal_texture
	if not is_enabled:
		target_tex = normal_texture
	elif not use_only_normal_texture:
		if _is_pressed:
			target_tex = pressed_texture if pressed_texture else normal_texture
		elif _is_hovered:
			target_tex = hover_texture if hover_texture else normal_texture
	
	_mat.set_shader_parameter("albedo_texture", target_tex)
	
	# 2. Paramètres 9-Slice (Totalement indépendants du Scale 3D global)
	if target_tex:
		_mat.set_shader_parameter("tex_size", target_tex.get_size())
		var mesh_size = Vector2(0.3, 0.1)
		if _mesh and _mesh.mesh and _mesh.mesh is QuadMesh:
			mesh_size = _mesh.mesh.size
		var useful_h = target_tex.get_height() - crop_top - crop_bottom
		var height_ratio = max(useful_h, 1.0) / max(mesh_size.y, 0.001)
		var r_size = mesh_size * height_ratio
		
		_mat.set_shader_parameter("real_size", r_size)
		_mat.set_shader_parameter("slice_margins", Vector4(slice_margin_left, slice_margin_top, slice_margin_right, slice_margin_bottom))
		_mat.set_shader_parameter("crop", Vector4(crop_left, crop_top, crop_right, crop_bottom))
	
	# 3. Application des matériaux et Layers
	var sat = 1.0 if is_enabled else 0.0
	_mat.set_shader_parameter("saturation", sat)
	_mat.set_shader_parameter("albedo_color", target_tint)
	_mesh.layers = target_layer
	
	if _label:
		_label.modulate = target_text_color
		_label.layers = target_layer
		_label.text = text
		_label.font_size = font_size
	
	# 4. Transitions fluides (Scale et Émission Shader)
	if Engine.is_editor_hint():
		scale = Vector3.ONE * target_scale_val
		_current_emission = target_emission # Preview Editor
	else:
		if _tween: _tween.kill()
		_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "scale", Vector3.ONE * target_scale_val, transition_duration)
		_tween.tween_property(self, "_current_emission", target_emission, transition_duration)
	
	# 5. Affichage du Prix
	_update_price_display()

func _update_price_display() -> void:
	if not _price_display: return
	
	if price <= 0:
		_price_display.visible = false
		_price_label.text = ""
		return
		
	_price_display.visible = true
	
	# Mise à jour synchronisée des layers
	var current_layer = layer_normal if not _is_hovered and not _is_pressed else (layer_hover if _is_hovered else layer_pressed)
	if not is_enabled: current_layer = layer_disabled
	
	_price_label.layers = current_layer
	_price_icon.layers = current_layer
	
	_price_label.text = str(price)
	_price_icon.texture = currency_icon
	_price_icon.visible = currency_icon != null
	
	# Logic Affordability
	var can_pay = true
	if not Engine.is_editor_hint() and SB_GameDatas.instance:
		can_pay = SB_GameDatas.instance.can_afford(price)
	
	var mod_color = Color.WHITE if can_pay else Color(1, 0.3, 0.3)
	_price_label.modulate = mod_color
	_price_icon.modulate = mod_color
	
	# Laisser l'utilisateur gérer la position de l'icône dans l'éditeur

func _on_mouse_entered() -> void:
	if not is_enabled: return
	_is_hovered = true
	hovered.emit(metadata)
	_update_ui()

func _on_mouse_exited() -> void:
	_is_hovered = false
	_is_pressed = false
	_update_ui()

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not is_enabled: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_pressed = true
		else:
			if _is_pressed:
				var can_interact = true
				if price > 0 and auto_deduct and SB_GameDatas.instance:
					if not SB_GameDatas.instance.spend_gold(price):
						can_interact = false
				
				if can_interact:
					pressed.emit()
					if target_scene != "": get_tree().change_scene_to_file(target_scene)
			_is_pressed = false
		_update_ui()


# --- SYSTÈME DE THÈMES MODULAIRE ---

## Appliqué par le SB_ThemeManager si style_class_name correspond.
func apply_theme_style(style: SB_BaseStyle) -> void:
	if style is SB_Button3d_Theme:
		var s: SB_Button3d_Theme = style as SB_Button3d_Theme
		
		# Injection des propriétés du thème
		if not s.default_text.is_empty():
			text = s.default_text
		tint_normal = s.tint_normal
		tint_hover = s.tint_hover
		tint_pressed = s.tint_pressed
		
		emission_energy_normal = s.emission_energy_normal
		emission_energy_hover = s.emission_energy_hover
		emission_energy_pressed = s.emission_energy_pressed
		
		layer_normal = s.layer_normal
		layer_hover = s.layer_hover
		layer_pressed = s.layer_pressed
		layer_disabled = s.layer_disabled
		
		font_size = s.font_size
		
		# Injection des couleurs de texte (si différent de blanc ou si configuré)
		text_color_normal = s.text_color_normal
		text_color_hover = s.text_color_hover
		text_color_pressed = s.text_color_pressed
			
		base_scale = s.base_scale
		hover_scale_factor = s.hover_scale_factor
		
		_update_ui()


func _request_theme_refresh() -> void:
	# Accès direct via Singleton (IP-112)
	var manager = SB_ThemeManager.instance
	
	if manager:
		if manager.has_method("request_style_update"):
			manager.call("request_style_update", self)
		else:
			push_warning("[SB_Button_3d] Le ThemeManager n'a pas de méthode request_style_update.")
	else:
		# Fallback vers le groupe si le singleton n'est pas encore prêt
		if is_inside_tree():
			var managers = get_tree().get_nodes_in_group("SB_ThemeManager")
			if managers.size() > 0:
				managers[0].call("request_style_update", self)
