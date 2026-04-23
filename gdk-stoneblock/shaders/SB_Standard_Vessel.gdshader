shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float specular : hint_range(0.0, 1.0) = 0.5;

uniform bool emission_enabled = false;
uniform vec4 emission : source_color = vec4(0.0);
uniform float emission_energy = 1.0;

varying float v_flash_intensity;
varying vec3 v_flash_color;

void vertex() {
	v_flash_intensity = INSTANCE_CUSTOM.x;
	v_flash_color = INSTANCE_CUSTOM.yzw;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	
	if (emission_enabled) {
		EMISSION = emission.rgb * emission_energy;
	}
	
	if (v_flash_intensity > 0.0) {
		ALBEDO = mix(ALBEDO, v_flash_color, v_flash_intensity);
		EMISSION += v_flash_color * v_flash_intensity * 2.0;
	}
}
