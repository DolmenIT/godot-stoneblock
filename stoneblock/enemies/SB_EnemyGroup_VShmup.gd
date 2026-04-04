@tool
extends Node3D
class_name SB_EnemyGroup_VShmup

## 🛸 SB_EnemyGroup_VShmup : Gère des vagues d'ennemis intelligentes.
## Permet de définir un template commun (modèle, PV, tir) et de générer la formation.

enum Formation { V_SHAPE, LINE_H, LINE_V, SQUARE, CIRCLE }

@export_group("Formation")
## Type de formation automatique pour les enfants.
@export var formation_type: Formation = Formation.V_SHAPE :
	set(v):
		formation_type = v
		update_formation()
## Espacement entre les ennemis dans la formation.
@export var spacing: float = 5.0 :
	set(v):
		spacing = v
		update_formation()

@export_group("Enemy Template")
## La scène d'ennemi à instancier (par défaut SB_Enemy_VShmup).
@export var enemy_scene: PackedScene = preload("res://stoneblock/enemies/SB_Enemy_VShmup.tscn")
## Remplacer le modèle 3D de tous les ennemis du groupe.
@export var vessel_scene: PackedScene :
	set(v):
		vessel_scene = v
		_sync_children()
## Échelle des visuels d'ennemis.
@export var vessel_scale: float = 1.0 :
	set(v):
		vessel_scale = v
		_sync_children()
## Points de vie pour tout le groupe.
@export var health: float = 15.0 :
	set(v):
		health = v
		_sync_children()
## Les ennemis du groupe peuvent-ils tirer ?
@export var can_shoot: bool = true :
	set(v):
		can_shoot = v
		_sync_children()
## Cadence de tir globale pour le groupe.
@export var fire_interval: float = 1.6 :
	set(v):
		fire_interval = v
		_sync_children()
## Si VRAI, le groupe écrase les PV, le modèle et la cadence de tir des enfants.
## Si FAUX, le groupe respecte les réglages individuels des Prefabs.
@export var override_prefab_stats: bool = true :
	set(v):
		override_prefab_stats = v
		_sync_children()

@export_group("Generator (Editor Only)")
## Nombre d'ennemis à générer dans ce groupe.
@export var enemy_count: int = 3
## Bouton : Cliquer ici (cocher puis décocher) pour recréer le groupe d'ennemis.
@export var rebuild_group: bool = false :
	set(v):
		if v and Engine.is_editor_hint():
			_generate_enemies()
		rebuild_group = false

@export_group("Mouvement de Groupe")
## Vitesse de descente du groupe entier.
@export var group_speed: float = 5.0
## Amplitude du mouvement latéral (sinusoïde). 0 = Désactivé.
@export var wave_amplitude: float = 8.0
## Vitesse du mouvement latéral.
@export var wave_speed: float = 2.0

@export_group("Activation")
## Distance (Z) à partir de laquelle le groupe entier s'active.
@export var activation_threshold: float = 45.0
var _is_active: bool = false
var _time: float = 0.0

# var _engines: Array[Node3D] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		_sync_children()
	update_formation()

func _generate_enemies() -> void:
	if not enemy_scene: return
	
	# Nettoyage
	for child in get_children():
		child.queue_free()
	
	# Génération
	for i in range(enemy_count):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.name = "Enemy_%d" % (i + 1)
		
		# IMPORTANT : Pour que les enfants soient sauvés dans la scène (.tscn)
		if Engine.is_editor_hint():
			var root = get_tree().edited_scene_root
			if root: enemy.owner = root
	
	_sync_children.call_deferred()
	update_formation.call_deferred()

func _sync_children() -> void:
	if not override_prefab_stats: 
		# On force quand même le 'follow_group' pour que le mouvement fonctionne
		for child in get_children():
			if child is SB_Enemy_VShmup:
				child.follow_group = true
		return
		
	for child in get_children():
		if child is SB_Enemy_VShmup:
			child.follow_group = true
			if vessel_scene: child.vessel_scene = vessel_scene
			child.vessel_scale = vessel_scale
			child.health = health
			child.health_max = health
			child.fire_interval = fire_interval
			child.fire_chance = 1.0 if can_shoot else 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if get_child_count() > 0:
			update_formation()
		return
	
	if not _is_active:
		var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
		if gm and gm.camera_pivot:
			var dist_z = global_position.z - gm.camera_pivot.global_position.z
			if dist_z >= -activation_threshold:
				_activate_group()
		return
	
	_time += delta
	position.z += group_speed * delta
	if wave_amplitude > 0:
		position.x = sin(_time * wave_speed) * wave_amplitude

func _activate_group() -> void:
	_is_active = true
	for child in get_children():
		if child is SB_Enemy_VShmup:
			child._activate()

func update_formation() -> void:
	var children = []
	for child in get_children():
		if child is SB_Enemy_VShmup or (Engine.is_editor_hint() and child is Node3D):
			children.append(child)
	
	var count = children.size()
	if count == 0: return
	
	match formation_type:
		Formation.V_SHAPE:
			for i in range(count):
				var side = 1 if i % 2 == 0 else -1
				var step = floor((i + 1) / 2.0)
				children[i].position = Vector3(step * spacing * side, 0, -step * spacing * 0.5)
		
		Formation.LINE_H:
			var total_w = (count - 1) * spacing
			for i in range(count):
				children[i].position = Vector3(-total_w/2.0 + (i * spacing), 0, 0)
				
		Formation.LINE_V:
			for i in range(count):
				children[i].position = Vector3(0, 0, -i * spacing)
				
		Formation.CIRCLE:
			var radius = (count * spacing) / (2.0 * PI)
			for i in range(count):
				var angle = (i / float(count)) * PI * 2.0
				children[i].position = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
				
		Formation.SQUARE:
			var side_count = ceil(sqrt(count))
			for i in range(count):
				var row = floor(i / side_count)
				var col = i % int(side_count)
				children[i].position = Vector3(col * spacing - (side_count-1)*spacing/2.0, 0, -row * spacing)
