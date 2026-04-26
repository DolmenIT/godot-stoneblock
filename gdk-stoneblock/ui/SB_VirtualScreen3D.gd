@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Viewport.svg")
extends Node3D
class_name SB_VirtualScreen3D

## 📺 SB_VirtualScreen3D : Définit un plan de travail virtuel pour l'interface 3D.
## Les SB_ScreenAnchor3D peuvent s'y référer pour se placer.

@export var size: Vector2 = Vector2(88, 50):
	set(v): size = v; _update_gizmo()

@export_group("Editor")
## Couleur du cadre dans l'éditeur.
@export var border_color: Color = Color(0.2, 0.6, 1.0, 0.5):
	set(v): border_color = v; _update_gizmo()

var _gizmo_mesh: MeshInstance3D

func _ready() -> void:
	# Désactive la sélection par clic dans la vue 3D
	# Note: Node3D n'a pas input_ray_pickable, mais on peut s'assurer 
	# que les meshes internes ne le sont pas.
	_update_gizmo()

func _update_gizmo() -> void:
	if not Engine.is_editor_hint():
		if _gizmo_mesh: _gizmo_mesh.queue_free()
		return

	if not _gizmo_mesh:
		_gizmo_mesh = MeshInstance3D.new()
		_gizmo_mesh.name = "EditorGizmo"
		_gizmo_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_gizmo_mesh.set_meta("_edit_lock_", true) # Aide à ne pas le bouger par erreur
		add_child(_gizmo_mesh)
	
	var mesh = ImmediateMesh.new()
	_gizmo_mesh.mesh = mesh
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = border_color
	mat.no_depth_test = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var w = size.x / 2.0
	var h = size.y / 2.0
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	# Cadre extérieur
	mesh.surface_add_vertex(Vector3(-w, -h, 0)); mesh.surface_add_vertex(Vector3(w, -h, 0))
	mesh.surface_add_vertex(Vector3(w, -h, 0)); mesh.surface_add_vertex(Vector3(w, h, 0))
	mesh.surface_add_vertex(Vector3(w, h, 0)); mesh.surface_add_vertex(Vector3(-w, h, 0))
	mesh.surface_add_vertex(Vector3(-w, h, 0)); mesh.surface_add_vertex(Vector3(-w, -h, 0))
	
	# Indicateur "HAUT" (petit triangle au centre haut)
	mesh.surface_add_vertex(Vector3(-1, h, 0)); mesh.surface_add_vertex(Vector3(0, h+1, 0))
	mesh.surface_add_vertex(Vector3(0, h+1, 0)); mesh.surface_add_vertex(Vector3(1, h, 0))
	
	# Croix centrale
	mesh.surface_add_vertex(Vector3(-0.5, 0, 0)); mesh.surface_add_vertex(Vector3(0.5, 0, 0))
	mesh.surface_add_vertex(Vector3(0, -0.5, 0)); mesh.surface_add_vertex(Vector3(0, 0.5, 0))
	
	mesh.surface_end()

func get_anchor_pos(anchor_factor: Vector2) -> Vector3:
	# anchor_factor: (0,0) = TopLeft, (1,1) = BottomRight
	# On convertit vers l'espace 3D Local (Centre = 0,0, Y+ = Haut)
	var x = (anchor_factor.x - 0.5) * size.x
	var y = (0.5 - anchor_factor.y) * size.y
	return Vector3(x, y, 0)
