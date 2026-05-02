@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
class_name SB_StageCard_Theme
extends SB_BaseStyle

## 🔘 SB_StageCard_Theme : Script de personnalisation dédié aux cartes de stage 3D.

@export_group("Text settings")
@export var force_single_line: bool = true
@export var text_anchor: SB_StageCard.AlignPoint = SB_StageCard.AlignPoint.TOP_LEFT
@export var text_pivot: SB_StageCard.AlignPoint = SB_StageCard.AlignPoint.TOP_LEFT
@export var offset_3d: Vector2 = Vector2(0.45, -0.45)

@export_group("Text font & size")
@export var text_font: Font
@export var text_size: int = 600
@export var text_color: Color = Color.WHITE
@export var text_outline_size: int = 200
@export var text_outline_color: Color = Color.BLACK

@export_group("Card style")
@export var tint_color: Color = Color("bf8f8f")
@export_range(0.0, 360.0) var tint_hue_shift: float = 120.0

func _init() -> void:
	target_class_name = "SB_StageCard"
