extends Node3D

## 🏛️ SB_Hangar_Logic : Gère les données dynamiques du Hangar.

@onready var gold_label: Label3D = $Label_Gold_Total
@onready var gold_icon: Sprite3D = $Icon_Gold_Total

func _ready() -> void:
	if SB_GameDatas.instance:
		SB_GameDatas.instance.gold_changed.connect(_on_gold_changed)
		_update_gold_display(SB_GameDatas.instance.get_value("gold"))
	
	# Mise à jour des boutons au cas où l'or a changé
	for btn in find_children("*", "SB_Button_3d", true):
		if btn is SB_Button_3d:
			btn._update_ui()

func _on_gold_changed(new_amount: int) -> void:
	_update_gold_display(new_amount)
	
	# Notifier tous les boutons pour rafraîchir leur état (prix rouge/blanc)
	for btn in find_children("*", "SB_Button_3d", true):
		if btn is SB_Button_3d:
			btn._update_ui()

func _update_gold_display(amount: int) -> void:
	if gold_label:
		gold_label.text = str(amount)
	
	if gold_icon:
		# On pourra ajuster la position de l'icône si besoin
		gold_icon.position.x = (gold_label.text.length() * 0.05) + 0.1
