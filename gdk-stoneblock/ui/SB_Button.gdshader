shader_type canvas_item;
render_mode blend_premul_alpha;

uniform sampler2D tex_from;
uniform sampler2D tex_to;
uniform float mix_weight : hint_range(0.0, 1.0) = 0.0;
uniform vec4 crop = vec4(5.0, 5.0, 5.0, 5.0); // x: left, y: top, z: right, w: bottom
uniform vec4 slice_margins = vec4(32.0, 32.0, 32.0, 32.0); // x: left, y: top, z: right, w: bottom
uniform vec2 real_size;
uniform vec2 tex_size;
uniform bool pixel_perfect = true;

// Neon Glow Anamorphique Natif
uniform bool enable_neon_glow = false;
uniform float neon_bleed_x = 40.0; // Espace d'overflow hors du bouton
uniform float neon_blur_scale : hint_range(0.0, 10.0) = 5.0;
uniform int neon_samples : hint_range(1, 40) = 15;
uniform float neon_luminance_threshold : hint_range(0.0, 1.0) = 0.7;
uniform vec4 neon_glow_color : source_color = vec4(0.0, 1.0, 0.5, 1.0);
uniform float neon_glow_intensity : hint_range(0.0, 10.0) = 2.0;

float get_uv(float pos, float size, float tex_size_full, float crop_start, float crop_end, float slice_start, float slice_end) {
	float useful_tex_size = tex_size_full - crop_start - crop_end;
	float res_uv = 0.0;
	
	if (pos < slice_start) {
		res_uv = (crop_start + pos) / tex_size_full;
	} else if (pos > size - slice_end) {
		res_uv = (tex_size_full - crop_end - (size - pos)) / tex_size_full;
	} else {
		float center_tex = useful_tex_size - slice_start - slice_end;
		float rel_pos = pos - slice_start;
		float tiled_pos = mod(rel_pos, max(center_tex, 0.001));
		res_uv = (crop_start + slice_start + tiled_pos) / tex_size_full;
	}
	
	if (pixel_perfect) {
		return (floor(res_uv * tex_size_full) + 0.5) / tex_size_full;
	}
	return res_uv;
}

void fragment() {
	if (real_size.x <= 0.0 || real_size.y <= 0.0 || tex_size.x <= 0.0 || tex_size.y <= 0.0) {
		discard;
	}

	// Calcul des coordonnées d'écran locales (en gérant l'overflow du bleed X)
	float bleed = enable_neon_glow ? neon_bleed_x : 0.0;
	float total_width = real_size.x + 2.0 * bleed;
	
	float tx = UV.x * total_width - bleed;
	float ty = UV.y * real_size.y;
	
	vec4 base_color = vec4(0.0);
	
	// Dessiner le bouton original uniquement s'il est techniquement à l'intérieur de sa vraie Bounding Box
	if (tx >= 0.0 && tx <= real_size.x) {
		float target_x_base = get_uv(tx, real_size.x, tex_size.x, crop.x, crop.z, slice_margins.x, slice_margins.z);
		float target_y_base = get_uv(ty, real_size.y, tex_size.y, crop.y, crop.w, slice_margins.y, slice_margins.w);
		
		vec4 col_from = texture(tex_from, vec2(target_x_base, target_y_base));
		vec4 col_to = texture(tex_to, vec2(target_x_base, target_y_base));
		base_color = mix(col_from, col_to, mix_weight);
	}
	
	// Pré-multiplication de l'alpha (Requis pour que Godot traite les parties transparentes correctement en blend_premul_alpha)
	base_color.rgb *= base_color.a;
	
	if (enable_neon_glow) {
		vec3 blurred_added = vec3(0.0);
		float total_weight = 0.0;
		// Boucle resserrée pour un effet de flare plus pur (pas un dotted line cheap)
		for (int i = -30; i <= 30; i++) {
			if (i < -neon_samples || i > neon_samples) continue;
			
			float sample_tx = tx + float(i) * neon_blur_scale;
			if (sample_tx < 0.0 || sample_tx > real_size.x) continue;
			
			float sample_target_x = get_uv(sample_tx, real_size.x, tex_size.x, crop.x, crop.z, slice_margins.x, slice_margins.z);
			float sample_target_y = get_uv(ty, real_size.y, tex_size.y, crop.y, crop.w, slice_margins.y, slice_margins.w);
			
			vec4 smp_from = texture(tex_from, vec2(sample_target_x, sample_target_y));
			vec4 smp_to = texture(tex_to, vec2(sample_target_x, sample_target_y));
			vec4 smp = mix(smp_from, smp_to, mix_weight);
			
			// Extraction du signal ultra-lumineux à +98-99% (Seulement le coeur blanc du néon)
			float luma = dot(smp.rgb, vec3(0.299, 0.587, 0.114));
			float mask = smoothstep(neon_luminance_threshold, neon_luminance_threshold + 0.02, luma);
			mask = pow(mask, 2.0); // Focus extrême
			
			vec3 light = smp.rgb * mask;
			
			// Distribution plus douce (Gaussienne simplifiée)
			float dist = abs(float(i)) / float(neon_samples);
			float weight = exp(-pow(dist * 2.0, 2.0)); 
			
			blurred_added += light * weight;
			total_weight += weight;
		}
		
		if (total_weight > 0.0) {
			blurred_added /= total_weight;
		}
		
		vec3 final_glow = blurred_added * neon_glow_color.rgb * neon_glow_intensity;
		
		// Un subtil fondu d'extrémité pour tuer les bordures franches (pour le bleed hors-champ)
		float edge_fade = smoothstep(0.0, 0.1, UV.x) * smoothstep(1.0, 0.9, UV.x);
		final_glow *= edge_fade;
		
		base_color.rgb += final_glow;
	}
	
	COLOR = base_color;
}
