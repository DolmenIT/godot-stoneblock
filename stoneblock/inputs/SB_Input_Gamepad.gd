@tool
extends Node
class_name SB_Input_Gamepad

## 🎮 SB_Input_Gamepad : Dispatcher d'entrées Gamepad (Mode No-Code).
## Résout les cibles dynamiquement par NOM dans la scène.

# --- Configuration Générale ---
@export_group("Globals")
@export var device_id: int = 0
@export var deadzone: float = 0.2

# --- STICKS ---
@export_group("Sticks")
@export_subgroup("Left Stick")
@export var left_stick_x_target_name: String = ""
@export var left_stick_x_method: String = "set_input_vector_x"
@export var left_stick_y_target_name: String = ""
@export var left_stick_y_method: String = "set_input_vector_y"
@export var left_stick_click_target_name: String = ""
@export var left_stick_click_method: String = ""

@export_subgroup("Right Stick")
@export var right_stick_x_target_name: String = ""
@export var right_stick_x_method: String = ""
@export var right_stick_y_target_name: String = ""
@export var right_stick_y_method: String = ""
@export var right_stick_click_target_name: String = ""
@export var right_stick_click_method: String = ""

# --- BOUTONS DE FACE ---
@export_group("Buttons")
@export_subgroup("Face Buttons")
@export var button_a_target_name: String = ""
@export var button_a_method: String = "set_firing"
@export var button_b_target_name: String = ""
@export var button_b_method: String = ""
@export var button_x_target_name: String = ""
@export var button_x_method: String = "set_dash"
@export var button_y_target_name: String = ""
@export var button_y_method: String = ""

# --- D-PAD ---
@export_subgroup("D-Pad")
@export var dpad_up_target_name: String = ""
@export var dpad_up_method: String = ""
@export var dpad_down_target_name: String = ""
@export var dpad_down_method: String = ""
@export var dpad_left_target_name: String = ""
@export var dpad_left_method: String = ""
@export var dpad_right_target_name: String = ""
@export var dpad_right_method: String = ""

# --- GÂCHETTES & BUMPERS ---
@export_subgroup("Bumpers & Triggers")
@export var l1_bumper_target_name: String = ""
@export var l1_bumper_method: String = ""
@export var r1_bumper_target_name: String = ""
@export var r1_bumper_method: String = ""
@export var l2_trigger_target_name: String = ""
@export var l2_trigger_method: String = ""
@export var r2_trigger_target_name: String = ""
@export var r2_trigger_method: String = ""

# --- SYSTÈME ---
@export_subgroup("System")
@export var start_pause_target_name: String = ""
@export var start_pause_method: String = ""
@export var select_menu_target_name: String = ""
@export var select_menu_method: String = ""

# Cache pour éviter de chercher dans l'arbre à chaque frame
var _node_cache: Dictionary = {}

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# --- Axes ---
	_dispatch_axis(JOY_AXIS_LEFT_X, left_stick_x_target_name, left_stick_x_method)
	_dispatch_axis(JOY_AXIS_LEFT_Y, left_stick_y_target_name, left_stick_y_method)
	_dispatch_axis(JOY_AXIS_RIGHT_X, right_stick_x_target_name, right_stick_x_method)
	_dispatch_axis(JOY_AXIS_RIGHT_Y, right_stick_y_target_name, right_stick_y_method)
	_dispatch_axis(JOY_AXIS_TRIGGER_LEFT, l2_trigger_target_name, l2_trigger_method)
	_dispatch_axis(JOY_AXIS_TRIGGER_RIGHT, r2_trigger_target_name, r2_trigger_method)
	
	# --- Boutons ---
	_dispatch_button(JOY_BUTTON_A, button_a_target_name, button_a_method)
	_dispatch_button(JOY_BUTTON_B, button_b_target_name, button_b_method)
	_dispatch_button(JOY_BUTTON_X, button_x_target_name, button_x_method)
	_dispatch_button(JOY_BUTTON_Y, button_y_target_name, button_y_method)
	
	_dispatch_button(JOY_BUTTON_LEFT_SHOULDER, l1_bumper_target_name, l1_bumper_method)
	_dispatch_button(JOY_BUTTON_RIGHT_SHOULDER, r1_bumper_target_name, r1_bumper_method)
	_dispatch_button(JOY_BUTTON_LEFT_STICK, left_stick_click_target_name, left_stick_click_method)
	_dispatch_button(JOY_BUTTON_RIGHT_STICK, right_stick_click_target_name, right_stick_click_method)
	
	_dispatch_button(JOY_BUTTON_DPAD_UP, dpad_up_target_name, dpad_up_method)
	_dispatch_button(JOY_BUTTON_DPAD_DOWN, dpad_down_target_name, dpad_down_method)
	_dispatch_button(JOY_BUTTON_DPAD_LEFT, dpad_left_target_name, dpad_left_method)
	_dispatch_button(JOY_BUTTON_DPAD_RIGHT, dpad_right_target_name, dpad_right_method)
	
	_dispatch_button(JOY_BUTTON_START, start_pause_target_name, start_pause_method)
	_dispatch_button(JOY_BUTTON_BACK, select_menu_target_name, select_menu_method)

func _get_target_node(node_name: String) -> Node:
	if node_name == "": return null
	
	# Vérifier le cache (si le nœud est toujours valide)
	if _node_cache.has(node_name) and is_instance_valid(_node_cache[node_name]):
		return _node_cache[node_name]
	
	# Recherche dans l'arbre
	var target = get_tree().root.find_child(node_name, true, false)
	if target:
		_node_cache[node_name] = target
		# Auto-activation de l'input externe si disponible
		if "use_external_input" in target:
			target.use_external_input = true
	return target

func _dispatch_axis(axis: JoyAxis, node_name: String, method: String) -> void:
	if node_name == "" or method == "": return
	var target = _get_target_node(node_name)
	if not target: return
	
	var val = Input.get_joy_axis(device_id, axis)
	if abs(val) < deadzone:
		val = 0.0
	else:
		val = sign(val) * ((abs(val) - deadzone) / (1.0 - deadzone))
	
	if target.has_method(method):
		target.call(method, val)

func _dispatch_button(button: JoyButton, node_name: String, method: String) -> void:
	if node_name == "" or method == "": return
	var target = _get_target_node(node_name)
	if not target: return
	
	var is_pressed = Input.is_joy_button_pressed(device_id, button)
	if target.has_method(method):
		target.call(method, is_pressed)
