@tool
class_name SB_Timer
extends Node

## ⏱️ SB_Timer : Séquenceur temporel StoneBlock.
## Attend un délai avant de déclencher la méthode start() de tous ses enfants.

@export_group("Timing")
## Temps d'attente (en secondes).
@export var delay: float = 1.0

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	# Intelligence de démarrage : fils direct du root uniquement
	var is_root_child = get_parent() == owner or get_parent() == get_tree().current_scene
	if is_root_child:
		start()

func start() -> void:
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	# Déclenchement de tous les enfants (Redirect, Fade, Log, etc.)
	for child in get_children():
		if child.has_method("start"):
			child.start()
