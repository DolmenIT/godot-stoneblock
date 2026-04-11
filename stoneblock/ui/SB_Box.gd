@tool
class_name SB_Box
extends PanelContainer

## 📦 SB_Box : Conteneur StoneBlock avec Bloc Margin SB_Margin.
## Structure : Root(Control) -> _SBMargin(SB_Margin) -> _SBContent(PanelContainer).

@export_group("Background")
@export var draw_background: bool = true:
	set(v):
		draw_background = v
		if is_inside_tree(): _update_layout()

@export var background_style: String = "StudioPanel":
	set(v):
		background_style = v
		if is_inside_tree(): _update_layout()

@export_group("Layout (StoneBlock CSS)")
@export_subgroup("Margins (Externe)")
@export var margin_left: int = 20:
	set(v):
		margin_left = v
		if is_inside_tree(): _update_layout()
@export var margin_top: int = 20:
	set(v):
		margin_top = v
		if is_inside_tree(): _update_layout()
@export var margin_right: int = 20:
	set(v):
		margin_right = v
		if is_inside_tree(): _update_layout()
@export var margin_bottom: int = 20:
	set(v):
		margin_bottom = v
		if is_inside_tree(): _update_layout()

@export_subgroup("Padding (Interne)")
@export var padding_left: int = 0:
	set(v):
		padding_left = v
		if is_inside_tree(): _update_layout()
@export var padding_top: int = 0:
	set(v):
		padding_top = v
		if is_inside_tree(): _update_layout()
@export var padding_right: int = 0:
	set(v):
		padding_right = v
		if is_inside_tree(): _update_layout()
@export var padding_bottom: int = 0:
	set(v):
		padding_bottom = v
		if is_inside_tree(): _update_layout()

@export_subgroup("Sizing")
@export var min_width: int = 0:
	set(v):
		min_width = v
		if is_inside_tree(): _update_layout()
@export var min_height: int = 0:
	set(v):
		min_height = v
		if is_inside_tree(): _update_layout()

@onready var _margin_block: SB_Margin = %_SBMargin
@onready var _content: PanelContainer = %_SBContent

func _ready() -> void:
	_update_layout()

func _update_layout() -> void:
	if not is_inside_tree(): return
	if not _margin_block: _margin_block = get_node_or_null("_SBMargin")
	if not _content: _content = get_node_or_null("_SBMargin/_SBContent")
	
	# Sizing
	custom_minimum_size = Vector2(min_width, min_height)
	
	# Pilotage via le composant officiel SB_Margin
	if _margin_block:
		_margin_block.set_margins(margin_left, margin_top, margin_right, margin_bottom)
	
	# Pilotage du fond et du padding (PanelContainer)
	if _content:
		var variation = theme_type_variation if not theme_type_variation.is_empty() else background_style
		_content.theme_type_variation = variation
		
		var sb = _content.get_theme_stylebox("panel", variation)
		if sb and sb is StyleBoxFlat:
			var new_sb = sb.duplicate()
			new_sb.content_margin_left = padding_left
			new_sb.content_margin_top = padding_top
			new_sb.content_margin_right = padding_right
			new_sb.content_margin_bottom = padding_bottom
			_content.add_theme_stylebox_override("panel", new_sb)
		
		_content.visible = draw_background
