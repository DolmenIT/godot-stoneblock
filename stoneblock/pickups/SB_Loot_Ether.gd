extends SB_Loot_Base

## ⚪ SB_Loot_Ether : Petit fragment blanc d'éther quantique (monnaie).

@export var ether_value: float = 1.0

func _on_collect(target: Node) -> void:
	if target.has_method("add_ether"):
		target.add_ether(ether_value)
	super._on_collect(target)
