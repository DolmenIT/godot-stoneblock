@tool
extends Node3D
class_name SB_CanvasLayer3D

## Gère un calque de dessin 3D individuel.
## Version 'Silk Smooth' PRO : Supporte désormais les styles artistiques (Douceur, Grain).

@export_group("Dimensions Physiques")
@export var physical_size_mm: Vector2 = Vector2(297, 210) # A4 Paysage par défaut
@export var dpi: int = 300 # 300 DPI pour qualité d'impression

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var canvas_resolution: Vector2i
var image: Image
var texture: ImageTexture
var brush_image: Image # Stamp de brosse anti-aliasé
var current_brush_radius: float = -1.0 
var current_brush_color: Color = Color.TRANSPARENT
var current_brush_softness: float = 0.5
var current_brush_grain: float = 0.0

var _is_setup: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_setup_canvas()

## Calcule la résolution et initialise les ressources.
func _setup_canvas() -> void:
	if _is_setup: return
	
	var px_w = int((physical_size_mm.x / 25.4) * dpi)
	var px_h = int((physical_size_mm.y / 25.4) * dpi)
	canvas_resolution = Vector2i(px_w, px_h)
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = physical_size_mm / 10.0
	mesh_instance.mesh = plane_mesh
	
	var col_shape = $StaticBody3D/CollisionShape3D.shape as BoxShape3D
	if col_shape:
		col_shape.size = Vector3(plane_mesh.size.x, 0.1, plane_mesh.size.y)
	
	image = Image.create(canvas_resolution.x, canvas_resolution.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	
	texture = ImageTexture.create_from_image(image)
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = texture
	mesh_instance.set_surface_override_material(0, mat)
	
	_is_setup = true
	print("🚀 [MockupFlow] Moteur ARTISTIQUE prêt : %dx%d" % [px_w, px_h])

## 🖌️ Peint sur le calque avec support des styles artistiques.
func paint(uv_curr: Vector2, uv_prev: Vector2, size_mm: float, pressure_curr: float, pressure_prev: float, color: Color, softness: float = 0.5, grain: float = 0.0) -> void:
	if not _is_setup: return
	
	var pos_curr = uv_curr * Vector2(canvas_resolution)
	
	if uv_prev.x < 0:
		var p = clamp(pressure_curr * 0.2, 0.05, 0.15)
		var r = (size_mm / 25.4) * dpi * p
		_update_brush_stamp(r, color, softness, grain)
		_draw_stamp(pos_curr)
	else:
		var pos_prev = uv_prev * Vector2(canvas_resolution)
		var dist = pos_prev.distance_to(pos_curr)
		
		# Interpolation haute densité
		var steps = ceil(dist / 1.0)
		if steps < 1: steps = 1
		
		for i in range(steps + 1):
			var t = float(i) / float(steps)
			var interp_pressure = lerp(pressure_prev, pressure_curr, t)
			interp_pressure = max(0.05, interp_pressure)
			
			var r = (size_mm / 25.4) * dpi * interp_pressure
			_update_brush_stamp(r, color, softness, grain)
			_draw_stamp(pos_prev.lerp(pos_curr, t))
	
	texture.update(image)

## 🎯 Calcule l'UV (0-1) à partir d'une position locale 3D.
func get_uv_from_local(local_pos: Vector3) -> Vector2:
	var half_w = (physical_size_mm.x / 10.0) / 2.0
	var half_h = (physical_size_mm.y / 10.0) / 2.0
	var uv_x = (local_pos.x + half_w) / (half_w * 2.0)
	var uv_y = (local_pos.z + half_h) / (half_h * 2.0)
	return Vector2(clamp(uv_x, 0, 1), clamp(uv_y, 0, 1))

func _draw_stamp(center: Vector2) -> void:
	var b_size = brush_image.get_width()
	var offset = Vector2i(center) - Vector2i(int(b_size / 2.0), int(b_size / 2.0))
	image.blend_rect(brush_image, Rect2i(0, 0, b_size, b_size), offset)

## 🎨 Génère le stamp avec SOFTNESS (AA dynamique) et GRAIN (Bruit).
func _update_brush_stamp(radius_px: float, color: Color, softness: float, grain: float) -> void:
	if abs(radius_px - current_brush_radius) < 0.02 \
		and color == current_brush_color \
		and softness == current_brush_softness \
		and grain == current_brush_grain:
		return
		
	current_brush_radius = radius_px
	current_brush_color = color
	current_brush_softness = softness
	current_brush_grain = grain
	
	var size = int(ceil(radius_px * 2.0)) + 6
	if size < 1: size = 1
	
	brush_image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = Vector2(size / 2.0, size / 2.0)
	
	# Paramètre de flou basé sur la softness (0 = net, 1 = très flou)
	var falloff_width = 1.0 + (softness * radius_px * 1.5)
	
	for y in range(size):
		for x in range(size):
			var dist = (Vector2(x, y) - center).length()
			
			if dist <= radius_px + falloff_width:
				# Calcul de l'alpha avec Falloff dynamique
				var alpha = clamp(1.0 - (dist - (radius_px - 0.5)) / falloff_width, 0.0, 1.0)
				alpha = alpha * alpha * (3.0 - 2.0 * alpha) # Soft Step
				
				# Ajout du GRAIN
				if grain > 0:
					var noise = randf() * grain * 0.5
					alpha = clamp(alpha - noise, 0.0, 1.0)
				
				var pixel_color = color
				pixel_color.a *= alpha
				brush_image.set_pixel(x, y, pixel_color)

func stop_painting() -> void: pass
func clear_canvas() -> void:
	image.fill(Color.WHITE)
	texture.update(image)
