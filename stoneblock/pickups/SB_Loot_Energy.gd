extends SB_Loot_Base

## 🟡 SB_Loot_Energy : Fragment jaune restaurant 1.0 d'énergie.

@export var energy_value: float = 1.0

func _on_collect(target: Node) -> void:
	if target.has_method("add_energy"):
		target.add_energy(energy_value)
	super._on_collect(target)
