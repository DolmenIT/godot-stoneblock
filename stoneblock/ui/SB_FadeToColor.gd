@tool
@icon("res://stoneblock/icons/SB_FadeToColor.svg")
class_name SB_FadeToColor
extends Node

## 🎬 SB_FadeToColor : Composant pour une disparition progressive en fondu.
## La scène s'obscurcit vers une couleur pleine.

@export_group("Timing")
## Durée du fondu.
@export var duration: float = 1.0

@export_group("Fade Settings")
## Couleur vers laquelle faire le fondu.
@export var fade_color: Color = Color.BLACK
## Les calques supérieurs à ce chiffre resteront visibles par-dessus le fondu (ex: Console à 128).
@export_range(-128, 128) var layer: int = 121

var _canvas_layer: CanvasLayer
var _fade_rect: ColorRect
var _elapsed_time: float = 0.0
var _is_active: bool = false

func _ready() -> void:
	set_process(false)
	if Engine.is_editor_hint():
		return
	
	_setup_nodes()
	
	# Intelligence de démarrage : fils direct du root uniquement
	var is_root_child = get_parent() == owner or get_parent() == get_tree().current_scene
	if is_root_child:
		start()

func start() -> void:
	_elapsed_time = 0.0
	_is_active = true
	if _fade_rect:
		_fade_rect.visible = true
	set_process(true)

func _setup_nodes() -> void:
	# Création dynamique du CanvasLayer
	if not _canvas_layer:
		_canvas_layer = CanvasLayer.new()
		_canvas_layer.name = "FadeCanvasLayer"
		_canvas_layer.layer = layer
		add_child(_canvas_layer)
	
	# Création du ColorRect
	if not _fade_rect:
		_fade_rect = ColorRect.new()
		_fade_rect.name = "FadeRect"
		_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_fade_rect.color = fade_color
		_fade_rect.color.a = 0.0
		_fade_rect.visible = false
		_canvas_layer.add_child(_fade_rect)

func _process(delta: float) -> void:
	if not _is_active: return
	
	_elapsed_time += delta
	
	var alpha = clamp(_elapsed_time / duration, 0.0, 1.0)
	
	if _fade_rect:
		_fade_rect.color.a = alpha
		_fade_rect.visible = alpha > 0.001
		
	if alpha >= 1.0:
		set_process(false)
