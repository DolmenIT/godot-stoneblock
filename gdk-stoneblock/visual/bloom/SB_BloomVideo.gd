@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends Node
class_name SB_BloomVideo

## 📺 SB_BloomVideo : ContrÃ´leur de Bloom sÃ©lectif dÃ©diÃ© aux vidÃ©os.
## Utilise un systÃ¨me de Double Mesh pour isoler le Bloom sans toucher Ã  la vue principale.

@export_group("Target")
## Le lecteur vidÃ©o 3D Ã  piloter.
@export var target_video: SB_VideoPlayer3D:
	set(v):
		target_video = v
		_update_bloom()

@export_group("Emission Settings")
## Couleur du Bloom appliquÃ©.
@export var emission_color: Color = Color.WHITE:
	set(v):
		emission_color = v
		_update_bloom()
## Puissance de l'éclat.
@export var emission_energy: float = 2.0:
	set(v):
		emission_energy = v
		_update_bloom()
## Seuil de brillance (0.0 = tout brille, 1.0 = seulement le trÃ¨s blanc).
@export_range(0, 1) var emission_threshold: float = 0.5:
	set(v):
		emission_threshold = v
		_update_bloom()

@export_group("Color Filtering")
## Activer le filtrage par couleur (ex: seulement le bleu brille).
@export var use_color_filter: bool = false:
	set(v):
		use_color_filter = v
		_update_bloom()
## La couleur cible Ã  faire briller.
@export var target_color: Color = Color.CYAN:
	set(v):
		target_color = v
		_update_bloom()
## TolÃ©rance de la couleur (0.1 = prÃ©cis, 0.8 = large).
@export_range(0, 1) var color_threshold: float = 0.25:
	set(v):
		color_threshold = v
		_update_bloom()

@export_group("Layers Configuration")
@export var bloom_long: bool = true
@export var bloom_med: bool = true
@export var bloom_short: bool = true

func _ready() -> void:
	# On attend un frame pour s'assurer que le VideoPlayer a crÃ©Ã© son viewport
	await get_tree().process_frame
	_update_bloom()

func _update_bloom() -> void:
	if not target_video or not is_inside_tree(): return
	
	# 1. Configuration du Mesh Principal (Calque 1 uniquement)
	target_video.layers = (1 << 0)
	
	# 2. CrÃ©ation/RÃ©cupÃ©ration du Proxy de Bloom
	var proxy = target_video.get_node_or_null("BloomProxy") as MeshInstance3D
	if not proxy:
		proxy = MeshInstance3D.new()
		proxy.name = "BloomProxy"
		target_video.add_child.call_deferred(proxy)
	
	proxy.mesh = target_video.mesh
	
	# Configuration des calques du Proxy (11, 12, 13 uniquement)
	var mask = 0
	if bloom_long: mask |= (1 << 10)
	if bloom_med: mask |= (1 << 11)
	if bloom_short: mask |= (1 << 12)
	proxy.layers = mask
	
	# 3. Application du shader d'ISOLATION sur le Proxy
	var smat = ShaderMaterial.new()
	smat.shader = _get_video_bloom_shader()
	
	var vp_tex = target_video._viewport.get_texture() if (target_video and target_video._viewport) else null
	
	# Si la texture n'est pas encore prÃªte, on rÃ©essaie au prochain frame
	if not vp_tex:
		get_tree().create_timer(0.1).timeout.connect(_update_bloom)
		return
	
	smat.set_shader_parameter("albedo_tex", vp_tex)
	smat.set_shader_parameter("emission_color", emission_color)
	smat.set_shader_parameter("emission_energy", emission_energy)
	smat.set_shader_parameter("threshold", emission_threshold)
	smat.set_shader_parameter("use_color_filter", use_color_filter)
	smat.set_shader_parameter("target_color", target_color)
	smat.set_shader_parameter("color_threshold", color_threshold)
	
	proxy.set_surface_override_material(0, smat)

func _get_video_bloom_shader() -> Shader:
	var s = Shader.new()
	s.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D albedo_tex : source_color;
uniform vec4 emission_color : source_color = vec4(1.0);
uniform float emission_energy = 1.0;
uniform float threshold = 0.5;

uniform bool use_color_filter = false;
uniform vec4 target_color : source_color = vec4(1.0);
uniform float color_threshold = 0.25;

// Fonction de conversion RGB vers HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void fragment() {
	vec4 tex = texture(albedo_tex, UV);
	
	// 1. Calcul de la brillance (On prend le canal le plus fort pour aider les couleurs saturÃ©es)
	float v = max(tex.r, max(tex.g, tex.b));
	float luminance_mask = smoothstep(threshold, threshold + 0.1, v);
	
	float final_mask = luminance_mask;
	
	// 2. Filtre de couleur (Distance pondÃ©rÃ©e pour plus de souplesse)
	if (use_color_filter) {
		// On donne plus d'importance Ã  la teinte qu'Ã  la luminositÃ© pure
		vec3 diff = tex.rgb - target_color.rgb;
		float d = sqrt(dot(diff * vec3(0.3, 0.59, 0.11), diff)); 
		
		// Un seuil beaucoup plus progressif
		float color_mask = 1.0 - smoothstep(color_threshold * 0.2, color_threshold, d);
		final_mask *= color_mask;
	}

	ALBEDO = tex.rgb * emission_color.rgb * final_mask;
	EMISSION = tex.rgb * emission_color.rgb * emission_energy * final_mask;
}
"""
	return s
