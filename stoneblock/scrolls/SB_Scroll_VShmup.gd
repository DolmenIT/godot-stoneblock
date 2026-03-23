@tool
extends Node3D
class_name SB_Scroll_VShmup

## 🚀 SB_Scroll_VShmup : Gère le défilement (parallax) d'objets ou de couches.
## Peut être utilisé pour des décors infinis ou des éléments de fond.

# --- Configuration ---
@export var scroll_speed: float = 1.0 # Facteur multiplicateur de la vitesse globale
@export var scroll_direction: Vector3 = Vector3(0, 0, 1) # Défilement vers le bas

@export_group("Infinite Mode")
@export var use_infinite_scrolling: bool = false
@export var repeat_distance: float = 100.0 # Distance après laquelle l'objet boucle

# --- État ---
var _initial_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_initial_position = position

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# Mouvement constant (simule le défilement si la caméra est fixe, ou ajoute un offset de parallax)
	position += scroll_direction * scroll_speed * delta
	
	# Bouclage infini
	if use_infinite_scrolling:
		var diff = position - _initial_position
		if diff.length() > repeat_distance:
			position = _initial_position + diff.limit_length(repeat_distance) # Approximatif, idéalement on veut un modulo
			# Modulo par axe pour plus de précision
			if abs(position.z - _initial_position.z) > repeat_distance:
				position.z = _initial_position.z
			if abs(position.x - _initial_position.x) > repeat_distance:
				position.x = _initial_position.x
