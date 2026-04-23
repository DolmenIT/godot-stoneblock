shader_type spatial;
render_mode unshaded, cull_disabled;

// 🍩 SB_DonutFlash : Shader optimisé pour le bloom viewport.
// Utilise l'énergie d'émission pour "brûler" le bloom layer.

uniform vec4 bloom_color : source_color = vec4(1.0);
uniform float radius : hint_range(0.0, 1.0) = 0.0;
uniform float thickness : hint_range(0.0, 0.5) = 0.02;
uniform float softness : hint_range(0.0, 0.5) = 0.05;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float dist = distance(UV, vec2(0.5));
    
    // Création de l'anneau avec des dégradés doux pour un meilleur flou
    float ring = smoothstep(radius - thickness - softness, radius - thickness, dist) * 
                 smoothstep(radius + thickness + softness, radius + thickness, dist);
    
    ALBEDO = bloom_color.rgb;
    ALPHA = ring * alpha;
    
    // Intensité HDR Massive : C'est ce qui fait réagir les calques de Bloom
    // sans avoir besoin de simuler le flou ici (c'est le Viewport qui s'en charge).
    EMISSION = bloom_color.rgb * 10.0 * alpha * ring;
}
