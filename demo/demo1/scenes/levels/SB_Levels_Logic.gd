extends Node3D

## 🌐 SB_Levels_Logic : Gère la sélection des niveaux et l'aperçu dynamique.

@onready var preview_panel: SB_LevelPreview_3d = _find_robust(["LevelPreview", "11RightPanel", "Right_Panel"])
@onready var left_panel: Node3D = _find_robust(["Left_Panel", "11LeftPanel", "LeftPanel"])
@onready var play_button = find_child("BTN_Play", true, false)

var _selected_level_id: String = "L1S1"

# --- Configuration des Niveaux ---
var levels = {
	"L1S1": {
		"name": "Secteur Alpha",
		"preview": preload("res://assets/demo1/hangar_background.png"),
		"params": {
			"background_scene": "res://demo/demo1/levels/level1/stage1/background.tscn",
			"mainground_scene": "res://demo/demo1/levels/level1/stage1/mainground.tscn",
			"scroll_speed": 15.0,
			"stage_name": "Secteur Alpha",
			"description": "Zone d'entraînement de la flotte. Faible densité d'astéroïdes."
		}
	},
	"L1S2": {
		"name": "Nébuleuse Pourpre",
		"preview": preload("res://assets/demo1/armory_background.png"),
		"params": {
			"background_scene": "res://demo/demo1/levels/level1/stage2/background.tscn",
			"mainground_scene": "res://demo/demo1/levels/level1/stage2/mainground.tscn",
			"scroll_speed": 22.0,
			"stage_name": "Nébuleuse Pourpre",
			"description": "Visibilité limitée due aux gaz ionisés. Activité ennemie accrue."
		}
	},
	"L1S3": {
		"name": "Station Nexus",
		"preview": preload("res://assets/demo1/options_background.png"),
		"params": {
			"background_scene": "res://demo/demo1/levels/level1/stage3/background.tscn",
			"mainground_scene": "res://demo/demo1/levels/level1/stage3/mainground.tscn",
			"scroll_speed": 35.0,
			"stage_name": "Station Nexus",
			"description": "Ancien avant-poste minier. Zone de combat intense."
		}
	}
}

func _ready() -> void:
	# Remplissage par défaut pour L2 et L3 (Placeholders)
	for l in [2, 3]:
		for s in [1, 2, 3]:
			var id = "L%dS%d" % [l, s]
			if not levels.has(id):
				levels[id] = {
					"name": "Secteur %d-%d" % [l, s],
					"preview": preload("res://assets/demo1/ui/cards/upgrade_card_background.png"),
					"params": {
						"background_scene": "res://demo/demo1/levels/level1/stage1/background.tscn",
						"mainground_scene": "res://demo/demo1/levels/level1/stage1/mainground.tscn",
						"scroll_speed": 20.0 + l*5,
						"stage_name": "Exploration %d-%d" % [l, s],
						"description": "Données topographiques manquantes. Entrée en zone inconnue."
					}
				}

	# Connexion automatique des boutons dans le panneau gauche
	_setup_buttons_recursive(left_panel)
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	
	# Sélection initiale
	_select_level(_selected_level_id)

func _setup_buttons_recursive(node: Node) -> void:
	if not node: return
	for child in node.get_children():
		if child.name.begins_with("BTN_L"):
			var level_id = child.name.replace("BTN_", "") # ex: L1S1
			
			# Calcul du texte sur deux lignes
			var parts = level_id.split("S") # ["L1", "1"]
			if parts.size() == 2:
				var l_num = parts[0].replace("L", "")
				var s_num = parts[1]
				child.text = "LEVEL %s\nSTAGE %s" % [l_num, s_num]
			
			child.pressed.connect(func(): _select_level(level_id))
			child.hovered.connect(func(_d): _on_button_hovered(level_id))
		
		if child.get_child_count() > 0:
			_setup_buttons_recursive(child)

func _on_button_hovered(level_id: String) -> void:
	if levels.has(level_id) and preview_panel:
		var data = {
			"stage_name": levels[level_id]["name"],
			"preview_texture": levels[level_id]["preview"],
			"level_params": levels[level_id]["params"]
		}
		preview_panel.update_from_data(data)

func _select_level(level_id: String) -> void:
	if not levels.has(level_id): return
	_selected_level_id = level_id
	
	# Mise à jour visuelle du panel
	_on_button_hovered(level_id)
	
	# Optionnel : Feedback visuel sur les boutons pour montrer la sélection
	# ... (on pourrait changer la couleur de fond du bouton sélectionné)
	print("[SB_Levels_Logic] Sélectionné : ", level_id)

func _on_play_pressed() -> void:
	var data = levels.get(_selected_level_id)
	if not data: return
	
	print("[SB_Levels_Logic] Lancement du niveau : ", data.name)
	
	if SB_Core.instance:
		SB_Core.instance.level_data = data.params
		SB_Core.instance.load_scene_async("res://demo/demo1/40_game_scene.tscn")

func _find_robust(names: Array) -> Node:
	for n in names:
		var found = find_child(n, true, false)
		if found: return found
	return null
