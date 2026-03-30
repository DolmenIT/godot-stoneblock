@tool
extends GPUParticles3D
class_name SB_EngineParticles

## ⚡ SB_EngineParticles : Gère le rendu du bloom pour les réacteurs.

@export_group("Bloom Sélectif")
enum BloomCategory { LONG = 11, MEDIUM = 12, SHORT = 13 }
## Pour les réacteurs, on utilise généralement le flou LONG (Layer 11).
@export var bloom_category: BloomCategory = BloomCategory.LONG

func _ready() -> void:
	# Appliquer le layer de bloom aux particules
	layers |= (1 << (int(bloom_category) - 1))
	
	# Optimisation Mobile : réduire le nombre de particules si nécessaire (IP-051)
	if not Engine.is_editor_hint():
		if SB_Core.instance and SB_Core.instance.is_mobile and SB_Core.instance.auto_optimize_mobile:
			amount = amount / 2
			SB_Core.instance.log_msg("EngineParticles: Réduction auto des particules sur mobile.", "info")
