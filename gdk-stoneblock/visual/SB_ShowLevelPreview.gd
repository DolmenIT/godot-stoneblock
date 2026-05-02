@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_ShowLevelPreview
extends Node

## 🗺️ SB_ShowLevelPreview : Met à jour l'aperçu du panneau droit et affiche le panneau au clic.

@export_group("Preview Setup")
@export var level_name: String = "Secteur Alpha"
@export var preview_texture: Texture2D = null
@export_multiline var description: String = ""

@export_group("Level Parameters (SB_Core)")
@export var background_scene: String = "res://demo/demo1/levels/level1/stage1/background.tscn"
@export var mainground_scene: String = "res://demo/demo1/levels/level1/stage1/mainground.tscn"
@export var scroll_speed: float = 15.0

func start() -> void:
	var root = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	if not root: return
	
	# Recherche robuste du panneau droit
	var preview_panel = root.find_child("11RightPanel", true, false)
	if not preview_panel:
		preview_panel = root.find_child("LevelPreview", true, false)
	if not preview_panel:
		preview_panel = root.find_child("Right_Panel", true, false)
		
	if preview_panel:
		var data = {
			"stage_name": level_name,
			"preview_texture": preview_texture,
			"level_params": {
				"background_scene": background_scene,
				"mainground_scene": mainground_scene,
				"scroll_speed": scroll_speed,
				"stage_name": level_name,
				"description": description
			}
		}
		
		# Mise à jour des données visuelles du panel
		if preview_panel.has_method("update_from_data"):
			preview_panel.update_from_data(data)
			
		# Affichage du panel
		preview_panel.visible = true
		
		# Enregistrement des données du niveau sélectionné dans SB_Core pour le BTN_Play
		if SB_Core.instance:
			SB_Core.instance.level_data = data["level_params"]
