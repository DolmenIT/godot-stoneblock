@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
extends Node3D
class_name SB_Scroll_VShmup

## 📜 SB_Scroll_VShmup : Gère le défilement (parallax) d'objets ou de couches.
## Peut Ãªtre utilisÃ© pour des dÃ©cors infinis ou des Ã©lÃ©ments de fond.

# --- Configuration ---
@export var scroll_speed: float = 1.0 # Facteur multiplicateur de la vitesse globale
@export var scroll_direction: Vector3 = Vector3(0, 0, 1) # DÃ©filement vers le bas

@export_group("Infinite Mode")
@export var use_infinite_scrolling: bool = false
@export var repeat_distance: float = 100.0 # Distance aprÃ¨s laquelle l'objet boucle

# --- Ã‰tat ---
var _initial_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_initial_position = position

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# Mouvement constant (simule le dÃ©filement si la camÃ©ra est fixe, ou ajoute un offset de parallax)
	position += scroll_direction * scroll_speed * delta
	
	# Bouclage infini
	if use_infinite_scrolling:
		var diff = position - _initial_position
		if diff.length() > repeat_distance:
			position = _initial_position + diff.limit_length(repeat_distance) # Approximatif, idÃ©alement on veut un modulo
			# Modulo par axe pour plus de prÃ©cision
			if abs(position.z - _initial_position.z) > repeat_distance:
				position.z = _initial_position.z
			if abs(position.x - _initial_position.x) > repeat_distance:
				position.x = _initial_position.x
