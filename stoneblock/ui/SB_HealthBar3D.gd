@tool
extends Node3D
class_name SB_HealthBar3D

## 🏥 SB_HealthBar3D : Composant de barre de vie 3D avec fond et ancrage à gauche.

@export var value: float = 100.0 : set = set_value
@export var max_value: float = 100.0 : set = set_max_value

@export_group("Visuals")
@export var size: Vector2 = Vector2(3.0, 0.2) : set = set_size
@export var background_color: Color = Color(0, 0, 0, 0.7) : set = set_bg_color
@export var show_text: bool = true : set = set_show_text
@export var text_pixel_size: float = 0.01 : set = set_text_size

var _bg_mesh: MeshInstance3D
var _fg_mesh: MeshInstance3D
var _label: Label3D

func _ready() -> void:
	_setup_nodes()
	_update_visuals()

func _setup_nodes() -> void:
	# 1. Fond
	if not _bg_mesh:
		_bg_mesh = MeshInstance3D.new()
		_bg_mesh.name = "Background"
		add_child(_bg_mesh)
		
		var mat = StandardMaterial3D.new()
		mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
		mat.no_depth_test = true
		mat.render_priority = 18
		mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
		_bg_mesh.material_override = mat

	# 2. Barre de progression
	if not _fg_mesh:
		_fg_mesh = MeshInstance3D.new()
		_fg_mesh.name = "Foreground"
		add_child(_fg_mesh)
		
		var mat = StandardMaterial3D.new()
		mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
		mat.no_depth_test = true
		mat.render_priority = 19
		_fg_mesh.material_override = mat

	# 3. Label
	if not _label:
		_label = Label3D.new()
		_label.name = "HealthLabel"
		_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_label.no_depth_test = true
		_label.render_priority = 20
		add_child(_label)

func _update_visuals() -> void:
	if not is_node_ready(): return
	
	var ratio = clamp(value / max_value, 0.0, 1.0)
	
	# Mise à jour des meshs
	var bg_m = BoxMesh.new()
	bg_m.size = Vector3(size.x, size.y, 0.1)
	_bg_mesh.mesh = bg_m
	_bg_mesh.material_override.albedo_color = background_color
	
	var fg_m = BoxMesh.new()
	fg_m.size = Vector3(size.x, size.y, 0.1) # On garde la taille max, on scalera l'instance
	_fg_mesh.mesh = fg_m
	
	# Couleur de la barre
	if ratio > 0.5:
		_fg_mesh.material_override.albedo_color = Color.GREEN
	elif ratio > 0.2:
		_fg_mesh.material_override.albedo_color = Color.YELLOW
	else:
		_fg_mesh.material_override.albedo_color = Color.RED
		
	# LOGIQUE D'ANCRAGE À GAUCHE
	_fg_mesh.scale.x = ratio
	# Calcul du centre pour que le bord gauche reste à -size.x/2
	_fg_mesh.position.x = (size.x / 2.0) * (ratio - 1.0)
	
	# Mise à jour du texte
	_label.visible = show_text
	_label.text = str(ceili(value)) + " / " + str(ceili(max_value))
	_label.pixel_size = text_pixel_size
	_label.position.y = 0.05 # Léger décollage pour éviter le Z-fighting
	_label.position.z = -0.6 # Au-dessus de la barre sur l'écran (Top-Down)

# -- Setters --
func set_value(v: float) -> void:
	value = v
	_update_visuals()

func set_max_value(v: float) -> void:
	max_value = v
	_update_visuals()

func set_size(v: Vector2) -> void:
	size = v
	_update_visuals()

func set_bg_color(v: Color) -> void:
	background_color = v
	if _bg_mesh: _bg_mesh.material_override.albedo_color = v

func set_show_text(v: bool) -> void:
	show_text = v
	if _label: _label.visible = v

func set_text_size(v: float) -> void:
	text_pixel_size = v
	if _label: _label.pixel_size = v
