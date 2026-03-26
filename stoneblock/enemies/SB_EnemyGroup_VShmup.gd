@tool
extends Node3D
class_name SB_EnemyGroup_VShmup

## 🚀 SB_EnemyGroup_VShmup : Gère des vagues d'ennemis structurées.
## Permet de définir des formations automatiques et des mouvements de groupe.

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

func _ready() -> void:
	update_formation()
	if Engine.is_editor_hint(): return
	
	# Désactiver les mouvements individuels des enfants ennemis
	for child in get_children():
		if child is SB_Enemy_VShmup:
			child.follow_group = true

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if get_child_count() > 0:
			update_formation()
		return
	
	if not _is_active:
		# Récupération du pivot via le premier enfant ou le parent
		var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
		if gm and gm.camera_pivot:
			var dist_z = global_position.z - gm.camera_pivot.global_position.z
			if dist_z >= -activation_threshold:
				_activate_group()
		return
	
	_time += delta
	
	# Mouvement de descente
	position.z += group_speed * delta
	
	# Mouvement latéral (Sinus)
	if wave_amplitude > 0:
		position.x = sin(_time * wave_speed) * wave_amplitude

func _activate_group() -> void:
	_is_active = true
	for child in get_children():
		if child is SB_Enemy_VShmup:
			child._activate() # Force l'activation immédiate de l'ennemi

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
