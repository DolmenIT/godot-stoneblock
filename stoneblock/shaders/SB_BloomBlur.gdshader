shader_type canvas_item;
render_mode blend_add;

/// Mode de flou : 0=FAST, 1=BALANCED, 2=ULTRA
uniform int blur_mode : hint_range(0, 2) = 1;
/// Rayon du flou. 0 = net, 20 = très baveux.
uniform float blur_radius : hint_range(0.0, 20.0) = 4.0;
/// Multiplicateurs de luminosité.
uniform float bloom_intensity : hint_range(0.0, 8.0) = 1.0;
/// Teinte globale appliquée au bloom.
uniform vec4 bloom_tint : source_color = vec4(1.0);
/// Facteur de saturation pour forcer la couleur.
uniform float saturation : hint_range(0.0, 4.0) = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 final_color = vec4(0.0);
	
	if (blur_radius < 0.1) {
		final_color = texture(TEXTURE, UV) * bloom_intensity;
	} else {
		float total_weight = 0.0;
		if (blur_mode == 0) {
			// --- MODE FAST (Kawase-like 16 samples) ---
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
			// --- MODE BALANCED (Dithered Gaussian 81 samples) ---
			float sigma_k = 1.8; // Falloff constant pour le kernel 9x9
			float step_k = blur_radius / 4.0;
			float noise = hash(UV + TIME * 0.01) * 0.2;
			for (float x = -4.0; x <= 4.0; x += 1.0) {
				for (float y = -4.0; y <= 4.0; y += 1.0) {
					vec2 o = vec2(x + noise, y + noise);
					float weight = exp(-dot(o, o) / (2.0 * sigma_k * sigma_k));
					final_color += texture(TEXTURE, UV + o * TEXTURE_PIXEL_SIZE * step_k) * weight;
					total_weight += weight;
				}
			}
			final_color /= total_weight;
			
		} else {
			// --- MODE ULTRA (Pure Gaussian 169 samples) ---
			float sigma_k = 2.5; // Falloff constant pour le kernel 13x13
			float step_k = blur_radius / 6.0;
			for (float x = -6.0; x <= 6.0; x += 1.0) {
				for (float y = -6.0; y <= 6.0; y += 1.0) {
					float weight = exp(-(x*x+y*y) / (2.0 * sigma_k * sigma_k));
					final_color += texture(TEXTURE, UV + vec2(x,y) * TEXTURE_PIXEL_SIZE * step_k) * weight;
					total_weight += weight;
				}
			}
			final_color /= total_weight;
		}
		
		final_color *= bloom_intensity;
	}
	
	// Appliquer la teinte
	final_color.rgb *= bloom_tint.rgb;
	
	// Renforcement de la saturation (évite l'effet "blanchi")
	float gray = dot(final_color.rgb, vec3(0.299, 0.587, 0.114));
	final_color.rgb = mix(vec3(gray), final_color.rgb, saturation);
	
	COLOR = final_color;
}
