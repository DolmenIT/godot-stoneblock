@tool
extends SB_Pickable
class_name SB_Pickup_TripleShot

## 🔫 SB_Pickup_TripleShot : Active le tir triple sur le joueur.

@export var triple_shot_duration: float = 8.0

func _collect() -> void:
	# Recherche du joueur dans la scène courante
	var player = get_tree().root.find_child("Player_VShmup", true, false)
	if player and player.has_method("activate_triple_shot"):
		player.activate_triple_shot(triple_shot_duration)
	
	# Comportement de base (score, log, free)
	super._collect()
