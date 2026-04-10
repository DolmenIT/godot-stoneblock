extends Node3D
class_name SB_CanvasLayer3D

## 🎨 SB_CanvasLayer3D : Un calque de dessin 3D.
## Gère la surface de dessin et le moteur de peinture GPU.

@export_group("Dimension Settings")
## Résolution de la texture de dessin (Albedo).
@export var canvas_resolution: Vector2i = Vector2i(1024, 1024)
## Taille physique du calque en mètres Godot (Ratio A4 Landscape approx).
@export var physical_size: Vector2 = Vector2(14.14, 10.0)

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var viewport: SubViewport = $SubViewport
@onready var paint_rect: ColorRect = $SubViewport/PaintRect

var _is_setup: bool = false

func _ready() -> void:
	_setup_canvas()

## 🛰️ Configure les nœuds nécessaires pour le rendu GPU.
func _setup_canvas() -> void:
	if _is_setup: return
	
	# 1. Configuration du Viewport (Moteur de peinture)
	viewport.size = canvas_resolution
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# 2. Configuration du Mesh (Surface 3D)
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = physical_size
	plane_mesh.subdivide_depth = 64 # Pour l'anticipation de la sculpture
	plane_mesh.subdivide_width = 64
	mesh_instance.mesh = plane_mesh
	
	# Mise à jour de la collision pour le raycasting
	var col_shape = $StaticBody3D/CollisionShape3D.shape as BoxShape3D
	if col_shape:
		col_shape.size = Vector3(physical_size.x, 0.1, physical_size.y)
	
	# 3. Création du matériau spatial
	var lap_mat = ShaderMaterial.new()
	lap_mat.shader = load("res://demo/demo2/shaders/layer_view.gdshader")
	lap_mat.set_shader_parameter("albedo_map", viewport.get_texture())
	mesh_instance.set_surface_override_material(0, lap_mat)
	
	# 4. Configuration du PaintRect (Shader de pinceau)
	var paint_mat = ShaderMaterial.new()
	paint_mat.shader = load("res://demo/demo2/shaders/brush_paint.gdshader")
	paint_rect.material = paint_mat
	paint_rect.size = canvas_resolution
	
	_is_setup = true

## 🖌️ Peint sur le calque à des coordonnées UV (0-1).
func paint(uv_pos: Vector2, size: float, strength: float, color: Color) -> void:
	var mat = paint_rect.material as ShaderMaterial
	mat.set_shader_parameter("brush_pos", uv_pos)
	mat.set_shader_parameter("brush_size", size)
	mat.set_shader_parameter("brush_strength", strength)
	mat.set_shader_parameter("brush_color", color)
	mat.set_shader_parameter("is_drawing", true)

## 🛑 Arrête le flux de dessin (pour éviter de peindre en continu à la même position).
func stop_painting() -> void:
	var mat = paint_rect.material as ShaderMaterial
	mat.set_shader_parameter("is_drawing", false)

## 🧹 Efface le calque.
func clear_canvas() -> void:
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
