@tool
class_name SB_DebugConsole
extends CanvasLayer

## 📟 SB_DebugConsole : Console de debug autonome (CanvasLayer).
## Ce composant gère son propre overlay et peut être ajouté n'importe où.

@export_group("Réglages Console")
## Nombre maximum de messages affichés à la fois.
@export var max_messages: int = 25
## Taille de la police pour le texte.
@export var font_size: int = 11

@export_group("Style Visuel")
## Couleur de fond (Noir transparent par défaut).
@export var bg_color: Color = Color(0, 0, 0, 0.6)
## Rayon des coins arrondis.
@export var corner_radius: int = 12

@export_group("Couleurs Log")
@export var color_info: Color = Color.SKY_BLUE
@export var color_success: Color = Color.SPRING_GREEN
@export var color_error: Color = Color.TOMATO

var _panel: PanelContainer
var _label: RichTextLabel
var _messages: Array[String] = []

func _ready() -> void:
	# On s'assure que la console est TOUJOURS au-dessus de tout
	layer = 128
	_setup_ui()
	
	if Engine.is_editor_hint():
		return
		
	# Connexion au Singleton global SB_Core
	if SB_Core.instance:
		if not SB_Core.instance.message_logged.is_connected(_on_message_logged):
			SB_Core.instance.message_logged.connect(_on_message_logged)
		
		_sync_history()
	else:
		push_warning("[SB_DebugConsole] SB_Core non trouvé.")

func _setup_ui() -> void:
	# 1. Création du PanelContainer (Le conteneur UI)
	if not _panel:
		_panel = PanelContainer.new()
		_panel.name = "ConsolePanel"
		add_child(_panel)
		
		# Positionnement robuste en bas à gauche
		_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 20)
		_panel.offset_top = -320
		_panel.offset_right = 320
		_panel.custom_minimum_size = Vector2(300, 300)
	
	# 2. Configuration du StyleBox (Arrière-plan arrondi)
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	_panel.add_theme_stylebox_override("panel", style)
	
	# 3. Création et configuration du RichTextLabel
	if not _label:
		_label = RichTextLabel.new()
		_label.name = "ConsoleLabel"
		_label.bbcode_enabled = true
		_label.scroll_following = true
		_label.selection_enabled = true
		_label.mouse_filter = Control.MOUSE_FILTER_STOP
		_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_label.add_theme_font_size_override("normal_font_size", font_size)
		_panel.add_child(_label)
		
	_label.text = ""

func _on_message_logged(msg: String, type: String) -> void:
	_add_log_to_console(msg, type, Time.get_time_string_from_system())

func _sync_history() -> void:
	if not SB_Core.instance: return
	
	_messages.clear()
	for entry in SB_Core.instance.get_log_history():
		_add_log_to_console(entry.text, entry.type, entry.time)

func _add_log_to_console(msg: String, type: String, timestamp: String) -> void:
	var color_hex = color_info.to_html()
	if type == "error": color_hex = color_error.to_html()
	elif type == "success": color_hex = color_success.to_html()
	
	var formatted_msg = "[color=gray][%s][/color] [color=#%s]%s[/color]" % [timestamp, color_hex, msg]
	
	_messages.append(formatted_msg)
	
	if _messages.size() > max_messages:
		_messages.remove_at(0)
		
	_update_console_text()

func _update_console_text() -> void:
	if not _label: return
	
	_label.clear()
	for m in _messages:
		_label.append_text(m + "\n")
