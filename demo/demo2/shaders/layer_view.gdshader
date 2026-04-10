shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_opaque;

// 🏔️ layer_view : Shader spatial pour l'affichage du calque 3D.
// Gère le déplacement de sommets (Heightmap) et l'albedo.

uniform sampler2D albedo_map : source_color, hint_default_transparent;
uniform sampler2D height_map : hint_default_black;
uniform float height_scale = 1.0;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying float h_val;

void vertex() {
	h_val = texture(height_map, UV).r;
	VERTEX.y += h_val * height_scale;
}

void fragment() {
	vec4 tex_color = texture(albedo_map, UV);
	ALBEDO = tex_color.rgb * base_color.rgb;
	ALPHA = tex_color.a * base_color.a;
}
