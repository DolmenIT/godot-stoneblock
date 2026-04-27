@tool
class_name SB_Icon3D
extends Node3D

## 🏷️ SB_Icon3D : Affiche une icône 2D simple dans l'espace 3D tout en respectant son ratio.

@export_group("Texture")
## La texture de l'icône.
@export var texture: Texture2D:
	set(v): texture = v; _update_visual()
## Teinte de l'icône.
@export var albedo_color: Color = Color.WHITE:
	set(v): albedo_color = v; _update_visual()

@export_group("Layout")
## Échelle de base de l'icône (conserve le ratio d'aspect).
@export var base_scale: float = 1.0:
	set(v): base_scale = v; _update_visual()

const SHADER_CODE: String = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 albedo_color : source_color = vec4(1.0);

void fragment() {
	vec4 tex = texture(albedo_texture, UV) * albedo_color;
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
}
"""

var _mesh_instance: MeshInstance3D
var _mat: ShaderMaterial

func _ready() -> void:
	_setup_nodes()
	_update_visual()

func _setup_nodes() -> void:
	if not _mesh_instance:
		_mesh_instance = MeshInstance3D.new()
		_mesh_instance.name = "InternalIconMesh"
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
	
	# Calcul du ratio d'aspect
	var tex_size = texture.get_size()
	var aspect = tex_size.x / float(tex_size.y) if tex_size.y > 0 else 1.0
	
	# Application de la taille en respectant le ratio
	if aspect > 1.0:
		_mesh_instance.mesh.size = Vector2(base_scale, base_scale / aspect)
	else:
		_mesh_instance.mesh.size = Vector2(base_scale * aspect, base_scale)
	
	_mat.set_shader_parameter("albedo_texture", texture)
	_mat.set_shader_parameter("albedo_color", albedo_color)
