extends SB_Loot_Base

## ⚪ SB_Loot_Coin : Fragment blanc d'éther (monnaie locale).

@export var coin_value: float = 1.0

func _on_collect(target: Node) -> void:
	if target.has_method("add_coin"):
		target.add_coin(coin_value)
	super._on_collect(target)
