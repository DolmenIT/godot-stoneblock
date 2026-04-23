shader_type spatial;
render_mode unshaded, cull_disabled;

// 🛰️ SB_PostProcess_Outline : Vrai Contour 2D de Silhouette (Screen Space).
// Détecte les bords en comparant les différences de profondeur (Depth).

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 10.0) = 1.0;
uniform float depth_threshold : hint_range(0.0, 0.1) = 0.01;

void fragment() {
	// 1. On récupère la couleur d'origine du jeu
	vec4 original_color = texture(screen_texture, SCREEN_UV);
	
	// 2. On récupère la profondeur au pixel courant
	float depth = texture(depth_texture, SCREEN_UV).r;
	
	// 3. On calcule le décalage du pixel pour l'épaisseur (Screen Space)
	vec2 pixel_size = (1.0 / VIEWPORT_SIZE) * outline_thickness;
	
	// 4. On s'assure d'être sur un objet "proche" (Pas le sol qui est vers depth = 1.0)
	float edge = 0.0;
	
	// On scanne les 4 voisins
	float d_up    = texture(depth_texture, SCREEN_UV + vec2(0.0, pixel_size.y)).r;
	float d_down  = texture(depth_texture, SCREEN_UV - vec2(0.0, pixel_size.y)).r;
	float d_left  = texture(depth_texture, SCREEN_UV - vec2(pixel_size.x, 0.0)).r;
	float d_right = texture(depth_texture, SCREEN_UV + vec2(pixel_size.x, 0.0)).r;
	
	float diff = 0.0;
	diff += abs(depth - d_up);
	diff += abs(depth - d_down);
	diff += abs(depth - d_left);
	diff += abs(depth - d_right);
	
	if (diff > depth_threshold) {
		edge = 1.0;
	}
	
	// 5. Rendu Final : ALBEDO remplace COLOR en shader spatial
	if (edge > 0.0 && depth < 0.99) {
		ALBEDO = outline_color.rgb;
		ALPHA = outline_color.a;
	} else {
		ALBEDO = original_color.rgb;
		ALPHA = original_color.a;
	}
}
