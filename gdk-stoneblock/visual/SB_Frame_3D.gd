@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_Frame_3D
extends Node3D

## 🖼️ SB_Frame_3D : Affiche et mélange un socle, une preview et un cadre dans un seul composant 3D.

enum SBBlendMode { NORMAL, MULTIPLY, ADD, SCREEN, OVERLAY, DARKEN, LIGHTEN, DIFFERENCE }
enum SBStretchMode { STRETCH, COVER }

@export_group("Textures")
## Texture d'arrière-plan (Socle). Découpée en 9 zones.
@export var socle_texture: Texture2D:
	set(v): socle_texture = v; _update_visual()

## Texture intermédiaire (Preview).
@export var preview_texture: Texture2D:
	set(v): preview_texture = v; _update_visual()

## Texture de premier plan (Cadre/Frame). Découpée en 9 zones.
@export var frame_texture: Texture2D:
	set(v): frame_texture = v; _update_visual()

## Couleur de teinte globale de l'arrière-plan.
@export var albedo_color: Color = Color.WHITE:
	set(v): albedo_color = v; _update_visual()

@export_group("Preview Mixing")
## Mélange entre la photo de preview et le socle (0 = Socle seul, 1 = Preview mélangée).
@export_range(0.0, 1.0) var preview_mix: float = 0.5:
	set(v): preview_mix = v; _update_visual()

## Mode de fusion entre la preview et le socle.
@export var preview_blend_mode: SBBlendMode = SBBlendMode.NORMAL:
	set(v): preview_blend_mode = v; _update_visual()

## Mode d'étirement de l'image de preview.
@export var preview_stretch_mode: SBStretchMode = SBStretchMode.COVER:
	set(v): preview_stretch_mode = v; _update_visual()

@export_group("Frame Mixing")
## Mélange entre le cadre et le fond (0 = Pas de cadre, 1 = Cadre appliqué).
@export_range(0.0, 1.0) var frame_mix: float = 1.0:
	set(v): frame_mix = v; _update_visual()

## Mode de fusion entre le cadre et le socle.
@export var frame_blend_mode: SBBlendMode = SBBlendMode.NORMAL:
	set(v): frame_blend_mode = v; _update_visual()

@export_group("Dimensions")
## Taille du panneau dans l'espace 3D.
@export var size: Vector2 = Vector2(15, 20):
	set(v): size = v; _update_visual()

## Désactiver l'auto scale et fixer l'échelle de la texture manuellement.
@export var custom_texture_scale: bool = false:
	set(v): custom_texture_scale = v; _update_visual()

## Échelle manuelle de la texture (1 = aspect pixel d'origine, 2 = Zoom x2).
@export var texture_scale: float = 1.0:
	set(v): texture_scale = v; _update_visual()

@export_group("Slicing & Cropping")
## Marges de découpe en 9 zones pour le socle et le cadre (Left, Top, Right, Bottom).
@export var slice_margins: Vector4 = Vector4(60, 60, 60, 60):
	set(v): slice_margins = v; _update_visual()

## Marges de recadrage du bord de texture (Left, Top, Right, Bottom).
@export var crop: Vector4 = Vector4(0, 0, 0, 0):
	set(v): crop = v; _update_visual()

@export_group("Interaction")
## Si coché, génère un collider invisible pour bloquer les clics et survols.
@export var blocks_ui_input: bool = false:
	set(v): blocks_ui_input = v; _update_collider()

const SHADER_CODE: String = """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D socle_texture : source_color;
uniform sampler2D preview_texture : hint_default_white;
uniform sampler2D frame_texture : source_color;

uniform vec2 real_size;
uniform vec2 tex_size;
uniform vec4 slice_margins;
uniform vec4 crop;

uniform float preview_mix : hint_range(0.0, 1.0) = 0.5;
uniform int preview_blend_mode = 0;
uniform int preview_stretch_mode = 1;

uniform float frame_mix : hint_range(0.0, 1.0) = 1.0;
uniform int frame_blend_mode = 0;

uniform vec4 albedo_color : source_color = vec4(1.0);
uniform vec2 preview_tex_size;
uniform bool use_socle_texture = false;
uniform bool use_frame_texture = false;

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
	if (real_size.x <= 0.0 || real_size.y <= 0.0) {
		discard;
	}

	float tx = UV.x * real_size.x;
	float ty = UV.y * real_size.y;
	
	vec2 final_uv;
	final_uv.x = get_uv(tx, real_size.x, tex_size.x, crop.x, crop.z, slice_margins.x, slice_margins.z);
	final_uv.y = get_uv(ty, real_size.y, tex_size.y, crop.y, crop.w, slice_margins.y, slice_margins.w);

	vec4 s_color = albedo_color;
	if (use_socle_texture) {
		s_color = texture(socle_texture, final_uv) * albedo_color;
	}

	vec4 f_color = vec4(0.0);
	if (use_frame_texture) {
		f_color = texture(frame_texture, final_uv);
	}

	// 1. Mix Socle + Frame
	vec3 f_blend = s_color.rgb;
	if (frame_blend_mode == 0) f_blend = f_color.rgb;
	else if (frame_blend_mode == 1) f_blend = s_color.rgb * f_color.rgb;
	else if (frame_blend_mode == 2) f_blend = s_color.rgb + f_color.rgb;
	else if (frame_blend_mode == 3) f_blend = 1.0 - (1.0 - s_color.rgb) * (1.0 - f_color.rgb);
	else if (frame_blend_mode == 4) {
		f_blend.r = s_color.r < 0.5 ? 2.0 * s_color.r * f_color.r : 1.0 - 2.0 * (1.0 - s_color.r) * (1.0 - f_color.r);
		f_blend.g = s_color.g < 0.5 ? 2.0 * s_color.g * f_color.g : 1.0 - 2.0 * (1.0 - s_color.g) * (1.0 - f_color.g);
		f_blend.b = s_color.b < 0.5 ? 2.0 * s_color.b * f_color.b : 1.0 - 2.0 * (1.0 - s_color.b) * (1.0 - f_color.b);
	}
	else if (frame_blend_mode == 5) f_blend = min(s_color.rgb, f_color.rgb);
	else if (frame_blend_mode == 6) f_blend = max(s_color.rgb, f_color.rgb);
	else if (frame_blend_mode == 7) f_blend = abs(s_color.rgb - f_color.rgb);

	vec4 socle_frame_color = mix(s_color, vec4(f_blend, f_color.a), f_color.a * frame_mix);

	// 2. Mix Preview par-dessus Socle+Frame
	vec2 p_uv = UV;
	if (preview_stretch_mode == 1 && preview_tex_size.x > 0.0 && preview_tex_size.y > 0.0) {
		float tex_aspect = preview_tex_size.x / preview_tex_size.y;
		float mesh_aspect = real_size.x / real_size.y;
		if (mesh_aspect > tex_aspect) {
			float scale = tex_aspect / mesh_aspect;
			p_uv.y = UV.y * scale + (1.0 - scale) * 0.5;
		} else {
			float scale = mesh_aspect / tex_aspect;
			p_uv.x = UV.x * scale + (1.0 - scale) * 0.5;
		}
	}
	vec4 p_color = texture(preview_texture, p_uv);

	vec3 blend_res = socle_frame_color.rgb;
	if (preview_blend_mode == 0) blend_res = p_color.rgb;
	else if (preview_blend_mode == 1) blend_res = socle_frame_color.rgb * p_color.rgb;
	else if (preview_blend_mode == 2) blend_res = socle_frame_color.rgb + p_color.rgb;
	else if (preview_blend_mode == 3) blend_res = 1.0 - (1.0 - socle_frame_color.rgb) * (1.0 - p_color.rgb);
	else if (preview_blend_mode == 4) {
		blend_res.r = socle_frame_color.r < 0.5 ? 2.0 * socle_frame_color.r * p_color.r : 1.0 - 2.0 * (1.0 - socle_frame_color.r) * (1.0 - p_color.r);
		blend_res.g = socle_frame_color.g < 0.5 ? 2.0 * socle_frame_color.g * p_color.g : 1.0 - 2.0 * (1.0 - socle_frame_color.g) * (1.0 - p_color.g);
		blend_res.b = socle_frame_color.b < 0.5 ? 2.0 * socle_frame_color.b * p_color.b : 1.0 - 2.0 * (1.0 - socle_frame_color.b) * (1.0 - p_color.b);
	}
	else if (preview_blend_mode == 5) blend_res = min(socle_frame_color.rgb, p_color.rgb);
	else if (preview_blend_mode == 6) blend_res = max(socle_frame_color.rgb, p_color.rgb);
	else if (preview_blend_mode == 7) blend_res = abs(socle_frame_color.rgb - p_color.rgb);

	vec4 final_color = vec4(mix(socle_frame_color.rgb, blend_res, p_color.a * preview_mix), socle_frame_color.a);

	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
}
"""

var _mesh_instance: MeshInstance3D
var _mat: ShaderMaterial
var _block_area: Area3D

func _ready() -> void:
	_setup_nodes()
	_update_visual()
	_update_collider()

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
	
	_mesh_instance.visible = true
	var quad: QuadMesh = _mesh_instance.mesh
	quad.size = size
	
	if blocks_ui_input:
		_update_collider()
	
	_mat.set_shader_parameter("socle_texture", socle_texture)
	_mat.set_shader_parameter("preview_texture", preview_texture)
	_mat.set_shader_parameter("frame_texture", frame_texture)
	_mat.set_shader_parameter("albedo_color", albedo_color)
	_mat.set_shader_parameter("preview_mix", preview_mix)
	_mat.set_shader_parameter("preview_blend_mode", int(preview_blend_mode))
	_mat.set_shader_parameter("preview_stretch_mode", int(preview_stretch_mode))
	
	_mat.set_shader_parameter("frame_mix", frame_mix)
	_mat.set_shader_parameter("frame_blend_mode", int(frame_blend_mode))
	
	_mat.set_shader_parameter("use_socle_texture", socle_texture != null)
	_mat.set_shader_parameter("use_frame_texture", frame_texture != null)
	
	var tex_to_use: Texture2D = socle_texture if socle_texture else frame_texture
	if tex_to_use:
		_mat.set_shader_parameter("tex_size", tex_to_use.get_size())
	else:
		_mat.set_shader_parameter("tex_size", Vector2(128, 128))

	if preview_texture:
		_mat.set_shader_parameter("preview_tex_size", preview_texture.get_size())
	else:
		_mat.set_shader_parameter("preview_tex_size", Vector2.ZERO)

	var useful_h = tex_to_use.get_height() - crop.y - crop.w if tex_to_use else size.y
	var height_ratio = max(useful_h, 1.0) / max(size.y, 0.001)
	if custom_texture_scale:
		height_ratio /= max(texture_scale, 0.001)
	
	var r_size = size * height_ratio
	_mat.set_shader_parameter("real_size", r_size)
	_mat.set_shader_parameter("slice_margins", slice_margins)
	_mat.set_shader_parameter("crop", crop)

func _update_collider() -> void:
	if not is_inside_tree(): return
	if blocks_ui_input:
		if not _block_area:
			_block_area = Area3D.new()
			_block_area.name = "UIBlockerArea"
			var col_shape = CollisionShape3D.new()
			col_shape.shape = BoxShape3D.new()
			_block_area.add_child(col_shape)
			add_child(_block_area)
		
		var shape = _block_area.get_child(0).shape as BoxShape3D
		shape.size = Vector3(size.x, size.y, 0.05)
	else:
		if _block_area:
			_block_area.queue_free()
			_block_area = null
