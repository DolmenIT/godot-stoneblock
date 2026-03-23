@tool
class_name SB_UI_Layer
extends CanvasLayer

## 🖼️ SB_UI_Layer : Conteneur global pour les éléments d'interface StoneBlock.
## Gère l'affichage, la priorité (Layer) et peut servir de point d'ancrage pour les menus.

@export_group("Layer Settings")
## Si vrai, l'UI est visible.
@export var is_ui_visible: bool = true:
	set(v):
		is_ui_visible = v
		visible = v

func _ready() -> void:
	# On s'assure que le layer est bien au-dessus du jeu par défaut
	if layer == 0:
		layer = 10
