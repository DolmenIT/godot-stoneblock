@tool
class_name SB_Label
extends PanelContainer

## 📝 SB_Label : Version "StoneBlock CSS" du Label.
## Basé sur le même schéma que SB_Button pour une gestion parfaite des marges et du sizing.

@export_group("Texte")
@export_multiline var text: String = "Label":
	set(v):
		text = v
		if is_inside_tree(): _update_ui()

@export var horizontal_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT:
	set(v):
		horizontal_alignment = v
		if is_inside_tree(): _update_ui()

@export var vertical_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER:
	set(v):
		vertical_alignment = v
		if is_inside_tree(): _update_ui()

@export_group("Layout (StoneBlock CSS)")
@export_subgroup("Margins (Autour)")
@export var margin_left: int = 0:
	set(v):
		margin_left = v
		if is_inside_tree(): _update_ui()
@export var margin_top: int = 0:
	set(v):
		margin_top = v
		if is_inside_tree(): _update_ui()
@export var margin_right: int = 0:
	set(v):
		margin_right = v
		if is_inside_tree(): _update_ui()
@export var margin_bottom: int = 0:
	set(v):
		margin_bottom = v
		if is_inside_tree(): _update_ui()

@export_subgroup("Padding (Dédans)")
@export var padding_left: int = 0:
	set(v):
		padding_left = v
		if is_inside_tree(): _update_ui()
@export var padding_top: int = 0:
	set(v):
		padding_top = v
		if is_inside_tree(): _update_ui()
@export var padding_right: int = 0:
	set(v):
		padding_right = v
		if is_inside_tree(): _update_ui()
@export var padding_bottom: int = 0:
	set(v):
		padding_bottom = v
		if is_inside_tree(): _update_ui()

@export_subgroup("Sizing")
@export var min_width: int = 0:
	set(v):
		min_width = v
		if is_inside_tree(): _update_ui()
@export var min_height: int = 0:
	set(v):
		min_height = v
		if is_inside_tree(): _update_ui()

@onready var _margin_block: SB_Margin = %_SBMargin
@onready var _label: Label = %_internal_label

func _ready() -> void:
	if not _label: _label = %_internal_label
	if not _margin_block: _margin_block = %_SBMargin
	_update_ui()

func _update_ui() -> void:
	if not is_inside_tree(): return
	if not _margin_block: _margin_block = get_node_or_null("_SBMargin")
	if not _label: _label = get_node_or_null("_SBMargin/_internal_label")
	
	# Sizing
	custom_minimum_size = Vector2(min_width, min_height)
	
	# Margins
	if _margin_block:
		_margin_block.set_margins(margin_left, margin_top, margin_right, margin_bottom)
	
	# Label & Style
	if _label:
		_label.text = text
		_label.horizontal_alignment = horizontal_alignment
		_label.vertical_alignment = vertical_alignment
		_label.theme_type_variation = theme_type_variation
		
		# Application du padding via StyleBox override (comme le bouton)
		# On cherche la variation du label (ex: Titre) ou par défaut "Label"
		var variation = theme_type_variation if not theme_type_variation.is_empty() else "Label"
		var sb = _label.get_theme_stylebox("normal", variation)
		
		# On crée un StyleBox vide si aucun n'existe pour injecter le padding
		var new_sb = sb.duplicate() if sb else StyleBoxEmpty.new()
		new_sb.content_margin_left = padding_left
		new_sb.content_margin_top = padding_top
		new_sb.content_margin_right = padding_right
		new_sb.content_margin_bottom = padding_bottom
		_label.add_theme_stylebox_override("normal", new_sb)
