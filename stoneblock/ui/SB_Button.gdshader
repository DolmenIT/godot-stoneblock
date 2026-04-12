shader_type canvas_item;

uniform sampler2D tex_from;
uniform sampler2D tex_to;
uniform float mix_weight : hint_range(0.0, 1.0) = 0.0;
uniform vec4 crop = vec4(10.0, 10.0, 10.0, 10.0); // x: left, y: top, z: right, w: bottom
uniform float slice_w = 32.0;
uniform vec2 real_size;
uniform vec2 tex_size;

void fragment() {
	// Sécurité anti-division par zéro et taille nulle
	if (real_size.x <= 0.0 || real_size.y <= 0.0 || tex_size.x <= 0.0 || tex_size.y <= 0.0) {
		discard;
	}

	float h_useful = max(tex_size.y - crop.y - crop.w, 1.0);
	float ratio = real_size.y / h_useful;
	
	float s_w = slice_w * ratio;
	
	float x = UV.x * real_size.x;
	float target_uv_x = 0.0;
	
	// Calcul sécurisé de target_uv_x
	if (x < s_w) {
		target_uv_x = (crop.x + (x / max(ratio, 0.001))) / tex_size.x;
	} else if (x > real_size.x - s_w) {
		float dist_right = real_size.x - x;
		target_uv_x = (tex_size.x - crop.z - (dist_right / max(ratio, 0.001))) / tex_size.x;
	} else {
		float center_w_orig = max(tex_size.x - crop.x - crop.z - 2.0 * slice_w, 1.0);
		float center_w_now = max(real_size.x - 2.0 * s_w, 1.0);
		float local_x = x - s_w;
		target_uv_x = (crop.x + slice_w + (local_x / center_w_now) * center_w_orig) / tex_size.x;
	}
	
	// Calcul sécurisé de target_uv_y
	float target_uv_y = (crop.y + UV.y * h_useful) / tex_size.y;
	
	vec4 col_from = texture(tex_from, vec2(target_uv_x, target_uv_y));
	vec4 col_to = texture(tex_to, vec2(target_uv_x, target_uv_y));
	
	COLOR = mix(col_from, col_to, mix_weight);
}
