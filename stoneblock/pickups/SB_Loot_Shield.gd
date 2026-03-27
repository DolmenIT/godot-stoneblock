extends SB_Loot_Base

## 🔵 SB_Loot_Shield : Fragment bleu restaurant 1.0 de bouclier.

@export var shield_value: float = 1.0

func _on_collect(target: Node) -> void:
	if target.has_method("add_shield"):
		target.add_shield(shield_value)
	super._on_collect(target)
