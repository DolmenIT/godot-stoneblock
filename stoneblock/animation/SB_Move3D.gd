@tool
@icon("res://stoneblock/icons/SB_Move3D.svg")
class_name SB_Move3D
extends Node

## Gère des séquences de mouvements 3D via des Tweens définis par le temps.

@export_group("Target")
## Le nœud 3D à déplacer. Si vide, utilise le parent.
@export var target_node: Node3D

@export_group("Sequence")
## Liste des étapes du mouvement.
@export var steps: Array[SB_MoveStep] = []

@export_group("Trajectory Alignment")
## Décalage de rotation appliqué APRES l'alignement trajectoire (cosmétique uniquement).
## Laisser à ZERO pour un résultat prévisible : le look-ahead est calculé en espace pur.
@export var model_rotation_offset: Vector3 = Vector3.ZERO

@export_group("Playback")
@export var auto_play: bool = true
@export var loop: bool = false
@export var play_in_editor: bool = false:
	set(val):
		if play_in_editor == val: return
		play_in_editor = val
		if val and Engine.is_editor_hint():
			play_sequence()
		elif not val:
			stop_sequence()
@export var preview_final_position: bool = false:
	set(val):
		preview_final_position = val
		if Engine.is_editor_hint() and not play_in_editor:
			if val:
				_apply_final_position()
			else:
				_apply_start_position()

var _tween: Tween
var _last_global_pos: Vector3
var _last_move_dir: Vector3 = Vector3.FORWARD
var _current_banking: float = 0.0
var _elapsed_time: float = 0.0
var _sequence_duration: float = 0.0

# Previsualisation Éditeur
var _debug_mesh_instance: MeshInstance3D
var _debug_mesh: ImmediateMesh
var _debug_material: StandardMaterial3D

func _ready() -> void:
	if not target_node and get_parent() is Node3D:
		target_node = get_parent()
	
	if Engine.is_editor_hint():
		_setup_debug_mesh()
	
	if auto_play and not Engine.is_editor_hint():
		play_sequence()

func play_sequence() -> void:
	stop_sequence()
	if steps.is_empty() or not target_node:
		return
		
	_last_global_pos = target_node.global_position
	_elapsed_time = 0.0
	_sequence_duration = 0.0
	
	for step in steps:
		if step:
			_sequence_duration = max(_sequence_duration, step.end_time)
		
	_tween = create_tween()
	if loop:
		_tween.set_loops()
		
	for step in steps:
		if not step: continue
		
		var duration = step.end_time - step.start_time
		if duration <= 0: continue
		
		# Séquençage précis via parallel() et set_delay()
		var p = _tween.parallel().set_trans(step.transition_type).set_ease(step.ease_type)
		if step.use_bezier:
			p.tween_method(_evaluate_bezier.bind(step), 0.0, 1.0, duration)\
			 .set_delay(step.start_time)
		else:
			p.tween_property(target_node, "position", step.end_position, duration)\
			 .from(step.start_position)\
			 .set_delay(step.start_time)


func _evaluate_bezier(t: float, step: SB_MoveStep) -> void:
	if not target_node: return
	target_node.position = _get_step_position(step, t)

func _get_step_position(step: SB_MoveStep, t: float) -> Vector3:
	if not step.use_bezier:
		return lerp(step.start_position, step.end_position, t)
		
	var u = 1.0 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t

	var p = uuu * step.start_position
	p += 3.0 * uu * t * (step.start_position + step.control_offset_1)
	p += 3.0 * u * tt * (step.end_position + step.control_offset_2)
	p += ttt * step.end_position
	return p
	
func stop_sequence() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	play_in_editor = false

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if _debug_mesh_instance:
			_update_trajectory_mesh()
			var ei = Engine.get_singleton("EditorInterface")
			if ei and ei.get_selection():
				var selection = ei.get_selection().get_selected_nodes()
				_debug_mesh_instance.visible = (self in selection)
				
		if not play_in_editor:
			if preview_final_position:
				_apply_final_position()
			else:
				_apply_start_position()
			return

		# --- play_in_editor : tout géré manuellement, sans dépendre du Tween ---
		# _tween.is_running() n'est pas fiable dans un script @tool.
		if not target_node: return
		_elapsed_time += delta
		if _sequence_duration > 0:
			if loop:
				_elapsed_time = fmod(_elapsed_time, _sequence_duration)
			elif _elapsed_time > _sequence_duration:
				_elapsed_time = _sequence_duration

		var eval_time_ed: float = _elapsed_time
		var current_step_ed: SB_MoveStep = null
		for step in steps:
			if step and eval_time_ed >= step.start_time and eval_time_ed <= step.end_time:
				current_step_ed = step
				break

		if current_step_ed:
			var step_dur_ed := current_step_ed.end_time - current_step_ed.start_time
			var t_ed := (eval_time_ed - current_step_ed.start_time) / step_dur_ed if step_dur_ed > 0 else 0.0
			target_node.position = _get_step_position(current_step_ed, t_ed)
			_update_node_orientation(current_step_ed, t_ed, delta, true)
		return
	# --- Mode jeu : Tween gère la position, _process gère l'orientation ---
	if target_node:
		var eval_time = _elapsed_time
		if _tween and _tween.is_running():
			_elapsed_time += delta
			eval_time = _elapsed_time
			if loop and _sequence_duration > 0:
				eval_time = fmod(_elapsed_time, _sequence_duration)

		var current_step: SB_MoveStep = null
		for step in steps:
			if step and eval_time >= step.start_time and eval_time <= step.end_time:
				current_step = step
				break

		if current_step:
			var step_duration = current_step.end_time - current_step.start_time
			var current_t = (eval_time - current_step.start_time) / step_duration if step_duration > 0 else 0.0
			_update_node_orientation(current_step, current_t, delta, false)

		_last_global_pos = target_node.global_position

func _apply_final_position() -> void:
	if steps.is_empty() or not target_node: return
	
	var last_step: SB_MoveStep = null
	for i in range(steps.size() - 1, -1, -1):
		if steps[i]:
			last_step = steps[i]
			break
			
	if not last_step: return
	
	target_node.position = last_step.end_position
	_update_node_orientation(last_step, 1.0, 0.016, true)

func _apply_start_position() -> void:
	if steps.is_empty() or not target_node: return
	
	var first_step: SB_MoveStep = null
	for step in steps:
		if step:
			first_step = step
			break
			
	if not first_step: return
	
	target_node.position = first_step.start_position
	_update_node_orientation(first_step, 0.0, 0.016, true)

## Avance sur la courbe depuis [t_start] jusqu'à atteindre [target_dist] en unités monde.
## Retourne le t correspondant. Résolution : [num_steps] échantillons max.
func _find_t_at_distance(step: SB_MoveStep, t_start: float, target_dist: float, num_steps: int = 64) -> float:
	var accumulated: float = 0.0
	var t_prev: float = t_start
	var p_prev: Vector3 = _get_step_position(step, t_prev)
	var step_size: float = (1.0 - t_start) / float(num_steps)
	if step_size <= 0.0:
		return t_start
	for i in range(1, num_steps + 1):
		var t_cur: float = t_start + float(i) * step_size
		var p_cur: Vector3 = _get_step_position(step, t_cur)
		var seg_len: float = (p_cur - p_prev).length()
		accumulated += seg_len
		if accumulated >= target_dist:
			# Interpolation linéaire pour affiner le t exact
			var overshoot: float = accumulated - target_dist
			var ratio: float = 1.0 - (overshoot / seg_len) if seg_len > 1e-8 else 0.0
			return lerp(t_prev, t_cur, ratio)
		t_prev = t_cur
		p_prev = p_cur
	return 1.0

## Identique à _find_t_at_distance mais VERS L'ARRIÈRE depuis t_start.
func _find_t_before_distance(step: SB_MoveStep, t_start: float, target_dist: float, num_steps: int = 64) -> float:
	var accumulated: float = 0.0
	var t_prev: float = t_start
	var p_prev: Vector3 = _get_step_position(step, t_prev)
	var step_size: float = t_start / float(num_steps)
	if step_size <= 0.0:
		return t_start
	for i in range(1, num_steps + 1):
		var t_cur: float = t_start - float(i) * step_size
		var p_cur: Vector3 = _get_step_position(step, t_cur)
		var seg_len: float = (p_cur - p_prev).length()
		accumulated += seg_len
		if accumulated >= target_dist:
			var overshoot: float = accumulated - target_dist
			var ratio: float = 1.0 - (overshoot / seg_len) if seg_len > 1e-8 else 0.0
			return lerp(t_prev, t_cur, ratio)
		t_prev = t_cur
		p_prev = p_cur
	return 0.0

func _update_node_orientation(step: SB_MoveStep, t: float, delta: float, instant: bool = false) -> void:
	if not step or not step.align_with_trajectory: return
	if not target_node: return

	# --- 1. Calculer p_a et p_b à look_ahead_distance mètres d'écart en espace LOCAL ---
	var dist: float = step.look_ahead_distance
	var t_cur: float = clamp(t, 0.0, 1.0)
	var t_ahead: float = _find_t_at_distance(step, t_cur, dist)

	var p_a: Vector3
	var p_b: Vector3

	if t_ahead > t_cur + 1e-6:
		# Cas normal : on regarde devant
		p_a = _get_step_position(step, t_cur)
		p_b = _get_step_position(step, t_ahead)
	else:
		# En bout de courbe (t≈1) : on regarde en arrière
		var t_behind: float = _find_t_before_distance(step, t_cur, dist)
		p_a = _get_step_position(step, t_behind)
		p_b = _get_step_position(step, t_cur)

	var tangent_local: Vector3 = (p_b - p_a).normalized()
	if tangent_local.length_squared() < 0.5: return

	# --- 2. Vecteur "haut" exprimé en espace parent-local ---
	# Les positions du step sont en espace local du parent → la tangente aussi.
	# On ramène world-UP dans cet espace via la rotation inverse du parent (sans échelle).
	var up_local: Vector3 = Vector3.UP
	var parent_node := target_node.get_parent()
	if parent_node is Node3D:
		var parent_rot_inv: Basis = Basis((parent_node as Node3D).global_transform.basis.get_rotation_quaternion().inverse())
		up_local = (parent_rot_inv * Vector3.UP).normalized()
		if abs(tangent_local.dot(up_local)) > 0.99:
			up_local = (parent_rot_inv * Vector3.FORWARD).normalized()
	elif abs(tangent_local.dot(up_local)) > 0.99:
		up_local = Vector3.FORWARD

	# --- 3. Orientation directement en espace local (pas de conversion global) ---
	# Basis.looking_at sur tangente locale → q déjà en local, prêt pour transform.basis.
	var q_trajectory: Quaternion = Basis.looking_at(tangent_local, up_local, step.use_model_front).get_rotation_quaternion()

	# --- 4. Appliquer le model_rotation_offset (cosmétique) ---
	var q_offset: Quaternion = Quaternion.from_euler(Vector3(
		deg_to_rad(model_rotation_offset.x),
		deg_to_rad(model_rotation_offset.y),
		deg_to_rad(model_rotation_offset.z)
	))
	var q_final: Quaternion = q_trajectory * q_offset.inverse()

	# --- 5. Appliquer sur transform.basis (local, stable éditeur et jeu) ---
	var current_scale: Vector3 = target_node.transform.basis.get_scale()
	if instant or Engine.is_editor_hint():
		target_node.transform.basis = Basis(q_final).scaled(current_scale)
	else:
		var q_current: Quaternion = target_node.transform.basis.get_rotation_quaternion()
		var weight: float = clamp(step.rotation_speed * delta, 0.0, 1.0)
		target_node.transform.basis = Basis(q_current.slerp(q_final, weight)).scaled(current_scale)

func _setup_debug_mesh() -> void:
	if _debug_mesh_instance: return
	
	_debug_mesh = ImmediateMesh.new()
	_debug_mesh_instance = MeshInstance3D.new()
	_debug_mesh_instance.mesh = _debug_mesh
	_debug_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	_debug_material = StandardMaterial3D.new()
	_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_debug_material.vertex_color_use_as_albedo = true
	_debug_material.albedo_color = Color(0.2, 0.8, 1.0, 0.8)
	_debug_mesh_instance.material_override = _debug_material
	
	_debug_mesh_instance.top_level = true
	add_child(_debug_mesh_instance)

func _update_trajectory_mesh() -> void:
	if not _debug_mesh: return
	
	_debug_mesh.clear_surfaces()
	if steps.is_empty() or not target_node: return
	
	_debug_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var parent_transform = Transform3D()
	if target_node.get_parent() is Node3D:
		parent_transform = target_node.get_parent().global_transform
	
	for step in steps:
		if not step: continue
		
		var p0 = parent_transform * step.start_position
		var p3 = parent_transform * step.end_position
		
		if step.use_bezier:
			var segments = 16
			var prev_point = p0
			var global_p1 = parent_transform * (step.start_position + step.control_offset_1)
			var global_p2 = parent_transform * (step.end_position + step.control_offset_2)
			
			for i in range(1, segments + 1):
				var t = float(i) / float(segments)
				var u = 1.0 - t
				var tt = t * t
				var uu = u * u
				
				var current_point = (uu * u * p0) + (3.0 * uu * t * global_p1) + (3.0 * u * tt * global_p2) + (tt * t * p3)
				
				_debug_mesh.surface_set_color(Color.AQUA)
				_debug_mesh.surface_add_vertex(prev_point)
				_debug_mesh.surface_set_color(Color.AQUA)
				_debug_mesh.surface_add_vertex(current_point)
				
				prev_point = current_point
		else:
			_debug_mesh.surface_set_color(Color(0.2, 1.0, 0.4, 0.5))
			_debug_mesh.surface_add_vertex(p0)
			_debug_mesh.surface_set_color(Color(0.2, 1.0, 0.4, 0.5))
			_debug_mesh.surface_add_vertex(p3)

	_debug_mesh.surface_end()
