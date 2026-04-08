shader_type canvas_item;
// Mode de blend MIX (Alpha) - Pas de render_mode blend_add

/// Rayon du flou. 0 = net, 20 = très baveux.
uniform float blur_radius : hint_range(0.0, 20.0) = 4.0;
/// Multiplicateurs de luminosité.
uniform float bloom_intensity : hint_range(0.0, 8.0) = 1.0;

void fragment() {
	vec4 final_color = vec4(0.0);
	
	if (blur_radius < 0.1) {
		final_color = texture(TEXTURE, UV) * bloom_intensity;
	} else {
		float total_weight = 0.0;
		float sigma = max(blur_radius * 0.5, 0.1);

		for (float x = -5.0; x <= 5.0; x += 1.5) {
			for (float y = -5.0; y <= 5.0; y += 1.5) {
				float dist2 = x * x + y * y;
				float weight = exp(-dist2 / (2.0 * sigma * sigma));
				vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE * (blur_radius * 0.4);
				final_color += texture(TEXTURE, UV + offset) * weight;
				total_weight += weight;
			}
		}
		final_color /= total_weight;
		final_color *= bloom_intensity;
	}
	
	COLOR = final_color;
}
