shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 filter_color : source_color = vec4(0.0, 0.4, 0.8, 0.4);
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Calcul de la distance au centre (Vignette plus agressive)
    // On multiplie par 1.4 pour que les coins soient à ~1.0
    float dist = length(uv - 0.5) * 1.4;
    float vignette = smoothstep(0.3, 0.8 + vignette_softness * 0.5, dist);
    
    // Flou simple
    vec4 color = textureLod(SCREEN_TEXTURE, uv, blur_amount * vignette * intensity);
    
    // Application de la couleur bleutée (plus intense)
    vec3 tinted_color = mix(color.rgb, filter_color.rgb, filter_color.a * intensity);
    
    // Assombrissement des bords (Vignette)
    float edge_darkness = 1.0 - (vignette * 0.7 * intensity);
    tinted_color *= edge_darkness;
    
    // Ajout d'une petite lueur bleue additive sur les bords pour le "punch"
    vec3 glow_color = filter_color.rgb * vignette * intensity * 0.3;
    tinted_color += glow_color;
    
    COLOR = vec4(tinted_color, 1.0);
}
