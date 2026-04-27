@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends Node3D
class_name SB_NineSlice3D

## 🧩 SB_NineSlice3D : Affiche une texture 2D découpée en 9 zones dans l'espace 3D.
## Les coins conservent leur ratio, les bords et le centre sont étirés.

@export_group("Texture")
@export var texture: Texture2D:
	set(v): texture = v; _update_visual()
@export var albedo_color: Color = Color.WHITE:
	set(v): albedo_color = v; _update_visual()

@export_group("Dimensions")
@export var size: Vector2 = Vector2(0.3, 0.1):
	set(v): size = v; _update_visual()

@export_group("Slicing & Cropping")
@export var slice_margins: Vector4 = Vector4(32, 32, 32, 32): # Left, Top, Right, Bottom
	set(v): slice_margins = v; _update_visual()
@export var crop: Vector4 = Vector4(10, 10, 10, 10): # Left, Top, Right, Bottom
	set(v): crop = v; _update_visual()

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

uniform vec4 slice_margins; // x: left, y: top, z: right, w: bottom
uniform vec2 real_size;
uniform vec2 tex_size;
uniform vec4 crop; // x: left, y: top, z: right, w: bottom

float get_uv(float pos, float size_px, float tex_size_full, float crop_start, float crop_end, float slice_start, float slice_end) {
	float useful_tex_size = tex_size_full - crop_start - crop_end;
	
	if (pos < slice_start) {
		return (crop_start + pos) / tex_size_full;
	} else if (pos > size_px - slice_end) {
		return (tex_size_full - crop_end - (size_px - pos)) / tex_size_full;
	} else {
		float center_real = max(size_px - slice_start - slice_end, 0.001);
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
	_mat.set_shader_parameter("saturation", saturation)
	_mat.set_shader_parameter("emission_energy", emission_energy)
	
	_mat.set_shader_parameter("tex_size", texture.get_size())
	
	# Calcul du real_size en pixels (simulation pour le shader)
	var useful_h = texture.get_height() - crop.y - crop.w
	var height_ratio = max(useful_h, 1.0) / max(size.y, 0.001)
	var r_size = size * height_ratio
	
	_mat.set_shader_parameter("real_size", r_size)
	_mat.set_shader_parameter("slice_margins", slice_margins)
	_mat.set_shader_parameter("crop", crop)
