@tool
extends MeshInstance3D

## 🚀 SB_BackgroundFit : Aligne et redimensionne un plan pour remplir la vue caméra.
## Mode 'Cover' : Remplit tout l'écran en conservant le ratio de l'image (recadrage si nécessaire).

@export var texture_aspect_ratio: float = 1.777 # 16:9 par défaut
@export var padding_factor: float = 1.05 # Petit surplus pour éviter les liserés noirs

func _ready() -> void:
	if not Engine.is_editor_hint():
		get_viewport().size_changed.connect(_update_size)
	
	_update_size()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_size()

func _update_size() -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera or camera.projection != Camera3D.PROJECTION_ORTHOGONAL:
		return
		
	var viewport_size = get_viewport().get_visible_rect().size
	if viewport_size.y == 0: return
	
	var screen_aspect = viewport_size.x / viewport_size.y
	
	# Taille visible de la caméra (Orthogonale)
	var v_height = camera.size
	var v_width = v_height * screen_aspect
	
	# Mode COVER : On s'adapte à la dimension la plus contraignante
	var final_w = v_width
	var final_h = v_height
	
	if screening_requires_wider_plane(screen_aspect, texture_aspect_ratio):
		# L'écran est plus large que l'image
		final_h = v_width / texture_aspect_ratio
	else:
		# L'écran est plus haut que l'image
		final_w = v_height * texture_aspect_ratio
		
	# Application au mesh ou au scale
	# Note: On utilise un Mesh de 1x1 ou on modifie le PlaneMesh
	if mesh is PlaneMesh:
		var pm = mesh as PlaneMesh
		pm.size = Vector2(final_w * padding_factor, final_h * padding_factor)
	else:
		scale = Vector3(final_w, 1, final_h)

func screening_requires_wider_plane(screen_aspect: float, tex_aspect: float) -> bool:
	return screen_aspect > tex_aspect
