@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends Node
class_name SB_BloomTagger_Color

## 🎨 SB_BloomTagger_Color : Réglage d'une couleur pour le SB_BloomTagger.
## Doit être placé en enfant d'un SB_BloomTagger pour être pris en compte.

@export_group("Target")
## La couleur à détecter dans la texture.
@export var target_color: Color = Color(0.25, 0.62, 1.0, 1.0)
## Tolérance de détection.
@export var color_threshold: float = 0.5

@export_group("Emission")
## Couleur de l'éclat produit.
@export var emission_color: Color = Color(0.25, 0.62, 1.0, 1.0)
## Puissance de l'éclat.
@export var emission_energy: float = 2.0
## Seuil de filtrage (0.0 = tout brille, 1.0 = rien ne brille).
@export_range(0, 1) var emission_threshold: float = 0.5

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		var parent = get_parent()
		if parent and parent is SB_BloomTagger:
			parent.trigger_scan = true
