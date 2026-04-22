@tool
extends Node
class_name SB_BloomTagger

## 🌸 SB_BloomTagger : Automatisateur de Bloom Sélectif.
## Scanne les matériaux et assigne les calques de Bloom (11, 12, 13) 
## aux objets possédant de l'émission.

@export_group("Settings")
## Si vrai, scanne l'objet au démarrage.
@export var auto_tag_on_ready: bool = true

@export_group("Emission Override (Glow)")
## Si vrai, force l'émission sur les matériaux pour qu'ils brillent.
@export var override_emission: bool = false
## Utilise la texture d'Albedo comme texture d'émission (idéal pour les fissures).
@export var use_albedo_as_emission: bool = false
## Couleur de l'émission forcée (multipliée par la texture si activée).
@export var emission_color: Color = Color.CORNFLOWER_BLUE
## Puissance de l'éclat.
@export var emission_energy: float = 2.0
## Seuil de filtrage (0.0 = tout brille, 1.0 = rien ne brille). 
## Utile pour isoler les fissures sur de la pierre grise.
@export_range(0, 1) var emission_threshold: float = 0.1

@export_group("Manual Override")
## Si vrai, ignore les filtres et fait briller TOUT l'objet et ses enfants.
@export var force_tag_all: bool = false
## Affiche les couleurs trouvées dans la console pour débugger.
@export var debug_log_colors: bool = false

@export_group("Color Filtering (Optional)")
## Si vrai, utilise la couleur au lieu de simplement vérifier l'émission.
@export var use_color_filter: bool = false
## La couleur à détecter pour le Bloom.
@export var target_color: Color = Color.CORNFLOWER_BLUE
## Tolérance de détection (0.0 = exact, 1.0 = n'importe quoi).
@export var color_threshold: float = 0.2

@export_group("Layers Configuration")
## Calque Bloom Long (Layer 11).
@export var bloom_long: bool = true
## Calque Bloom Med (Layer 12).
@export var bloom_med: bool = true
## Calque Bloom Short (Layer 13).
@export var bloom_short: bool = false
@export var only_show_bloom: bool = false
@export var base_layer: int = 2

@export_group("Actions")
## Bouton pour forcer le scan dans l'éditeur.
@export var trigger_scan: bool = false:
	set(v):
		if v: _perform_scan()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	if auto_tag_on_ready:
		# On attend un peu que tout soit bien instancié
		await get_tree().process_frame
		_perform_scan()

func _perform_scan() -> void:
	var target = get_parent()
	if not target: return
	
	print("[SB_BloomTagger] DÉBUT SCAN sur : ", target.name, " (Force: ", force_tag_all, ")")
	
	var mask = 0
	if bloom_long: mask |= (1 << 10) # Layer 11
	if bloom_med: mask |= (1 << 11)  # Layer 12
	if bloom_short: mask |= (1 << 12) # Layer 13
	
	_scan_recursive(target, mask)
	print("[SB_BloomTagger] FIN SCAN sur : ", target.name)

func _scan_recursive(node: Node, mask: int) -> void:
	# Debug discret pour voir passer les noeuds si besoin
	if debug_log_colors: print("  > Analyse de : ", node.name, " (Type: ", node.get_class(), ")")
	
	if node is MeshInstance3D:
		var should_tag = force_tag_all or _has_matching_material(node)
		if should_tag:
			var final_mask = mask
			if not only_show_bloom and base_layer > 0:
				final_mask |= (1 << (base_layer - 1))
			
			node.layers = final_mask
			
			if override_emission:
				_apply_emission_override(node)
			print("[SB_BloomTagger] ✅ SUCCÈS : ", node.name, " taggué avec le masque ", final_mask)
	
	for child in node.get_children():
		_scan_recursive(child, mask)

func _apply_emission_override(mesh: MeshInstance3D) -> void:
	for i in range(mesh.get_surface_override_material_count()):
		var mat = mesh.get_surface_override_material(i)
		if not mat:
			var m = mesh.mesh
			if m: mat = m.surface_get_material(i)
		
		if mat is StandardMaterial3D or mat is ORMMaterial3D:
			if emission_threshold > 0.01:
				# MODE SHADER (Pour isolation précise des fissures)
				var smat = ShaderMaterial.new()
				smat.shader = _get_bloom_shader()
				smat.set_shader_parameter("albedo_tex", mat.albedo_texture)
				smat.set_shader_parameter("albedo_color", mat.albedo_color)
				smat.set_shader_parameter("emission_color", emission_color)
				smat.set_shader_parameter("emission_energy", emission_energy)
				smat.set_shader_parameter("threshold", emission_threshold)
				smat.set_shader_parameter("target_color", target_color)
				mesh.set_surface_override_material(i, smat)
			else:
				# MODE STANDARD (Simple multiplication)
				var new_mat = mat.duplicate()
				new_mat.emission_enabled = true
				new_mat.emission = emission_color
				new_mat.emission_energy_multiplier = emission_energy
				
				if use_albedo_as_emission and mat.albedo_texture:
					new_mat.emission_operator = BaseMaterial3D.EMISSION_OP_MULTIPLY
					new_mat.emission_texture = mat.albedo_texture
				
				mesh.set_surface_override_material(i, new_mat)

func _get_bloom_shader() -> Shader:
	var s = Shader.new()
	s.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_tex : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform vec4 emission_color : source_color = vec4(1.0);
uniform float emission_energy = 1.0;
uniform float threshold = 0.1;
uniform vec4 target_color : source_color = vec4(0.25, 0.62, 1.0, 1.0);

void fragment() {
	vec4 tex = texture(albedo_tex, UV);
	ALBEDO = tex.rgb * albedo_color.rgb;
	
	// Isolation par "Pureté de Couleur" (Distance à la cible)
	float d = distance(tex.rgb, target_color.rgb);
	
	// Plus la distance est petite (d -> 0), plus le masque est fort (1.0)
	// On utilise un seuil inverse (threshold à 0.5 par défaut)
	float mask = smoothstep(threshold + 0.1, threshold, d);
	
	// Bonus : On élimine les gris (où R, G, B sont presque égaux)
	float saturation = max(max(tex.r, tex.g), tex.b) - min(min(tex.r, tex.g), tex.b);
	mask *= smoothstep(0.05, 0.2, saturation);

	EMISSION = tex.rgb * emission_color.rgb * emission_energy * mask;
}
"""
	return s

func _has_matching_material(mesh: MeshInstance3D) -> bool:
	for i in range(mesh.get_surface_override_material_count()):
		var mat = mesh.get_surface_override_material(i)
		if _check_mat(mat, mesh.name): return true
		
	var m = mesh.mesh
	if m:
		for i in range(m.get_surface_count()):
			var mat = m.surface_get_material(i)
			if _check_mat(mat, mesh.name): return true
			
	return false

func _check_mat(mat: Material, node_name: String = "") -> bool:
	if not mat: return false
	
	if mat is StandardMaterial3D or mat is ORMMaterial3D:
		var c_albedo = mat.albedo_color
		var c_emission = mat.emission if mat.emission_enabled else Color.BLACK
		
		if debug_log_colors:
			print("[SB_BloomTagger] Debug Material (%s) -> Albedo: %s, Emission: %s (Enabled: %s)" % [node_name, c_albedo, c_emission, mat.emission_enabled])

		if use_color_filter:
			if _is_color_match(c_albedo) or (mat.emission_enabled and _is_color_match(c_emission)):
				return true
			return false
		else:
			return mat.emission_enabled
			
	return false

func _is_color_match(c: Color) -> bool:
	# Calcul de distance RGB
	var diff = abs(c.r - target_color.r) + abs(c.g - target_color.g) + abs(c.b - target_color.b)
	# Normalisation approximative (max diff = 3.0)
	return (diff / 3.0) <= color_threshold
