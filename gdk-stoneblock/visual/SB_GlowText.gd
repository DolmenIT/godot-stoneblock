@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_GlowText
extends Label3D

## 💡 SB_GlowText : Label3D avec effet de néon éclatant (Glow/Bloom) et outline pulsant.

@export_group("Style de Texte")
## Le texte à afficher (multiligne).
@export_multiline var glow_text: String = "StoneBlock":
	set(v):
		glow_text = v
		_update_text()

## Forcer l'affichage sur une seule ligne.
@export var force_single_line: bool = false:
	set(v):
		force_single_line = v
		_update_text()

@export var text_font: Font:
	set(v): text_font = v; font = v

@export var text_size: int = 72:
	set(v): text_size = v; font_size = v

## Couleur et intensité de l'éclat du texte (valeurs > 1.0 pour forcer le bloom).
@export var text_color: Color = Color(1.5, 2.5, 5.0, 1.0):
	set(v): text_color = v; modulate = v

@export var text_outline_size: int = 15:
	set(v): text_outline_size = v; outline_size = v

## Couleur de l'outline à faire pulser.
@export var text_outline_color: Color = Color(0.0, 0.2, 0.4, 1.0):
	set(v): text_outline_color = v; _update_pulse(0.0)

@export_group("Effet Pulsation (Outline)")
## Activer ou désactiver la pulsation de l'outline.
@export var pulse_enabled: bool = true

## Épaisseur minimale de l'outline.
@export var min_outline: float = 8.0
## Épaisseur maximale de l'outline.
@export var max_outline: float = 18.0
## Fréquence des pulsations par seconde (en Hz).
@export var pulse_frequency: float = 1.0

## Activer le Bloom Long (Layer 13).
@export var enable_long_bloom: bool = true:
	set(v): enable_long_bloom = v; _update_layers()

## Activer le Bloom Medium (Layer 12).
@export var enable_medium_bloom: bool = true:
	set(v): enable_medium_bloom = v; _update_layers()

## Activer le Bloom Short (Layer 11).
@export var enable_short_bloom: bool = true:
	set(v): enable_short_bloom = v; _update_layers()

@export_group("Advanced Options")
## Taille des pixels de la police en 3D.
@export var text_pixel_size: float = 0.05:
	set(v): text_pixel_size = v; pixel_size = v

var _time: float = 0.0

func _ready() -> void:
	_update_text()
	_update_layers()
	if text_font: font = text_font
	if text_size > 0: font_size = text_size
	outline_size = text_outline_size
	pixel_size = text_pixel_size
	modulate = text_color
	outline_modulate = text_outline_color

func _update_text() -> void:
	if force_single_line:
		text = glow_text.replace("\n", " ").replace("\r", "")
	else:
		text = glow_text

func _update_layers() -> void:
	var mask = 1 # Calque 1 standard
	if enable_short_bloom: mask |= 1024 # Calque 11
	if enable_medium_bloom: mask |= 2048 # Calque 12
	if enable_long_bloom: mask |= 4096 # Calque 13
	layers = mask

func _process(delta: float) -> void:
	if not pulse_enabled: return
	_time += delta
	_update_pulse(delta)

func _update_pulse(_delta: float) -> void:
	var wave = sin(_time * (2.0 * PI * pulse_frequency))
	var current_f = lerp(min_outline, max_outline, (wave + 1.0) / 2.0)
	
	if current_f < 0.05:
		outline_size = 0
	else:
		var target_size = int(ceil(current_f))
		outline_size = target_size
		var alpha_factor = (current_f / float(target_size))
		
		var final_c = text_outline_color
		final_c.a *= alpha_factor
		outline_modulate = final_c
