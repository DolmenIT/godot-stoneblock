@tool
class_name SB_Button
extends PanelContainer

## 🔘 SB_Button : Bouton StoneBlock standard.
## Structure : Root(Control) -> _SBMargin(SB_Margin) -> _internal_button(Button).

signal pressed

@export_group("Texte")
@export var text: String = "Button":
	set(v):
		text = v
		if is_inside_tree(): _update_ui()

@export var alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER:
	set(v):
		alignment = v
		if is_inside_tree(): _update_ui()

@export_group("Layout (StoneBlock CSS)")
@export_subgroup("Margins (Autour)")
@export var margin_left: int = 20:
	set(v):
		margin_left = v
		if is_inside_tree(): _update_ui()
@export var margin_top: int = 20:
	set(v):
		margin_top = v
		if is_inside_tree(): _update_ui()
@export var margin_right: int = 20:
	set(v):
		margin_right = v
		if is_inside_tree(): _update_ui()
@export var margin_bottom: int = 20:
	set(v):
		margin_bottom = v
		if is_inside_tree(): _update_ui()

@export_subgroup("Padding (Dédans)")
@export var padding_left: int = 15:
	set(v):
		padding_left = v
		if is_inside_tree(): _update_ui()
@export var padding_top: int = 10:
	set(v):
		padding_top = v
		if is_inside_tree(): _update_ui()
@export var padding_right: int = 15:
	set(v):
		padding_right = v
		if is_inside_tree(): _update_ui()
@export var padding_bottom: int = 10:
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
@onready var _btn: Button = %_internal_button

func _ready() -> void:
	if not _btn: _btn = %_internal_button
	if not _margin_block: _margin_block = %_SBMargin
	
	if _btn and not _btn.pressed.is_connected(_on_btn_pressed):
		_btn.pressed.connect(_on_btn_pressed)
	
	_update_ui()

func _update_ui() -> void:
	if not is_inside_tree(): return
	if not _margin_block: _margin_block = get_node_or_null("_SBMargin")
	if not _btn: _btn = get_node_or_null("_SBMargin/_internal_button")
	
	# Sizing
	custom_minimum_size = Vector2(min_width, min_height)
	
	# Utilisation du composant SB_Margin officiel
	if _margin_block:
		_margin_block.set_margins(margin_left, margin_top, margin_right, margin_bottom)
	
	if _btn:
		_btn.text = text
		_btn.alignment = alignment
		_btn.theme_type_variation = theme_type_variation
		
		# Application du padding via les StyleBox overrides
		var variation = theme_type_variation if not theme_type_variation.is_empty() else "Button"
		var sb = _btn.get_theme_stylebox("normal", variation)
		if sb and sb is StyleBoxFlat:
			var new_sb = sb.duplicate()
			new_sb.content_margin_left = padding_left
			new_sb.content_margin_top = padding_top
			new_sb.content_margin_right = padding_right
			new_sb.content_margin_bottom = padding_bottom
			
			# On applique à tous les états pour garder un padding cohérent
			_btn.add_theme_stylebox_override("normal", new_sb)
			_btn.add_theme_stylebox_override("hover", new_sb)
			_btn.add_theme_stylebox_override("pressed", new_sb)
			_btn.add_theme_stylebox_override("focus", new_sb)

func _on_btn_pressed() -> void:
	pressed.emit()

func get_btn() -> Button:
	return _btn
