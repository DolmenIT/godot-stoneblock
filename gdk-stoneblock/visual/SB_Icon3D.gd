@tool
class_name SB_Icon3D
extends Node3D

## 🏷️ SB_Icon3D : Affiche une icône 2D nette dans l'espace 3D via un Sprite3D interne.

@export_group("Texture")
## La texture de l'icône.
@export var texture: Texture2D:
	set(v): texture = v; _update_visual()
## Teinte de l'icône.
@export var albedo_color: Color = Color.WHITE:
	set(v): albedo_color = v; _update_visual()

@export_group("Layout")
## Échelle de base de l'icône (le côté le plus long fera cette taille en unités 3D).
@export var base_scale: float = 1.0:
	set(v): base_scale = v; _update_visual()

var _sprite: Sprite3D

func _ready() -> void:
	_setup_nodes()
	_update_visual()

func _setup_nodes() -> void:
	if not _sprite:
		# On cherche si un sprite existe déjà (ex: après un reload)
		_sprite = get_node_or_null("InternalSprite")
		
		if not _sprite:
			_sprite = Sprite3D.new()
			_sprite.name = "InternalSprite"
			_sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_sprite.shaded = false
			_sprite.double_sided = true
			_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			_sprite.set_meta("_edit_lock_", true)
			add_child(_sprite)

func _update_visual() -> void:
	if not is_inside_tree(): return
	_setup_nodes()
	
	if not texture:
		_sprite.visible = false
		return
	
	_sprite.visible = true
	_sprite.texture = texture
	_sprite.modulate = albedo_color
	
	# Calcul du pixel_size pour que la dimension la plus grande soit égale à base_scale
	var tex_size = texture.get_size()
	var max_dim = max(tex_size.x, tex_size.y)
	
	if max_dim > 0:
		_sprite.pixel_size = base_scale / max_dim
	else:
		_sprite.pixel_size = 0.01
