@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends SB_2_World3D
class_name SB_WarpStarfield

## 🌌 SB_WarpStarfield : Effet de voyage spatial multi-bloom.
## Les étoiles divergent du centre et sont réparties sur différents calques de Bloom.

@export_group("Génération")
@export_range(100, 5000) var amount: int = 1000:
	set(v):
		amount = v
		_refresh_all()

@export var star_size: float = 0.1:
	set(v):
		star_size = v
		_refresh_all()

@export var star_scale_min: float = 1.0:
	set(v):
		star_scale_min = v
		_refresh_all()

@export var star_scale_max: float = 10.0:
	set(v):
		star_scale_max = v
		_refresh_all()

@export var spawn_area_radius: float = 0.0:
	set(v):
		spawn_area_radius = v
		_refresh_all()

@export var travel_distance: float = 100.0:
	set(v):
		travel_distance = v
		_refresh_all()

@export_group("Mouvement")
@export var speed_min: float = 6.25:
	set(v):
		speed_min = v
		_refresh_all()

@export var speed_max: float = 12.5:
	set(v):
		speed_max = v
		_refresh_all()

@export var lifetime: float = 25.0:
	set(v):
		lifetime = v
		_refresh_all()

@export_group("Orientation & Axe")
enum MovementAxis { X, Y, Z }
## Axe principal du voyage (Y pour Shmup, Z pour Vue de face).
@export var movement_axis: MovementAxis = MovementAxis.Z:
	set(v):
		movement_axis = v
		_refresh_all()

## Inverser le sens du voyage sur l'axe choisi.
@export var inverse_direction: bool = false:
	set(v):
		inverse_direction = v
		_refresh_all()

## Simuler artificiellement la profondeur (Indispensable en ORTHO, optionnel en PERSPECTIVE).
@export var depth_simulation: bool = true:
	set(v):
		depth_simulation = v
		_refresh_all()

var _particle_nodes: Array[GPUParticles3D] = []

func _refresh_all() -> void:
	if not is_inside_tree(): return
	# En mode Tool, on reconstruit tout pour être sûr
	for child in get_children():
		child.queue_free()
	_particle_nodes.clear()
	_setup_multi_particles()

func _ready() -> void:
	# Nettoyage
	for child in get_children():
		child.queue_free()
	_particle_nodes.clear()
		
	_setup_multi_particles()

func _setup_multi_particles() -> void:
	# On crée 4 émetteurs pour varier le Bloom
	# 1: Background seul (1)
	# 2: Background + Bloom Long (1 | 1024)
	# 3: Background + Bloom Med (1 | 2048)
	# 4: Background + Bloom Short (1 | 4096)
	var masks = [1, 1 | 1024, 1 | 2048, 1 | 4096]
	var amount_per_node: int = int(float(amount) / masks.size())
	
	# Détermination du vecteur de direction et de position
	var dir = Vector3.ZERO
	var start_pos = Vector3.ZERO
	var inv = -1.0 if inverse_direction else 1.0
	
	match movement_axis:
		MovementAxis.X:
			dir = Vector3(1, 0, 0) * inv
			start_pos = Vector3(-travel_distance * inv, 0, 0)
		MovementAxis.Y:
			dir = Vector3(0, 1, 0) * inv
			start_pos = Vector3(0, -travel_distance * inv, 0)
		MovementAxis.Z:
			dir = Vector3(0, 0, 1) * inv
			start_pos = Vector3(0, 0, -travel_distance * inv)
	
	for mask in masks:
		var p = _create_particle_node(mask, amount_per_node, dir, start_pos)
		add_child(p)
		_particle_nodes.append(p)

func _create_particle_node(mask: int, count: int, dir: Vector3, start_pos: Vector3) -> GPUParticles3D:
	var p = GPUParticles3D.new()
	p.amount = count
	p.lifetime = lifetime
	p.preprocess = lifetime
	p.visibility_aabb = AABB(Vector3(-500, -500, -500), Vector3(1000, 1000, 1000))
	p.layers = mask
	p.local_coords = false
	
	# Placement initial
	p.position = start_pos
	
	var pm = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = spawn_area_radius
	
	pm.direction = dir
	pm.initial_velocity_min = speed_min
	pm.initial_velocity_max = speed_max
	pm.gravity = Vector3.ZERO
	
	# Gestion de la taille (Multipliée par star_size pour un contrôle total)
	pm.scale_min = star_size * star_scale_min
	pm.scale_max = star_size * star_scale_max
	
	if depth_simulation:
		# EFFET ORTHO : Accélération radiale pour divergence
		pm.radial_accel_min = 2.0
		pm.radial_accel_max = 10.0
		
		# EFFET ORTHO : Courbe de taille ULTRA AGRESSIVE
		var curve = Curve.new()
		curve.add_point(Vector2(0, 0.05)) # Invisible au loin
		curve.add_point(Vector2(0.5, 0.5)) # Grossit à moitié
		curve.add_point(Vector2(1, 5.0))  # Devient énorme juste avant de mourir
		var tex = CurveTexture.new()
		tex.curve = curve
		pm.scale_curve = tex
	else:
		# MODE PERSPECTIVE : On laisse la caméra gérer, mais on peut garder une petite courbe de fondu
		pm.spread = 15.0 # On réduit la dispersion pour un effet "tunnel" plus propre
		var curve = Curve.new()
		curve.add_point(Vector2(0, 0.0))
		curve.add_point(Vector2(0.1, 1.0))
		curve.add_point(Vector2(0.9, 1.0))
		curve.add_point(Vector2(1, 0.0))
		var tex = CurveTexture.new()
		tex.curve = curve
		pm.scale_curve = tex
	
	pm.color_initial_ramp = _get_color_gradient()
	p.process_material = pm
	
	# Mesh (Taille de base à 1.0 pour laisser le scale du ParticleProcessMaterial piloter)
	var mesh = QuadMesh.new()
	mesh.size = Vector2(1.0, 1.0)
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.billboard_keep_scale = true # LA CLÉ : Permet de garder l'échelle des particules
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.surface_set_material(0, mat)
	p.draw_pass_1 = mesh
	
	return p

func _update_all_particles() -> void:
	if _particle_nodes.is_empty(): return
	var count: int = int(float(amount) / _particle_nodes.size())
	for p in _particle_nodes:
		p.amount = count

func _get_color_gradient() -> GradientTexture1D:
	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 1.0])
	grad.colors = PackedColorArray([
		Color.WHITE,
		Color(0.7, 0.8, 1.0, 0.8), # Bleu
		Color(1.0, 1.0, 0.7, 0.9), # Jaune
		Color(1.0, 0.7, 0.5, 0.8), # Orange
		Color.WHITE
	])
	var tex = GradientTexture1D.new()
	tex.gradient = grad
	return tex
