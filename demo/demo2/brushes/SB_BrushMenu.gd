extends PanelContainer

## Menu popup pour la sélection des brosses.
## Version Visuelle : Utilise les SB_Button placés dans la scène.

signal brush_selected(brush_data: Dictionary)

@onready var grid: GridContainer = %BrushGrid
@onready var label_selected: Label = %LabelSelected

# Dictionnaire des brosses (Ordre correspondant aux boutons Btn_1 à Btn_12)
var brushes = [
	{"id": "pencil", "name": "Crayon", "settings": {"size": 0.5, "softness": 0.1, "opacity": 0.9, "grain": 0.2}},
	{"id": "pen", "name": "Stylo Plume", "settings": {"size": 0.4, "softness": 0.05, "opacity": 1.0, "grain": 0.0}},
	{"id": "quill", "name": "Plume d'oie", "settings": {"size": 0.3, "softness": 0.0, "opacity": 1.0, "grain": 0.0}},
	{"id": "marker", "name": "Marqueur", "settings": {"size": 2.0, "softness": 0.1, "opacity": 0.7, "grain": 0.0}},
	
	{"id": "brush", "name": "Pinceau", "settings": {"size": 1.2, "softness": 0.4, "opacity": 0.8, "grain": 0.1}},
	{"id": "watercolor", "name": "Aquarelle", "settings": {"size": 3.0, "softness": 0.8, "opacity": 0.4, "grain": 0.0}},
	{"id": "airbrush", "name": "Aérographe", "settings": {"size": 5.0, "softness": 1.0, "opacity": 0.3, "grain": 0.0}},
	{"id": "chalk", "name": "Craie", "settings": {"size": 2.5, "softness": 0.4, "opacity": 0.9, "grain": 0.8}},
	
	{"id": "charcoal", "name": "Fusain", "settings": {"size": 2.2, "softness": 0.6, "opacity": 0.6, "grain": 1.0}},
	{"id": "tech_pen", "name": "Stylo Technique", "settings": {"size": 0.2, "softness": 0.0, "opacity": 1.0, "grain": 0.0}},
	{"id": "knife", "name": "Couteau", "settings": {"size": 4.0, "softness": 0.0, "opacity": 1.0, "grain": 0.0}},
	{"id": "sponge", "name": "Texture / Éponge", "settings": {"size": 6.0, "softness": 0.5, "opacity": 0.5, "grain": 1.2}}
]

func _ready() -> void:
	visible = false
	pivot_offset = Vector2.ZERO # Dropdown style
	_populate_grid()

func _populate_grid() -> void:
	var btns = grid.get_children()
	
	for i in range(btns.size()):
		if i >= brushes.size(): break
		
		var b = brushes[i]
		var btn = btns[i]
		
		# On s'assure que le bouton affiche le bon texte (au cas où)
		btn.text = b.name
		
		# Connexion des signaux
		if not btn.pressed.is_connected(_on_item_pressed):
			btn.pressed.connect(_on_item_pressed.bind(b))
		if not btn.mouse_entered.is_connected(_on_item_hover):
			btn.mouse_entered.connect(_on_item_hover.bind(b.name))

func open() -> void:
	visible = true
	scale = Vector2.ZERO
	modulate.a = 0
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.3)
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	
	label_selected.text = "Choisir un outil"

func close() -> void:
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	await tw.finished
	visible = false

func _on_item_pressed(b_data: Dictionary) -> void:
	label_selected.text = b_data.name
	brush_selected.emit(b_data)
	close()

func _on_item_hover(tool_name: String) -> void:
	label_selected.text = tool_name
