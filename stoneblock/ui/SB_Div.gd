@tool
class_name SB_Div
extends PanelContainer

## 📦 SB_Div : Un bloc de layout universel de type "CSS".
## Gère ses marges et son padding de manière intuitive.

@export_group("Layout (CSS)")
@export_subgroup("Padding (Interne)")
## Padding Gauche.
@export var padding_left: int = 0:
	set(v):
		padding_left = v
		_update_layout()
## Padding Haut.
@export var padding_top: int = 0:
	set(v):
		padding_top = v
		_update_layout()
## Padding Droite.
@export var padding_right: int = 0:
	set(v):
		padding_right = v
		_update_layout()
## Padding Bas.
@export var padding_bottom: int = 0:
	set(v):
		padding_bottom = v
		_update_layout()

@export_subgroup("Margins (Externe)")
## Note : Dans Godot, les marges dépendent du conteneur parent.
## Ces valeurs sont appliquées via custom_minimum_size ou injectées dans le parent.
@export var margin_top: int = 0:
	set(v):
		margin_top = v
		_update_layout()
@export var margin_bottom: int = 0:
	set(v):
		margin_bottom = v
		_update_layout()

func _ready() -> void:
	_update_layout()

func _update_layout() -> void:
	# On applique le padding via un override de StyleBox si on n'en a pas déjà un du thème
	# Mais le plus propre est de laisser le ThemeManager s'en occuper.
	# Ici, on fournit des overrides locaux si spécifiés.
	
	var sb = get_theme_stylebox("panel")
	if sb and sb is StyleBoxFlat:
		var new_sb = sb.duplicate()
		if padding_left > 0: new_sb.content_margin_left = padding_left
		if padding_top > 0: new_sb.content_margin_top = padding_top
		if padding_right > 0: new_sb.content_margin_right = padding_right
		if padding_bottom > 0: new_sb.content_margin_bottom = padding_bottom
		add_theme_stylebox_override("panel", new_sb)
	
	# Gestion basique des marges verticales via sep ou min_size
	# (C'est un compromis pour le feeling CSS)
	custom_minimum_size.y = (margin_top + margin_bottom) if not get_parent() is BoxContainer else 0
