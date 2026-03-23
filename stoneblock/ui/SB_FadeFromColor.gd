@tool
class_name SB_FadeFromColor
extends Node

## 🎬 SB_FadeFromColor : Composant pour une apparition progressive en fondu.
## Le jeu commence par une couleur pleine qui s'estompe pour révéler la scène.

@export_group("Timing")
## Durée du fondu (en secondes).
@export var duration: float = 1.0

@export_group("Fade Settings")
## Couleur de départ (celle qui s'effacera).
@export var fade_color: Color = Color.BLACK
## Calque de rendu supérieur (devrait être au-dessus du jeu, mais sous la console).
@export_range(-128, 128) var layer: int = 121

var _canvas_layer: CanvasLayer
var _fade_rect: ColorRect
var _elapsed_time: float = 0.0
var _is_active: bool = false

func _ready() -> void:
	set_process(false)
	if Engine.is_editor_hint(): return
	
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
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.name = "FadeFromCanvas"
	_canvas_layer.layer = layer
	add_child(_canvas_layer)
	
	# Création du ColorRect plein
	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.color = fade_color
	_canvas_layer.add_child(_fade_rect)

func _process(delta: float) -> void:
	if not _is_active: return
	
	_elapsed_time += delta
	
	var progress = clamp(_elapsed_time / duration, 0.0, 1.0)
	
	if _fade_rect:
		_fade_rect.color.a = 1.0 - progress
		if _fade_rect.color.a <= 0.0:
			# Une fois fini, on nettoie pour libérer des ressources
			_canvas_layer.queue_free()
			set_process(false)
