extends SB_Loot_Base
class_name SB_EnergyFragment_VShmup

## 💎 SB_EnergyFragment_VShmup : Fragment d'énergie bleu (loot).
## Hérite de SB_Loot_Base pour la gestion du Bloom et du Magnétisme.

@export var energy_value: float = 1.0

func _on_collect(target: Node) -> void:
	if target.has_method("add_energy"):
		target.add_energy(energy_value)
	# Feedback ici (son/particules) si besoin
	queue_free()
