@tool
class_name SB_Margin
extends MarginContainer

## 📏 SB_Margin : Composant de gestion des marges StoneBlock.

@export var margin_left: int = 20:
	set(v):
		margin_left = v
		add_theme_constant_override("margin_left", v)

@export var margin_top: int = 20:
	set(v):
		margin_top = v
		add_theme_constant_override("margin_top", v)

@export var margin_right: int = 20:
	set(v):
		margin_right = v
		add_theme_constant_override("margin_right", v)

@export var margin_bottom: int = 20:
	set(v):
		margin_bottom = v
		add_theme_constant_override("margin_bottom", v)

func _ready() -> void:
	# Initialisation forcée des marges au démarrage
	add_theme_constant_override("margin_left", margin_left)
	add_theme_constant_override("margin_top", margin_top)
	add_theme_constant_override("margin_right", margin_right)
	add_theme_constant_override("margin_bottom", margin_bottom)

func set_margins(l: int, t: int, r: int, b: int) -> void:
	margin_left = l
	margin_top = t
	margin_right = r
	margin_bottom = b
	
	add_theme_constant_override("margin_left", l)
	add_theme_constant_override("margin_top", t)
	add_theme_constant_override("margin_right", r)
	add_theme_constant_override("margin_bottom", b)
