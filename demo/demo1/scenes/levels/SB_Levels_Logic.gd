extends Node3D

## 🌐 SB_Levels_Logic : Gère la sélection des niveaux et l'aperçu dynamique.

@onready var preview_panel: SB_LevelPreview_3d = $LevelPreview
@onready var cards_root: Node3D = $Cards_Root

# --- Configuration des Niveaux ---
# (Note : On pourrait charger ça d'un JSON ou d'une Ressource plus tard)
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
			"scroll_speed": 25.0,
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
	# Connexion automatique des cartes
	for child in cards_root.get_children():
		if child is SB_LevelCard_3d:
			child.hovered.connect(_on_card_hovered)
			child.pressed.connect(func(): _on_card_pressed(child.level_id))
			
			# Injection des données initiales dans la carte
			if levels.has(child.level_id):
				child.stage_name = levels[child.level_id]["name"]
				child.level_params = levels[child.level_id]["params"]
				if levels[child.level_id].has("preview"):
					child.preview_texture = levels[child.level_id]["preview"]

func _on_card_hovered(data: Dictionary) -> void:
	if preview_panel:
		preview_panel.update_from_data(data)
		# Petit feedback visuel additionnel (Optionnel : Bloom etc.)

func _on_card_pressed(level_id: String) -> void:
	if not levels.has(level_id): return
	
	var data = levels[level_id]
	print("[SB_Levels_Logic] Lancement du niveau : ", data.name)
	
	if SB_Core.instance:
		# Injection des paramètres (comme le faisait SB_Redirect)
		SB_Core.instance.level_data = data.params
		# Chargement de la scène de jeu
		SB_Core.instance.load_scene_async("res://demo/demo1/40_game_scene.tscn")
