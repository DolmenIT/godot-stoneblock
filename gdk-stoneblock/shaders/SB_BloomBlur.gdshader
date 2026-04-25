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
			// --- MODE FAST (Gaussian 5x5 - 25 samples) ---
			float sigma_k = 1.2; 
			float step_k = blur_radius / 2.0;
			for (float x = -2.0; x <= 2.0; x += 1.0) {
				for (float y = -2.0; y <= 2.0; y += 1.0) {
					float weight = exp(-(x*x+y*y) / (2.0 * sigma_k * sigma_k));
					final_color += texture(TEXTURE, UV + vec2(x,y) * TEXTURE_PIXEL_SIZE * step_k) * weight;
					total_weight += weight;
				}
			}
			final_color /= total_weight;
			
		} else if (blur_mode == 1) {
			// --- MODE BALANCED (Gaussian 9x9 - 81 samples) ---
			float sigma_k = 2.0; 
			float step_k = blur_radius / 4.0;
			for (float x = -4.0; x <= 4.0; x += 1.0) {
				for (float y = -4.0; y <= 4.0; y += 1.0) {
					float weight = exp(-(x*x+y*y) / (2.0 * sigma_k * sigma_k));
					final_color += texture(TEXTURE, UV + vec2(x,y) * TEXTURE_PIXEL_SIZE * step_k) * weight;
					total_weight += weight;
				}
			}
			final_color /= total_weight;
			
		} else {
			// --- MODE ULTRA (Gaussian 13x13 - 169 samples) ---
			float sigma_k = 3.0; 
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
