@tool
class_name SB_Image3D
extends Node3D

## 🖼️ SB_Image3D : Affiche une image 2D dans l'espace 3D avec gestion intelligente du ratio.
## Remplace et étend les fonctionnalités de SB_BackgroundFit.

enum SBViewMode { FRONT, TOP_DOWN }
enum SBStretchMode { STRETCH, COVER }

@export_group("Texture")
## La texture à afficher.
@export var texture: Texture2D:
	set(v): texture = v; _update_visual()
## Teinte de l'image.
@export var albedo_color: Color = Color.WHITE:
	set(v): albedo_color = v; _update_visual()

@export_group("Layout")
## Orientation de l'image (FRONT = face caméra, TOP_DOWN = au sol).
@export var view_mode: SBViewMode = SBViewMode.FRONT:
	set(v): view_mode = v; _update_visual()
## Mode d'étirement (STRETCH = étiré, COVER = remplissage avec ratio).
@export var stretch_mode: SBStretchMode = SBStretchMode.STRETCH:
	set(v): stretch_mode = v; _update_visual()
## Dimensions manuelles de l'image (si auto_fit_camera est désactivé).
@export var size: Vector2 = Vector2(350, 200):
	set(v): size = v; _update_visual()
## Si activé, redimensionne automatiquement l'image pour remplir la vue caméra (mode fond d'écran).
@export var auto_fit_camera: bool = false:
	set(v): auto_fit_camera = v; _update_visual()

const SHADER_CODE: String = """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_texture : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform int stretch_mode = 0; // 0 = Stretch, 1 = Cover
uniform vec2 real_size;
uniform vec2 tex_size;

void fragment() {
	vec2 final_uv = UV;
	
	if (stretch_mode == 1 && tex_size.x > 0.0 && tex_size.y > 0.0) {
		float tex_aspect = tex_size.x / tex_size.y;
		float mesh_aspect = real_size.x / real_size.y;
		if (mesh_aspect > tex_aspect) {
			float scale = tex_aspect / mesh_aspect;
			final_uv.y = UV.y * scale + (1.0 - scale) * 0.5;
		} else {
			float scale = mesh_aspect / tex_aspect;
			final_uv.x = UV.x * scale + (1.0 - scale) * 0.5;
		}
	}
	
	vec4 tex = texture(albedo_texture, final_uv) * albedo_color;
	
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
}
"""

var _mesh_instance: MeshInstance3D
var _mat: ShaderMaterial
var _first_fit_done: bool = false

func _ready() -> void:
	_setup_nodes()
	if not Engine.is_editor_hint():
		get_viewport().size_changed.connect(_update_visual)
	_update_visual.call_deferred()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if auto_fit_camera:
			_update_visual()
	elif auto_fit_camera and not _first_fit_done:
		_update_visual()

func _setup_nodes() -> void:
	if not _mesh_instance:
		_mesh_instance = MeshInstance3D.new()
		_mesh_instance.name = "InternalMesh"
		_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_mesh_instance.set_meta("_edit_lock_", true)
		_mesh_instance.mesh = QuadMesh.new()
		add_child(_mesh_instance)
		
		_mat = ShaderMaterial.new()
		_mat.shader = Shader.new()
		_mat.shader.code = SHADER_CODE
		_mesh_instance.material_override = _mat

func _update_visual() -> void:
	if not is_inside_tree(): return
	_setup_nodes()
	
	if not texture:
		_mesh_instance.visible = false
		return
	
	_mesh_instance.visible = true
	
	# Orientation
	if view_mode == SBViewMode.TOP_DOWN:
		_mesh_instance.rotation_degrees.x = -90
	else:
		_mesh_instance.rotation_degrees.x = 0
		
	# Calcul de la taille finale
	var final_size = size
	var has_fitted = false
	
	if auto_fit_camera:
		var camera = get_viewport().get_camera_3d()
		
		# Fallback Éditeur : Essayer de trouver une caméra dans la scène si le viewport n'en renvoie pas encore
		if not camera and Engine.is_editor_hint():
			camera = _find_first_camera(get_tree().root)
			
		if camera:
			var viewport_size = get_viewport().get_visible_rect().size
			if viewport_size.y > 0.0:
				var screen_aspect = viewport_size.x / viewport_size.y
				var v_height = 0.0
				
				if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
					v_height = camera.size
				else:
					# Perspective : Calcul de la hauteur visible à la distance du plan
					var dist = global_position.distance_to(camera.global_position)
					# On s'assure d'une distance minimale pour éviter les divisions par zéro ou valeurs folles
					dist = max(dist, 0.1)
					v_height = 2.0 * dist * tan(deg_to_rad(camera.fov) * 0.5)
				
				var v_width = v_height * screen_aspect
				
				var tex_aspect = texture.get_width() / float(texture.get_height())
				
				if tex_aspect > 0.0:
					if screen_aspect > tex_aspect:
						# L'écran est plus large que l'image
						final_size = Vector2(v_width, v_width / tex_aspect)
					else:
						# L'écran est plus haut que l'image
						final_size = Vector2(v_height * tex_aspect, v_height)
					
					# Petit surplus de sécurité (interne) pour éviter les liserés sur les bords
					final_size *= 1.02 
					has_fitted = true
					_first_fit_done = true
	
	# On n'applique la taille que si on a réussi à calculer le fit OU si on est en mode manuel
	if has_fitted or not auto_fit_camera:
		_mesh_instance.mesh.size = final_size
	
	_mat.set_shader_parameter("albedo_texture", texture)
	_mat.set_shader_parameter("albedo_color", albedo_color)
	_mat.set_shader_parameter("stretch_mode", int(stretch_mode))
	_mat.set_shader_parameter("tex_size", texture.get_size())
	_mat.set_shader_parameter("real_size", final_size)

func _find_first_camera(node: Node) -> Camera3D:
	if node is Camera3D: return node
	for child in node.get_children():
		var cam = _find_first_camera(child)
		if cam: return cam
	return null
