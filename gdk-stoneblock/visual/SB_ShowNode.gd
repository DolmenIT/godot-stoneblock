@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_ShowNode
extends Node

## 👁️ SB_ShowNode : Affiche un nœud cible lorsque le bouton parent est pressé.

@export var target_name: String = ""
@export var target_node: Node = null

func start() -> void:
	var target = target_node
	if not target:
		var root = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
		if root and target_name != "":
			target = root.find_child(target_name, true, false)
	
	if is_instance_valid(target) and "visible" in target:
		target.visible = true


