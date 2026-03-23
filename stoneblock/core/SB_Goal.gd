@tool
@icon("res://stoneblock/icons/SB_Goal.svg")
class_name SB_Goal
extends Area3D

## 🏁 SB_Goal : Gère l'atteinte d'un objectif de fin de niveau.

@export_group("Navigation")
## La scène vers laquelle rediriger après la victoire.
@export_file("*.tscn") var next_scene: String = ""
## Délai avant la redirection (secondes).
@export var delay: float = 2.0

@export_group("Visuals")
## Si assigné, joue une animation sur ce nœud lors de la victoire.
@export var animation_player: AnimationPlayer
## Nom de l'animation de victoire.
@export var victory_animation: String = "victory"

signal reached

var _target_reached: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if _target_reached: return
	
	if body is SB_PlayerController3D or body.name == "Dolmenir":
		_target_reached = true
		if SB_Core.instance:
			SB_Core.instance.log_msg("Objectif atteint ! Bravo Dolmenir.", "success")
		reached.emit()
		
		if animation_player and animation_player.has_animation(victory_animation):
			animation_player.play(victory_animation)
		
		if next_scene != "" and SB_Core.instance:
			await get_tree().create_timer(delay).timeout
			SB_Core.instance.load_scene_async(next_scene)
