@tool
@icon("res://stoneblock/icons/SB_Gradient3D.svg")
class_name SB_Gradient3D
extends Sprite3D

## Un composant de dégradé 3D simplifié pour le SDK StoneBlock.
## Utilise une GradientTexture2D appliquée à un Sprite3D.

enum Orientation {
	VERTICAL,
	HORIZONTAL,
	DIAGONAL_TL_BR,
	DIAGONAL_TR_BL
}

@export var color_1: Color = Color.WHITE:
	set(value):
		color_1 = value
		_update_gradient()

@export var color_2: Color = Color.BLACK:
	set(value):
		color_2 = value
		_update_gradient()

@export var orientation := Orientation.VERTICAL:
	set(value):
		orientation = value
		_update_gradient()

@export_group("Layout Helper")
## Si activé, le dégradé s'ajustera automatiquement à la taille de la caméra orthogonale.
@export var auto_fit_to_camera: bool = false:
	set(value):
		auto_fit_to_camera = value
		if auto_fit_to_camera:
			_fit_to_camera()

## (Optionnel) Spécifiez une caméra manuelle. Sinon, utilise la caméra active du Viewport.
@export var target_camera: Camera3D:
	set(value):
		target_camera = value
		if auto_fit_to_camera:
			_fit_to_camera()

func _fit_to_camera() -> void:
	if not is_inside_tree(): return
	
	var cam := target_camera
	if not cam:
		cam = get_viewport().get_camera_3d()
	
	if cam and cam.projection == Camera3D.PROJECTION_ORTHOGONAL:
		var cam_size := cam.size # Taille verticale en unités 3D
		var viewport_size = get_viewport().get_visible_rect().size
		var aspect := float(viewport_size.x) / float(viewport_size.y)
		
		# Calcul de la taille réelle du sprite à l'échelle 1.0
		var tex_size = texture.get_size()
		var unit_size_x = tex_size.x * pixel_size
		var unit_size_y = tex_size.y * pixel_size
		
		if unit_size_x > 0 and unit_size_y > 0:
			scale.y = cam_size / unit_size_y
			scale.x = (cam_size * aspect) / unit_size_x
	elif not cam and Engine.is_editor_hint():
		scale = Vector3(19.2, 10.8, 1.0)

func _init() -> void:
	# Configuration par défaut pour un sprite d'UI 3D
	centered = true
	# On s'assure d'avoir une texture de base
	if not texture:
		texture = GradientTexture2D.new()
		texture.gradient = Gradient.new()
	
	_update_gradient()

func _ready() -> void:
	_update_gradient()
	if auto_fit_to_camera:
		_fit_to_camera()
	
	# S'adapter si le viewport change de taille
	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	if auto_fit_to_camera:
		_fit_to_camera()

func _update_gradient() -> void:
	if auto_fit_to_camera:
		_fit_to_camera()
	if not texture or not texture is GradientTexture2D:
		texture = GradientTexture2D.new()
	
	var tex = texture as GradientTexture2D
	if not tex.gradient:
		tex.gradient = Gradient.new()
	
	# Mise à jour des couleurs
	tex.gradient.set_color(0, color_1)
	tex.gradient.set_color(1, color_2)
	
	# Mise à jour des points de remplissage selon l'orientation
	match orientation:
		Orientation.VERTICAL:
			tex.fill_from = Vector2(0.5, 0)
			tex.fill_to = Vector2(0.5, 1)
		Orientation.HORIZONTAL:
			tex.fill_from = Vector2(0, 0.5)
			tex.fill_to = Vector2(1, 0.5)
		Orientation.DIAGONAL_TL_BR:
			tex.fill_from = Vector2(0, 0)
			tex.fill_to = Vector2(1, 1)
		Orientation.DIAGONAL_TR_BL:
			tex.fill_from = Vector2(1, 0)
			tex.fill_to = Vector2(0, 1)
	
	# Force le rafraîchissement visuel en 3D
	notify_property_list_changed()
