@tool
extends Node3D
class_name SB_Player_VShmup

## 🚀 SB_Player_VShmup : Controleur du vaisseau joueur pour le mode SHMUP.
## Gère le mouvement, l'inclinaison (banking) et les limites de l'écran.

# --- Configuration ---
@export_group("Movement")
@export var movement_speed: float = 30.0
@export var acceleration: float = 10.0
@export var damping: float = 5.0

@export_group("Special Actions")
@export var dash_duration: float = 0.4
@export var dash_boost: float = 2.0
@export var dash_cooldown: float = 0.5

@export_group("Banking (Tilt)")
@export var max_bank_angle: float = 25.0 # Degrés
@export var bank_speed: float = 5.0

@export var horizontal_limit: float = 25.0
@export var vertical_limit: float = 18.0

@export_group("Propulsion (IP-031)")
## Multiplicateur de vitesse lors de l'accélération (Boost).
@export var boost_speed_mult: float = 1.5
## Multiplicateur de vitesse lors du freinage (Brake).
@export var brake_speed_mult: float = 0.4
## Coût en énergie par seconde lors du Boost.
@export var energy_cost_boost: float = 10.0

@export_subgroup("Reactors Visuals")
## Nombre de réacteurs (1 = centre, 2+= symétrie).
@export var engine_count: int = 2:
	set(v):
		engine_count = v
		if Engine.is_editor_hint(): _setup_engines()
## Écartement horizontal entre les réacteurs.
@export var engine_spacing_x: float = 0.5:
	set(v):
		engine_spacing_x = v
		if Engine.is_editor_hint(): _setup_engines()
## Décalage vertical des réacteurs.
@export var engine_offset_y: float = 0.1:
	set(v):
		engine_offset_y = v
		if Engine.is_editor_hint(): _setup_engines()
## Décalage en profondeur des réacteurs (Z+ = Arrière).
@export var engine_offset_z: float = 1.2:
	set(v):
		engine_offset_z = v
		if Engine.is_editor_hint(): _setup_engines()
## Positions locales manuelles (Dépasse les réglages ci-dessus si renseigné).
@export var manual_engine_positions: Array[Vector3] = []
## Scène de particules pour les réacteurs.
@export var engine_particle_scene: PackedScene = preload("res://stoneblock/effects/SB_EngineParticles.tscn")
## Énergie maximum du vaisseau.
@export var energy_max: float = 100.0
## Vitesse de régénération d'énergie (% par seconde).
@export var energy_regen: float = 2.0
@export var energy_cost_fire: float = 1.0
@export var energy_cost_dash: float = 20.0

@export_group("Shield & Health")
## Points de vie maximum.
@export var health_max: float = 100.0
## Bouclier maximum (se régénère au repos).
@export var shield_max: float = 25.0
## Temps d'attente sans dégâts avant régénération (secondes).
@export var shield_regen_delay: float = 2.0
## Vitesse de régénération du bouclier (points par seconde).
@export var shield_regen_speed: float = 5.0
## Temps d'invulnérabilité après un impact (secondes).
@export var invul_duration: float = 2.0

@export_group("Combat")
@export var projectile_scene: PackedScene = preload("res://stoneblock/projectiles/SB_Projectile_VShmup.tscn")
@export var fire_rate: float = 0.25 # Secondes entre deux tirs
@export var fire_action: String = "ui_accept"
@export var use_external_input: bool = false # Si vrai, ignore le clavier interne

@export_group("Power-ups")
## Scène du projectile à utiliser pour le Triple Shot (optionnel, sinon utilise le défaut).
@export var triple_projectile_scene: PackedScene = null
## Angle d'éventail pour le Triple Shot (degrés).
@export var triple_shot_spread: float = 15.0

@export var explosion_scene: PackedScene = preload("res://stoneblock/effects/SB_PlayerExplosion_VShmup.tscn")
## Modèle 3D du vaisseau (Scène GLB/TSCN). Si défini, remplace le visuel par défaut.
@export var vessel_scene: PackedScene
## Rotation corrective à appliquer au modèle 3D.
@export var vessel_rotation: Vector3 = Vector3.ZERO
## Échelle du modèle 3D.
@export var vessel_scale: float = 1.0
@export var visual_node: Node3D # Le nœud qui subira les rotations (Modèle du vaisseau)

# --- État ---
var velocity: Vector2 = Vector2.ZERO
var external_input_vector: Vector2 = Vector2.ZERO
var is_external_firing: bool = false

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: float = 0.0
var cooldown_timer: float = 0.0
var target_bank: float = 0.0
var current_bank: float = 0.0
var _last_fire_time: float = 0.0
var _pivot_ref: Node3D
var _is_dead: bool = false

var energy: float = 100.0
var health: float = 100.0
var shield: float = 25.0
var _invul_timer: float = 0.0
var _shield_regen_timer: float = 0.0

var _triple_shot_timer: float = 0.0
var _has_triple_shot: bool = false
var _banking_input: float = 0.0
var _engines: Array[GPUParticles3D] = []

# --- Pilotage par Cible (Touch/Mouse) ---
var _target_world_pos: Vector3 = Vector3.ZERO
var _has_target_pos: bool = false
@export var touch_interpolation_speed: float = 12.0

func _ready() -> void:
	health = health_max
	shield = shield_max
	if Engine.is_editor_hint(): return
	
	# Instanciation dynamique du vaisseau si spécifié
	if vessel_scene:
		_apply_vessel_visuals()
		
	_setup_engines()

## Configure le vaisseau et les power-ups selon les sélections du Workshop.
func apply_workshop_settings(ship_id: String, powerup_id: String) -> void:
	# 1. Gestion du Vaisseau (Stats & Visuels)
	match ship_id:
		"phantom_jet":
			movement_speed = 30.0
			health_max = 100.0
			# Modèle par défaut déjà chargé via l'export ou mainground.tscn
		"nexus_disk":
			movement_speed = 36.0 # +20%
			health_max = 80.0     # -20%
			# Ici on pourrait charger un autre vessel_scene si on avait le chemin
		"storm_stalker":
			movement_speed = 24.0 # -20%
			health_max = 150.0    # +50%
	
	health = health_max
	if SB_Core.instance:
		SB_Core.instance.log_msg("Workshop : Configuration appliquée pour " + ship_id, "info")
	
	# 2. Gestion du Power-up de départ
	match powerup_id:
		"triple_shot":
			activate_triple_shot(99999) # Permanent pour ce vaisseau
		"dual_cannon":
			# TODO: Logique Dual Cannon (plus tard)
			pass
		"heavy_laser":
			# TODO: Logique Heavy Laser (plus tard)
			pass

func _apply_vessel_visuals() -> void:
	_hide_ship()
	visible = true
	
	# Création d'un pivot pour séparer la rotation corrective du banking technique
	var pivot = Node3D.new()
	pivot.name = "VesselPivot"
	add_child(pivot)
	
	var vessel = vessel_scene.instantiate()
	pivot.add_child(vessel)
	vessel.rotation_degrees = vessel_rotation
	
	# C'est le pivot qui subira les inclinaisons (banking)
	visual_node = pivot
	visual_node.scale = Vector3(vessel_scale, vessel_scale, vessel_scale)

func _setup_engines() -> void:
	if not engine_particle_scene or not visual_node: return
	
	# Nettoyage des anciens réacteurs
	for engine in _engines:
		if engine: engine.queue_free()
	_engines.clear()
	
	# Calcul des positions
	var positions: Array[Vector3] = []
	if not manual_engine_positions.is_empty():
		positions = manual_engine_positions
	else:
		if engine_count <= 1:
			positions.append(Vector3(0, engine_offset_y, engine_offset_z))
		else:
			for i in range(engine_count):
				# Répartition symétrique
				var x = -engine_spacing_x/2.0 + (i * engine_spacing_x / (engine_count - 1))
				positions.append(Vector3(x, engine_offset_y, engine_offset_z))
	
	for pos in positions:
		var particles = engine_particle_scene.instantiate() as GPUParticles3D
		if particles:
			visual_node.add_child(particles)
			particles.position = pos
			particles.rotation_degrees = Vector3.ZERO # Direction de base (+Z)
			_engines.append(particles)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or _is_dead: return
	
	# Mise à jour des timers de dash
	# --- Timers compensés ---
	var effective_delta = delta
	if Engine.time_scale < 1.0 and Engine.time_scale > 0:
		effective_delta = delta / Engine.time_scale

	if is_dashing:
		dash_timer -= effective_delta
		if dash_timer <= 0.0:
			is_dashing = false
	
	if cooldown_timer > 0.0:
		cooldown_timer -= effective_delta
	
	# Régénération d'énergie (On garde peut-être le temps ralenti pour l'énergie ? Non, on va dire que le générateur du vaisseau est aussi en temps réel)
	energy = min(energy_max, energy + energy_regen * effective_delta)
	
	# Régénération de bouclier
	if _shield_regen_timer > 0.0:
		_shield_regen_timer -= effective_delta
	elif shield < shield_max:
		shield = min(shield_max, shield + shield_regen_speed * effective_delta)
	
	# Temps du Power-up
	if _triple_shot_timer > 0.0:
		_triple_shot_timer -= effective_delta
		if _triple_shot_timer <= 0:
			_has_triple_shot = false
			if SB_Core.instance:
				SB_Core.instance.log_msg("Triple Shot expiré !", "info")
	
	if _invul_timer > 0.0:
		_invul_timer -= effective_delta
		# Effet visuel de clignotement simple
		if visual_node:
			visual_node.visible = fmod(_invul_timer, 0.2) > 0.1
	elif visual_node and not _is_dead:
		visual_node.visible = true
	
	_process_movement(delta)
	_process_visuals(delta)
	_handle_firing()

func _process_movement(delta: float) -> void:
	var input_vec = Vector2.ZERO
	var is_direct_input = false
	
	if use_external_input:
		input_vec = external_input_vector
		if input_vec.length() > 0.1: is_direct_input = true
	else:
		input_vec.x = Input.get_axis("ui_left", "ui_right")
		input_vec.y = Input.get_axis("ui_up", "ui_down")
		if input_vec.length() > 0.1: is_direct_input = true
	
	if is_direct_input:
		_has_target_pos = false # Annule le mouvement tactile si on utilise le stick/clavier
	
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
	
	# --- Compensation Bullet Time ---
	var effective_delta = delta
	if Engine.time_scale < 1.0 and Engine.time_scale > 0:
		effective_delta = delta / Engine.time_scale

	# --- Mouvement ---
	var final_speed = movement_speed 
	
	if is_direct_input or is_dashing:
		if is_dashing:
			input_vec.x = dash_direction 
			final_speed *= dash_boost
		
		# Propulsion (Accélération / Freinage)
		var thrust = 0.0 
		var thrust_input = Input.get_axis("ui_down", "ui_up") 
		if thrust_input > 0.1 and energy > 0:
			thrust = thrust_input
			final_speed *= lerp(1.0, boost_speed_mult, thrust)
			energy -= energy_cost_boost * effective_delta
		elif thrust_input < -0.1:
			thrust = thrust_input
			final_speed *= lerp(1.0, brake_speed_mult, -thrust)
		
		global_position.x += input_vec.x * final_speed * effective_delta
		global_position.z += input_vec.y * final_speed * effective_delta 
		_banking_input = input_vec.x
		_update_engines_visual(thrust)
		
	elif _has_target_pos:
		# --- Pilotage Tactile/Souris ---
		# On clampe la cible pour qu'elle ne dépasse pas les limites du vaisseau
		# Cela évite que le vaisseau ne "pousse" indéfiniment contre les bords
		var p_pos = _pivot_ref.global_position if _pivot_ref else Vector3.ZERO
		var target_x = clamp(_target_world_pos.x, p_pos.x - horizontal_limit, p_pos.x + horizontal_limit)
		var target_z = clamp(_target_world_pos.z, p_pos.z - vertical_limit, p_pos.z + vertical_limit)
		
		var dir_3d = Vector3(target_x, 0, target_z) - global_position
		dir_3d.y = 0 # On reste sur le plan
		
		if dir_3d.length() > 0.1:
			var lerp_val = touch_interpolation_speed * effective_delta
			global_position.x = lerp(global_position.x, target_x, lerp_val)
			global_position.z = lerp(global_position.z, target_z, lerp_val)
			
			# Banking simulé basé sur la direction du mouvement
			_banking_input = clamp(dir_3d.x / 5.0, -1.0, 1.0)
		else:
			_has_target_pos = false
			_banking_input = 0
	
	# Clamping horizontal (Camera relative)
	
	# Clamping horizontal (Camera relative)
	if not _pivot_ref:
		var gm = get_parent()
		while gm and not gm.has_method("add_score_kill"):
			gm = gm.get_parent()
		if gm:
			_pivot_ref = gm.camera_pivot

	if not _pivot_ref: return
	
	var pivot_pos = _pivot_ref.global_position
	global_position.x = clamp(global_position.x, pivot_pos.x - horizontal_limit, pivot_pos.x + horizontal_limit)
	global_position.z = clamp(global_position.z, pivot_pos.z - vertical_limit, pivot_pos.z + vertical_limit)

func _process_visuals(delta: float) -> void:
	var mesh = visual_node
	if not mesh:
		mesh = get_node_or_null("Mesh")
	if not mesh:
		mesh = get_node_or_null("MeshInstance3D")
	if not mesh:
		# Fallback : Prend le premier enfant qui ressemble à un visuel
		for child in get_children():
			if child is VisualInstance3D:
				mesh = child
				break
	
	if not mesh: return
	
	# Inclinaison latérale (Banking léger)
	target_bank = -_banking_input * deg_to_rad(max_bank_angle)
	# --- Compensation Bullet Time ---
	var effective_delta = delta
	if Engine.time_scale < 1.0 and Engine.time_scale > 0:
		effective_delta = delta / Engine.time_scale

	current_bank = lerp(current_bank, target_bank, bank_speed * effective_delta)
	
	# Tonneau (Rotation 360 sur l'axe Forward/Z)
	var barrel_rot = 0.0
	if is_dashing:
		var progress = (dash_duration - dash_timer) / dash_duration
		barrel_rot = -dash_direction * progress * 360.0
	
	# Application combinée sur l'axe Z
	mesh.rotation_degrees.z = rad_to_deg(current_bank) + barrel_rot

func _update_engines_visual(thrust: float) -> void:
	for engine in _engines:
		# On module l'émission en fonction du thrust (-1 à 1)
		# 0.5 au repos, 1.0 en boost, 0.2 en frein
		var power = 0.5 + (thrust * 0.5)
		if engine.process_material is ParticleProcessMaterial:
			engine.amount_ratio = clamp(power, 0.1, 1.0)

func _handle_firing() -> void:
	var wants_to_fire = false
	if use_external_input:
		wants_to_fire = is_external_firing
	else:
		wants_to_fire = Input.is_action_pressed(fire_action)
		
	if wants_to_fire:
		var now = Time.get_ticks_msec() / 1000.0
		if now - _last_fire_time > fire_rate:
			fire()
			_last_fire_time = now

## API PUBLIQUE : Pilotage externe
func set_input_vector(vec: Vector2) -> void:
	external_input_vector = vec

func set_input_vector_x(val: float) -> void:
	external_input_vector.x = val

func set_input_vector_y(val: float) -> void:
	external_input_vector.y = val

func set_firing(active: bool) -> void:
	is_external_firing = active

## API PUBLIQUE : Pilotage par Raycast (Touch/Mouse)
func _on_raycast_hit(pos: Vector3) -> void:
	# print("[Player] Reçu cible: ", pos)
	_target_world_pos = pos
	_has_target_pos = true

func stop_touch_movement() -> void:
	# print("[Player] Stop Touch Movement")
	_has_target_pos = false

func set_dash(active: bool) -> void:
	if not active or is_dashing or cooldown_timer > 0.0: return
	
	# Vérification énergie
	if energy < energy_cost_dash: return
	
	# Récupération de la direction actuelle
	var input_x = Input.get_axis("ui_left", "ui_right") if not use_external_input else external_input_vector.x
	
	if abs(input_x) > 0.1:
		energy -= energy_cost_dash
		is_dashing = true
		dash_timer = dash_duration
		dash_direction = sign(input_x)
		cooldown_timer = dash_cooldown

## API PUBLIQUE : Gestion Énergie
func add_energy(amount: float) -> void:
	energy = min(energy_max, energy + amount)

func die() -> void:
	if _is_dead: return
	_is_dead = true
	
	# Ralentissement global dramatique (Mort)
	if SB_TimeManager.instance:
		SB_TimeManager.instance.death_slowmo(0.1)
	
	# Explosion visuelle
	if explosion_scene:
		var exp_instance = explosion_scene.instantiate()
		get_parent().add_child(exp_instance)
		exp_instance.global_position = global_position
	
	# Désactivation visuelle robuste
	_hide_ship()
	
	# Signalement au GameMode
	var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
	if gm and gm.has_method("trigger_game_over"):
		gm.trigger_game_over()

## API PUBLIQUE : Gestion Dégâts & Bouclier
func take_damage(amount: float) -> void:
	if _is_dead or _invul_timer > 0.0: return
	
	_shield_regen_timer = shield_regen_delay
	
	# On impacte d'abord le bouclier
	if shield > 0:
		var shield_dmg = min(shield, amount)
		shield -= shield_dmg
		amount -= shield_dmg
	
	# Puis la vie si reste des dégâts
	if amount > 0:
		health -= amount
		_invul_timer = invul_duration
	
	# Bullet Time (Slow Motion au hit)
	if SB_TimeManager.instance and health > 0:
		SB_TimeManager.instance.hit_slowmo(1.0, 0.2)
	
	# Shake Camera (via GameMode -> CameraManager)
	var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
	if gm and gm.camera_manager and gm.camera_manager.has_method("add_shake"):
		gm.camera_manager.add_shake(1.5, 0.3)
	
	if health <= 0:
		health = 0
		die()
	else:
		if SB_Core.instance:
			SB_Core.instance.log_msg("Dégâts reçus ! Vie : %d%%, Bouclier : %d%%" % [(health/health_max)*100, (shield/shield_max)*100], "warning")

func add_shield(amount: float) -> void:
	shield = min(shield_max, shield + amount)

func add_health(amount: float) -> void:
	health = min(health_max, health + amount)

func add_coin(amount: float) -> void:
	# Stockage des coins (monnaie) dans les statistiques du Core
	if SB_Core.instance:
		SB_Core.instance.add_stat("magie", int(amount)) 
		SB_Core.instance.log_msg("Coin collecté : +%d" % amount, "success")

func _hide_ship() -> void:
	visible = false
	# On cherche tous les meshs enfants pour être sûr
	for child in get_children():
		if child is VisualInstance3D: child.visible = false
		for sub_child in child.get_children():
			if sub_child is VisualInstance3D: sub_child.visible = false

## Méthode pour tirer
func fire() -> void:
	if not projectile_scene or energy < energy_cost_fire: return
	
	if _has_triple_shot:
		_fire_triple_shot()
	else:
		_fire_single_shot()

func _fire_single_shot() -> void:
	energy -= energy_cost_fire
	var bullet = projectile_scene.instantiate()
	_spawn_projectile(bullet, global_position, Vector3(0, 0, -1))

func _fire_triple_shot() -> void:
	energy -= energy_cost_fire * 2.0 # Coût légèrement plus élevé
	
	# Tir Central
	var b1 = (triple_projectile_scene if triple_projectile_scene else projectile_scene).instantiate()
	_spawn_projectile(b1, global_position, Vector3(0, 0, -1))
	
	# Tir Gauche
	var b2 = (triple_projectile_scene if triple_projectile_scene else projectile_scene).instantiate()
	var dir_left = Vector3(sin(deg_to_rad(-triple_shot_spread)), 0, -cos(deg_to_rad(-triple_shot_spread)))
	_spawn_projectile(b2, global_position, dir_left)
	
	# Tir Droit
	var b3 = (triple_projectile_scene if triple_projectile_scene else projectile_scene).instantiate()
	var dir_right = Vector3(sin(deg_to_rad(triple_shot_spread)), 0, -cos(deg_to_rad(triple_shot_spread)))
	_spawn_projectile(b3, global_position, dir_right)

func _spawn_projectile(bullet: Node3D, pos: Vector3, dir: Vector3) -> void:
	# On cherche un pivot de défilement mondial (Z-only) pour garder la portée stable sans déviation en X
	var scroll_pivot = get_tree().root.find_child("World_Scroll_Pivot", true, false)
	if not scroll_pivot:
		scroll_pivot = get_tree().root.find_child("Camera_Pivot", true, false)
	
	if scroll_pivot:
		scroll_pivot.add_child(bullet)
	else:
		get_parent().add_child(bullet)
		
	bullet.global_position = pos
	bullet.direction = dir

## API PUBLIQUE : Activation Power-ups
func activate_triple_shot(duration: float = 10.0) -> void:
	_has_triple_shot = true
	_triple_shot_timer = duration
	if SB_Core.instance:
		SB_Core.instance.log_msg("Triple Shot ACTIF (%ds) !" % [duration], "success")
