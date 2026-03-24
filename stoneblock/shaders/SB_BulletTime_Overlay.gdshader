shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 filter_color : source_color = vec4(0.0, 0.4, 0.8, 0.4);
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Calcul de la distance au centre (Vignette)
    float dist = distance(uv, vec2(0.5));
    float vignette = smoothstep(0.4, 0.5 + vignette_softness, dist);
    
    // Flou simple (plusieurs échantillons autour du point)
    vec4 color = textureLod(SCREEN_TEXTURE, uv, blur_amount * vignette * intensity);
    
    // Application de la couleur bleutée
    vec3 tinted_color = mix(color.rgb, filter_color.rgb, filter_color.a * intensity);
    
    // Assombrissement des bords
    tinted_color = mix(tinted_color, tinted_color * 0.5, vignette * intensity);
    
    COLOR = vec4(tinted_color, 1.0);
}
