@tool
class_name SB_ThemeManager
extends Node

## 🧠 SB_ThemeManager : Gestionnaire de thème centralisé et hiérarchique.
## Scanne ses enfants pour générer un thème Godot au démarrage.

@export_group("Configuration")
## Rafraîchir le thème automatiquement lors d'un changement d'un enfant (Mode Editor).
@export var auto_refresh: bool = true

var _generated_theme: Theme
var _style_map: Dictionary = {} # Nom de classe de style (nom du nœud) -> SB_ThemeStyle

func _ready() -> void:
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
	var styles = find_children("*", "SB_ThemeStyle", true, false)
	
	for style in styles:
		if style is SB_ThemeStyle:
			_style_map[style.name] = style # Mémorisation pour application physique
			_register_style_in_theme(style)
	
	print("[SB_ThemeManager] Thème généré avec %d styles." % styles.size())

func _register_style_in_theme(style: SB_ThemeStyle) -> void:
	var base: String = style.target_class_name
	var style_class: String = style.name
	
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

func _resolve_style_lookup_key(node: Control) -> String:
	if node is SB_Button:
		var sb: SB_Button = node as SB_Button
		if not sb.style_class_name.is_empty():
			return sb.style_class_name
	return node.theme_type_variation

func _on_scene_loaded(_path: String, node: Node) -> void:
	_apply_to_node_recursive(node)

func _apply_to_node_recursive(node: Node) -> void:
	if node is Control:
		var ctl: Control = node as Control
		if ctl.theme == null:
			ctl.theme = _generated_theme
		
		var var_name: String = _resolve_style_lookup_key(ctl)
		if var_name.is_empty():
			for st in _style_map.values():
				if st.is_global_default and _node_matches_global_target(node, st.target_class_name):
					if "skew" in ctl: ctl.skew = st.skew
					break
		else:
			if _style_map.has(var_name):
				var s: SB_ThemeStyle = _style_map[var_name]
				if "skew" in ctl: ctl.skew = s.skew
				
				if node is SB_Div or node is SB_Box or node is SB_Label:
					node.padding_left = s.padding_left
					node.padding_top = s.padding_top
					node.padding_right = s.padding_right
					node.padding_bottom = s.padding_bottom
					
					if node is SB_Box or node is SB_Label:
						node.margin_left = s.margin_left
						node.margin_top = s.margin_top
						node.margin_right = s.margin_right
						node.margin_bottom = s.margin_bottom
					else:
						node.margin_top = s.margin_top
						node.margin_bottom = s.margin_bottom
				
				if node is SB_Button:
					var sbtn: SB_Button = node as SB_Button
					sbtn.margin_left = s.margin_left
					sbtn.margin_top = s.margin_top
					sbtn.margin_right = s.margin_right
					sbtn.margin_bottom = s.margin_bottom
	
	for child in node.get_children():
		_apply_to_node_recursive(child)

func _on_structure_changed() -> void:
	if auto_refresh:
		rebuild_theme()
