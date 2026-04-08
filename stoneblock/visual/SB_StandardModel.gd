@tool
extends Node3D
class_name SB_StandardModel

## 🎨 SB_StandardModel : Force l'aspect visuel (PBR) sur un modèle 3D.
## Utile pour supprimer l'effet glossy (brillant) des modèles importés.

@export_group("Standard Model Settings")
@export var enable_standard_override: bool = true:
	set(value):
		enable_standard_override = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

## Le nœud à scanner récursivement pour les meshs. Si vide, utilise le manager lui-même.
@export var target_node: Node3D:
	set(value):
		target_node = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

@export_subgroup("Material Properties")
@export var albedo_color: Color = Color.WHITE:
	set(value):
		albedo_color = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

@export_range(0.0, 1.0) var metallic: float = 0.0:
	set(value):
		metallic = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

@export_range(0.0, 1.0) var roughness: float = 1.0:
	set(value):
		roughness = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()
		
@export_range(0.0, 1.0) var specular: float = 0.0:
	set(value):
		specular = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

@export_group("Advanced Rendering")
@export var diffuse_mode: BaseMaterial3D.DiffuseMode = BaseMaterial3D.DIFFUSE_BURLEY:
	set(value):
		diffuse_mode = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

@export var specular_mode: BaseMaterial3D.SpecularMode = BaseMaterial3D.SPECULAR_SCHLICK_GGX:
	set(value):
		specular_mode = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

@export_group("Emission (Glow) Settings")
## Active l'émission (éclat) sur le mesh principal.
@export var enable_glow: bool = false:
	set(value):
		enable_glow = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

## Couleur de l'émission.
@export var glow_color: Color = Color.WHITE:
	set(value):
		glow_color = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

## Intensité de l'émission.
@export_range(0.0, 16.0) var glow_energy: float = 1.0:
	set(value):
		glow_energy = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

@export_group("Bloom Sélectif Settings")
enum BloomCategory { NONE = 0, LONG = 11, MEDIUM = 12, SHORT = 13 }
## Catégorie de Bloom pour cet objet.
@export var bloom_category: BloomCategory = BloomCategory.NONE:
	set(value):
		bloom_category = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

@export_group("Shell (Next Pass) Settings")
## Active une coque/bouclier énergétique autour du mesh.
@export var enable_shell: bool = false:
	set(value):
		enable_shell = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

## Couleur de la coque.
@export var shell_color: Color = Color(1, 0, 0, 0.3):
	set(value):
		shell_color = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

## Épaisseur de la coque (Grow).
@export_range(0.0, 0.5) var shell_thickness: float = 0.02:
	set(value):
		shell_thickness = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

## Active l'émission (glow) sur la coque.
@export var enable_shell_glow: bool = false:
	set(value):
		enable_shell_glow = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

## Intensité de l'éclat de la coque.
@export_range(0.0, 16.0) var shell_glow_energy: float = 1.0:
	set(value):
		shell_glow_energy = value
		if Engine.is_editor_hint() and is_inside_tree(): apply_standard_settings()

func _ready() -> void:
	if not is_inside_tree(): return
	apply_standard_settings()

func apply_standard_settings() -> void:
	if not enable_standard_override: return
	var root = target_node if target_node else self
	_apply_recursive(root)

func _apply_recursive(node: Node) -> void:
	if not is_instance_valid(node): return
	if node is MeshInstance3D:
		_override_mesh_material(node as MeshInstance3D)
	
	for child in node.get_children():
		_apply_recursive(child)

func _override_mesh_material(mesh_inst: MeshInstance3D) -> void:
	if not is_instance_valid(mesh_inst): return
	
	# On travaille sur les overrides de surface pour ne pas modifier la ressource mesh elle-même
	var surface_count = mesh_inst.get_surface_override_material_count()
	if mesh_inst.mesh:
		surface_count = mesh_inst.mesh.get_surface_count()
	
	for i in range(surface_count):
		# Gestion du Bloom Sélectif (Layers)
		var final_mask: int = 1 # Visible par défaut sur le calque 1
		if bloom_category != BloomCategory.NONE:
			final_mask |= (1 << (int(bloom_category) - 1))
		
		mesh_inst.layers = final_mask
		
		var mat = mesh_inst.get_surface_override_material(i)
		if not mat and mesh_inst.mesh:
			mat = mesh_inst.mesh.surface_get_material(i)
		
		# Application du matériau de base (PBR)
		if mat and mat is BaseMaterial3D:
			var new_mat = mat.duplicate()
			
			# On multiplie l'albedo au lieu de l'écraser (préserve les textures)
			new_mat.albedo_color = mat.albedo_color * albedo_color
			
			new_mat.metallic = metallic
			new_mat.roughness = roughness
			
			# On préserve l'émission d'origine (important pour les détails lumineux)
			if mat.emission_enabled:
				new_mat.emission_enabled = true
				new_mat.emission = mat.emission
				new_mat.emission_energy_multiplier = mat.emission_energy_multiplier
			
			# En Godot 4, 'specular' peut déclencher des warnings de compatibilité
			# sur certains matériaux importés. On utilise set() pour être plus souple
			# ou on s'assure que c'est bien un StandardMaterial3D.
			if new_mat is StandardMaterial3D:
				new_mat.specular = specular
			else:
				new_mat.set("specular", specular)
				
			new_mat.diffuse_mode = diffuse_mode
			new_mat.specular_mode = specular_mode
			
			# Gestion de la coque (Next Pass - Bouclier 3D Volumétrique)
			if enable_shell:
				var shell_mat = StandardMaterial3D.new()
				shell_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				shell_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
				shell_mat.cull_mode = BaseMaterial3D.CULL_BACK
				shell_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				shell_mat.albedo_color = shell_color
				shell_mat.grow = true
				shell_mat.grow_amount = shell_thickness
				
				if enable_shell_glow:
					shell_mat.emission_enabled = true
					# On force l'alpha à 1.0 pour que l'éclat soit maximal (indépendant de la transparence)
					shell_mat.emission = Color(shell_color.r, shell_color.g, shell_color.b, 1.0)
					shell_mat.emission_energy_multiplier = shell_glow_energy
				
				new_mat.next_pass = shell_mat
			else:
				new_mat.next_pass = null
			
			
			mesh_inst.set_surface_override_material(i, new_mat)

func _create_bloom_ghost(base_mesh: MeshInstance3D, surface_idx: int, mask: int) -> void:
	var ghost = MeshInstance3D.new()
	ghost.name = base_mesh.name + "_BloomGhost_" + str(surface_idx)
	ghost.mesh = base_mesh.mesh
	ghost.skin = base_mesh.skin
	ghost.skeleton = base_mesh.skeleton
	
	# Uniquement visible par le Bloom, ignore le calque 1 (mainground)
	ghost.layers = mask
	ghost.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# Matériau spécial X-Ray (No depth test pour bypasser l'occlusion du boss)
	var mat = base_mesh.get_surface_override_material(surface_idx)
	if not mat and base_mesh.mesh:
		mat = base_mesh.mesh.surface_get_material(surface_idx)
		
	var ghost_mat = StandardMaterial3D.new()
	ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ghost_mat.no_depth_test = true
	ghost_mat.render_priority = 10
	ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	if mat and mat is BaseMaterial3D:
		ghost_mat.albedo_color = (mat.albedo_color * albedo_color) * glow_energy
		if mat.albedo_texture:
			ghost_mat.albedo_texture = mat.albedo_texture
		if mat.emission_enabled:
			ghost_mat.albedo_color += (mat.emission * mat.emission_energy_multiplier) * glow_energy
	else:
		ghost_mat.albedo_color = (glow_color * albedo_color) * glow_energy
		
	ghost.set_surface_override_material(surface_idx, ghost_mat)
	base_mesh.add_child(ghost)
