@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Logic.svg")
class_name SB_ToggleVisibility
extends Node

## 👁️ SB_ToggleVisibility : Composant d'événement UI.
## Bascule la visibilité d'un nœud cible lorsqu'il est déclenché par un parent (ex: SB_Button_3d) via `start()`.

@export var target_node: Node = null
@export var is_enabled: bool = true

@export_group("Options avancées")
## Si coché, applique un état fixe au lieu d'inverser l'état actuel.
@export var force_state: bool = false
## L'état à forcer si 'force_state' est activé.
@export var target_visible: bool = true
## Si coché, désactive également la physique et l'exécution du nœud cible quand il est masqué.
@export var sync_process_mode: bool = true

func start() -> void:
	if not is_enabled or not is_instance_valid(target_node):
		return
	
	var new_visibility = true
	
	if force_state:
		new_visibility = target_visible
	else:
		if "visible" in target_node:
			new_visibility = not target_node.visible
			
	if "visible" in target_node:
		target_node.visible = new_visibility
		
	if sync_process_mode and "process_mode" in target_node:
		target_node.process_mode = Node.PROCESS_MODE_INHERIT if new_visibility else Node.PROCESS_MODE_DISABLED
