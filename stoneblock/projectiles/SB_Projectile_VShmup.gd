@tool
extends Area3D
class_name SB_Projectile_VShmup

## 🚀 SB_Projectile_VShmup : Base pour les projectiles (alliés ou ennemis).
## Gère le mouvement, les trajectoires oscillantes et l'auto-destruction.

# --- Configuration ---
@export_group("Movement")
@export var speed: float = 50.0
@export var direction: Vector3 = Vector3(0, 0, -1) # Par défaut vers le haut en Top-Down

@export_group("Oscillation")
@export var use_oscillation: bool = false
@export var frequency: float = 2.0
@export var amplitude: float = 2.0

@export_group("Cleanup")
@export var life_time: float = 5.0 # Secondes
@export var distance_limit: float = 25.0

@export_group("VFX (Sprite Based)")
@export var bullet_color: Color = Color(1.0, 0.8, 0.2, 1.0) # Jaune/Orange par défaut
@export var bullet_scale: float = 1.0

@export_group("Bloom Sélectif")
## Si activé, ajoute le render layer du bloom (layer 11 par défaut) sur le visuel et les fantômes.
@export var use_bloom: bool = true
## Index du render layer utilisé pour le bloom sélectif (11 = standard projet).
@export_range(1, 20) var bloom_layer_index: int = 11

# --- Nœuds VFX ---
@onready var _visual: Node3D = get_node_or_null("BulletVisual")
@onready var _trail: GPUParticles3D = get_node_or_null("BulletTrail")

# --- État ---
var _spawn_time: float = 0.0
var _spawn_position: Vector3 = Vector3.ZERO
var _total_time: float = 0.0
var _visual_node: Node3D
var _ghosts: Array[Node3D] = []
var _prev_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_spawn_time = Time.get_ticks_msec() / 1000.0
	_spawn_position = global_position
	_prev_pos = global_position
	
	# Détection du visuel principal
	if has_node("BulletVisual"):
		_visual_node = get_node("BulletVisual")
	elif has_node("MeshInstance3D"):
		_visual_node = get_node("MeshInstance3D")
	
	# Création des fantômes
	if _visual_node:
		for i in range(3):
			var ghost = _visual_node.duplicate()
			if ghost is AnimatedSprite3D:
				ghost.autoplay = ""
			add_child(ghost)
			# Dupliquer le matériau APRÈS add_child pour qu'il soit dans l'arbre
			if ghost.material_override:
				ghost.material_override = ghost.material_override.duplicate()
			_ghosts.append(ghost)
	
	# Appliquer les couleurs au prochain frame (nœuds garantis dans l'arbre)
	call_deferred("_apply_vfx_settings")

func _apply_vfx_settings() -> void:
	if not is_inside_tree(): return
	
	# Appliquer la couleur et la transparence
	if _visual_node:
		_set_node_color(_visual_node, bullet_color, 1.0)
	
	# Fantômes avec transparence dégressive (60%, 30%, 10%)
	var alphas = [0.6, 0.3, 0.1]
	for i in range(_ghosts.size()):
		_set_node_color(_ghosts[i], bullet_color, alphas[i])
	
	# Bloom sélectif : ajouter le render layer aux visuels
	_apply_bloom_layers()

func _apply_bloom_layers() -> void:
	if not use_bloom: return
	var bloom_mask: int = 1 << (bloom_layer_index - 1)
	
	# Visuel principal
	if _visual_node and _visual_node is VisualInstance3D:
		(_visual_node as VisualInstance3D).layers |= bloom_mask
	elif not _visual_node:
		push_warning("SB_Projectile_VShmup: _visual_node est null, bloom non appliqué.")
	
	# Fantômes (rémanances) — même layer que le visuel principal
	for ghost in _ghosts:
		if ghost is VisualInstance3D:
			(ghost as VisualInstance3D).layers |= bloom_mask

func _set_node_color(node: Node, color: Color, alpha: float) -> void:
	var final_color = Color(color.r, color.g, color.b, alpha)
	
	if node is Sprite3D or node is AnimatedSprite3D:
		node.modulate = final_color
	
	elif node is MeshInstance3D:
		var mat = node.get_active_material(0)
		if mat:
			var new_mat = mat.duplicate()
			new_mat.albedo_color = final_color
			node.material_override = new_mat

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	_total_time += delta
	_update_movement(delta)
	_check_cleanup()

func _update_movement(delta: float) -> void:
	# Mémoriser la position avant le mouvement
	_prev_pos = global_position
	
	# Mouvement de base (Linéaire)
	var movement = direction * speed * delta
	global_position += movement
	
	# Oscillation (Latérale par rapport à la direction)
	if use_oscillation:
		var offset = sin(_total_time * PI * 2 * frequency) * amplitude
		var perp = Vector3(-direction.z, 0, direction.x).normalized()
		global_position += perp * offset * delta
	
	# Mise à jour des fantômes (position réelle, espacement doublé)
	var trail_vec = global_position - _prev_pos
	for i in range(_ghosts.size()):
		var factor = (i + 1) * 0.5
		_ghosts[i].global_transform.origin = global_position - trail_vec * factor
		_ghosts[i].global_transform.origin.y -= 0.001 * (i + 1)

func _check_cleanup() -> void:
	# Auto-destruction après certain temps
	if _total_time > life_time:
		queue_free()
	
	# Auto-destruction après certaine distance
	if global_position.distance_to(_spawn_position) > distance_limit:
		queue_free()
