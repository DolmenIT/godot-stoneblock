@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends Node3D
class_name SB_NineSlice3D

## 🧩 SB_NineSlice3D : Affiche une texture 2D découpée en 9 zones dans l'espace 3D.
## Les coins conservent leur ratio, les bords et le centre sont étirés.

enum SBBlendMode { NORMAL, MULTIPLY, ADD, SCREEN, OVERLAY, DARKEN, LIGHTEN, DIFFERENCE }

@export_group("Texture")
@export var texture: Texture2D:
	set(v): texture = v; _update_visual()
@export var albedo_color: Color = Color.WHITE:
	set(v): albedo_color = v; _update_visual()
@export var mask_texture: Texture2D:
	set(v): mask_texture = v; _update_visual()
@export var mask_slice_margins: Vector4 = Vector4(32, 32, 32, 32):
	set(v): mask_slice_margins = v; _update_visual()
@export var mask_crop: Vector4 = Vector4(0, 0, 0, 0):
	set(v): mask_crop = v; _update_visual()
@export var mask_mix: float = 0.0:
	set(v): mask_mix = v; _update_visual()
@export var mask_blend_mode: SBBlendMode = SBBlendMode.NORMAL:
	set(v): mask_blend_mode = v; _update_visual()
@export var mask_albedo_color: Color = Color.WHITE:
	set(v): mask_albedo_color = v; _update_visual()

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
uniform sampler2D mask_texture : hint_default_white;
uniform float saturation : hint_range(0.0, 1.0) = 1.0;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float emission_energy : hint_range(0.0, 5.0) = 1.0;

uniform vec4 slice_margins; // x: left, y: top, z: right, w: bottom
uniform vec2 real_size;
uniform vec2 tex_size;
uniform vec4 crop; // x: left, y: top, z: right, w: bottom
uniform vec4 mask_crop;
uniform vec4 mask_slice_margins;
uniform vec2 mask_tex_size;
uniform vec2 mask_real_size;
uniform float mask_mix : hint_range(0.0, 1.0) = 0.0;
uniform int mask_blend_mode = 0;
uniform vec4 mask_albedo_color : source_color = vec4(1.0);

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
	
	float mx = get_uv(UV.x * mask_real_size.x, mask_real_size.x, mask_tex_size.x, mask_crop.x, mask_crop.z, mask_slice_margins.x, mask_slice_margins.z);
	float my = get_uv(UV.y * mask_real_size.y, mask_real_size.y, mask_tex_size.y, mask_crop.y, mask_crop.w, mask_slice_margins.y, mask_slice_margins.w);
	vec4 mask = texture(mask_texture, vec2(mx, my));
	vec3 m_rgb = mask.rgb * mask_albedo_color.rgb;
	vec3 blend_res = final_color;
	
	if (mask_blend_mode == 0) blend_res = m_rgb; // Normal (on prend le fond)
	else if (mask_blend_mode == 1) blend_res = final_color * m_rgb; // Multiply
	else if (mask_blend_mode == 2) blend_res = final_color + m_rgb; // Add
	else if (mask_blend_mode == 3) blend_res = 1.0 - (1.0 - final_color) * (1.0 - m_rgb); // Screen
	else if (mask_blend_mode == 4) { // Overlay
		blend_res.r = final_color.r < 0.5 ? 2.0 * final_color.r * m_rgb.r : 1.0 - 2.0 * (1.0 - final_color.r) * (1.0 - m_rgb.r);
		blend_res.g = final_color.g < 0.5 ? 2.0 * final_color.g * m_rgb.g : 1.0 - 2.0 * (1.0 - final_color.g) * (1.0 - m_rgb.g);
		blend_res.b = final_color.b < 0.5 ? 2.0 * final_color.b * m_rgb.b : 1.0 - 2.0 * (1.0 - final_color.b) * (1.0 - m_rgb.b);
	}
	else if (mask_blend_mode == 5) blend_res = min(final_color, m_rgb); // Darken
	else if (mask_blend_mode == 6) blend_res = max(final_color, m_rgb); // Lighten
	else if (mask_blend_mode == 7) blend_res = abs(final_color - m_rgb); // Difference
	
	ALBEDO = mix(final_color, blend_res, mask_mix);
	EMISSION = ALBEDO * emission_energy * saturation;
	ALPHA = tex.a * mask.a;
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
	if mask_texture:
		_mat.set_shader_parameter("mask_texture", mask_texture)
		_mat.set_shader_parameter("mask_tex_size", mask_texture.get_size())
		_mat.set_shader_parameter("mask_crop", mask_crop)
		_mat.set_shader_parameter("mask_slice_margins", mask_slice_margins)
		
		# Calcul de la taille réelle spécifique au masque
		var m_useful_h = mask_texture.get_height() - mask_crop.y - mask_crop.w
		var m_height_ratio = max(m_useful_h, 1.0) / max(size.y, 0.001)
		_mat.set_shader_parameter("mask_real_size", size * m_height_ratio)
		_mat.set_shader_parameter("mask_mix", mask_mix)
		_mat.set_shader_parameter("mask_blend_mode", mask_blend_mode)
		_mat.set_shader_parameter("mask_albedo_color", mask_albedo_color)
	else:
		_mat.set_shader_parameter("mask_texture", null)
	
	# Calcul du real_size en pixels (simulation pour le shader)
	var useful_h = texture.get_height() - crop.y - crop.w
	var height_ratio = max(useful_h, 1.0) / max(size.y, 0.001)
	var r_size = size * height_ratio
	
	_mat.set_shader_parameter("real_size", r_size)
	_mat.set_shader_parameter("slice_margins", slice_margins)
	_mat.set_shader_parameter("crop", crop)
