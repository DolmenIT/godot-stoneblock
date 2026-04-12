@tool
class_name SB_Button
extends Control

## 🔘 SB_Button : Bouton StoneBlock standard.
## Structure : Root(Control) -> _SBMargin(SB_Margin) -> _internal_button(Button).

const SB_BUTTON_SHADER = preload("res://stoneblock/ui/SB_Button.gdshader")

signal pressed

@export_group("Thème")
## Nom du nœud SB_ThemeStyle (ex: ButtonFont). Vide = pas d’application des marges / variation dédiée.
@export var style_class_name: String = "":
	set(v):
		style_class_name = v
		if is_inside_tree(): 
			_ensure_references()
			if _btn: _btn.theme_type_variation = style_class_name
			_update_ui()

@export_group("Texte")
@export_multiline var text: String = "Button":
	set(v):
		text = v
		if is_inside_tree(): 
			_ensure_references()
			# On ne vide plus le texte ici, _update_ui gérera la visibilité via les couleurs
			_update_ui()

@export var font_size: int = 16:
	set(v):
		var prev_fs: int = font_size
		font_size = v
		if debug_font_measure and prev_fs != v:
			print("[SB_Button:%s] font_size setter %d -> %d | in_tree=%s editor=%s" % [
				str(get_path()), prev_fs, v, str(is_inside_tree()), str(Engine.is_editor_hint())
			])
		if is_inside_tree(): _update_ui()

@export var alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER:
	set(v):
		alignment = v
		if is_inside_tree(): 
			_ensure_references()
			if _btn: _btn.alignment = alignment
			_update_ui()

@export var text_vertical_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER:
	set(v):
		text_vertical_alignment = v
		if is_inside_tree(): _update_ui()

@export var autowrap_mode: TextServer.AutowrapMode = TextServer.AUTOWRAP_OFF:
	set(v):
		autowrap_mode = v
		if is_inside_tree(): 
			_ensure_references()
			if _btn: _btn.autowrap_mode = autowrap_mode
			_update_ui()

@export_group("Icône")
@export var icon: Texture2D:
	set(v):
		icon = v
		if is_inside_tree(): 
			_ensure_references()
			if _btn:
				if icon_vertical_alignment == VERTICAL_ALIGNMENT_CENTER:
					_btn.icon = icon
				elif _btn.icon != null:
					_btn.icon = null
			_update_ui()
@export var icon_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER:
	set(v):
		icon_alignment = v
		if is_inside_tree(): _update_ui()

@export var icon_vertical_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER:
	set(v):
		icon_vertical_alignment = v
		if is_inside_tree(): _update_ui()
@export var icon_max_width: int = 75:
	set(v):
		icon_max_width = v
		if is_inside_tree(): _update_ui()

@export_group("Layout (StoneBlock CSS)")
@export_subgroup("Margins (Autour)")
@export var margin_left: int = 20:
	set(v):
		margin_left = v
		if is_inside_tree(): _update_ui()
@export var margin_top: int = 20:
	set(v):
		margin_top = v
		if is_inside_tree(): _update_ui()
@export var margin_right: int = 20:
	set(v):
		margin_right = v
		if is_inside_tree(): _update_ui()
@export var margin_bottom: int = 20:
	set(v):
		margin_bottom = v
		if is_inside_tree(): _update_ui()

@export_subgroup("Padding (Dédans)")
@export var padding_left: int = 20:
	set(v):
		padding_left = v
		if is_inside_tree(): _update_ui()
@export var padding_top: int = 20:
	set(v):
		padding_top = v
		if is_inside_tree(): _update_ui()
@export var padding_right: int = 20:
	set(v):
		padding_right = v
		if is_inside_tree(): _update_ui()
@export var padding_bottom: int = 20:
	set(v):
		padding_bottom = v
		if is_inside_tree(): _update_ui()

@export_subgroup("Sizing")
@export var min_width: int = 200:
	set(v):
		min_width = v
		if is_inside_tree(): _update_ui()
@export var min_height: int = 200:
	set(v):
		min_height = v
		if is_inside_tree(): _update_ui()

@export_group("Textures (Style Nineslice)")
@export var normal_texture: Texture2D = preload("res://stoneblock/assets/sb_button/button_square_normal.png"):
	set(v):
		normal_texture = v
		if is_inside_tree(): _update_ui()
@export var hover_texture: Texture2D = preload("res://stoneblock/assets/sb_button/button_square_hover.png"):
	set(v):
		hover_texture = v
		if is_inside_tree(): _update_ui()
@export var pressed_texture: Texture2D = preload("res://stoneblock/assets/sb_button/button_square_pressed.png"):
	set(v):
		pressed_texture = v
		if is_inside_tree(): _update_ui()

@export_subgroup("Slice Margins")
@export var slice_margin_left: float = 32:
	set(v):
		slice_margin_left = v
		if is_inside_tree(): _update_ui()
@export var slice_margin_top: float = 32:
	set(v):
		slice_margin_top = v
		if is_inside_tree(): _update_ui()
@export var slice_margin_right: float = 32:
	set(v):
		slice_margin_right = v
		if is_inside_tree(): _update_ui()
@export var slice_margin_bottom: float = 32:
	set(v):
		slice_margin_bottom = v
		if is_inside_tree(): _update_ui()

@export_subgroup("Texture Cropping (Empty Margins)")
@export var crop_left: float = 10:
	set(v):
		crop_left = v
		if is_inside_tree(): _update_ui()
@export var crop_top: float = 10:
	set(v):
		crop_top = v
		if is_inside_tree(): _update_ui()
@export var crop_right: float = 10:
	set(v):
		crop_right = v
		if is_inside_tree(): _update_ui()
@export var crop_bottom: float = 10:
	set(v):
		crop_bottom = v
		if is_inside_tree(): _update_ui()

@export_group("Transitions & Animations")
@export var transition_duration: float = 0.15
@export var hover_scale_px: float = 4.0
@export var pressed_scale_px: float = -4.0
@export var match_texture_height: bool = false:
	set(v):
		match_texture_height = v
		if is_inside_tree(): _update_ui()

@export_group("Debug")
## Active : traces dans la sortie Éditeur (onglet Sortie) lors des changements de font / _update_ui.
@export var debug_font_measure: bool = false

@onready var _margin_block: SB_Margin = %_SBMargin
@onready var _btn: Button = %_internal_button
@onready var _custom_label: Label = %_sb_custom_label
@onready var _custom_icon: TextureRect = %_sb_custom_icon

var _is_updating: bool = false # Verrou anti-récursion pour le mode @tool

var _last_state: String = ""
var _tex_from: Texture2D
var _tex_to: Texture2D
var _mix_weight: float = 1.0 # Contrôlé par Tween pour le Cross-Fade
var _tween: Tween # Référence pour le nettoyage des tweens en cours

func _ready() -> void:
	# Détection hybride sécurisée (permet de fonctionner sur un bouton natif ou en composant)
	if get_class() == "Button":
		_btn = self as Object
	else:
		_btn = get_node_or_null("%_internal_button") as Button
	
	if not _margin_block:
		_margin_block = get_node_or_null("%_SBMargin")
	
	if _btn and _btn != self:
		if not _btn.pressed.is_connected(_on_btn_pressed):
			_btn.pressed.connect(_on_btn_pressed)
		if not _btn.mouse_entered.is_connected(_update_ui):
			_btn.mouse_entered.connect(_update_ui)
		if not _btn.mouse_exited.is_connected(_update_ui):
			_btn.mouse_exited.connect(_update_ui)
	elif _btn == self:
		# Sur un bouton natif, on se connecte à soi-même pour gérer les enfants
		if not pressed.is_connected(_on_btn_pressed):
			pressed.connect(_on_btn_pressed)
		if not mouse_entered.is_connected(_update_ui):
			mouse_entered.connect(_update_ui)
		if not mouse_exited.is_connected(_update_ui):
			mouse_exited.connect(_update_ui)
	
	_tex_to = normal_texture
	_tex_from = normal_texture
	
	# Centre du pivot pour les animations de scale
	# Centre du pivot pour les animations de scale (Racine)
	pivot_offset = size / 2.0
	if not resized.is_connected(_on_self_resized):
		resized.connect(_on_self_resized)
	
	_update_ui()

func _process(_delta: float) -> void:
	if _btn:
		_btn.pivot_offset = _btn.size / 2.0
		
		# Mise à jour des couleurs pour les labels personnalisés (Animation fluide)
		var type = _btn.theme_type_variation if not _btn.theme_type_variation.is_empty() else "Button"
		
		if _custom_label and _custom_label.is_inside_tree():
			# On demande au label de chercher la couleur dans le thème sous le type du bouton
			# Cela ignore l'override de transparence du bouton parent.
			var target_color = _custom_label.get_theme_color("font_color", type)
			if _btn.is_pressed(): target_color = _custom_label.get_theme_color("font_pressed_color", type)
			elif _btn.is_hovered(): target_color = _custom_label.get_theme_color("font_hover_color", type)
			
			if _custom_label.get_theme_color("font_color") != target_color:
				_custom_label.add_theme_color_override("font_color", target_color)
		
		# Mise à jour du Shader (Transitions)
		if normal_texture:
			_update_shader_params()

func _update_shader_params() -> void:
	var bg_parent = _btn.get_parent() if _btn != self else _btn
	var bg = bg_parent.get_node_or_null("_sb_bg_shader")
	if not bg: return
	
	# ... (Logique shader extraite de _update_ui pour clarté)
	bg.material.set_shader_parameter("tex_from", _tex_from)
	bg.material.set_shader_parameter("tex_to", _tex_to)
	bg.material.set_shader_parameter("mix_weight", _mix_weight)
	bg.material.set_shader_parameter("real_size", _btn.size)

func _on_self_resized() -> void:
	# Ne pas rappeler _update_ui ici : set_deferred(custom_minimum_size) déclenche resized
	# et boucle infinie / blocage éditeur (réouverture des scènes, @tool).
	pivot_offset = size / 2.0

## Mesure une ligne : TextLine (shaping) + get_string_size, on garde le max pour ne jamais sous-estimer (clip / min_width).
func _measure_text_line_size(p_text: String, p_font: Font, p_font_size: int) -> Vector2:
	if p_text.is_empty() or p_font == null:
		return Vector2.ZERO
	var gs: Vector2 = p_font.get_string_size(p_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, p_font_size)
	var line := TextLine.new()
	var add_result: Variant = line.add_string(p_text, p_font, p_font_size)
	if typeof(add_result) == TYPE_BOOL:
		if add_result != true:
			return gs
	elif add_result != OK:
		return gs
	var tl: Vector2 = line.get_size()
	var out: Vector2 = Vector2(maxf(gs.x, tl.x), maxf(gs.y, tl.y))
	if debug_font_measure:
		print("    [SB_Button measure] fs_arg=%d add_string=%s | get_string_size=%s TextLine.get_size=%s => %s" % [
			p_font_size, str(add_result), str(gs), str(tl), str(out)
		])
	return out


func _ensure_references() -> void:
	if not _margin_block: 
		_margin_block = get_node_or_null("%_SBMargin")
		if not _margin_block: _margin_block = find_child("_SBMargin", true, false)
		
	if not _btn:
		if get_class() == "Button": 
			_btn = self as Object
		else: 
			_btn = get_node_or_null("%_internal_button") as Button
			if not _btn: _btn = find_child("_internal_button", true, false) as Button
	
	if _btn:
		if not _custom_label: _custom_label = _btn.get_node_or_null("%_sb_custom_label")
		if not _custom_icon: _custom_icon = _btn.get_node_or_null("%_sb_custom_icon")

func _update_ui() -> void:
	if not is_inside_tree() or _is_updating: return
	_is_updating = true
	
	_ensure_references()
	
	# Utilisation du composant SB_Margin officiel
	if _margin_block:
		_margin_block.set_margins(margin_left, margin_top, margin_right, margin_bottom)
	
	if _btn:
		# On évite d'écraser si identique pour limiter les notifications système
		if _btn.text != text: 
			if Engine.is_editor_hint(): _btn.set_deferred("text", text)
			else: _btn.text = text
			
		if _btn.alignment != alignment: _btn.alignment = alignment
		if _btn.autowrap_mode != autowrap_mode: _btn.autowrap_mode = autowrap_mode
		if _btn.theme_type_variation != style_class_name: _btn.theme_type_variation = style_class_name
		
		# Sécurité : on empêche le débordement visuel
		_btn.clip_contents = true
		# Même taille que le label : sinon le thème « Button » garde souvent 16 px et fausse rendu / layout.
		_btn.add_theme_font_size_override("font_size", font_size)
		
		var text_w: float = 0.0
		var text_h: float = 0.0
		
		# --- GESTION DES ANCRES (STRATÉGIE DIRECTE) ---
		# On utilise désormais TOUJOURS les nœuds personnalisés pour un rendu cohérent
		if _custom_label and _custom_icon:
			_custom_label.show()
			var _lbl_fs_before: int = -1
			if debug_font_measure and _custom_label.is_inside_tree():
				_lbl_fs_before = _custom_label.get_theme_font_size("font_size")
			_custom_label.add_theme_font_size_override("font_size", font_size)
			var _lbl_fs_after: int = -1
			if debug_font_measure and _custom_label.is_inside_tree():
				_lbl_fs_after = _custom_label.get_theme_font_size("font_size")
			if debug_font_measure:
				print("[SB_Button:%s] label theme font_size avant/après override: %d -> %d (export font_size=%d)" % [
					str(get_path()), _lbl_fs_before, _lbl_fs_after, font_size
				])
			
			# Masquage du texte natif (On le vide VRAIMENT pour ne plus qu'il pèse sur la taille)
			_btn.text = ""
			_btn.icon = null
			
			_custom_label.text = text
			_custom_label.horizontal_alignment = alignment
			_custom_label.autowrap_mode = autowrap_mode
			
			var measure_font_size_l: int = maxi(1, font_size)
			var _font_l: Font = ThemeDB.fallback_font
			var _lf_pick := _custom_label.get_theme_font("font")
			if _lf_pick != null:
				_font_l = _lf_pick
			
			if not text.is_empty():
				if autowrap_mode == TextServer.AUTOWRAP_OFF:
					var _ts_l := _measure_text_line_size(text, _font_l, measure_font_size_l)
					text_w = _ts_l.x
					text_h = _ts_l.y
				else:
					var wrap_base_l: float = custom_minimum_size.x
					if wrap_base_l <= 0.0:
						wrap_base_l = float(maxi(min_width, 64))
					var wrap_w_l: float = maxf(wrap_base_l - float(padding_left + padding_right), 1.0)
					var _ms_l := _font_l.get_multiline_string_size(text, alignment, wrap_w_l, measure_font_size_l)
					text_w = _ms_l.x
					text_h = _ms_l.y
			
			var lh: int = maxi(1, ceili(text_h))
			var lw: int = maxi(1, ceili(text_w))
			
			if autowrap_mode == TextServer.AUTOWRAP_OFF:
				# Pas de *_WIDE : sinon le label s’étire sur toute la largeur du bouton (ex. 265 px) alors que
				# le texte fait ~121 px → rendu / hitbox incohérents avec la taille de police réelle.
				_custom_label.custom_minimum_size = Vector2(float(lw), float(lh))
				if text_vertical_alignment == VERTICAL_ALIGNMENT_TOP:
					_custom_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE)
				elif text_vertical_alignment == VERTICAL_ALIGNMENT_BOTTOM:
					_custom_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE)
				else:
					_custom_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
				var dph: float = (float(padding_left) - float(padding_right)) * 0.5
				_custom_label.offset_left += dph
				_custom_label.offset_right += dph
				if text_vertical_alignment == VERTICAL_ALIGNMENT_TOP:
					_custom_label.offset_top = float(padding_top)
					_custom_label.offset_bottom = float(padding_top + lh)
				elif text_vertical_alignment == VERTICAL_ALIGNMENT_BOTTOM:
					_custom_label.offset_bottom = -float(padding_bottom)
					_custom_label.offset_top = _custom_label.offset_bottom - float(lh)
				else:
					var dpv: float = (float(padding_top) - float(padding_bottom)) * 0.5
					_custom_label.offset_top += dpv
					_custom_label.offset_bottom += dpv
			else:
				_custom_label.custom_minimum_size = Vector2.ZERO
				var t_preset = Control.PRESET_CENTER
				if text_vertical_alignment == VERTICAL_ALIGNMENT_TOP: t_preset = Control.PRESET_TOP_WIDE
				elif text_vertical_alignment == VERTICAL_ALIGNMENT_BOTTOM: t_preset = Control.PRESET_BOTTOM_WIDE
				else: t_preset = Control.PRESET_HCENTER_WIDE
				_custom_label.set_anchors_and_offsets_preset(t_preset, Control.PRESET_MODE_MINSIZE)
				_custom_label.offset_left = padding_left
				_custom_label.offset_right = -padding_right
				if text_vertical_alignment == VERTICAL_ALIGNMENT_TOP:
					var h = _custom_label.size.y
					_custom_label.offset_top = padding_top
					_custom_label.offset_bottom = padding_top + h
				elif text_vertical_alignment == VERTICAL_ALIGNMENT_BOTTOM:
					var h2 = _custom_label.size.y
					_custom_label.offset_bottom = -padding_bottom
					_custom_label.offset_top = -padding_bottom - h2
			
			# --- POSITIONNEMENT DE L'ICÔNE ---
			var i_preset = Control.PRESET_CENTER
			if icon_vertical_alignment == VERTICAL_ALIGNMENT_TOP: i_preset = Control.PRESET_TOP_WIDE
			elif icon_vertical_alignment == VERTICAL_ALIGNMENT_BOTTOM: i_preset = Control.PRESET_BOTTOM_WIDE
			else: i_preset = Control.PRESET_HCENTER_WIDE
			
			_custom_icon.set_anchors_and_offsets_preset(i_preset, Control.PRESET_MODE_MINSIZE)
			_custom_icon.texture = icon
			_custom_icon.custom_minimum_size = Vector2(icon_max_width, icon_max_width) if icon_max_width > 0 else Vector2.ZERO
			
			# Application des paddings sur l'icône
			if icon_alignment == HORIZONTAL_ALIGNMENT_LEFT:
				_custom_icon.anchor_left = 0.0; _custom_icon.anchor_right = 0.0
				_custom_icon.offset_left = padding_left
			elif icon_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
				_custom_icon.anchor_left = 1.0; _custom_icon.anchor_right = 1.0
				_custom_icon.offset_right = -padding_right
			else: # CENTER
				_custom_icon.anchor_left = 0.5; _custom_icon.anchor_right = 0.5
			
			if icon_vertical_alignment == VERTICAL_ALIGNMENT_TOP:
				var h = _custom_icon.size.y
				_custom_icon.offset_top = padding_top
				_custom_icon.offset_bottom = padding_top + h
			elif icon_vertical_alignment == VERTICAL_ALIGNMENT_BOTTOM:
				var h = _custom_icon.size.y
				_custom_icon.offset_bottom = -padding_bottom
				_custom_icon.offset_top = -padding_bottom - h
		
		# text_w / text_h : remplis avec _custom_label ; secours si scène incomplète.
		if text_w <= 0.0 and not text.is_empty():
			var measure_fb: int = maxi(1, font_size)
			var _font_fb: Font = ThemeDB.fallback_font
			var _ts_fb := _measure_text_line_size(text, _font_fb, measure_fb)
			text_w = _ts_fb.x
			text_h = _ts_fb.y

		var _new_size: Vector2
		var core_w: int = 0
		var core_h: int = 0
		if not text.is_empty():
			# Padding via offsets Label/Icône uniquement ; StyleBoxEmpty à 0 (évite double compte).
			var pad_h: int = padding_left + padding_right
			var pad_v: int = padding_top + padding_bottom
			core_w = maxi(1, ceili(text_w))
			core_h = maxi(1, ceili(text_h))
			var w: int = maxi(min_width, core_w + pad_h)
			if icon != null and icon_max_width > 0:
				w = maxi(min_width, maxi(w, icon_max_width + pad_h))
			var h: int = maxi(min_height, core_h + pad_v)
			_new_size = Vector2(float(w), float(h))
		else:
			_new_size = Vector2(min_width, min_height)

		if debug_font_measure and _btn and not text.is_empty():
			var btn_fs: int = _btn.get_theme_font_size("font_size") if _btn.is_inside_tree() else -1
			var lbl_sz: Vector2 = _custom_label.size if _custom_label else Vector2.ZERO
			var lbl_min: Vector2 = _custom_label.get_minimum_size() if _custom_label else Vector2.ZERO
			var lbl_scale: Vector2 = _custom_label.scale if _custom_label else Vector2.ONE
			var vp_info: String = "null"
			var vp: Viewport = get_viewport()
			if vp != null:
				vp_info = "screen_xform=%s" % str(vp.get_screen_transform())
			print("[SB_Button:%s] _update_ui sizing | export font_size=%d | btn.theme font_size=%d | text_w/h=%s | core %dx%d pad_h=%d pad_v=%d => %dx%d | custom_min_was=%s will=%s defer=%s | label size=%s min=%s scale=%s | %s" % [
				str(get_path()),
				font_size,
				btn_fs,
				str(Vector2(text_w, text_h)),
				core_w,
				core_h,
				padding_left + padding_right,
				padding_top + padding_bottom,
				int(round(_new_size.x)),
				int(round(_new_size.y)),
				str(custom_minimum_size),
				str(_new_size),
				str(int(round(_new_size.x)) != int(round(custom_minimum_size.x)) or int(round(_new_size.y)) != int(round(custom_minimum_size.y))),
				str(lbl_sz),
				str(lbl_min),
				str(lbl_scale),
				vp_info,
			])

		# Comparaison stricte en entiers : is_equal_approx peut laisser passer des deltas sub-pixel
		# et bloquer un set_deferred alors que le padding vient de changer.
		var cur_x: int = int(round(custom_minimum_size.x))
		var cur_y: int = int(round(custom_minimum_size.y))
		if int(round(_new_size.x)) != cur_x or int(round(_new_size.y)) != cur_y:
			set_deferred("custom_minimum_size", _new_size)

		# --- APPLICATION DU PADDING (FONCTIONNE POUR TEXTE ET ICÔNE) ---
		if not _btn.has_theme_stylebox_override("normal") or not (_btn.get_theme_stylebox("normal") is StyleBoxEmpty):
			var sb_p = StyleBoxEmpty.new()
			# Marges 0 : le padding visuel est porté par les offsets du label / icône (voir plus haut).
			sb_p.content_margin_left = 0.0
			sb_p.content_margin_top = 0.0
			sb_p.content_margin_right = 0.0
			sb_p.content_margin_bottom = 0.0
			
			_btn.add_theme_stylebox_override("normal", sb_p)
			_btn.add_theme_stylebox_override("hover", sb_p)
			_btn.add_theme_stylebox_override("pressed", sb_p)
			_btn.add_theme_stylebox_override("focus", sb_p)
		
		if normal_texture:
			# MODE TEXTURE (Premium Shader Engine)
			var bg_parent = _btn.get_parent() if _btn != self else _btn
			var bg = bg_parent.get_node_or_null("_sb_bg_shader")
			
			if not bg:
				bg = ColorRect.new()
				bg.name = "_sb_bg_shader"
				bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
				bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				
				var mat = ShaderMaterial.new()
				mat.shader = SB_BUTTON_SHADER
				bg.material = mat
				
				bg_parent.add_child(bg)
				if bg_parent != _btn:
					bg_parent.move_child(bg, 0) # Derrière le bouton dans le conteneur
				else:
					bg.show_behind_parent = true
			
			# Détection de l'état actuel pour les transitions
			var current_state = "normal"
			var target_tex = normal_texture
			var target_scale = Vector2.ONE
			
			if _btn.is_pressed() and pressed_texture:
				current_state = "pressed"
				target_tex = pressed_texture
				if _btn.size.y > 0:
					var s = (_btn.size.y + pressed_scale_px) / _btn.size.y
					target_scale = Vector2(s, s)
			elif _btn.is_hovered() and hover_texture:
				current_state = "hover"
				target_tex = hover_texture
				if _btn.size.y > 0:
					var s = (_btn.size.y + hover_scale_px) / _btn.size.y
					target_scale = Vector2(s, s)
			
			# Calcul de la taille forcée (match_texture_height)
			if match_texture_height and normal_texture:
				var tex_h = normal_texture.get_size().y - crop_top - crop_bottom
				if _margin_block:
					_margin_block.custom_minimum_size.y = tex_h
				else:
					custom_minimum_size.y = tex_h
			
			# Gestion de l'animation de transition
			if current_state != _last_state:
				_last_state = current_state
				_tex_from = _tex_to # On garde l'ancienne pour le fondu
				_tex_to = target_tex
				_mix_weight = 0.0
				
				if _tween: _tween.kill()
				_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				
				var duration = transition_duration if not Engine.is_editor_hint() else 0.05
				_tween.tween_property(self, "_mix_weight", 1.0, duration)
				_tween.tween_property(self, "scale", target_scale, duration)
				
				# Centrage dynamique du pivot pour le scale (Racine)
				pivot_offset = size / 2.0
			
			# Mise à jour des paramètres du shader
			bg.material.set_shader_parameter("tex_from", _tex_from)
			bg.material.set_shader_parameter("tex_to", _tex_to)
			bg.material.set_shader_parameter("mix_weight", _mix_weight)
			bg.material.set_shader_parameter("crop", Vector4(crop_left, crop_top, crop_right, crop_bottom))
			bg.material.set_shader_parameter("slice_w", slice_margin_left)
			bg.material.set_shader_parameter("real_size", _btn.size)
			bg.material.set_shader_parameter("tex_size", normal_texture.get_size())
			
			# Masquage des styles standards pour laisser place au shader, tout en gardant le padding
			# On ne le fait que si nécessaire pour éviter de saturer l'éditeur
			if not _btn.has_theme_stylebox_override("normal") or not (_btn.get_theme_stylebox("normal") is StyleBoxEmpty):
				var sb_p = StyleBoxEmpty.new()
				sb_p.content_margin_left = 0.0
				sb_p.content_margin_top = 0.0
				sb_p.content_margin_right = 0.0
				sb_p.content_margin_bottom = 0.0
				
				_btn.add_theme_stylebox_override("normal", sb_p)
				_btn.add_theme_stylebox_override("hover", sb_p)
				_btn.add_theme_stylebox_override("pressed", sb_p)
				_btn.add_theme_stylebox_override("focus", sb_p)
			
			if Engine.is_editor_hint(): 
				_btn.queue_redraw()
				queue_redraw()
		else:
			# MODE THEME (Standard Elite)
			# Suppression du background shader s'il reste d'une texture précédente
			var bg = _btn.get_node_or_null("_sb_bg_shader")
			if bg: bg.queue_free()
			
			var variation: StringName = &"Button"
			if not style_class_name.is_empty():
				variation = StringName(style_class_name)
			elif not theme_type_variation.is_empty():
				variation = StringName(theme_type_variation)
			var sb = _btn.get_theme_stylebox("normal", variation)
			if sb and sb is StyleBoxFlat:
				var new_sb = sb.duplicate()
				new_sb.content_margin_left = padding_left
				new_sb.content_margin_top = padding_top
				new_sb.content_margin_right = padding_right
				new_sb.content_margin_bottom = padding_bottom
				
				# On applique à tous les états pour garder un padding cohérent
				_btn.add_theme_stylebox_override("normal", new_sb)
				_btn.add_theme_stylebox_override("hover", new_sb)
				_btn.add_theme_stylebox_override("pressed", new_sb)
				_btn.add_theme_stylebox_override("focus", new_sb)
	
	# Anciennes scènes : StyleBoxEmpty avec marges = padding doublait la zone réservée (offsets label).
	if _btn:
		for st_key in [&"normal", &"hover", &"pressed", &"focus"]:
			var sbx: StyleBox = _btn.get_theme_stylebox(st_key)
			if sbx != null and sbx is StyleBoxEmpty:
				var se: StyleBoxEmpty = sbx as StyleBoxEmpty
				se.content_margin_left = 0.0
				se.content_margin_top = 0.0
				se.content_margin_right = 0.0
				se.content_margin_bottom = 0.0
	
	_is_updating = false

func _on_btn_pressed() -> void:
	# Déclenchement automatique des composants "sous-événements" StoneBlock
	for child in get_children():
		if child.has_method("start"):
			child.start()
	
	if _btn != self:
		pressed.emit()

func get_btn() -> Button:
	return _btn
