extends PanelContainer

## Menu popup pour la sélection des brosses.
## Gère l'instanciation des items et les réglages de chaque outil.

signal brush_selected(brush_data: Dictionary)

@onready var grid: GridContainer = %BrushGrid
@onready var label_selected: Label = %LabelSelected

@export var BRUSH_ITEM_SCENE: PackedScene = preload("res://demo/demo2/brushes/SB_BrushItem.tscn")
var ICON_ATLAS: Texture2D = null

# Dictionnaire des brosses (Ordre correspondant à la grille 4x3 de l'image)
var brushes = [
	{"id": "pencil", "name": "Crayon", "coords": [0,0], "settings": {"size": 0.5, "softness": 0.1, "opacity": 0.9, "grain": 0.2}},
	{"id": "pen", "name": "Stylo Plume", "coords": [1,0], "settings": {"size": 0.4, "softness": 0.05, "opacity": 1.0, "grain": 0.0}},
	{"id": "quill", "name": "Plume d'oie", "coords": [2,0], "settings": {"size": 0.3, "softness": 0.0, "opacity": 1.0, "grain": 0.0}},
	{"id": "marker", "name": "Marqueur", "coords": [3,0], "settings": {"size": 2.0, "softness": 0.1, "opacity": 0.7, "grain": 0.0}},
	
	{"id": "brush", "name": "Pinceau", "coords": [0,1], "settings": {"size": 1.2, "softness": 0.4, "opacity": 0.8, "grain": 0.1}},
	{"id": "watercolor", "name": "Aquarelle", "coords": [1,1], "settings": {"size": 3.0, "softness": 0.8, "opacity": 0.4, "grain": 0.0}},
	{"id": "airbrush", "name": "Aérographe", "coords": [2,1], "settings": {"size": 5.0, "softness": 1.0, "opacity": 0.3, "grain": 0.0}},
	{"id": "chalk", "name": "Craie", "coords": [3,1], "settings": {"size": 2.5, "softness": 0.4, "opacity": 0.9, "grain": 0.8}},
	
	{"id": "charcoal", "name": "Fusain", "coords": [0,2], "settings": {"size": 2.2, "softness": 0.6, "opacity": 0.6, "grain": 1.0}},
	{"id": "tech_pen", "name": "Stylo Technique", "coords": [1,2], "settings": {"size": 0.2, "softness": 0.0, "opacity": 1.0, "grain": 0.0}},
	{"id": "knife", "name": "Couteau", "coords": [2,2], "settings": {"size": 4.0, "softness": 0.0, "opacity": 1.0, "grain": 0.0}},
	{"id": "sponge", "name": "Texture / Éponge", "coords": [3,2], "settings": {"size": 6.0, "softness": 0.5, "opacity": 0.5, "grain": 1.2}}
]

func _ready() -> void:
	visible = false
	pivot_offset = Vector2(200, 0) # Pivot en haut au centre
	
	ICON_ATLAS = load("res://demo/demo2/brushes/assets/brush_icons.png")
	if not ICON_ATLAS:
		push_error("[SB] Impossible de charger l'atlas d'icônes !")
	
	_populate_grid()

func _populate_grid() -> void:
	var items = grid.get_children()
	
	for i in range(brushes.size()):
		if i >= items.size(): break
		
		var b = brushes[i]
		var item = items[i]
		
		item.setup(b.id, b.name, Vector2i(b.coords[0], b.coords[1]), ICON_ATLAS)
		
		# Connexion des signaux
		if not item.pressed.is_connected(_on_item_pressed):
			item.pressed.connect(_on_item_pressed.bind(b))
		if not item.mouse_entered.is_connected(_on_item_hover):
			item.mouse_entered.connect(_on_item_hover.bind(b.name))

func open() -> void:
	visible = true
	scale = Vector2.ZERO
	modulate.a = 0
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.3)
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	
	await get_tree().create_timer(0.05).timeout
	# On recentre le label sur le texte actuel
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
