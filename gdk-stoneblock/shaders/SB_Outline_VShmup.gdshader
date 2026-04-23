shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 1.0) = 0.05;

void vertex() {
	// Approximation de contour par expansion des normales dans l'espace vue
	// On pousse les sommets vers l'extérieur pour créer la silhouette
	VERTEX += NORMAL * outline_thickness;
}

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA = outline_color.a;
}
