shader_type spatial;

uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// Mélange l'albedo pour la base
	ALBEDO = mix(ALBEDO, flash_color, flash_modifier);
	// Ajoute de l'émission pour un effet "glow" (notamment pour le rouge de tir)
	EMISSION = flash_color * flash_modifier * 2.0;
}
