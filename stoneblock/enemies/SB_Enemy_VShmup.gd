@tool
extends Area3D
class_name SB_Enemy_VShmup

## 👾 SB_Enemy_VShmup : Enemi de base pour le mode SHMUP.
## Se déplace vers le bas et explose au contact ou sous les tirs.

@export var speed: float = 0.0
@export var health: float = 1.0
@export var damage: float = 10.0

@export_group("Combat")
## Scène du projectile tiré par l'ennemi.
@export var projectile_scene: PackedScene = preload("res://stoneblock/projectiles/SB_Projectile_Enemy_VShmup.tscn")
## Intervalle entre deux tirs (secondes).
@export var fire_interval: float = 1.6
## Chance de tirer à chaque intervalle (0 à 1).
@export var fire_chance: float = 0.8
## Durée de l'alerte avant le tir (secondes).
@export var warning_duration: float = 0.6

@export var explosion_scene: PackedScene = preload("res://stoneblock/effects/SB_Explosion_VShmup.tscn")

@export_group("Loot (Drops)")
@export_subgroup("Static Loots")
## Premier slot de loot (ex: énergie).
@export var loot_1_scene: PackedScene = preload("res://stoneblock/pickups/SB_Loot_Energy.tscn")
@export var loot_1_count: int = 2

## Deuxième slot de loot (ex: bouclier).
@export var loot_2_scene: PackedScene = preload("res://stoneblock/pickups/SB_Loot_Shield.tscn")
@export var loot_2_count: int = 1

## Troisième slot de loot (ex: pièces).
@export var loot_3_scene: PackedScene = preload("res://stoneblock/pickups/SB_Loot_Coin.tscn")
@export var loot_3_count: int = 3

@export_subgroup("Dynamic Loots")
@export var triple_shot_scene: PackedScene = preload("res://stoneblock/pickups/SB_Pickup_TripleShot.tscn")
@export var triple_shot_chance: float = 0.15

@export_group("Vessel Parameters")
## Modèle 3D de l'ennemi (Scène GLB/TSCN). Si défini, remplace le visuel par défaut.
@export var vessel_scene: PackedScene :
	set(v):
		vessel_scene = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()
## Rotation corrective à appliquer au modèle 3D.
@export var vessel_rotation: Vector3 = Vector3.ZERO :
	set(v):
		vessel_rotation = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()
## Échelle du modèle 3D.
@export var vessel_scale: float = 1.25 :
	set(v):
		vessel_scale = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

var _pivot_ref: Node3D
var _visual_nodes: Array[Node3D] = []
var _flash_material: ShaderMaterial = ShaderMaterial.new()
var _fire_timer: float = 0.0
var _is_warning: bool = false
var _warning_tween: Tween
var _game_mode_ref: Node
var _is_visible: bool = true # Par défaut visible pour ne pas bloquer les tirs

@export_group("Movement & Activation")
## Distance (Z) à partir de laquelle l'ennemi s'active par rapport au pivot caméra.
@export var activation_threshold: float = 45.0
## Si activé, l'ennemi ignore son propre mouvement pour suivre celui de son parent (vague/groupe).
@export var follow_group: bool = false
## Afficher un indicateur 360° quand l'ennemi est hors-champ.
@export var show_incoming_warning: bool = true
## Distance maximale d'affichage de l'alerte (en mètres).
@export var warning_max_distance: float = 105.0
var _is_active: bool = false

func _refresh_visuals() -> void:
	if not _flash_material.shader:
		_flash_material.shader = load("res://stoneblock/shaders/SB_HitFlash.gdshader")

	# Instanciation dynamique si spécifié
	if vessel_scene:
		_hide_mesh()
		
		var pivot = get_node_or_null("VesselPivot")
		if not pivot:
			pivot = Node3D.new()
			pivot.name = "VesselPivot"
			add_child(pivot)
		
		pivot.scale = Vector3(vessel_scale, vessel_scale, vessel_scale)
		
		# On nettoie les vaisseaux précédents si déjà là (cas du reload éditeur)
		for child in pivot.get_children():
			child.queue_free()
		
		var vessel = vessel_scene.instantiate()
		pivot.add_child(vessel)
		vessel.rotation_degrees = vessel_rotation
		
		# On récupère les meshs pour le flash
		_visual_nodes.clear()
		_find_visual_nodes(vessel)
	else:
		_visual_nodes.clear()
		_find_visual_nodes(self)

func _ready() -> void:
	_refresh_visuals()
	
	# Connexion aux signaux de collision (Sécurisée)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if Engine.is_editor_hint(): return
	
	# Recherche du pivot pour le cleanup
	var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
	if gm:
		_game_mode_ref = gm
		if "camera_pivot" in gm:
			_pivot_ref = gm.camera_pivot
	
	# Ajout dynamique de l'indicateur d'alerte
	if show_incoming_warning:
		var indicator = SB_TargetIndicator_VShmup.new()
		indicator.max_distance = warning_max_distance
		add_child(indicator)

func _process(delta: float) -> void:
	# Gestion du réveil si inactif (Ignoré si géré par un groupe)
	if not _is_active:
		if not follow_group and _game_mode_ref and _game_mode_ref.camera_pivot:
			# Distance relative au pivot (Z négatif = au-dessus de l'écran)
			var dist_z = global_position.z - _game_mode_ref.camera_pivot.global_position.z
			if dist_z >= -activation_threshold:
				_activate()
		return

	# Mouvement vers le bas (Z positif) - Désactivé si géré par le groupe
	if not follow_group:
		global_position.z += speed * delta
	
	_process_combat(delta)
	_check_cleanup()

func _activate() -> void:
	_is_active = true
	# On peut ici déclencher une petite animation d'entrée s'il y a un mesh caché

func _process_combat(delta: float) -> void:
	if _game_mode_ref and _game_mode_ref.is_game_over: return
	
	if not _is_visible: return
	
	if not projectile_scene: return
	
	_fire_timer += delta
	
	# Gestion de l'alerte pré-tir (Uniquement si l'ennemi a une chance de tirer)
	var warning_start_time = max(0.0, fire_interval - warning_duration)
	if fire_chance > 0 and _fire_timer >= warning_start_time and not _is_warning:
		_is_warning = true
		_start_warning()
	
	if _fire_timer >= fire_interval:
		_fire_timer = 0.0
		if _is_warning:
			_is_warning = false
			_stop_warning()
		if randf() < fire_chance:
			_fire()

func _start_warning() -> void:
	# Clignotement rouge
	for node in _visual_nodes:
		if node is MeshInstance3D:
			node.material_override = _flash_material
	
	_flash_material.set_shader_parameter("flash_color", Color.RED)
	
	if _warning_tween: _warning_tween.kill()
	_warning_tween = create_tween().set_loops()
	_warning_tween.tween_method(_update_flash_intensity.bind(null), 0.0, 1.0, 0.1)
	_warning_tween.tween_method(_update_flash_intensity.bind(null), 1.0, 0.0, 0.1)

func _stop_warning() -> void:
	if _warning_tween:
		_warning_tween.kill()
		_warning_tween = null
	
	for node in _visual_nodes:
		if node is MeshInstance3D:
			node.material_override = null

func _fire() -> void:
	var bullet = projectile_scene.instantiate()
	_get_objects_container().add_child(bullet)
	
	bullet.global_position = global_position
	# Tirer vers le bas (Z+)
	bullet.direction = Vector3(0, 0, 1)

func _get_objects_container() -> Node:
	# On cherche la racine du monde (le Viewport Mainground) qui est statique.
	# Les objets ajoutés ici resteront à leur position mondiale pendant que la caméra avance.
	if _game_mode_ref and _game_mode_ref.mainground_viewport:
		return _game_mode_ref.mainground_viewport
	
	# Fallback si pas de GameMode (dev)
	return get_tree().root

func _check_cleanup() -> void:
	if not _pivot_ref: return
	
	# Si l'ennemi est trop loin derrière le pivot (en bas de l'écran)
	if global_position.z > _pivot_ref.global_position.z + 40.0:
		queue_free()

func take_damage(amount: float) -> void:
	health -= amount
	_hit_flash()
	if health <= 0:
		_explode()

func _hit_flash() -> void:
	if _is_warning: _stop_warning()
	
	for node in _visual_nodes:
		if node is MeshInstance3D:
			node.material_override = _flash_material
			_flash_material.set_shader_parameter("flash_color", Color.WHITE)
			_flash_material.set_shader_parameter("flash_modifier", 1.0)
			
			var tween = create_tween()
			tween.tween_method(_update_flash_intensity.bind(node), 1.0, 0.0, 0.15)
			tween.finished.connect(func(): node.material_override = null)

func _update_flash_intensity(value: float, _node: MeshInstance3D) -> void:
	_flash_material.set_shader_parameter("flash_modifier", value)

func _explode(silent: bool = false) -> void:
	# Signalement du kill au GameMode (Score & Combo)
	if not silent:
		var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
		if gm and gm.has_method("add_score_kill"):
			gm.add_score_kill()
	
	# Explosion visuelle
	if explosion_scene:
		var exp_instance = explosion_scene.instantiate()
		get_parent().add_child(exp_instance)
		exp_instance.global_position = global_position
	
	# Loot : Chance de lâcher un Power-up Triple Shot
	if triple_shot_scene and randf() < triple_shot_chance:
		var ts = triple_shot_scene.instantiate()
		_get_objects_container().add_child(ts)
		ts.global_position = global_position
	
	# Drops Fixes (Génériques)
	_spawn_loot_group(loot_1_scene, loot_1_count)
	_spawn_loot_group(loot_2_scene, loot_2_count)
	_spawn_loot_group(loot_3_scene, loot_3_count)
	
	queue_free()

func _spawn_loot_group(scene: PackedScene, count: int) -> void:
	if not scene or count <= 0: return
	
	for i in range(count):
		var loot = scene.instantiate()
		_get_objects_container().add_child(loot)
		loot.global_position = global_position
		
		# Éjection aléatoire pour l'effet visuel de dispersion
		var force = randf_range(4.0, 12.0)
		var angle = randf_range(0, PI * 2)
		if "velocity" in loot:
			loot.velocity = Vector3(cos(angle), 0, sin(angle)) * force

func _on_area_entered(area: Area3D) -> void:
	# Si touché par un projectile
	if area is SB_Projectile_VShmup or area.name.contains("Projectile"):
		take_damage(1.0)
		if area.has_method("explode"):
			area.explode()
		else:
			area.queue_free()

func _on_body_entered(body: Node3D) -> void:
	# Si collision avec le joueur -> DEGATS
	if body.name.contains("Player") or body.has_method("take_damage"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		_explode(true)

func _hide_mesh() -> void:
	# On cherche tous les meshs enfants pour être sûr
	for child in get_children():
		if child is VisualInstance3D: child.visible = false
		for sub_child in child.get_children():
			if sub_child is VisualInstance3D: sub_child.visible = false

func _find_visual_nodes(root: Node) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			_visual_nodes.append(child)
		_find_visual_nodes(child)
