@tool
class_name SB_LevelCard_3d
extends Node3D

## 🗺️ SB_LevelCard_3d : Carte de sélection de niveau 3D.
## Basée sur l'esthétique Upgrade Card avec logique de bouton intégrée.

signal pressed
signal hovered(data: Dictionary)

@export_group("Données du Niveau")
@export var level_id: String = "L1S1":
	set(v): level_id = v; _update_ui()
@export var stage_name: String = "STAGE 1":
	set(v): stage_name = v; _update_ui()
@export var preview_texture: Texture2D:
	set(v): preview_texture = v; _update_ui()
@export var level_params: Dictionary = {}:
	set(v): level_params = v; _update_ui()

@export_group("Visuel & Animation")
@export var is_locked: bool = false:
	set(v): is_locked = v; _update_ui()
@export var base_scale: float = 25.0:
	set(v): base_scale = v; _update_ui()
@export var transition_duration: float = 0.2

@export_subgroup("Couleurs & Éclat")
@export var tint_normal: Color = Color(0.15, 0.45, 0.8):
	set(v): tint_normal = v; _update_ui()
@export var tint_hover: Color = Color(0.2, 0.6, 1.0):
	set(v): tint_hover = v; _update_ui()
@export var emission_hover: float = 1.5:
	set(v): emission_hover = v; _update_ui()

# --- Liens Nœuds ---
@onready var _socle: MeshInstance3D = $Layer0_Socle
@onready var _preview: MeshInstance3D = $Layer1_Preview
@onready var _frame: MeshInstance3D = $Layer2_Frame
@onready var _label_name: Label3D = $Labels/Label_Name
@onready var _label_id: Label3D = $Labels/Label_ID
@onready var _area: Area3D = $Area3D

var _is_hovered: bool = false
var _is_pressed: bool = false
var _tween: Tween

# --- Shaders ---
const CARD_SHADER = """
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

func _ready() -> void:
	_setup_materials()
	if not Engine.is_editor_hint():
		if _area:
			_area.mouse_entered.connect(_on_mouse_entered)
			_area.mouse_exited.connect(_on_mouse_exited)
			_area.input_event.connect(_on_input_event)
	_update_ui()

func _setup_materials() -> void:
	for mesh in [_socle, _preview, _frame]:
		if mesh and not mesh.material_override:
			var mat = ShaderMaterial.new()
			mat.shader = Shader.new()
			mat.shader.code = CARD_SHADER
			mesh.material_override = mat

func _update_ui() -> void:
	if not is_inside_tree(): return
	
	var target_scale_val = base_scale
	var target_emission: float = 0.0
	var target_tint: Color = tint_normal
	var sat = 0.0 if is_locked else 1.0
	
	if _is_hovered and not is_locked:
		target_scale_val *= 1.1
		target_emission = emission_hover
		target_tint = tint_hover
	
	if _is_pressed and not is_locked:
		target_scale_val *= 0.95
		target_emission = emission_hover * 1.5

	# Mise à jour des textures
	if _preview and _preview.material_override:
		_preview.material_override.set_shader_parameter("albedo_texture", preview_texture)
		_preview.material_override.set_shader_parameter("saturation", sat)
	
	if _socle and _socle.material_override:
		_socle.material_override.set_shader_parameter("albedo_color", target_tint)
		_socle.material_override.set_shader_parameter("saturation", sat)
		_socle.material_override.set_shader_parameter("emission_energy", target_emission)

	if _label_name:
		_label_name.text = stage_name
		_label_name.modulate = Color.WHITE if not is_locked else Color(0.5, 0.5, 0.5)
		
	if _label_id:
		_label_id.text = level_id

	# Animation
	if Engine.is_editor_hint():
		scale = Vector3.ONE * target_scale_val
	else:
		if _tween: _tween.kill()
		_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "scale", Vector3.ONE * target_scale_val, transition_duration)

func _on_mouse_entered() -> void:
	if is_locked: return
	_is_hovered = true
	hovered.emit({"id": level_id, "name": stage_name, "params": level_params})
	_update_ui()

func _on_mouse_exited() -> void:
	_is_hovered = false
	_is_pressed = false
	_update_ui()

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if is_locked: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_pressed = true
		else:
			if _is_pressed:
				pressed.emit()
			_is_pressed = false
		_update_ui()
