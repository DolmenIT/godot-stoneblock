@tool
extends Label3D

## 🚀 SB_PulseOutline : Fait osciller l'outline du Label3D pour un effet "néon vivant".
## Version optimisée avec lissage via l'Alpha de l'outline (Sub-pixel simulation).

@export var min_outline: float = 0.0
@export var max_outline: float = 5.0

## Nombre de pulsations complètes par seconde (Fréquence en Hz).
@export var pulse_frequency: float = 1.0

## La couleur de l'outline (sera modifiée en Alpha dynamiquement)
@export var outline_color: Color = Color(0.0, 0.2, 0.4, 1)

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	
	# Fréquence angulaire = 2 * PI * f
	var wave = sin(_time * (2.0 * PI * pulse_frequency))
	
	# Mappage vers [min_outline, max_outline] en float
	var current_f = lerp(min_outline, max_outline, (wave + 1.0) / 2.0)
	
	if current_f < 0.05:
		outline_size = 0
	else:
		var target_size = int(ceil(current_f))
		outline_size = target_size
		var alpha_factor = (current_f / float(target_size))
		
		var final_c = outline_color
		final_c.a *= alpha_factor
		outline_modulate = final_c
