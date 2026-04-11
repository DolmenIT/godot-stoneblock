@tool
class_name SB_ThemeManager
extends Node

## 🧠 SB_ThemeManager : Gestionnaire de thème centralisé et hiérarchique.
## Scanne ses enfants pour générer un thème Godot au démarrage.

@export_group("Configuration")
## Rafraîchir le thème automatiquement lors d'un changement d'un enfant (Mode Editor).
@export var auto_refresh: bool = true

var _generated_theme: Theme
var _style_map: Dictionary = {} # Nom de variation -> Nœud SB_ThemeStyle

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
	var type = style.target_type
	var variation = ""
	
	# Si ce n'est pas un défaut global, on utilise le nom du nœud comme variation
	if not style.is_global_default:
		variation = style.name
		_generated_theme.add_type(variation)
		_generated_theme.set_type_variation(variation, type)
	
	var target = variation if not variation.is_empty() else type
	
	# Application de la taille de police
	if style.font_size > 0:
		_generated_theme.set_font_size("font_size", target, style.font_size)
	
	# Application de la couleur
	_generated_theme.set_color("font_color", target, style.font_color)
	
	# Gestion de la StyleBox (Fond, Coins, Bordures, Ombres)
	if style.use_stylebox:
		var sb = StyleBoxFlat.new()
		sb.bg_color = style.bg_color
		sb.draw_center = style.draw_center
		
		# Coins (Gestion pillule, cercle ou rayon fixe)
		if style.is_circle:
			sb.set_corner_radius_all(1024)
		elif style.is_pill_shape:
			sb.set_corner_radius_all(1024)
		else:
			sb.set_corner_radius_all(style.corner_radius)
		
		# Ombres
		if style.shadow_size > 0:
			sb.shadow_size = style.shadow_size
			sb.shadow_color = style.shadow_color
			sb.shadow_offset = style.shadow_offset
		
		# Bordures
		if style.border_width > 0:
			sb.set_border_width_all(style.border_width)
			sb.border_color = style.border_color
		
		# Padding CSS Style
		if style.padding_left > 0: sb.content_margin_left = style.padding_left
		if style.padding_top > 0: sb.content_margin_top = style.padding_top
		if style.padding_right > 0: sb.content_margin_right = style.padding_right
		if style.padding_bottom > 0: sb.content_margin_bottom = style.padding_bottom
		
		# Attribution selon le type
		if type == "Button":
			_generated_theme.set_stylebox("normal", target, sb)
			
			var sb_hover = sb.duplicate()
			sb_hover.bg_color = sb_hover.bg_color.lightened(0.15)
			# On peut aussi augmenter l'ombre au survol pour un effet de "levée"
			if sb_hover.shadow_size > 0: sb_hover.shadow_size += 2 
			_generated_theme.set_stylebox("hover", target, sb_hover)
			
			var sb_pressed = sb.duplicate()
			sb_pressed.bg_color = sb_pressed.bg_color.darkened(0.15)
			sb_pressed.shadow_offset = Vector2.ZERO # On "écrase" l'ombre au clic
			_generated_theme.set_stylebox("pressed", target, sb_pressed)
		elif type == "Panel" or type == "PanelContainer":
			_generated_theme.set_stylebox("panel", target, sb)
	
	# Gestion des Margins (CSS Style) spécifiques au MarginContainer
	if type == "MarginContainer":
		if style.margin_left >= 0: _generated_theme.set_constant("margin_left", target, style.margin_left)
		if style.margin_top >= 0: _generated_theme.set_constant("margin_top", target, style.margin_top)
		if style.margin_right >= 0: _generated_theme.set_constant("margin_right", target, style.margin_right)
		if style.margin_bottom >= 0: _generated_theme.set_constant("margin_bottom", target, style.margin_bottom)
	
	# Gestion des propriétés personnalisées du dictionnaire
	for prop in style.extra_properties:
		var val = style.extra_properties[prop]
		if val is int:
			_generated_theme.set_constant(prop, target, val)
		elif val is Color:
			_generated_theme.set_color(prop, target, val)
		# On peut étendre ici selon les besoins (StyleBox, Font, etc.)

func _on_scene_loaded(_path: String, node: Node) -> void:
	_apply_to_node_recursive(node)

func _apply_to_node_recursive(node: Node) -> void:
	if node is Control:
		# Application du thème
		if node.theme == null:
			node.theme = _generated_theme
		
		# Application des propriétés physiques (Transformations)
		var var_name = node.theme_type_variation
		if var_name.is_empty():
			# On cherche si on a un style global par défaut pour ce type
			for style in _style_map.values():
				if style.is_global_default and style.target_type == node.get_class():
					if "skew" in node: node.skew = style.skew
					break
		else:
			if _style_map.has(var_name):
				var s = _style_map[var_name]
				if "skew" in node: node.skew = s.skew
				
				# Support spécifique pour SB_Div (Ancien), SB_Box & SB_Label (Nouveau)
				if node is SB_Div or node is SB_Box or node is SB_Label:
					node.padding_left = s.padding_left
					node.padding_top = s.padding_top
					node.padding_right = s.padding_right
					node.padding_bottom = s.padding_bottom
					
					# Les margins sont gérées par les nouveaux composants SB_Box & SB_Label
					if node is SB_Box or node is SB_Label:
						node.margin_left = s.margin_left
						node.margin_top = s.margin_top
						node.margin_right = s.margin_right
						node.margin_bottom = s.margin_bottom
					else:
						# SB_Div obsolète
						node.margin_top = s.margin_top
						node.margin_bottom = s.margin_bottom
				
				# Support pour SB_Button
				if node is SB_Button:
					node.margin_left = s.margin_left
					node.margin_top = s.margin_top
					node.margin_right = s.margin_right
					node.margin_bottom = s.margin_bottom
					# Le padding est interne au stylebox du bouton, géré par son propre script
	
	# On cherche aussi dans les CanvasLayer (qui peuvent masquer des UI)
	for child in node.get_children():
		_apply_to_node_recursive(child)

func _on_structure_changed() -> void:
	if auto_refresh:
		rebuild_theme()
