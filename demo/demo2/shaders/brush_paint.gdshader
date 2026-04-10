shader_type canvas_item;

// 🖌️ brush_paint : Moteur de peinture GPU.
// Lit l'état précédent du canvas et ajoute le nouveau trait.

uniform sampler2D prev_texture; // Texture du frame précédent
uniform vec2 brush_pos;         // Position du pinceau (0.0 - 1.0)
uniform float brush_size;       // Taille relative du pinceau
uniform float brush_strength : hint_range(0.0, 1.0) = 1.0;
uniform vec4 brush_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool is_drawing = false;

void fragment() {
	vec4 old_color = texture(prev_texture, UV);
	
	if (is_drawing) {
		float dist = distance(UV, brush_pos);
		float mask = smoothstep(brush_size, brush_size * 0.8, dist);
		
		// Mélange de la nouvelle couleur avec l'ancienne
		vec4 draw_color = vec4(brush_color.rgb, brush_color.a * mask * brush_strength);
		COLOR = mix(old_color, draw_color, draw_color.a);
	} else {
		COLOR = old_color;
	}
}
