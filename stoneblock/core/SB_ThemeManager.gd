@tool
class_name SB_ThemeManager
extends Node

## 🧠 SB_ThemeManager : Gestionnaire de thème centralisé et hiérarchique.
## Scanne ses enfants pour générer un thème Godot au démarrage.

@export_group("Configuration")
## Rafraîchir le thème automatiquement lors d'un changement d'un enfant (Mode Editor).
@export var auto_refresh: bool = true

var _generated_theme: Theme

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
	var styles = find_children("*", "SB_ThemeStyle", true, false)
	
	for style in styles:
		if style is SB_ThemeStyle:
			_register_style_in_theme(style)
	
	print("[SB_ThemeManager] Thème généré avec %d styles définis." % styles.size())

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
		# On n'écrase que si le nœud n'a pas déjà un thème spécifique
		if node.theme == null:
			node.theme = _generated_theme
	
	# On cherche aussi dans les CanvasLayer (qui peuvent masquer des UI)
	for child in node.get_children():
		_apply_to_node_recursive(child)

func _on_structure_changed() -> void:
	if auto_refresh:
		rebuild_theme()
