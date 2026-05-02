@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
class_name SB_ScrollContainer3D
extends Node3D

## 📜 SB_ScrollContainer3D : Permet le défilement vertical 3D de ses enfants.

@export var view_height: float = 12.0
@export var scroll_speed: float = 1.0
@export var inertia: float = 0.15

var _current_scroll_y: float = 0.0
var _target_scroll_y: float = 0.0
var _original_positions: Dictionary = {}

var _is_dragging: bool = false
var _drag_start_mouse_y: float = 0.0
var _drag_start_scroll_y: float = 0.0

func _ready() -> void:
	_original_positions.clear()
	for child in get_children():
		if child is Node3D:
			_original_positions[child] = child.position

func _get_content_height() -> float:
	var min_y = INF
	var max_y = -INF
	for child in get_children():
		if child is Node3D and child.visible:
			min_y = min(min_y, child.position.y)
			max_y = max(max_y, child.position.y)
	if min_y == INF: return 0.0
	return abs(max_y - min_y) + 4.0

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	
	var content_height = _get_content_height()
	var max_scroll = max(0.0, content_height - view_height)

	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_target_scroll_y = clamp(_target_scroll_y - scroll_speed, 0.0, max_scroll)
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_target_scroll_y = clamp(_target_scroll_y + scroll_speed, 0.0, max_scroll)
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_LEFT:
				_is_dragging = true
				_drag_start_mouse_y = event.position.y
				_drag_start_scroll_y = _target_scroll_y
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_is_dragging = false

	elif event is InputEventMouseMotion and _is_dragging:
		var diff = event.position.y - _drag_start_mouse_y
		_target_scroll_y = clamp(_drag_start_scroll_y + diff * 0.05, 0.0, max_scroll)

	elif event is InputEventScreenDrag:
		_target_scroll_y = clamp(_target_scroll_y + event.relative.y * 0.05, 0.0, max_scroll)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	# Interpolation fluide
	_current_scroll_y = lerp(_current_scroll_y, _target_scroll_y, inertia)
	
	# Appliquer le défilement aux enfants
	for child in _original_positions.keys():
		if is_instance_valid(child) and child is Node3D:
			var orig_pos = _original_positions[child]
			child.position.y = orig_pos.y + _current_scroll_y
