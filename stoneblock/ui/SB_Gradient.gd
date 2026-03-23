@tool
@icon("res://stoneblock/icons/SB_Gradient.svg")
class_name SB_Gradient
extends TextureRect

## Un composant de dégradé simplifié pour le SDK StoneBlock.
## Permet de créer rapidement des dégradés verticaux, horizontaux ou diagonaux.

enum Orientation {
	VERTICAL,
	HORIZONTAL,
	DIAGONAL_TL_BR,
	DIAGONAL_TR_BL
}

@export var color_1: Color = Color.WHITE:
	set(value):
		color_1 = value
		_update_gradient()

@export var color_2: Color = Color.BLACK:
	set(value):
		color_2 = value
		_update_gradient()

@export var orientation := Orientation.VERTICAL:
	set(value):
		orientation = value
		_update_gradient()

@export_group("Layout Helper")
## Cliquez pour forcer le dégradé à remplir tout l'espace de son parent.
@export var fill_parent: bool = false:
	set(value):
		if value:
			set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fill_parent = false # Reset après action

func _init() -> void:
	# Configuration par défaut pour que ça remplisse l'espace
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	
	if not texture:
		texture = GradientTexture2D.new()
		texture.gradient = Gradient.new()
	
	_update_gradient()

func _ready() -> void:
	_update_gradient()

func _update_gradient() -> void:
	if not texture or not texture is GradientTexture2D:
		texture = GradientTexture2D.new()
	
	var tex = texture as GradientTexture2D
	if not tex.gradient:
		tex.gradient = Gradient.new()
	
	# Mise à jour des couleurs
	tex.gradient.set_color(0, color_1)
	tex.gradient.set_color(1, color_2)
	
	# Mise à jour des points de remplissage selon l'orientation
	match orientation:
		Orientation.VERTICAL:
			tex.fill_from = Vector2(0.5, 0)
			tex.fill_to = Vector2(0.5, 1)
		Orientation.HORIZONTAL:
			tex.fill_from = Vector2(0, 0.5)
			tex.fill_to = Vector2(1, 0.5)
		Orientation.DIAGONAL_TL_BR:
			tex.fill_from = Vector2(0, 0)
			tex.fill_to = Vector2(1, 1)
		Orientation.DIAGONAL_TR_BL:
			tex.fill_from = Vector2(1, 0)
			tex.fill_to = Vector2(0, 1)
