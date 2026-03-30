shader_type canvas_item;
render_mode blend_add;

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
		float sigma = max(blur_radius * 0.4, 0.1);

		// Échantillonnage Gaussian (noyau 9x9)
		for (int x = -4; x <= 4; x++) {
			for (int y = -4; y <= 4; y++) {
				float dist2 = float(x * x + y * y);
				float weight = exp(-dist2 / (2.0 * sigma * sigma));
				vec2 offset = vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE * (blur_radius * 0.25);
				final_color += texture(TEXTURE, UV + offset) * weight;
				total_weight += weight;
			}
		}
		final_color /= total_weight;
		final_color *= bloom_intensity;
	}
	
	COLOR = final_color;
}
