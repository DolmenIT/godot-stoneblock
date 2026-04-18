@tool
class_name SB_LevelPreview_3d
extends Node3D

## 📺 SB_LevelPreview_3d : Panneau d'affichage des détails du niveau.
## Utilise l'esthétique Upgrade Card en format large.

@export var stage_name: String = "SÉLECTIONNEZ UN SECTEUR":
	set(v): stage_name = v; _update_ui()
@export var preview_texture: Texture2D = preload("res://assets/demo1/upgrade_card_background.png"):
	set(v): preview_texture = v; _update_ui()
@export var description: String = "Survolez une carte pour voir les détails du niveau.":
	set(v): description = v; _update_ui()
@export var difficulty_text: String = "Difficulté : --":
	set(v): difficulty_text = v; _update_ui()

@onready var _preview: MeshInstance3D = $Layer1_Preview
@onready var _label_name: Label3D = $Labels/Label_Name
@onready var _label_desc: Label3D = $Labels/Label_Description
@onready var _label_diff: Label3D = $Labels/Label_Difficulty

const PREVIEW_SHADER = """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_texture : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float emission_energy : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec4 tex = texture(albedo_texture, UV) * albedo_color;
    vec3 holo_tint = vec3(0.2, 0.5, 1.0);
    vec3 final_rgb = mix(tex.rgb, holo_tint, 0.15);
    ALBEDO = final_rgb;
    EMISSION = final_rgb * emission_energy;
    ALPHA = tex.a * 0.95;
}
"""

func _ready() -> void:
	if _preview and not _preview.material_override:
		var mat = ShaderMaterial.new()
		mat.shader = Shader.new()
		mat.shader.code = PREVIEW_SHADER
		_preview.material_override = mat
	_update_ui()

func _update_ui() -> void:
	if not is_inside_tree(): return
	
	if _label_name: _label_name.text = stage_name
	if _label_desc: _label_desc.text = description
	if _label_diff: _label_diff.text = difficulty_text
	
	if _preview and _preview.material_override:
		_preview.material_override.set_shader_parameter("albedo_texture", preview_texture)

func update_from_data(data: Dictionary) -> void:
	stage_name = data.get("name", "INCONNU")
	var params = data.get("params", {})
	description = params.get("description", "Aucune description disponible.")
	difficulty_text = "Vitesse : " + str(params.get("scroll_speed", 0)) + " m/s"
	# On pourrait aussi passer une texture dans data
	if params.has("preview_texture"):
		preview_texture = params["preview_texture"]
	_update_ui()
