shader_type canvas_item;

uniform float blur_scale : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform int samples : hint_range(1, 30) = 15;
uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.5, 1.0);
uniform float glow_intensity : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform bool additive_blend = true;
uniform bool hide_base_texture = true; // IMPORTANT : Cache la texture d'origine pour ne laisser QUE le rayon lumineux
uniform float luminance_threshold : hint_range(0.0, 1.0, 0.01) = 0.7;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	vec4 blurred_color = vec4(0.0);
	float total_weight = 0.0;
	
	// Flou Directionnel (Horizontal)
	for (int i = -samples; i <= samples; i++) {
		float offset = float(i) * blur_scale * TEXTURE_PIXEL_SIZE.x;
		float weight = 1.0 - (abs(float(i)) / float(samples)); 
		
		vec2 sample_uv = UV + vec2(offset, 0.0);
		vec4 sample_color = vec4(0.0);
		
		if (sample_uv.x >= 0.0 && sample_uv.x <= 1.0) {
			sample_color = texture(TEXTURE, sample_uv);
		}
		
		float luminance = dot(sample_color.rgb, vec3(0.299, 0.587, 0.114));
		
		// L'effet de Threshold HDR extrêment sévère
		float mask = smoothstep(luminance_threshold, luminance_threshold + 0.15, luminance);
		mask = pow(mask, 3.0); // Courbe de puissance pour écraser violemment les tons moyens
		
		sample_color.rgb *= mask;
		
		blurred_color += sample_color * weight;
		total_weight += weight;
	}
	
	blurred_color /= total_weight;
	blurred_color *= glow_color * glow_intensity;
	
	// On adoucit les bords secs de la box aura pour fondre le néon
	float edge_fade = smoothstep(0.0, 0.05, UV.x) * smoothstep(1.0, 0.95, UV.x);
	blurred_color *= edge_fade;
		
	if (hide_base_texture) {
		original_color = vec4(0.0); // Le node devient un pur émetteur spectral !
	}
	
	if (additive_blend) {
		COLOR = original_color + blurred_color;
		COLOR.a = min(original_color.a + blurred_color.a, 1.0);
	} else {
		COLOR = mix(original_color, blurred_color, blurred_color.a);
	}
}
