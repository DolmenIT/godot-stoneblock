shader_type canvas_item;
render_mode blend_add;

/// Mode de flou : 0=FAST, 1=BALANCED, 2=ULTRA
uniform int blur_mode : hint_range(0, 2) = 1;
/// Rayon du flou. 0 = net, 20 = très baveux.
uniform float blur_radius : hint_range(0.0, 20.0) = 4.0;
/// Multiplicateurs de luminosité.
uniform float bloom_intensity : hint_range(0.0, 8.0) = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 final_color = vec4(0.0);
	
	if (blur_radius < 0.1) {
		final_color = texture(TEXTURE, UV) * bloom_intensity;
	} else {
		float total_weight = 0.0;
		float sigma = max(blur_radius * 0.45, 0.1);
		
		if (blur_mode == 0) {
			// --- MODE FAST (Kawase-like 16 samples) ---
			// Très performant, utilise le filtrage bilinéaire natif
			float d = blur_radius * 0.5;
			vec2 offsets[4] = vec2[](vec2(-d,-d), vec2(d,-d), vec2(-d,d), vec2(d,d));
			for(int i=0; i<4; i++) {
				final_color += texture(TEXTURE, UV + offsets[i] * TEXTURE_PIXEL_SIZE);
				final_color += texture(TEXTURE, UV + offsets[i] * 0.5 * TEXTURE_PIXEL_SIZE);
				final_color += texture(TEXTURE, UV + offsets[i] * 1.5 * TEXTURE_PIXEL_SIZE);
				final_color += texture(TEXTURE, UV + offsets[i] * 2.0 * TEXTURE_PIXEL_SIZE);
			}
			final_color /= 16.0;
			
		} else if (blur_mode == 1) {
			// --- MODE BALANCED (Dithered Gaussian 9x9 = 81 samples) ---
			float noise = hash(UV + TIME * 0.01) * 0.4;
			for (float x = -4.0; x <= 4.0; x += 1.0) {
				for (float y = -4.0; y <= 4.0; y += 1.0) {
					vec2 o_uv = vec2(x + noise, y + noise);
					float weight = exp(-dot(o_uv, o_uv) / (2.0 * sigma * sigma));
					final_color += texture(TEXTURE, UV + o_uv * TEXTURE_PIXEL_SIZE * (blur_radius * 0.25)) * weight;
					total_weight += weight;
				}
			}
			final_color /= total_weight;
			
		} else {
			// --- MODE ULTRA (Pure Gaussian 13x13 = 169 samples) ---
			for (float x = -6.0; x <= 6.0; x += 1.0) {
				for (float y = -6.0; y <= 6.0; y += 1.0) {
					float weight = exp(-(x*x+y*y) / (2.0 * sigma * sigma));
					final_color += texture(TEXTURE, UV + vec2(x,y) * TEXTURE_PIXEL_SIZE * (blur_radius * 0.18)) * weight;
					total_weight += weight;
				}
			}
			final_color /= total_weight;
		}
		
		final_color *= bloom_intensity;
	}
	
	COLOR = final_color;
}
