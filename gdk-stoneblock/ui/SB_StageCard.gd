@tool
extends Node3D
class_name SB_StageCard

## 🎴 SB_StageCard : Contrôleur pour les cartes de sélection de niveau.
## Gère l'affichage des étoiles, l'état de verrouillage et les infos du stage.

@export_group("Stage Info")
## Texte affiché sur la carte.
@export_multiline var stage_text: String = "NIVEAU 1\nSTAGE 1":
	set(v): stage_text = v; _update_ui()

## Image de prévisualisation du niveau.
@export var preview_image: Texture2D:
	set(v): preview_image = v; _update_ui()

@export_group("Progress")
## Nombre d'étoiles obtenues (0 à 3).
@export_range(0, 3) var stars_count: int = 0:
	set(v): stars_count = v; _update_ui()

## État de verrouillage du niveau.
@export var is_locked: bool = false:
	set(v): is_locked = v; _update_ui()

@export_group("Resources")
@export var tex_star_full: Texture2D = preload("res://assets/demo1/ui/icons/star-full.png")
@export var tex_star_empty: Texture2D = preload("res://assets/demo1/ui/icons/star-empty.png")

# Références aux nœuds internes
@onready var _button: Node3D = get_child(0) # BTN_L1S1
@onready var _star_icons: Array = []
@onready var _lock_icon: Node3D = null

func _ready() -> void:
	_cache_nodes()
	_update_ui()

func _cache_nodes() -> void:
	# On cherche les étoiles
	_star_icons.clear()
	var container = find_child("SB_StaticContainer3D", true, false)
	if container:
		for child in container.get_children():
			if child is SB_Icon3D:
				_star_icons.append(child)
	
	# On cherche le cadenas
	_lock_icon = find_child("SB_IconLock", true, false)

func _update_ui() -> void:
	if not is_inside_tree(): return
	if not _button: _cache_nodes()
	if not _button: return
	
	# 1. Mise à jour du texte et de l'image
	if _button.has_method("set"):
		_button.set("text", stage_text)
		if preview_image:
			_button.set("image_preview_texture", preview_image)
	
	# 2. Mise à jour des étoiles
	var container = find_child("SB_StaticContainer3D", true, false)
	if container:
		container.visible = not is_locked
	
	for i in range(_star_icons.size()):
		var star = _star_icons[i]
		if i < stars_count:
			star.texture = tex_star_full
		else:
			star.texture = tex_star_empty
	
	# 3. Gestion du verrouillage
	if _lock_icon:
		_lock_icon.visible = is_locked
	
	# Effet visuel sur le bouton
	if is_locked:
		_button.set("tint_normal", Color(0.2, 0.2, 0.2, 1.0)) # Grisé
		_button.set("preview_mix", 0.05) # Presque invisible
		if _button.has_method("set_deferred"):
			_button.set("process_mode", PROCESS_MODE_DISABLED) # Désactive l'interaction
	else:
		_button.set("tint_normal", Color(0.75, 0.875, 1.0, 1.0)) # Bleu normal
		_button.set("preview_mix", 0.25)
		_button.set("process_mode", PROCESS_MODE_INHERIT)
