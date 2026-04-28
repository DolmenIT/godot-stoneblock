@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Logic.svg")
class_name SB_SetVisibility
extends Node

## ⚙️ SB_SetVisibility : Gestionnaire de visibilité dynamique.
## S'applique au chargement de la scène et lors des changements d'orientation.
## Si aucun target_node n'est défini, il contrôle son parent direct.

@export var target_node: Node = null

@export_group("Visibilité Globale")
## La visibilité par défaut si aucune surcharge d'orientation ne s'applique.
@export var default_visibility: bool = true

@export_group("Surcharges par Orientation")
## Si coché, force la visibilité en mode Paysage.
@export var override_landscape: bool = true
@export var landscape_visibility: bool = true

## Si coché, force la visibilité en mode Portrait.
@export var override_portrait: bool = true
@export var portrait_visibility: bool = false

@export_group("Avancé")
## Si coché, désactive également la physique/input (process_mode) quand rendu invisible.
@export var sync_process_mode: bool = true

func _ready() -> void:
	# Si aucune cible n'est définie, on utilise le parent par défaut
	if target_node == null:
		target_node = get_parent()
		
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
	if not is_inside_tree() or not is_instance_valid(target_node):
		return
		
	var is_portrait = false
	
	# Détection de l'orientation
	if not Engine.is_editor_hint() and SB_Core.instance:
		is_portrait = SB_Core.instance.get_current_orientation() == SB_Core.SBOrientation.PORTRAIT
	else:
		# Fallback Éditeur
		var viewport_size = get_viewport().get_visible_rect().size
		if Engine.is_editor_hint():
			viewport_size = Vector2(
				ProjectSettings.get_setting("display/window/size/viewport_width"),
				ProjectSettings.get_setting("display/window/size/viewport_height")
			)
			if viewport_size == Vector2.ZERO: viewport_size = Vector2(1920, 1080)
		is_portrait = viewport_size.y > viewport_size.x

	# Application des règles
	var new_visibility = default_visibility
	
	if is_portrait and override_portrait:
		new_visibility = portrait_visibility
	elif not is_portrait and override_landscape:
		new_visibility = landscape_visibility
		
	# Modification de la cible
	if "visible" in target_node and target_node.visible != new_visibility:
		target_node.visible = new_visibility
		
		if sync_process_mode and "process_mode" in target_node:
			target_node.process_mode = Node.PROCESS_MODE_INHERIT if new_visibility else Node.PROCESS_MODE_DISABLED
