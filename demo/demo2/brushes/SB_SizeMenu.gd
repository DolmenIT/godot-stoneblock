extends PanelContainer

## Menu popup pour la sélection de la taille de brosse.
## Affiche une grille de boutons avec des paliers prédéfinis.

signal size_selected(value: float)

@onready var grid: GridContainer = %SizeGrid
@onready var label_selected: Label = %LabelSelected

# Les valeurs sont lues directement depuis le texte des boutons SB_Button dans la scène.

func _ready() -> void:
	visible = false
	pivot_offset = Vector2.ZERO # Déploiement depuis le coin haut-gauche
	_populate_grid()

func _populate_grid() -> void:
	# On se connecte simplement aux boutons déjà placés dans la scène
	for btn in grid.get_children():
		if btn is SB_Button or btn is Button:
			# On extrait la valeur numérique depuis le texte du bouton
			var val = float(btn.text)
			
			if not btn.pressed.is_connected(_on_size_pressed):
				btn.pressed.connect(_on_size_pressed.bind(val))
			if not btn.mouse_entered.is_connected(_on_size_hover):
				btn.mouse_entered.connect(_on_size_hover.bind(val))

func open() -> void:
	visible = true
	scale = Vector2.ZERO
	modulate.a = 0
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.3)
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	
	label_selected.text = "Choisir l'épaisseur"

func close() -> void:
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	await tw.finished
	visible = false

func _on_size_pressed(val: float) -> void:
	label_selected.text = str(val) + " mm"
	size_selected.emit(val)
	close()

func _on_size_hover(val: float) -> void:
	label_selected.text = str(val) + " mm"
