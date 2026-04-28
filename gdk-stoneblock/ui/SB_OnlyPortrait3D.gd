@tool
@icon("res://gdk-stoneblock/assets/icons/SB_UI.svg")
extends Node3D
class_name SB_OnlyPortrait3D

## 📱 SB_OnlyPortrait3D : Affiche ses enfants uniquement en mode Portrait.
## Si l'orientation est Paysage, le noeud devient invisible (visible = false) et se désactive (process_mode).

func _ready() -> void:
	if not Engine.is_editor_hint():
		if SB_Core.instance:
			if not SB_Core.instance.orientation_changed.is_connected(_on_orientation_changed):
				SB_Core.instance.orientation_changed.connect(_on_orientation_changed)
		
		get_viewport().size_changed.connect(_update_visibility)
		
	_update_visibility.call_deferred()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_visibility()

func _on_orientation_changed(_new_orientation) -> void:
	_update_visibility()

func _update_visibility() -> void:
	if not is_inside_tree(): return
	var is_portrait = false
	
	if not Engine.is_editor_hint() and SB_Core.instance:
		is_portrait = SB_Core.instance.get_current_orientation() == SB_Core.SBOrientation.PORTRAIT
	else:
		# Fallback de prévisualisation dans l'éditeur (basé sur la fenêtre ou viewport virtuel)
		var viewport_size = get_viewport().get_visible_rect().size
		if Engine.is_editor_hint():
			viewport_size = Vector2(
				ProjectSettings.get_setting("display/window/size/viewport_width"),
				ProjectSettings.get_setting("display/window/size/viewport_height")
			)
			if viewport_size == Vector2.ZERO: viewport_size = Vector2(1920, 1080)
		is_portrait = viewport_size.y > viewport_size.x
		
	if visible != is_portrait:
		visible = is_portrait
		process_mode = Node.PROCESS_MODE_INHERIT if is_portrait else Node.PROCESS_MODE_DISABLED
