@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends Node
class_name SB_BloomTagger

## 🌸 SB_BloomTagger : Chef d'orchestre du Bloom Sélectif.
## Scanne les matériaux et assigne les calques de Bloom (11, 12, 13).
## Gère le multi-couleurs via les noeuds enfants SB_BloomTagger_Color.

@export_group("Settings")
## Si vrai, scanne l'objet au démarrage.
@export var auto_tag_on_ready: bool = true

@export_group("Emission Override (Glow)")
## Si vrai, force l'émission sur les matériaux pour qu'ils brillent.
@export var override_emission: bool = true

@export_group("Manual Override")
## Si vrai, ignore les filtres et fait briller TOUT l'objet et ses enfants.
@export var force_tag_all: bool = false
## Affiche les couleurs trouvées dans la console pour débugger.
@export var debug_log_colors: bool = true

@export_group("Default Color (Fallback)")
## Utilisé uniquement s'il n'y a pas de noeuds enfants SB_BloomColor.
@export var target_color: Color = Color(0.25, 0.62, 1.0, 1.0)
@export var emission_color: Color = Color(0.25, 0.62, 1.0, 1.0)
@export var emission_energy: float = 25.0
@export_range(0, 1) var emission_threshold: float = 0.5
@export var color_threshold: float = 0.5

@export_group("Layers Configuration")
## Calque Bloom Long (Layer 11).
@export var bloom_long: bool = true
## Calque Bloom Med (Layer 12).
@export var bloom_med: bool = false
## Calque Bloom Short (Layer 13).
@export var bloom_short: bool = false
@export var only_show_bloom: bool = false
@export var base_layer: int = 1

@export_group("Actions")
## Bouton pour forcer le scan dans l'éditeur.
@export var trigger_scan: bool = false:
	set(v):
		if v: _perform_scan()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	if auto_tag_on_ready:
		_perform_scan()

func _perform_scan() -> void:
	var target = get_parent()
	if not target: return
	
	var configs = _get_colors_config()
	print("[SB_BloomTagger] DÉBUT SCAN sur : ", target.name, " (", configs.size(), " couleurs détectées)")
	
	var mask = 0
	if bloom_long: mask |= (1 << 10) # Layer 11
	if bloom_med: mask |= (1 << 11)  # Layer 12
	if bloom_short: mask |= (1 << 12) # Layer 13
	
	_scan_recursive(target, mask, configs)
	print("[SB_BloomTagger] FIN SCAN sur : ", target.name)

func _get_colors_config() -> Array:
	var configs = []
	for child in get_children():
		if child is SB_BloomTagger_Color:
			configs.append({
				"target": child.target_color,
				"emission": child.emission_color,
				"energy": child.emission_energy,
				"threshold": child.emission_threshold,
				"color_threshold": child.color_threshold
			})
	
	if configs.is_empty():
		configs.append({
			"target": target_color,
			"emission": emission_color,
			"energy": emission_energy,
			"threshold": emission_threshold,
			"color_threshold": color_threshold
		})
	return configs

func _scan_recursive(node: Node, mask: int, configs: Array) -> void:
	if node is MeshInstance3D:
		var should_tag = force_tag_all or _has_matching_material(node, configs)
		if should_tag:
			var final_mask = mask
			if not only_show_bloom and base_layer > 0:
				final_mask |= (1 << (base_layer - 1))
			
			node.layers |= final_mask
			
			if override_emission:
				_apply_multi_emission_override(node, configs)
			print("[SB_BloomTagger] ✅ SUCCÈS : ", node.name, " taggué.")
	
	for child in node.get_children():
		if not child is SB_BloomTagger and not child is SB_BloomTagger_Color:
			_scan_recursive(child, mask, configs)

func _apply_multi_emission_override(mesh: MeshInstance3D, configs: Array) -> void:
	var surface_count = mesh.mesh.get_surface_count() if mesh.mesh else mesh.get_surface_override_material_count()
	
	for i in range(surface_count):
		var mat = mesh.get_surface_override_material(i)
		if not mat:
			var m = mesh.mesh
			if m: mat = m.surface_get_material(i)
		
		if not mat: continue
		
		# On applique toujours le shader multi-couleurs si c'est un matériau standard ou notre shader
		if mat is StandardMaterial3D or mat is ORMMaterial3D or (mat is ShaderMaterial and mat.get_shader_parameter("target_colors")):
			var smat = ShaderMaterial.new()
			smat.shader = _get_multi_bloom_shader(configs.size())
			
			# Transfert des propriétés d'origine
			if mat is StandardMaterial3D or mat is ORMMaterial3D:
				smat.set_shader_parameter("albedo_tex", mat.albedo_texture)
				smat.set_shader_parameter("albedo_color", mat.albedo_color)
			elif mat is ShaderMaterial:
				smat.set_shader_parameter("albedo_tex", mat.get_shader_parameter("albedo_tex"))
				smat.set_shader_parameter("albedo_color", mat.get_shader_parameter("albedo_color"))
			
			# Remplissage des tableaux de couleurs
			var targets = []
			var emissions = []
			var energies = []
			var thresholds = []
			
			for cfg in configs:
				targets.append(cfg.target)
				emissions.append(cfg.emission)
				energies.append(cfg.energy)
				thresholds.append(cfg.threshold)
			
			smat.set_shader_parameter("target_colors", targets)
			smat.set_shader_parameter("emission_colors", emissions)
			smat.set_shader_parameter("emission_energies", energies)
			smat.set_shader_parameter("thresholds", thresholds)
			
			mesh.set_surface_override_material(i, smat)

func _get_multi_bloom_shader(count: int) -> Shader:
	var s = Shader.new()
	s.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_tex : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);

uniform vec4 target_colors[16];
uniform vec4 emission_colors[16];
uniform float emission_energies[16];
uniform float thresholds[16];

void fragment() {
	vec4 tex = texture(albedo_tex, UV);
	ALBEDO = tex.rgb * albedo_color.rgb;
	
	vec3 total_emission = vec3(0.0);
	
	for(int i = 0; i < """ + str(count) + """; i++) {
		float d = distance(tex.rgb, target_colors[i].rgb);
		float mask = smoothstep(thresholds[i] + 0.1, thresholds[i], d);
		
		float saturation = max(max(tex.r, tex.g), tex.b) - min(min(tex.r, tex.g), tex.b);
		mask *= smoothstep(0.05, 0.2, saturation);
		
		total_emission += tex.rgb * emission_colors[i].rgb * emission_energies[i] * mask;
	}
	
	EMISSION = total_emission;
}
"""
	return s

func _has_matching_material(mesh: MeshInstance3D, _configs: Array) -> bool:
	# Un peu plus permissif ici : si on a une texture, on accepte
	var m = mesh.mesh
	if m:
		for i in range(m.get_surface_count()):
			var mat = m.surface_get_material(i)
			if mat and (mat.get("albedo_texture") != null or mat is ShaderMaterial):
				return true
	return false

func _check_mat(mat: Material, configs: Array) -> bool:
	if not mat: return false
	if mat is ShaderMaterial and mat.get_shader_parameter("target_colors"): return true
	if mat is StandardMaterial3D or mat is ORMMaterial3D:
		if mat.albedo_texture != null: return true
		for cfg in configs:
			if _is_color_match(mat.albedo_color, cfg.target, cfg.color_threshold):
				return true
	return false

func _is_color_match(c: Color, target: Color, threshold: float) -> bool:
	var diff = abs(c.r - target.r) + abs(c.g - target.g) + abs(c.b - target.b)
	return (diff / 3.0) <= threshold
