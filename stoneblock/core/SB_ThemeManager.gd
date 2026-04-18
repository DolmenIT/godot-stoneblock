@tool
class_name SB_ThemeManager
extends Node

## 🧠 SB_ThemeManager : Gestionnaire de thème centralisé et hiérarchique.
## Scanne ses enfants pour générer un thème Godot au démarrage.

@export_group("Configuration")
## Rafraîchir le thème automatiquement lors d'un changement d'un enfant (Mode Editor).
@export var auto_refresh: bool = true
## Chemin vers le fichier .tres généré pour la persistance dans l'éditeur.
@export_file("*.tres") var output_theme_path: String = ""

var _generated_theme: Theme
static var instance: SB_ThemeManager

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		instance = self

var _style_map: Dictionary = {} # Nom de classe de style (nom du nœud) -> SB_BaseStyle

func _ready() -> void:
	add_to_group("SB_ThemeManager")
	if Engine.is_editor_hint():
		child_order_changed.connect(_on_structure_changed)
	
	# Génération initiale
	rebuild_theme()
	
	# Connexion au Core pour injection dans les nouvelles scènes
	if SB_Core.instance:
		SB_Core.instance.resource_loaded.connect(_on_scene_loaded)
		# Si une scène est déjà active, on lui applique le thème
		if SB_Core.instance.active_scene_container:
			_apply_to_node_recursive(SB_Core.instance.active_scene_container)

## Reconstruit entièrement la ressource Theme à partir de la hiérarchie.
func rebuild_theme() -> void:
	_generated_theme = Theme.new()
	_style_map.clear()
	var styles = find_children("*", "SB_BaseStyle", true, false)
	
	for style in styles:
		if style is SB_BaseStyle:
			_style_map[style.name] = style 
			if style is SB_ThemeStyle:
				_register_style_in_theme(style as SB_ThemeStyle)
	
	print("[SB_ThemeManager] Thème généré avec %d styles." % styles.size())
	
	# Sauvegarde physique pour l'éditeur (WYSIWYG)
	if not output_theme_path.is_empty() and Engine.is_editor_hint():
		var err = ResourceSaver.save(_generated_theme, output_theme_path)
		if err == OK:
			print("[SB_ThemeManager] Thème persisté dans : %s" % output_theme_path)
		else:
			push_error("[SB_ThemeManager] Erreur lors de la sauvegarde du thème : %d" % err)

func _register_style_in_theme(style: SB_ThemeStyle) -> void:
	var base: String = style.target_class_name
	var style_class: String = style.name
	
	if base.is_empty():
		return
		
	_generated_theme.add_type(style_class)
	_generated_theme.set_type_variation(style_class, base)
	
	var targets: Array[String] = [style_class]
	if style.is_global_default:
		targets.append(base)
	
	for theme_key in targets:
		_apply_style_to_theme_key(style, theme_key, base)

func _apply_style_to_theme_key(style: SB_ThemeStyle, theme_key: String, base_class: String) -> void:
	if style.font_size > 0:
		_generated_theme.set_font_size("font_size", theme_key, style.font_size)
	
	_generated_theme.set_color("font_color", theme_key, style.font_color)
	
	if base_class == "Label":
		if style.outline_size > 0:
			_generated_theme.set_constant("outline_size", theme_key, style.outline_size)
			_generated_theme.set_color("font_outline_color", theme_key, style.outline_color)
	
	if style.use_stylebox:
		var sb = StyleBoxFlat.new()
		sb.bg_color = style.bg_color
		sb.draw_center = style.draw_center
		
		if style.is_circle:
			sb.set_corner_radius_all(1024)
		elif style.is_pill_shape:
			sb.set_corner_radius_all(1024)
		else:
			sb.set_corner_radius_all(style.corner_radius)
		
		if style.shadow_size > 0:
			sb.shadow_size = style.shadow_size
			sb.shadow_color = style.shadow_color
			sb.shadow_offset = style.shadow_offset
		
		if style.border_width > 0:
			sb.set_border_width_all(style.border_width)
			sb.border_color = style.border_color
		
		if style.padding_left > 0: sb.content_margin_left = style.padding_left
		if style.padding_top > 0: sb.content_margin_top = style.padding_top
		if style.padding_right > 0: sb.content_margin_right = style.padding_right
		if style.padding_bottom > 0: sb.content_margin_bottom = style.padding_bottom
		
		if base_class == "Button":
			_generated_theme.set_stylebox("normal", theme_key, sb)
			
			var sb_hover = sb.duplicate()
			sb_hover.bg_color = sb_hover.bg_color.lightened(0.15)
			if sb_hover.shadow_size > 0: sb_hover.shadow_size += 2 
			_generated_theme.set_stylebox("hover", theme_key, sb_hover)
			
			var sb_pressed = sb.duplicate()
			sb_pressed.bg_color = sb_pressed.bg_color.darkened(0.15)
			sb_pressed.shadow_offset = Vector2.ZERO
			_generated_theme.set_stylebox("pressed", theme_key, sb_pressed)
		elif base_class == "Panel" or base_class == "PanelContainer":
			_generated_theme.set_stylebox("panel", theme_key, sb)
	
	if base_class == "MarginContainer":
		if style.margin_left >= 0: _generated_theme.set_constant("margin_left", theme_key, style.margin_left)
		if style.margin_top >= 0: _generated_theme.set_constant("margin_top", theme_key, style.margin_top)
		if style.margin_right >= 0: _generated_theme.set_constant("margin_right", theme_key, style.margin_right)
		if style.margin_bottom >= 0: _generated_theme.set_constant("margin_bottom", theme_key, style.margin_bottom)
	
	for prop in style.extra_properties:
		var val = style.extra_properties[prop]
		if val is int:
			_generated_theme.set_constant(prop, theme_key, val)
		elif val is Color:
			_generated_theme.set_color(prop, theme_key, val)

func _node_matches_global_target(node: Node, target_class_name: String) -> bool:
	if node.get_class() == target_class_name:
		return true
	if target_class_name == "Button" and node is SB_Button:
		return true
	if target_class_name == "Label" and node is SB_Label:
		return true
	if (target_class_name == "PanelContainer" or target_class_name == "Panel") and node is PanelContainer:
		return true
	return false

func _resolve_style_lookup_key(node: Node) -> String:
	if node is SB_Button:
		return (node as SB_Button).style_class_name
	if node is Control:
		return (node as Control).theme_type_variation
	if node.has_method("get_style_class_name"):
		return node.call("get_style_class_name")
	if "style_class_name" in node:
		return node.style_class_name
	return ""

func _on_scene_loaded(_path: String, node: Node) -> void:
	_apply_to_node_recursive(node)

## Demande l'application (ou la mise à jour) du thème pour un nœud spécifique.
func request_style_update(node: Node) -> void:
	# On applique le style uniquement au nœud (pas besoin de descendre récursivement ici)
	var var_name: String = _resolve_style_lookup_key(node)
	var active_style: SB_BaseStyle = null
	
	if var_name.is_empty():
		for st in _style_map.values():
			if st.is_global_default and _node_matches_global_target(node, st.target_class_name):
				active_style = st
				break
	elif _style_map.has(var_name):
		active_style = _style_map[var_name]

	# Application 3D
	if node.has_method("apply_theme_style"):
		if active_style != null:
			if not Engine.is_editor_hint(): 
				print("[SB_ThemeManager] Style '%s' appliqué à %s" % [var_name, node.name])
			node.call("apply_theme_style", active_style)
		else:
			if not var_name.is_empty() and not Engine.is_editor_hint():
				print("[SB_ThemeManager] ALERTE: Style '%s' introuvable dans la map pour %s" % [var_name, node.name])
	
	# Application 2D
	if node is Control:
		var ctl: Control = node as Control
		if ctl.theme == null: ctl.theme = _generated_theme
		if active_style != null and active_style is SB_ThemeStyle:
			_apply_2d_style_to_control(ctl, active_style as SB_ThemeStyle)

func _apply_to_node_recursive(node: Node) -> void:
	var var_name: String = _resolve_style_lookup_key(node)
	var active_style: SB_BaseStyle = null
	
	if var_name.is_empty():
		for st in _style_map.values():
			if st.is_global_default and _node_matches_global_target(node, st.target_class_name):
				active_style = st
				break
	elif _style_map.has(var_name):
		active_style = _style_map[var_name]

	# --- APPLICATION 2D (CONTRÔLES) ---
	if node is Control:
		var ctl: Control = node as Control
		if ctl.theme == null:
			ctl.theme = _generated_theme
			
		if active_style != null and active_style is SB_ThemeStyle:
			var s: SB_ThemeStyle = active_style as SB_ThemeStyle
			_apply_2d_style_to_control(ctl, s)

	# --- APPLICATION 3D (DIÉGÉTIQUE) ---
	if node.has_method("apply_theme_style"):
		if active_style != null:
			node.call("apply_theme_style", active_style)

	for child in node.get_children():
		_apply_to_node_recursive(child)

func _apply_2d_style_to_control(ctl: Control, s: SB_ThemeStyle) -> void:
	if "skew" in ctl: ctl.skew = s.skew
	
	if ctl is SB_Div or ctl is SB_Box or ctl is SB_Label or ctl is SB_Button:
		ctl.padding_left = s.padding_left
		ctl.padding_top = s.padding_top
		ctl.padding_right = s.padding_right
		ctl.padding_bottom = s.padding_bottom
		
		if ctl is SB_Box or ctl is SB_Label:
			ctl.margin_left = s.margin_left
			ctl.margin_top = s.margin_top
			ctl.margin_right = s.margin_right
			ctl.margin_bottom = s.margin_bottom
		else:
			ctl.margin_top = s.margin_top
			ctl.margin_bottom = s.margin_bottom
	
	if ctl is SB_Button:
		var sbtn: SB_Button = ctl as SB_Button
		sbtn.margin_left = s.margin_left
		sbtn.margin_top = s.margin_top
		sbtn.margin_right = s.margin_right
		sbtn.margin_bottom = s.margin_bottom
		if s.min_width >= 0: sbtn.min_width = s.min_width
		if s.min_height >= 0: sbtn.min_height = s.min_height
		if s.font_size > 0: sbtn.font_size = s.font_size

func _on_structure_changed() -> void:
	if auto_refresh:
		rebuild_theme()
