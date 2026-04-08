@tool
class_name SB_Pickable
extends Area3D

## 🍪 SB_Pickable : Objet ramassable avec animation.
## Gère la détection du joueur et l'animation de présentation.

signal collected(type: String, amount: int)

@export_group("Collectible Settings")
## Type d'objet (ex: "galette", "kouign_amann").
@export var type: String = "galette"
## Valeur ajoutée au compteur.
@export var amount: int = 1
## Effet sonore à jouer lors du ramassage.
@export var sfx_on_collect: AudioStream

@export_group("Visual Animation")
## Vitesse de rotation (degrés par seconde).
@export var rotation_speed: float = 90.0
## Amplitude du flottement.
@export var float_amplitude: float = 0.2
## Vitesse du flottement.
@export var float_speed: float = 2.0

@export_group("Bloom Sélectif")
enum BloomCategory { LONG = 11, MEDIUM = 12, SHORT = 13 }
## Catégorie de flou pour cet objet.
@export var bloom_category: BloomCategory = BloomCategory.SHORT

var _start_y: float = 0.0
var _time_passed: float = 0.0
var _child_visual: Node3D

func _ready() -> void:
	_start_y = position.y
	_time_passed = randf() * 10.0 # Random offset
	
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
	
	_apply_bloom_layers()

func _apply_bloom_layers() -> void:
	var bloom_mask: int = 1 << (int(bloom_category) - 1)
	
	# Applique le masque à tous les visuels 3D enfants récursivement
	_apply_mask_recursive(self, bloom_mask)
	
	# On cherche le premier enfant 3D pour l'animer si possible
	for child in get_children():
		if child is Node3D and not child is CollisionShape3D:
			_child_visual = child
			break

func _apply_mask_recursive(node: Node, mask: int) -> void:
	if node is VisualInstance3D:
		# Le mesh principal reste sur le calque 1 (mainground) uniquement
		node.layers = 1
		
		# On nettoie les anciens fantômes
		for child in node.get_children():
			if child.name.contains("_BloomGhost"):
				child.queue_free()
		
		# Création du fantôme pour le bloom
		var ghost = MeshInstance3D.new()
		ghost.name = node.name + "_BloomGhost"
		if node is MeshInstance3D:
			ghost.mesh = node.mesh
			ghost.skin = node.skin
			ghost.skeleton = node.skeleton
			
			# Matériau spécial Bloom X-Ray
			var mat = node.get_surface_override_material(0)
			if not mat and node.mesh: mat = node.mesh.surface_get_material(0)
			
			var ghost_mat = StandardMaterial3D.new()
			ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			ghost_mat.no_depth_test = true # Passe à travers le boss !
			ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			if mat:
				ghost_mat.albedo_color = mat.albedo_color
			else:
				ghost_mat.albedo_color = Color.YELLOW
			
			ghost.set_surface_override_material(0, ghost_mat)
		
		ghost.layers = mask
		ghost.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.add_child(ghost)

	for child in node.get_children():
		if not child.name.contains("_BloomGhost"):
			_apply_mask_recursive(child, mask)

func _process(delta: float) -> void:
	_time_passed += delta
	
	# Animation de rotation
	rotate_y(deg_to_rad(rotation_speed * delta))
	
	# Animation de flottement (Sinus)
	position.y = _start_y + (sin(_time_passed * float_speed) * float_amplitude)

func _on_body_entered(body: Node3D) -> void:
	# Détection basique du joueur par son nom ou son groupe
	if body.name.contains("Player") or body.is_in_group("player"):
		_collect()

func _collect() -> void:
	collected.emit(type, amount)
	
	if SB_Core.instance:
		SB_Core.instance.log_msg("Récolté : %d %s" % [amount, type], "success")
		SB_Core.instance.add_stat(type, amount)
		SB_Core.instance.add_stat("score", amount * 10)
	
	# Masquage et destruction différée
	hide()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# On peut ajouter ici un timer pour le SFX ou une particule
	queue_free()
