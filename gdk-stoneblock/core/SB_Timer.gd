@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
class_name SB_Timer
extends SB_1_Foundation

## ⏳ SB_Timer : Séquenceur temporel StoneBlock.
## Attend un délai avant de déclencher la méthode start() de tous ses enfants.

@export_group("Timing")
## Temps d'attente (en secondes).
@export var delay: float = 1.0
## Si vrai, le timer recommence après avoir fini sa séquence.
@export var loop: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	# Intelligence de démarrage : fils direct du root uniquement
	var is_root_child = get_parent() == owner or get_parent() == get_tree().current_scene
	if is_root_child:
		start()

func start() -> void:
	_run_timer()

func _run_timer() -> void:
	if not is_inside_tree(): return
	
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	if not is_inside_tree(): return
	
	# Déclenchement de tous les enfants (Redirect, Fade, Log, etc.)
	for child in get_children():
		if child.has_method("start"):
			child.start()
	
	if loop:
		_run_timer()
