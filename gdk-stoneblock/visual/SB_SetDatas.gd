@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_SetDatas
extends Node

## 📦 SB_SetDatas : Met à jour les données du panneau droit et les paramètres de niveau au clic.

@export var target_name: String = ""

@export_group("Data Settings")
@export var level_name: String = ""
@export var preview_texture: Texture2D = null
@export_multiline var description: String = ""

@export_group("Level Parameters (SB_Core)")
@export var background_scene: String = ""
@export var mainground_scene: String = ""
@export var scroll_speed: float = 15.0

@export_group("Initialization Options")
## Si vrai, applique les données dès le démarrage (_ready).
@export var apply_on_ready: bool = false


func _ready() -> void:
	if apply_on_ready and not Engine.is_editor_hint():
		call_deferred("start")

func start() -> void:
	var root = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	if not root: return
	
	# Recherche robuste du panneau droit
	var preview_panel = null
	if target_name != "":
		preview_panel = root.find_child(target_name, true, false)
		
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
			
		# Enregistrement des données du niveau sélectionné dans SB_Core
		if SB_Core.instance:
			SB_Core.instance.level_data = data["level_params"]
