@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends Node3D
class_name SB_ThreeSlice3D

## 🧩 SB_ThreeSlice3D : Affiche une texture 2D découpée en 3 zones (H ou V).
## Utile pour les barres ou les boutons étirés sur un seul axe.

enum SBOrientation { HORIZONTAL, VERTICAL }

@export_group("Texture")
@export var texture: Texture2D:
	set(v): texture = v; _update_visual()
@export var albedo_color: Color = Color.WHITE:
	set(v): albedo_color = v; _update_visual()

@export_group("Dimensions")
@export var size: Vector2 = Vector2(0.3, 0.05):
	set(v): size = v; _update_visual()
@export var orientation: SBOrientation = SBOrientation.HORIZONTAL:
	set(v): orientation = v; _update_visual()

@export_group("Slicing")
## Marges des extrémités (pixels). X: Début, Y: Fin.
@export var margins: Vector2 = Vector2(32, 32):
	set(v): margins = v; _update_visual()

@export_group("Effects")
@export var emission_energy: float = 0.0:
	set(v): emission_energy = v; _update_visual()
@export var saturation: float = 1.0:
	set(v): saturation = v; _update_visual()

const SHADER_CODE: String = """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_texture : source_color;
uniform float saturation : hint_range(0.0, 1.0) = 1.0;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float emission_energy : hint_range(0.0, 5.0) = 1.0;

uniform vec2 margins;
uniform vec2 real_size;
uniform vec2 tex_size;
uniform bool horizontal;

float get_uv_1d(float pos, float total_size, float tex_full, float m_start, float m_end) {
	if (pos < m_start) {
		return pos / tex_full;
	} else if (pos > total_size - m_end) {
		return (tex_full - (total_size - pos)) / tex_full;
	} else {
		float center_real = max(total_size - m_start - m_end, 0.001);
		float center_tex = max(tex_full - m_start - m_end, 0.001);
		float rel_pos = pos - m_start;
		return (m_start + (rel_pos / center_real) * center_tex) / tex_full;
	}
}

void fragment() {
	if (real_size.x <= 0.0 || real_size.y <= 0.0 || tex_size.x <= 0.0 || tex_size.y <= 0.0) {
		discard;
	}

	float target_x = UV.x;
	float target_y = UV.y;
	
	if (horizontal) {
		float px = UV.x * real_size.x;
		target_x = get_uv_1d(px, real_size.x, tex_size.x, margins.x, margins.y);
	} else {
		float py = UV.y * real_size.y;
		target_y = get_uv_1d(py, real_size.y, tex_size.y, margins.x, margins.y);
	}
	
	vec4 tex = texture(albedo_texture, vec2(target_x, target_y)) * albedo_color;
	float grey = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 final_color = mix(vec3(grey), tex.rgb, saturation);
	
	ALBEDO = final_color;
	EMISSION = final_color * emission_energy * saturation;
	ALPHA = tex.a;
}
"""

var _mesh_instance: MeshInstance3D
var _mat: ShaderMaterial

func _ready() -> void:
	_setup_nodes()
	_update_visual()

func _setup_nodes() -> void:
	if not _mesh_instance:
		_mesh_instance = MeshInstance3D.new()
		_mesh_instance.name = "InternalMesh"
		_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_mesh_instance.set_meta("_edit_lock_", true)
		_mesh_instance.mesh = QuadMesh.new()
		_mesh_instance.mesh.size = Vector2.ZERO
		add_child(_mesh_instance)
		
		_mat = ShaderMaterial.new()
		_mat.shader = Shader.new()
		_mat.shader.code = SHADER_CODE
		_mesh_instance.material_override = _mat

func _update_visual() -> void:
	if not is_inside_tree(): return
	_setup_nodes()
	
	if not texture:
		_mesh_instance.visible = false
		return
	
	_mesh_instance.visible = true
	var quad: QuadMesh = _mesh_instance.mesh
	quad.size = size
	
	_mat.set_shader_parameter("albedo_texture", texture)
	_mat.set_shader_parameter("albedo_color", albedo_color)
	_mat.set_shader_parameter("emission_energy", emission_energy)
	_mat.set_shader_parameter("saturation", saturation)
	_mat.set_shader_parameter("horizontal", orientation == SBOrientation.HORIZONTAL)
	_mat.set_shader_parameter("tex_size", texture.get_size())
	
	# Calcul du real_size pour l'axe concerné
	var r_size = size
	if orientation == SBOrientation.HORIZONTAL:
		var ratio = texture.get_height() / size.y
		r_size.x = size.x * ratio
		r_size.y = texture.get_height()
	else:
		var ratio = texture.get_width() / size.x
		r_size.y = size.y * ratio
		r_size.x = texture.get_width()
		
	_mat.set_shader_parameter("real_size", r_size)
	_mat.set_shader_parameter("margins", margins)
