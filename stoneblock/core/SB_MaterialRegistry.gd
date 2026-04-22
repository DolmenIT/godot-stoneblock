@tool
extends Object
class_name SB_MaterialRegistry

## 🗃️ SB_MaterialRegistry : Centralise et réutilise les matériaux PBR.
## Permet d'optimiser le rendu MultiMesh en garantissant que des réglages 
## identiques utilisent le même RID de matériau.

# Cache des matériaux. Clé : String (Hash des paramètres), Valeur : Material
static var _material_cache: Dictionary = {}

## Récupère un matériau partagé basé sur les paramètres.
## Si un matériau identique existe déjà, il est retourné. Sinon, il est créé.
static func get_shared_material(base_mat: Material, params: Dictionary) -> Material:
	if not base_mat: return null
	
	# Génération d'une clé unique basée sur le matériau source et les overrides
	var key = _generate_key(base_mat, params)
	
	if _material_cache.has(key) and is_instance_valid(_material_cache[key]):
		return _material_cache[key]
	
	# Création d'une nouvelle instance partagée
	var new_mat: Material
	
	if params.get("use_multimesh_shader", false):
		new_mat = _create_multimesh_shader_material(base_mat, params)
	else:
		new_mat = base_mat.duplicate()
		_apply_params(new_mat, params)
	
	_material_cache[key] = new_mat
	return new_mat

static func _create_multimesh_shader_material(base_mat: Material, params: Dictionary) -> ShaderMaterial:
	var sm = ShaderMaterial.new()
	sm.shader = load("res://stoneblock/shaders/SB_Standard_Vessel.gdshader")
	
	# Mapping des paramètres PBR vers les uniformes du shader
	if params.has("albedo_color"): sm.set_shader_parameter("albedo", params["albedo_color"])
	if params.has("metallic"): sm.set_shader_parameter("metallic", params["metallic"])
	if params.has("roughness"): sm.set_shader_parameter("roughness", params["roughness"])
	if params.has("specular"): sm.set_shader_parameter("specular", params["specular"])
	
	if base_mat is BaseMaterial3D and base_mat.albedo_texture:
		sm.set_shader_parameter("texture_albedo", base_mat.albedo_texture)
	
	if params.get("emission_enabled", false):
		sm.set_shader_parameter("emission_enabled", true)
		sm.set_shader_parameter("emission", params.get("emission", Color.BLACK))
		sm.set_shader_parameter("emission_energy", params.get("emission_energy_multiplier", 1.0))
	
	# Gestion de la coque (Next Pass)
	if params.has("next_pass_params"):
		_apply_next_pass(sm, params["next_pass_params"])
		
	return sm

## Nettoie le cache (utile lors des changements de niveaux ou en éditeur).
static func clear_cache() -> void:
	_material_cache.clear()

static func _generate_key(base_mat: Material, params: Dictionary) -> String:
	# On commence par le RID du matériau d'origine pour différencier les textures sources
	var key_parts = [str(base_mat.get_rid().get_id())]
	
	# On ajoute tous les paramètres triés pour garantir la consistance de la clé
	var sorted_keys = params.keys()
	sorted_keys.sort()
	
	for p_key in sorted_keys:
		key_parts.append(str(p_key) + ":" + str(params[p_key]))
	
	return "_".join(key_parts)

static func _apply_params(mat: Material, params: Dictionary) -> void:
	if not mat: return
	
	for p_key in params:
		var val = params[p_key]
		
		# Cas particuliers pour StandardMaterial3D
		if p_key == "next_pass_params" and val is Dictionary:
			_apply_next_pass(mat, val)
		else:
			# Utilisation de set() pour la compatibilité avec différents types de matériaux
			mat.set(p_key, val)

static func _apply_next_pass(mat: Material, params: Dictionary) -> void:
	if not mat: return
	
	# Création d'une coque énergétique partagée (Shell)
	var shell_mat = StandardMaterial3D.new()
	shell_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shell_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	shell_mat.cull_mode = BaseMaterial3D.CULL_BACK
	shell_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	for p_key in params:
		shell_mat.set(p_key, params[p_key])
	
	mat.next_pass = shell_mat
