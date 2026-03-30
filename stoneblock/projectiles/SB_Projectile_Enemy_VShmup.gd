@tool
extends Area3D
class_name SB_Projectile_Enemy_VShmup

## ☄️ SB_Projectile_Enemy_VShmup : Projectile tiré par les ennemis.
## Inflige des dégâts au bouclier du joueur.

@export_group("VFX (Sprite Based)")
@export var bullet_color: Color = Color(1.0, 0.2, 0.4, 1.0) # Rose/Rouge par défaut
@export var bullet_scale: float = 1.2

@export var speed: float = 40.0
@export var damage: float = 10.0
@export var direction: Vector3 = Vector3(0, 0, 1) # Vers le bas

var _total_time: float = 0.0
var _life_time: float = 5.0
var _visual_node: Node3D
var _ghosts: Array[Node3D] = []
var _prev_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_prev_pos = global_position
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	
	# Détection du visuel
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
			# Dupliquer le matériau APRÈS add_child
			if ghost.material_override:
				ghost.material_override = ghost.material_override.duplicate()
			_ghosts.append(ghost)
	
	call_deferred("_apply_vfx_settings")
	_apply_bloom_layers()

func _apply_bloom_layers() -> void:
	var bloom_mask: int = 1 << 10 # Layer 11
	
	if _visual_node and _visual_node is VisualInstance3D:
		(_visual_node as VisualInstance3D).layers |= bloom_mask
	
	for ghost in _ghosts:
		if is_instance_valid(ghost) and ghost is VisualInstance3D:
			(ghost as VisualInstance3D).layers |= bloom_mask

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# Mémoriser la position avant le mouvement
	_prev_pos = global_position
	
	# Mouvement
	var movement = direction * speed * delta
	global_position += movement
	
	# Mise à jour des fantômes (espacement doublé)
	var movement_vec = global_position - _prev_pos
	for i in range(_ghosts.size()):
		var factor = (i + 1) * 0.5
		if is_instance_valid(_ghosts[i]):
			_ghosts[i].global_transform.origin = global_position - movement_vec * factor
			# Petit décalage de profondeur
			_ghosts[i].global_transform.origin.y -= 0.001 * (i + 1)
		
	_total_time += delta
	if _total_time > _life_time:
		queue_free()

func _apply_vfx_settings() -> void:
	if not is_inside_tree(): return
	
	# Appliquer la couleur et la transparence
	if _visual_node:
		_set_node_color(_visual_node, bullet_color, 1.0)
	
	var alphas = [0.6, 0.3, 0.1]
	for i in range(_ghosts.size()):
		if is_instance_valid(_ghosts[i]):
			_set_node_color(_ghosts[i], bullet_color, alphas[i])

func _set_node_color(node: Node, color: Color, alpha: float) -> void:
	var final_color = Color(color.r, color.g, color.b, alpha)
	if node is AnimatedSprite3D or node is Sprite3D:
		node.modulate = final_color
	elif node is MeshInstance3D:
		var mat = node.get_active_material(0)
		if mat:
			var new_mat = mat.duplicate()
			new_mat.albedo_color = final_color
			new_mat.albedo_color.a = alpha
			node.material_override = new_mat

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.name.contains("Projectile") and not area is SB_Projectile_Enemy_VShmup:
		queue_free()
