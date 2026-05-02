@tool
extends Node3D
class_name SB_StageCard

## 🎴 SB_StageCard : Contrôleur pour les cartes de sélection de niveau.
## Gère l'affichage des étoiles, l'état de verrouillage et les infos du stage.

signal pressed
signal hovered(data)

@export_group("Theme Settings")
## Nom du style dans le ThemeManager pour cette carte de stage.
@export var style_class_name: String = "":
	set(v): style_class_name = v; _request_theme_refresh()

enum AlignPoint {
	TOP_LEFT, TOP_CENTER, TOP_RIGHT,
	CENTER_LEFT, CENTER, CENTER_RIGHT,
	BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT
}

## Texte affiché sur la carte.
@export_multiline var stage_text: String = "NIVEAU 1\nSTAGE 1":
	set(v): stage_text = v; _update_ui()

## Alias pour la compatibilité avec le duck-typing (utilisé par SB_Levels_Logic).
var text: String:
	get: return stage_text
	set(v): stage_text = v

## Forcer l'affichage sur une seule ligne (remplace les retours à la ligne par des espaces).
@export var force_single_line: bool = true:
	set(v): force_single_line = v; _update_ui()

@export var text_anchor: AlignPoint = AlignPoint.TOP_LEFT:
	set(v): text_anchor = v; _update_ui()
@export var text_pivot: AlignPoint = AlignPoint.TOP_LEFT:
	set(v): text_pivot = v; _update_ui()
## Décalage manuel du texte (en unités 3D locales, ex: 0.05).
@export var offset_3d: Vector2 = Vector2(0.45, -0.45):
	set(v): offset_3d = v; _update_ui()

@export var text_font: Font:
	set(v): text_font = v; _update_ui()
@export var text_size: int = 600:
	set(v): text_size = v; _update_ui()
@export var text_color: Color = Color.WHITE:
	set(v): text_color = v; _update_ui()
@export var text_outline_size: int = 200:
	set(v): text_outline_size = v; _update_ui()
@export var text_outline_color: Color = Color.BLACK:
	set(v): text_outline_color = v; _update_ui()

## Image de prévisualisation du niveau.
@export var preview_image: Texture2D:
	set(v): preview_image = v; _update_ui()
	
## Teinte de base de la carte (lorsqu'elle n'est pas verrouillée).
@export var tint_color: Color = Color("bf8f8f"):
	set(v): tint_color = v; _update_ui()

## Décalage de la teinte (0-360) appliqué au bouton.
@export_range(0.0, 360.0) var tint_hue_shift: float = 120.0:
	set(v): tint_hue_shift = v; _update_ui()

## Nombre d'étoiles obtenues (0 à 3).
@export_range(0, 3) var stars_count: int = 0:
	set(v): stars_count = v; _update_ui()

## État de verrouillage du niveau.
@export var is_locked: bool = false:
	set(v): is_locked = v; _update_ui()

@export_group("Resources")
@export var tex_lock: Texture2D = preload("res://assets/demo1/ui/icons/locked.png")
@export var tex_star_full: Texture2D = preload("res://assets/demo1/ui/icons/star-full.png")
@export var tex_star_empty: Texture2D = preload("res://assets/demo1/ui/icons/star-empty.png")

# Références aux nœuds internes
@onready var _button: Node3D = get_child(0) # BTN_L1S1
@onready var _star_icons: Array = []
@onready var _lock_icon: Node3D = null

func _ready() -> void:
	_cache_nodes()
	_update_ui()
	
	# Forward des signaux du bouton interne pour compatibilité
	if _button:
		if _button.has_signal("pressed"):
			_button.pressed.connect(func():
				pressed.emit()
				for child in get_children():
					if child.has_method("start"):
						child.start()
			)
		if _button.has_signal("hovered"):
			_button.hovered.connect(func(d): hovered.emit(d))
			
	# Sécurité : On s'assure d'écraser les valeurs du ThemeManager après l'initialisation du jeu
	call_deferred("_update_ui")
	if is_inside_tree():
		get_tree().process_frame.connect(_update_ui, CONNECT_ONE_SHOT)
		
	# Rafraîchir le thème dès le démarrage
	_request_theme_refresh()

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
		var final_text = stage_text
		if force_single_line:
			final_text = final_text.replace("\n", " ").replace("\r", "")
			
		_button.set("text", final_text)
		_button.set("tint_hue_shift", tint_hue_shift)
		_button.set("autowrap_mode", TextServer.AUTOWRAP_OFF)
		
		# Transfert des propriétés de style au bouton
		_button.set("font_size", text_size)
		_button.set("text_color_normal", text_color)
		_button.set("text_color_hover", text_color)
		_button.set("text_color_pressed", text_color)
		_button.set("outline_size", text_outline_size)
		_button.set("outline_color", text_outline_color)
		
		var label = _button.get_node_or_null("Label")
		if label:
			label.font = text_font
			_apply_pivot_to_label(label, text_pivot)
			
			var mesh_size = _button.get("mesh_size") if _button.get("mesh_size") != null else Vector2(0.3, 0.1)
			var anchor_3d = _get_anchor_pos(text_anchor, mesh_size)
			
			# Application de l'offset 3D manuel de l'utilisateur
			var final_pos_3d = anchor_3d + Vector3(offset_3d.x, offset_3d.y, 0)
			
			# Conversion en pixels (offset du Label3D) via le pixel_size
			label.offset = Vector2(final_pos_3d.x, final_pos_3d.y) / label.pixel_size
			
		if preview_image:
			_button.set("image_preview_texture", preview_image)
		else:
			_button.set("image_preview_texture", _get_default_gradient())
	
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
		if tex_lock and "texture" in _lock_icon:
			_lock_icon.texture = tex_lock
	
	# Effet visuel sur le bouton
	if is_locked:
		_button.set("tint_normal", Color(0.2, 0.2, 0.2, 1.0)) # Grisé
		_button.set("preview_mix", 0.05) # Presque invisible
		if _button.has_method("set_deferred"):
			_button.set("process_mode", PROCESS_MODE_DISABLED) # Désactive l'interaction
	else:
		_button.set("tint_normal", tint_color) # Utilise la couleur choisie par l'utilisateur
		_button.set("preview_mix", 0.25)
		_button.set("process_mode", PROCESS_MODE_INHERIT)

func _get_default_gradient() -> GradientTexture2D:
	var grad_tex = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(0.29, 0.29, 0.29), Color(0.1, 0.1, 0.1)])
	grad_tex.gradient = grad
	grad_tex.fill_from = Vector2(0, 0)
	grad_tex.fill_to = Vector2(1, 1)
	grad_tex.width = 256
	grad_tex.height = 256
	return grad_tex

func _apply_pivot_to_label(label: Label3D, p: AlignPoint):
	match p:
		AlignPoint.TOP_LEFT, AlignPoint.CENTER_LEFT, AlignPoint.BOTTOM_LEFT:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		AlignPoint.TOP_CENTER, AlignPoint.CENTER, AlignPoint.BOTTOM_CENTER:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		AlignPoint.TOP_RIGHT, AlignPoint.CENTER_RIGHT, AlignPoint.BOTTOM_RIGHT:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			
	match p:
		AlignPoint.TOP_LEFT, AlignPoint.TOP_CENTER, AlignPoint.TOP_RIGHT:
			label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		AlignPoint.CENTER_LEFT, AlignPoint.CENTER, AlignPoint.CENTER_RIGHT:
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		AlignPoint.BOTTOM_LEFT, AlignPoint.BOTTOM_CENTER, AlignPoint.BOTTOM_RIGHT:
			label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

func _get_anchor_pos(a: AlignPoint, size: Vector2) -> Vector3:
	var hw = size.x / 2.0
	var hh = size.y / 2.0
	var x = 0.0
	var y = 0.0
	
	match a:
		AlignPoint.TOP_LEFT, AlignPoint.CENTER_LEFT, AlignPoint.BOTTOM_LEFT:
			x = -hw
		AlignPoint.TOP_RIGHT, AlignPoint.CENTER_RIGHT, AlignPoint.BOTTOM_RIGHT:
			x = hw
			
	match a:
		AlignPoint.TOP_LEFT, AlignPoint.TOP_CENTER, AlignPoint.TOP_RIGHT:
			y = hh
		AlignPoint.BOTTOM_LEFT, AlignPoint.BOTTOM_CENTER, AlignPoint.BOTTOM_RIGHT:
			y = -hh
			
	return Vector3(x, y, 0)


func apply_theme_style(s: SB_BaseStyle) -> void:
	if s:
		if "force_single_line" in s: force_single_line = s.force_single_line
		if "text_anchor" in s: text_anchor = s.text_anchor
		if "text_pivot" in s: text_pivot = s.text_pivot
		if "offset_3d" in s: offset_3d = s.offset_3d
		if "text_font" in s: text_font = s.text_font
		if "text_size" in s: text_size = s.text_size
		if "text_color" in s: text_color = s.text_color
		if "text_outline_size" in s: text_outline_size = s.text_outline_size
		if "text_outline_color" in s: text_outline_color = s.text_outline_color
		if "tint_color" in s: tint_color = s.tint_color
		if "tint_hue_shift" in s: tint_hue_shift = s.tint_hue_shift
		_update_ui()

func _apply_style_from_dict(data: Dictionary) -> void:
	if data.has("force_single_line"): force_single_line = data["force_single_line"]
	if data.has("text_anchor"): text_anchor = data["text_anchor"]
	if data.has("text_pivot"): text_pivot = data["text_pivot"]
	if data.has("offset_3d"): offset_3d = data["offset_3d"]
	if data.has("text_font"): text_font = data["text_font"]
	if data.has("text_size"): text_size = data["text_size"]
	if data.has("text_color"): text_color = data["text_color"]
	if data.has("text_outline_size"): text_outline_size = data["text_outline_size"]
	if data.has("text_outline_color"): text_outline_color = data["text_outline_color"]
	if data.has("tint_color"): tint_color = data["tint_color"]
	if data.has("tint_hue_shift"): tint_hue_shift = data["tint_hue_shift"]
	_update_ui()

func _request_theme_refresh() -> void:
	if not is_inside_tree(): return
	var manager = SB_ThemeManager.instance
	if manager:
		if manager.has_method("request_style_update"):
			manager.call("request_style_update", self)
	elif Engine.is_editor_hint():
		var cache_path = "res://demo/demo1/ui/demo1_styles.tres"
		if FileAccess.file_exists(cache_path):
			var cache = load(cache_path)
			if cache and cache.has_method("get_style_data"):
				var data = cache.call("get_style_data", style_class_name)
				if not data.is_empty():
					_apply_style_from_dict(data)
	else:
		var managers = get_tree().get_nodes_in_group("SB_ThemeManager")
		if managers.size() > 0:
			managers[0].call("request_style_update", self)


