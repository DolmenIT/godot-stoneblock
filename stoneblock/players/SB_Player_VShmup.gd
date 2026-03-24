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

@export_group("Energy")
@export var energy_max: float = 100.0
@export var energy_regen: float = 2.0 # % par seconde
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
@export var invul_duration: float = 1.0

@export_group("Combat")
@export var projectile_scene: PackedScene = preload("res://stoneblock/projectiles/SB_Projectile_VShmup.tscn")
@export var fire_rate: float = 0.1 # Secondes entre deux tirs
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

func _ready() -> void:
	health = health_max
	shield = shield_max
	if Engine.is_editor_hint(): return
	
	# Instanciation dynamique du vaisseau si spécifié
	if vessel_scene:
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

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or _is_dead: return
	
	# Mise à jour des timers de dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	
	# Régénération d'énergie
	energy = min(energy_max, energy + energy_regen * delta)
	
	# Régénération de bouclier
	if _shield_regen_timer > 0.0:
		_shield_regen_timer -= delta
	elif shield < shield_max:
		shield = min(shield_max, shield + shield_regen_speed * delta)
	
	# Temps du Power-up
	if _triple_shot_timer > 0.0:
		_triple_shot_timer -= delta
		if _triple_shot_timer <= 0:
			_has_triple_shot = false
			if SB_Core.instance:
				SB_Core.instance.log_msg("Triple Shot expiré !", "info")
	
	if _invul_timer > 0.0:
		_invul_timer -= delta
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
	if use_external_input:
		input_vec = external_input_vector
	else:
		input_vec.x = Input.get_axis("ui_left", "ui_right")
		input_vec.y = Input.get_axis("ui_up", "ui_down")
	
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
	
	# Application du boost de dash (uniquement latéralement)
	var final_speed = movement_speed # Changed from 'move_speed' to 'movement_speed'
	if is_dashing:
		input_vec.x = dash_direction # Force la direction du dash
		final_speed *= dash_boost
	
	global_position.x += input_vec.x * final_speed * delta
	global_position.z += input_vec.y * final_speed * delta # Z for forward/backward in 3D, not Y
	
	# Clamping horizontal (Camera relative)
	if not _pivot_ref:
		var gm = get_parent()
		while gm and not gm is SB_GameMode_VShmup:
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
	var input_x = Input.get_axis("ui_left", "ui_right") if not use_external_input else external_input_vector.x
	target_bank = -input_x * deg_to_rad(max_bank_angle)
	current_bank = lerp(current_bank, target_bank, bank_speed * delta)
	
	# Tonneau (Rotation 360 sur l'axe Forward/Z)
	var barrel_rot = 0.0
	if is_dashing:
		var progress = (dash_duration - dash_timer) / dash_duration
		barrel_rot = -dash_direction * progress * 360.0
	
	# Application combinée sur l'axe Z
	mesh.rotation_degrees.z = rad_to_deg(current_bank) + barrel_rot

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
