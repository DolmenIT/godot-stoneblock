@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends SB_5_Interface_Layer

## 🌈 SB_BloomMiniView : Miniature de debug pour le BloomViewport.
## Affiche la texture du SubViewport de bloom en bas à gauche de l'écran.
## Adapté de bloom_debug_display.gd (Cosmic HyperSquad).

# --- Configuration ---
@export_group("Source")
## Chemin vers le SubViewport bloom. Si vide, résolution automatique par nom ("BloomViewport").
@export var bloom_viewport_path: NodePath
## Nom du container SubViewportContainer (ex: "BloomLongContainer").
@export var bloom_container_name: String = "BloomLongContainer"

@export_group("Affichage")
## Facteur de rÃ©duction (6 = 1/6 de la largeur). Plus grand = plus petit.
@export var width_divisor: float = 5.0
## DÃ©calage en X depuis le bord gauche (px).
@export var offset_x: int = 4
## DÃ©calage en Y depuis le bord bas (px).
@export var offset_y: int = 4
## Ã‰paisseur de la bordure.
@export var border_width: int = 2
@export var border_color: Color = Color(0.0, 1.0, 1.0, 0.8)  # Cyan (couleur projet)
@export var background_color: Color = Color(0, 0, 0, 0.85)
## Empilage vertical (0 = bas, 1 = juste au-dessus, etc.)
@export var vertical_stack_index: int = 0

@export_group("Label")
@export var show_label: bool = true
@export var label_text: String = "Bloom"
@export var label_font_size: int = 11
@export var label_color: Color = Color(0.0, 1.0, 1.0, 1.0)

# --- NÅ“uds internes ---
var _frame: Panel = null
var _texture_rect: TextureRect = null
var _border_overlay: Panel = null
var _title_label: Label = null

# --- Ã‰tat ---
var _cached_viewport: SubViewport = null

func _ready() -> void:
	# DÃ©sactivation sur mobile (IP-054)
	if SB_Core.instance and SB_Core.instance.is_mobile and SB_Core.instance.auto_optimize_mobile:
		visible = false
		set_process(false)
		return
		
	_build_ui()
	_resolve_viewport()

func _process(_delta: float) -> void:
	_update_layout()
	_update_texture()

# ---------------------------------------------------------------------------
# Construction de l'UI (entiÃ¨rement par code, pas de nÅ“uds dans la scÃ¨ne)
# ---------------------------------------------------------------------------
func _build_ui() -> void:
	# Panel principal (fond)
	_frame = Panel.new()
	_frame.name = "BloomMiniFrame"
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.clip_contents = true
	add_child(_frame)
	
	var style = StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_top = 0
	style.border_width_bottom = 0
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	_frame.add_theme_stylebox_override("panel", style)
	
	# TextureRect (contenu bloom)
	_texture_rect = TextureRect.new()
	_texture_rect.name = "BloomTexture"
	_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_frame.add_child(_texture_rect)
	
	# Overlay de bordure (par-dessus la texture)
	_border_overlay = Panel.new()
	_border_overlay.name = "BorderOverlay"
	_border_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color.TRANSPARENT
	border_style.draw_center = false
	border_style.border_width_left = border_width
	border_style.border_width_right = border_width
	border_style.border_width_top = border_width
	border_style.border_width_bottom = border_width
	border_style.border_color = border_color
	border_style.corner_radius_top_left = 2
	border_style.corner_radius_top_right = 2
	border_style.corner_radius_bottom_left = 2
	border_style.corner_radius_bottom_right = 2
	_border_overlay.add_theme_stylebox_override("panel", border_style)
	_frame.add_child(_border_overlay)
	
	# Label de titre
	if show_label:
		_title_label = Label.new()
		_title_label.name = "TitleLabel"
		_title_label.text = label_text
		_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_title_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_title_label.add_theme_color_override("font_color", label_color)
		_title_label.add_theme_font_size_override("font_size", label_font_size)
		_title_label.add_theme_constant_override("shadow_offset_x", 1)
		_title_label.add_theme_constant_override("shadow_offset_y", 1)
		_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
		_frame.add_child(_title_label)

# ---------------------------------------------------------------------------
# Mise Ã  jour du layout (taille + position en bas Ã  gauche)
# ---------------------------------------------------------------------------
func _update_layout() -> void:
	if not _frame or not _texture_rect:
		return
	
	var vp_size = get_viewport().get_visible_rect().size
	var mini_width = vp_size.x / width_divisor
	var mini_height = mini_width * (vp_size.y / vp_size.x)
	
	# Position bas-gauche avec empilement
	var stacked_offset = (mini_height + offset_y) * vertical_stack_index
	var pos_x = offset_x
	var pos_y = vp_size.y - mini_height - offset_y - stacked_offset
	
	_frame.position = Vector2(pos_x, pos_y)
	_frame.size = Vector2(mini_width, mini_height)
	
	_texture_rect.position = Vector2.ZERO
	_texture_rect.size = Vector2(mini_width, mini_height)
	
	if _border_overlay:
		_border_overlay.position = Vector2.ZERO
		_border_overlay.size = Vector2(mini_width, mini_height)
	
	if _title_label:
		var label_height = label_font_size + 4
		_title_label.position = Vector2(0, mini_height - label_height - 3)
		_title_label.size = Vector2(mini_width, label_height)

# ---------------------------------------------------------------------------
# RÃ©solution du SubViewport source
# ---------------------------------------------------------------------------
func _resolve_viewport() -> void:
	if bloom_viewport_path != NodePath():
		_cached_viewport = get_node_or_null(bloom_viewport_path) as SubViewport
		if _cached_viewport:
			return
	
	# 1. Recherche via le BloomManager (IP-109)
	var root = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().root
	var manager = root.find_child("*", true, false) if root else null # On cherche n'importe quoi pour commencer
	# Version plus prÃ©cise : on cherche le manager par type
	for child in root.find_children("*", "SB_BloomManager", true, false):
		var m = child as SB_BloomManager
		if m:
			var container = m.get(bloom_container_name.to_snake_case())
			if container and container is SubViewportContainer:
				for vp in container.get_children():
					if vp is SubViewport:
						_cached_viewport = vp
						break
	
	if not _cached_viewport:
		# 2. Recherche par nom de container (Fallback)
		var container = root.find_child(bloom_container_name, true, false) if root else null
		if container and container is SubViewportContainer:
			for child in container.get_children():
				if child is SubViewport:
					_cached_viewport = child
					break
			
			if _texture_rect and container.material:
				_texture_rect.material = container.material
	
	if not _cached_viewport:
		# 3. Fallback ancien nom
		_cached_viewport = root.find_child("BloomViewport", true, false) if root else null
		
	# On ne pousse l'avertissement que si on est en jeu (pour Ã©viter de spammer l'Ã©diteur au chargement)
	if not _cached_viewport and not Engine.is_editor_hint():
		# On utilise une petite sÃ©curitÃ© pour ne pas spammer
		if Time.get_ticks_msec() % 1000 < 20: 
			push_warning("SB_BloomMiniView : Viewport introuvable pour " + bloom_container_name)

# ---------------------------------------------------------------------------
# Mise Ã  jour de la texture depuis le viewport
# ---------------------------------------------------------------------------
func _update_texture() -> void:
	if not _texture_rect:
		return
	
	if not _cached_viewport or not is_instance_valid(_cached_viewport):
		_resolve_viewport()
		return
	
	var tex = _cached_viewport.get_texture()
	if tex and _texture_rect.texture != tex:
		_texture_rect.texture = tex
