extends Area3D
class_name SB_Loot_Base

## 💎 SB_Loot_Base : Classe de base pour tous les fragments de loot du Shmup.
## Gère l'éjection initiale, la friction, le magnétisme vers le joueur et la collecte.

@export_group("Physics")
@export var friction: float = 0.96
@export var magnet_range: float = 8.0
@export var magnet_speed: float = 30.0
@export var min_collect_dist: float = 0.8

@export_group("Visuals")
@export var rotation_speed: float = 2.0

var velocity: Vector3 = Vector3.ZERO
var _player_ref: Node3D = null

func _ready() -> void:
	# Recherche du joueur par nom (No-Code style)
	_player_ref = get_tree().root.find_child("Player_VShmup", true, false)
	
	# Rotation aléatoire initiale pour le naturel
	rotation.x = randf_range(0, PI * 2)
	rotation.y = randf_range(0, PI * 2)
	rotation.z = randf_range(0, PI * 2)
	
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Application de la vélocité (éjection) et friction
	global_position += velocity * delta
	velocity *= friction
	
	# Rotation continue
	rotate_y(rotation_speed * delta)
	rotate_z(rotation_speed * 0.5 * delta)
	
	_handle_magnetism(delta)

func _handle_magnetism(delta: float) -> void:
	if not _player_ref or not is_instance_valid(_player_ref):
		# Fallback recherche si le joueur a respawn ou changé
		_player_ref = get_tree().root.find_child("Player_VShmup", true, false)
		return
		
	var dist = global_position.distance_to(_player_ref.global_position)
	
	# Collecte immédiate si très proche
	if dist < min_collect_dist:
		_on_collect(_player_ref)
		return
		
	# Magnétisme
	if dist < magnet_range:
		var dir = (_player_ref.global_position - global_position).normalized()
		# On combine la vélocité actuelle avec l'aspiration
		velocity = lerp(velocity, dir * magnet_speed, 6.0 * delta)

func _on_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") or body is CharacterBody3D:
		_on_collect(body)

func _on_area_entered(area: Area3D) -> void:
	if area.name.contains("Player"):
		_on_collect(area)

## À surcharger dans les classes filles.
func _on_collect(target: Node) -> void:
	# Logique spécifique (add_energy, etc.) injectée ici
	_spawn_feedback()
	queue_free()

func _spawn_feedback() -> void:
	# TODO: Son ou particules de collecte légères
	pass
