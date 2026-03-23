@tool
@icon("res://stoneblock/icons/SB_Particles3D.svg")
class_name SB_Particles3D
extends Node3D

## Système de particules simplifié pour StoneBlock.
## Permet de projeter des sprites (Cercles, Images, Animations) avec contrôle précis de la trajectoire.

enum VisualMode { COLOR_CIRCLE, IMAGE, ANIMATED }

@export_group("Spawn & Trajectory")
## Position de départ relative à l'émetteur.
@export var origin_offset: Vector3 = Vector3.ZERO
## Rayon de dispersion au point de départ (r1).
@export var spawn_radius: float = 0.5
## Orientation du jet (ax, ay, az) en degrés, relative à l'émetteur.
@export var direction_angles: Vector3 = Vector3.ZERO
## Dispersion de la direction (r2). Ajoute un décalage aléatoire au vecteur de direction.
@export var direction_spread: float = 0.2
## Puissance de projection (P).
@export var min_power: float = 2.0
@export var max_power: float = 5.0
## Si vrai, les particules suivent les mouvements de l'émetteur après leur spawn.
@export var local_space: bool = false

@export_group("Visuals")
## Mode de rendu des particules.
@export var visual_mode: VisualMode = VisualMode.COLOR_CIRCLE
## Couleur utilisée pour le mode COLOR_CIRCLE.
@export var particle_color: Color = Color.WHITE
## Image utilisée pour le mode IMAGE.
@export var particle_image: Texture2D
## SpriteFrames utilisé pour le mode ANIMATED.
@export var sprite_frames: SpriteFrames
## Si vrai, les particules font face à la caméra.
@export var billboard: bool = true
## Si vrai, chaque particule commence avec une rotation aléatoire (0-360°).
@export var random_initial_rotation: bool = false
## Vitesse de rotation minimale (degrés/sec).
@export var rotation_speed_min: float = 0.0
## Vitesse de rotation maximale (degrés/sec).
@export var rotation_speed_max: float = 0.0
## Calque de rendu pour les particules (Défaut 1).
@export_flags_3d_render var layers: int = 1

@export_group("Lifetime & Scale")
## Durée de vie d'une particule en secondes.
@export var lifetime: float = 1.0
## Taille minimale de base (aléatoire).
@export var scale_min: float = 0.5
## Taille maximale de base (aléatoire).
@export var scale_max: float = 1.0
## Courbe d'évolution de la taille sur la durée de vie (multiplicateur).
@export var scale_curve: Curve

@export_group("Physics & Curvature")
## Force de gravité constante appliquée aux particules.
@export var gravity: Vector3 = Vector3.ZERO
## Force d'attraction vers le point d'origine (crée un effet de courbure/retour).
@export var attraction_to_origin: float = 0.0

@export_group("Emission")
## Nombre d'émissions par seconde.
@export var emission_rate: float = 5.0
## Quantité minimale de particules par émission.
@export var amount_min: int = 1
## Quantité maximale de particules par émission.
@export var amount_max: int = 1
## Espacement temporel (en sec) entre les particules d'un burst pour créer une trainée.
@export var burst_spacing: float = 0.01
## Si vrai, émet automatiquement au démarrage.
@export var auto_emit: bool = true

var _timer: float = 0.0
var _particle_pool: Array[Node3D] = []
var _inactive_pool: Array[Node3D] = []

func _ready() -> void:
	if not Engine.is_editor_hint() and auto_emit:
		set_process(true)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	_timer += delta
	var spawn_interval = 1.0 / emission_rate
	
	while _timer >= spawn_interval:
		emit_burst()
		_timer -= spawn_interval
	
	_update_particles(delta)

func emit_once() -> void:
	spawn_particle()

func emit_burst() -> void:
	var count = randi_range(amount_min, amount_max)
	if count <= 0: return
	
	# Calculer une origine, une vélocité et une vitesse de rotation partagées pour tout le burst
	var shared_origin = _calculate_origin()
	var shared_velocity = _calculate_velocity()
	var shared_rot_speed = deg_to_rad(randf_range(rotation_speed_min, rotation_speed_max))
	
	for i in count:
		spawn_particle(i * burst_spacing, shared_origin, shared_velocity, shared_rot_speed)

func spawn_particle(time_offset: float = 0.0, shared_origin: Vector3 = Vector3.ZERO, shared_velocity: Vector3 = Vector3.ZERO, shared_rot_speed: float = -999.0) -> void:
	var particle: Node3D
	if not _inactive_pool.is_empty():
		particle = _inactive_pool.pop_back()
	else:
		particle = _create_particle_node()
		add_child(particle)
	
	_reset_particle(particle, time_offset, shared_origin, shared_velocity, shared_rot_speed)
	# On ne met pas visible tout de suite si delay > 0
	particle.visible = false
	_particle_pool.append(particle)

func _create_particle_node() -> Node3D:
	var node = Node3D.new()
	var sprite: Node3D
	
	match visual_mode:
		VisualMode.COLOR_CIRCLE, VisualMode.IMAGE:
			sprite = Sprite3D.new()
			if visual_mode == VisualMode.COLOR_CIRCLE:
				# On pourrait utiliser un placeholder circulaire ici, 
				# ou simplement une texture générée dynamiquement si besoin.
				# Par souci de simplicité pour StoneBlock, on utilise une texture blanche 
				# modulée par la couleur.
				(sprite as Sprite3D).texture = particle_image if particle_image else _get_default_circle_texture()
			else:
				(sprite as Sprite3D).texture = particle_image
			
			(sprite as Sprite3D).modulate = particle_color
			# On désactive le billboard natif car il casse la rotation Z
			(sprite as Sprite3D).billboard = BaseMaterial3D.BILLBOARD_DISABLED
			(sprite as Sprite3D).layers = layers
			
		VisualMode.ANIMATED:
			sprite = AnimatedSprite3D.new()
			(sprite as AnimatedSprite3D).sprite_frames = sprite_frames
			# On désactive le billboard natif car il casse la rotation Z
			(sprite as AnimatedSprite3D).billboard = BaseMaterial3D.BILLBOARD_DISABLED
			(sprite as AnimatedSprite3D).layers = layers
			(sprite as AnimatedSprite3D).play()
	
	node.add_child(sprite)
	sprite.name = "Visual"
	return node

func _reset_particle(p: Node3D, delay: float = 0.0, shared_origin: Vector3 = Vector3.ZERO, shared_velocity: Vector3 = Vector3.ZERO, shared_rot_speed: float = -999.0) -> void:
	# On stocke les paramètres de spawn
	var origin = shared_origin if shared_origin != Vector3.ZERO else _calculate_origin()
	var velocity = shared_velocity if shared_velocity != Vector3.ZERO else _calculate_velocity()
	
	# Si on est en espace global, on transforme la vélocité locale en globale dès maintenant
	if not local_space:
		velocity = global_transform.basis * velocity
	
	p.set_meta("velocity", velocity)
	p.set_meta("spawn_pos", origin)
	p.set_meta("age", -delay) # Age négatif pour le délai de spawn
	
	# Taille de base aléatoire
	var base_s = randf_range(scale_min, scale_max)
	p.set_meta("base_scale", base_s)
	p.scale = Vector3.ONE * base_s
	
	# Rotation initiale (toujours individuelle par particule)
	var visual = p.get_node("Visual")
	if random_initial_rotation:
		visual.rotation.z = randf_range(0, TAU)
	else:
		visual.rotation.z = 0
	
	# Vitesse de rotation (partagée si burst)
	var rot_speed = shared_rot_speed
	if rot_speed == -999.0: # Valeur sentinelle pour "non fourni"
		rot_speed = deg_to_rad(randf_range(rotation_speed_min, rotation_speed_max))
		
	p.set_meta("rot_speed", rot_speed)
	
	# Configuration de l'indépendance
	p.top_level = not local_space

func _calculate_origin() -> Vector3:
	var random_offset = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized() * randf_range(0, spawn_radius)
	return origin_offset + random_offset

func _calculate_velocity() -> Vector3:
	# Direction : angles + random r2 (local)
	var base_dir = Vector3.FORWARD
	base_dir = base_dir.rotated(Vector3.RIGHT, deg_to_rad(direction_angles.x))
	base_dir = base_dir.rotated(Vector3.UP, deg_to_rad(direction_angles.y))
	base_dir = base_dir.rotated(Vector3.BACK, deg_to_rad(direction_angles.z))
	
	var spread_offset = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized() * direction_spread
	
	return (base_dir + spread_offset).normalized() * randf_range(min_power, max_power)

func _update_particles(delta: float) -> void:
	var to_remove = []
	for p in _particle_pool:
		var age = p.get_meta("age") + delta
		p.set_meta("age", age)
		
		# Tant que l'âge est négatif, la particule attend son tour à l'origine
		if age < 0:
			p.visible = false
			continue
			
		# Au moment de l'activation (passage à age >= 0)
		if not p.visible:
			p.visible = true
			var spawn_pos = p.get_meta("spawn_pos")
			if local_space:
				p.position = spawn_pos
			else:
				p.global_position = global_transform * spawn_pos
		
		if age >= lifetime:
			to_remove.append(p)
			continue
		
		# Manuel Billboard : Force la particule à faire face à la caméra tout en préservant la rotation locale Z
		if billboard:
			var camera = get_viewport().get_camera_3d()
			if camera:
				# On aligne la basis de la particule sur celle de la caméra
				p.global_transform.basis = camera.global_transform.basis
				# Le scale sera réappliqué proprement à la fin de la fonction
		
		# Mouvement & Physique
		var velocity = p.get_meta("velocity")
		
		# Appliquer la gravité
		velocity += gravity * delta
		
		# Appliquer l'attraction vers l'origine
		if attraction_to_origin != 0:
			var origin: Vector3
			if local_space:
				origin = p.get_meta("spawn_pos")
			else:
				# Si global, on rappelle que spawn_pos était relatif à l'émetteur AU SPAWN
				# mais ici on veut peut-être attirer vers le point global de spawn.
				# Pour simplifier StoneBlock, on attire vers le point GLOBAL calculé au spawn.
				origin = global_transform * p.get_meta("spawn_pos")
				
			var current_pos = p.position if local_space else p.global_position
			var to_origin = origin - current_pos
			velocity += to_origin.normalized() * attraction_to_origin * delta
		
		p.set_meta("velocity", velocity)
		
		if local_space:
			p.position += velocity * delta
		else:
			p.global_position += velocity * delta
		
		# Rotation du sprite
		var rot_speed = p.get_meta("rot_speed")
		if rot_speed != 0:
			p.get_node("Visual").rotation.z += rot_speed * delta
		
		# Scale
		var t = age / lifetime
		var base_s = p.get_meta("base_scale")
		var multiplier = scale_curve.sample(t) if scale_curve else (1.0 - t)
		p.scale = Vector3.ONE * (base_s * multiplier)
		
	for p in to_remove:
		p.visible = false
		_particle_pool.erase(p)
		_inactive_pool.append(p)

func _get_default_circle_texture() -> GradientTexture2D:
	# Fallback si pas d'image : un cercle blanc simple via gradient
	var grad = Gradient.new()
	grad.colors = [Color.WHITE, Color.WHITE, Color.TRANSPARENT]
	grad.offsets = [0.0, 0.8, 0.81]
	
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.width = 64
	tex.height = 64
	return tex
