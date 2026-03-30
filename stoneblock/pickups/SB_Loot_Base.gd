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

@export_group("Bloom Sélectif")
enum BloomCategory { LONG = 11, MEDIUM = 12, SHORT = 13 }
## Catégorie de flou pour cet objet (Layer 13 par défaut pour les loots).
@export var bloom_category: BloomCategory = BloomCategory.SHORT

var velocity: Vector3 = Vector3.ZERO
var _player_ref: Node3D = null

func _ready() -> void:
	_player_ref = get_tree().root.find_child("Player_VShmup", true, false)
	
	rotation.x = randf_range(0, PI * 2)
	rotation.y = randf_range(0, PI * 2)
	rotation.z = randf_range(0, PI * 2)
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	_apply_bloom_layers()

func _apply_bloom_layers() -> void:
	var bloom_mask: int = 1 << (int(bloom_category) - 1)
	_apply_mask_recursive(self, bloom_mask)

func _apply_mask_recursive(node: Node, mask: int) -> void:
	if node is VisualInstance3D:
		node.layers |= mask
	for child in node.get_children():
		_apply_mask_recursive(child, mask)

func _process(delta: float) -> void:
	global_position += velocity * delta
	velocity *= friction
	rotate_y(rotation_speed * delta)
	rotate_z(rotation_speed * 0.5 * delta)
	_handle_magnetism(delta)

func _handle_magnetism(delta: float) -> void:
	if not _player_ref or not is_instance_valid(_player_ref):
		_player_ref = get_tree().root.find_child("Player_VShmup", true, false)
		return
	var dist = global_position.distance_to(_player_ref.global_position)
	if dist < min_collect_dist:
		_on_collect(_player_ref)
		return
	if dist < magnet_range:
		var dir = (_player_ref.global_position - global_position).normalized()
		velocity = lerp(velocity, dir * magnet_speed, 6.0 * delta)

func _on_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") or body is CharacterBody3D:
		_on_collect(body)

func _on_collect(_target: Node) -> void:
	queue_free()
