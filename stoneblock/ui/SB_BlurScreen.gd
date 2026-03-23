@tool
@icon("res://stoneblock/icons/SB_BlurScreen.svg")
class_name SB_BlurScreen
extends Node3D

## Composant StoneBlock pour flouter progressivement l'écran.
## Placer en enfant de la Camera3D pour un meilleur contrôle.

@export_group("Timing")
## Temps (en secondes) où le flou commence.
@export var start_time: float = 33.0
## Temps (en secondes) où le flou atteint son maximum.
@export var end_time: float = 35.0

@export_group("Blur Settings")
## Intensité maximale du flou (LOD du shader).
@export var max_blur: float = 2.5
## Index du CanvasLayer. 
## Entre 1 et 119 : L'effet est derrière l'UI des dialogues (120).
## 121 ou plus : L'effet recouvre aussi l'UI.
@export_range(-128, 128) var layer: int = 111

var _canvas_layer: CanvasLayer
var _blur_rect: ColorRect
var _elapsed_time: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	# Création dynamique du CanvasLayer pour le post-processing
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.name = "BlurCanvasLayer"
	_canvas_layer.layer = layer
	add_child(_canvas_layer)
	
	# Création du ColorRect qui servira de support au shader
	_blur_rect = ColorRect.new()
	_blur_rect.name = "BlurRect"
	_blur_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_blur_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas_layer.add_child(_blur_rect)
	
	# Configuration du shader de flou
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount);
}
"""
	
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("blur_amount", 0.0)
	_blur_rect.material = mat
	
	_elapsed_time = 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	_elapsed_time += delta
	
	if _elapsed_time < start_time:
		_set_blur(0.0)
	elif _elapsed_time >= end_time:
		_set_blur(max_blur)
	else:
		# Interpolation linéaire entre start_time et end_time
		var t = (_elapsed_time - start_time) / (end_time - start_time)
		_set_blur(t * max_blur)

func _set_blur(amount: float) -> void:
	if _blur_rect and _blur_rect.material:
		_blur_rect.material.set_shader_parameter("blur_amount", amount)
		# Optimisation : masquer le rect si le flou est à 0
		_blur_rect.visible = amount > 0.001
