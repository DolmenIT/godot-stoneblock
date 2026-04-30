@tool
@icon("res://gdk-stoneblock/assets/icons/SB_UI.svg")
extends Node3D
class_name SB_StaticContainer3D

## 📦 SB_StaticContainer3D : Un conteneur 3D flexible Statique.
## Version optimisée qui ne range ses enfants que sur demande (via bouton ou script).

enum LayoutDirection { HORIZONTAL, VERTICAL }
enum Align { START, CENTER, END }
enum YDirection { NORMAL_Y, INVERSED_Y }

@export_group("Flex Settings")
## Force le rangement immédiat des enfants.
@export var arrange_now: bool = false:
	set(v): if v: _perform_layout()

## Ajuste automatiquement max_size au contenu actuel.
@export var fit_to_content: bool = false:
	set(v): if v: _do_fit_to_content()

## Direction principale du flux (Ligne ou Colonne).
@export var layout_direction: LayoutDirection = LayoutDirection.HORIZONTAL

## Taille maximale avant de passer à la ligne/colonne suivante.
@export var max_size: Vector2 = Vector2(10.0, 10.0)

## Espacement entre les éléments (X: horizontal, Y: vertical).
@export var gap: Vector2 = Vector2(0.5, 0.5)

## Système de coordonnées Y (Inversed = Y- vers le bas comme une UI, Normal = Y+ vers le haut).
@export var y_direction: YDirection = YDirection.INVERSED_Y

@export_group("Alignment")
## Alignement sur l'axe principal (ex: Gauche/Centre/Droite pour HORIZONTAL).
@export var main_align: Align = Align.START

## Alignement sur l'axe secondaire (ex: Haut/Centre/Bas pour chaque ligne).
@export var cross_align: Align = Align.START

@export_group("Editor")
@export var show_gizmo: bool = true:
	set(v): show_gizmo = v; _update_gizmo()
@export var gizmo_color: Color = Color(1.0, 0.5, 0.0, 0.5):
	set(v): gizmo_color = v; _update_gizmo()

var _gizmo_mesh: MeshInstance3D
var _last_layout_lines: Array = []

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_gizmo()
	else:
		# En jeu, on ne fait RIEN automatiquement. 
		# On se fie au placement fait dans l'éditeur.
		pass

func _perform_layout() -> void:
	if not is_inside_tree(): return
	
	var children = []
	for c in get_children():
		if c is Node3D and c != _gizmo_mesh and c.visible:
			children.append(c)
			
	if Engine.is_editor_hint():
		_update_gizmo()
		
	if children.is_empty(): return
	
	# 1. Pré-calculer les tailles des enfants
	var items = []
	for c in children:
		var container_aabb = AABB()
		var size_found = false
		
		# Priorité aux propriétés explicites des composants UI (SB_Button_3d, SB_Image3D, etc.)
		if "mesh_size" in c and typeof(c.get("mesh_size")) == TYPE_VECTOR2:
			var ms = c.get("mesh_size")
			container_aabb = AABB(Vector3(-ms.x / 2.0, -ms.y / 2.0, 0), Vector3(ms.x, ms.y, 0))
			size_found = true
		elif "size" in c and typeof(c.get("size")) == TYPE_VECTOR2:
			var sz = c.get("size")
			container_aabb = AABB(Vector3(-sz.x / 2.0, -sz.y / 2.0, 0), Vector3(sz.x, sz.y, 0))
			size_found = true
			
		if size_found:
			var basis_transform = Transform3D(c.transform.basis, Vector3.ZERO)
			container_aabb = basis_transform * container_aabb
		else:
			# Fallback sur l'AABB visuel (Meshes enfants)
			var local_aabb = _get_combined_local_aabb(c)
			var basis_transform = Transform3D(c.transform.basis, Vector3.ZERO)
			container_aabb = basis_transform * local_aabb
		
		# On gère le cas où l'AABB est vide
		if container_aabb.size.x <= 0.001 and container_aabb.size.y <= 0.001:
			container_aabb.size = Vector3(0.01, 0.01, 0.01)
			
		var size_2d = Vector2(container_aabb.size.x, container_aabb.size.y)
		items.append({ "node": c, "size": size_2d, "aabb": container_aabb })
		
	# 2. Moteur de layout (Wrap)
	var lines = []
	var current_line = []
	var current_line_size = 0.0
	var current_line_cross = 0.0
	
	var max_main = max_size.x if layout_direction == LayoutDirection.HORIZONTAL else max_size.y
	
	for item in items:
		var main_dim = item.size.x if layout_direction == LayoutDirection.HORIZONTAL else item.size.y
		var cross_dim = item.size.y if layout_direction == LayoutDirection.HORIZONTAL else item.size.x
		var main_gap = gap.x if layout_direction == LayoutDirection.HORIZONTAL else gap.y
		
		# Vérifier si on doit passer à la ligne
		if current_line.size() > 0 and (current_line_size + main_gap + main_dim) > max_main:
			lines.append({"items": current_line, "main_size": current_line_size, "cross_size": current_line_cross})
			current_line = []
			current_line_size = 0.0
			current_line_cross = 0.0
			
		current_line.append(item)
		if current_line.size() > 1:
			current_line_size += main_gap
		current_line_size += main_dim
		current_line_cross = maxf(current_line_cross, cross_dim)
		
	if current_line.size() > 0:
		lines.append({"items": current_line, "main_size": current_line_size, "cross_size": current_line_cross})
		
	_last_layout_lines = lines # Sauvegarder pour le gizmo
	
	# 3. Placement
	var current_cross_pos = 0.0
	var cross_gap = gap.y if layout_direction == LayoutDirection.HORIZONTAL else gap.x
	
	for line in lines:
		var start_main_pos = 0.0
		if main_align == Align.CENTER:
			start_main_pos = (max_main - line.main_size) / 2.0
		elif main_align == Align.END:
			start_main_pos = max_main - line.main_size
			
		var current_main_pos = start_main_pos
		var main_gap = gap.x if layout_direction == LayoutDirection.HORIZONTAL else gap.y
		
		for item in line.items:
			var main_dim = item.size.x if layout_direction == LayoutDirection.HORIZONTAL else item.size.y
			var cross_dim = item.size.y if layout_direction == LayoutDirection.HORIZONTAL else item.size.x
			
			var offset_cross = 0.0
			if cross_align == Align.CENTER:
				offset_cross = (line.cross_size - cross_dim) / 2.0
			elif cross_align == Align.END:
				offset_cross = line.cross_size - cross_dim
				
			var pos_x = 0.0
			var pos_y = 0.0
			
			if layout_direction == LayoutDirection.HORIZONTAL:
				pos_x = current_main_pos
				pos_y = current_cross_pos + offset_cross
			else:
				pos_y = current_main_pos
				pos_x = current_cross_pos + offset_cross
				
			var child_left_x = item.aabb.position.x
			var child_top_y = item.aabb.position.y + item.aabb.size.y
			
			var layout_y_dir = 1.0 if y_direction == YDirection.NORMAL_Y else -1.0
			
			var target_x = pos_x
			var target_y = pos_y * layout_y_dir
			
			var final_x = target_x - child_left_x
			var final_y = target_y - child_top_y
				
			item.node.position = Vector3(final_x, final_y, item.node.position.z)
			
			current_main_pos += main_dim + main_gap
			
		current_cross_pos += line.cross_size + cross_gap
	
	arrange_now = false
	notify_property_list_changed()

func _do_fit_to_content() -> void:
	# On s'assure que le layout est à jour (synchrone cette fois)
	_perform_layout()
	
	if _last_layout_lines.is_empty(): return
	
	var total_main = 0.0
	var total_cross = 0.0
	
	var cross_gap = gap.y if layout_direction == LayoutDirection.HORIZONTAL else gap.x
	
	for i in range(_last_layout_lines.size()):
		var line = _last_layout_lines[i]
		total_main = maxf(total_main, line.main_size)
		total_cross += line.cross_size
		if i > 0:
			total_cross += cross_gap
	
	# On applique la nouvelle taille
	if layout_direction == LayoutDirection.HORIZONTAL:
		max_size = Vector2(total_main, total_cross)
	else:
		max_size = Vector2(total_cross, total_main)
	
	# On force une notification de changement pour l'inspecteur et on reset le bouton
	fit_to_content = false
	notify_property_list_changed()

func _get_combined_local_aabb(node: Node3D) -> AABB:
	var combined = AABB()
	var first = true
	var stack = [node]
	
	# Transformée inverse pour passer du global de l'enfant vers son local
	var origin_inv = node.global_transform.affine_inverse()
	
	while stack.size() > 0:
		var current = stack.pop_back()
		if current is VisualInstance3D:
			var aabb = current.get_aabb()
			var local_transform = origin_inv * current.global_transform
			var transformed_aabb = local_transform * aabb
			if first:
				combined = transformed_aabb
				first = false
			else:
				combined = combined.merge(transformed_aabb)
		for child in current.get_children():
			if child is Node3D:
				stack.push_back(child)
				
	return combined

func _update_gizmo() -> void:
	if not Engine.is_editor_hint():
		if _gizmo_mesh: _gizmo_mesh.queue_free()
		return

	# 1. Nettoyage des orphelins (fantômes de scripts précédents ou crashs)
	for child in get_children():
		if child.name == "EditorGizmo" and child != _gizmo_mesh:
			child.queue_free()

	# 2. Gestion de la visibilité
	if not show_gizmo:
		if _gizmo_mesh: _gizmo_mesh.visible = false
		return
		
	# 3. Récupération ou création du gizmo
	if not _gizmo_mesh:
		_gizmo_mesh = get_node_or_null("EditorGizmo")
		if not _gizmo_mesh:
			_gizmo_mesh = MeshInstance3D.new()
			_gizmo_mesh.name = "EditorGizmo"
			_gizmo_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_gizmo_mesh.set_meta("_edit_lock_", true)
			add_child(_gizmo_mesh)
	
	_gizmo_mesh.visible = true
	var mesh = ImmediateMesh.new()
	_gizmo_mesh.mesh = mesh
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = gizmo_color
	mat.no_depth_test = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var w = max_size.x
	var h = max_size.y
	var layout_y_dir = 1.0 if y_direction == YDirection.NORMAL_Y else -1.0
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	
	# Cadre extérieur
	var corners = [
		Vector3(0, 0, 0),
		Vector3(w, 0, 0),
		Vector3(w, h * layout_y_dir, 0),
		Vector3(0, h * layout_y_dir, 0)
	]
	
	mesh.surface_add_vertex(corners[0]); mesh.surface_add_vertex(corners[1])
	mesh.surface_add_vertex(corners[1]); mesh.surface_add_vertex(corners[2])
	mesh.surface_add_vertex(corners[2]); mesh.surface_add_vertex(corners[3])
	mesh.surface_add_vertex(corners[3]); mesh.surface_add_vertex(corners[0])
	
	# Dessin des lignes de séparation réelles (Rows / Columns)
	var current_cross = 0.0
	var cross_gap = gap.y if layout_direction == LayoutDirection.HORIZONTAL else gap.x
	
	# On ne dessine pas la première ligne (déjà faite par le cadre)
	for i in range(len(_last_layout_lines)):
		var line = _last_layout_lines[i]
		current_cross += line.cross_size
		
		# Ligne de séparation
		var line_y = current_cross * layout_y_dir
		if layout_direction == LayoutDirection.HORIZONTAL:
			if abs(line_y) < h: # Ne pas dessiner si ça sort du cadre
				mesh.surface_add_vertex(Vector3(0, line_y, 0))
				mesh.surface_add_vertex(Vector3(w, line_y, 0))
		else:
			if abs(line_y) < w:
				mesh.surface_add_vertex(Vector3(line_y, 0, 0))
				mesh.surface_add_vertex(Vector3(line_y, h * layout_y_dir, 0))
				
		current_cross += cross_gap

	mesh.surface_end()
