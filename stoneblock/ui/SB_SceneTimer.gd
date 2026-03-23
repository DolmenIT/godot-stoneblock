@tool
class_name SB_SceneTimer
extends Node3D

## Composant StoneBlock pour afficher le temps écoulé d'une scène.
## Se place idéalement sous la caméra principale.

@export var is_active: bool = true:
	set(v):
		is_active = v
		set_process(is_active)
		if _label:
			_label.visible = is_active
			
@export var font_size: int = 24:
	set(v):
		font_size = v
		_update_label_style()

@export var text_color: Color = Color(1.0, 1.0, 1.0, 0.5):
	set(v):
		text_color = v
		_update_label_style()

@export_category("Avancé")
## Index du calque CanvasLayer. 128 = Au-dessus de tout (système).
@export var canvas_layer: int = 128:
	set(v):
		canvas_layer = v
		if _canvas:
			_canvas.layer = canvas_layer

var _canvas: CanvasLayer
var _label: Label
var _elapsed_time: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(false)
		return
		
	# Création du CanvasLayer dynamique
	_canvas = CanvasLayer.new()
	_canvas.name = "SceneTimerCanvas"
	_canvas.layer = canvas_layer
	add_child(_canvas)
	
	# Création d'un conteneur Control plein écran
	var container = Control.new()
	container.name = "TimerContainer"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.add_child(container)
	
	# Création du Label
	_label = Label.new()
	_label.name = "TimeLabel"
	container.add_child(_label)
	
	# Ancres : Haut - Droite avec marges
	_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_label.offset_top = 20
	_label.offset_right = -20
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_label.grow_vertical = Control.GROW_DIRECTION_END
	
	_update_label_style()
	_update_display()

func _update_label_style() -> void:
	if not _label: return
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", text_color)
	# Ajout d'une petite ombre pour la lisibilité
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	_elapsed_time += delta
	_update_display()

func _update_display() -> void:
	if not _label: return
	
	var total_seconds = int(_elapsed_time)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	var centiseconds = int((_elapsed_time - total_seconds) * 100)
	
	_label.text = "%02d:%02d.%02d" % [minutes, seconds, centiseconds]

func reset_timer() -> void:
	_elapsed_time = 0.0
	_update_display()
