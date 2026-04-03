@tool
extends Node
class_name SB_TargetIndicator_VShmup

## 🎯 SB_TargetIndicator : Affiche un indicateur 360° pour suivre une cible hors-champ.
## Utile pour les ennemis arrivant de n'importe quelle direction ou les objectifs.

@export_group("Visuals")
## Icône au centre de l'indicateur (ex: tête de mort).
@export var icon_texture: Texture2D = preload("res://stoneblock/ui/assets/warning_skull.jpg")
## Flèche pointant vers la cible.
@export var arrow_texture: Texture2D = preload("res://stoneblock/ui/assets/indicator_arrow.jpg")
## Couleur de l'indicateur.
@export var color: Color = Color.RED
## Taille de l'icône (en pixels).
@export var icon_size: float = 32.0

@export_group("Behavior")
## Distance (marge) par rapport aux bords de l'écran.
@export var margin: float = 60.0
## Cacher l'indicateur quand la cible est visible à l'écran.
@export var hide_on_screen: bool = true
## Faire pivoter la flèche vers la cible.
@export var rotate_to_target: bool = true
## Durée de l'animation de pulsation (secondes).
@export var pulse_duration: float = 0.6
## Distance maximale d'affichage (en mètres). 0 = Illimité.
@export var max_distance: float = 105.0

# --- État Interne ---
var _canvas_layer: CanvasLayer
var _indicator_node: Control
var _icon_sprite: Sprite2D
var _arrow_sprite: Sprite2D
var _parent_3d: Node3D
var _camera: Camera3D
var _pulse_timer: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_parent_3d = get_parent() as Node3D
	if not _parent_3d:
		push_error("SB_TargetIndicator : Le parent doit être un Node3D.")
		queue_free()
		return
	
	_setup_ui()

func _setup_ui() -> void:
	# Recherche ou création du CanvasLayer pour les alertes sur le GameMode ou plus haut
	var root = get_tree().root
	_canvas_layer = root.get_node_or_null("SB_IndicatorLayer")
	
	if not _canvas_layer:
		_canvas_layer = CanvasLayer.new()
		_canvas_layer.name = "SB_IndicatorLayer"
		_canvas_layer.layer = 10 
		root.add_child.call_deferred(_canvas_layer)
	
	# Création de l'indicateur
	_indicator_node = Control.new()
	_indicator_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_indicator_node.visible = false # Cahé par défaut jusqu'au prochain frame
	
	# On attend que le CanvasLayer soit prêt
	_canvas_layer.add_child.call_deferred(_indicator_node)
	
	# On applique un shader pour gérer le manque de transparence du JPEG
	var mat = ShaderMaterial.new()
	mat.shader = _get_chroma_shader()
	
	# Icône
	_icon_sprite = Sprite2D.new()
	_icon_sprite.texture = icon_texture
	_icon_sprite.modulate = color
	_icon_sprite.material = mat
	var base_scale = icon_size / icon_texture.get_width() if icon_texture else 1.0
	_icon_sprite.scale = Vector2(base_scale, base_scale)
	_indicator_node.add_child(_icon_sprite)
	
	# Flèche
	if arrow_texture:
		_arrow_sprite = Sprite2D.new()
		_arrow_sprite.texture = arrow_texture
		_arrow_sprite.modulate = color
		_arrow_sprite.material = mat
		_arrow_sprite.scale = _icon_sprite.scale * 1.2
		_indicator_node.add_child(_arrow_sprite)
		_arrow_sprite.position.y = -icon_size * 0.8

func _get_chroma_shader() -> Shader:
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	// On rend transparent tout ce qui est très sombre (fond JPEG)
	if (length(tex_color.rgb) < 0.1) {
		discard;
	}
	// En Godot 4, 'COLOR' à cet endroit contient la modulation du nœud
	COLOR = tex_color * COLOR;
}
"""
	return shader

func _exit_tree() -> void:
	if _indicator_node:
		_indicator_node.queue_free()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not _indicator_node or not _parent_3d: return
	
	_camera = get_viewport().get_camera_3d()
	if not _camera: 
		_indicator_node.visible = false
		return
	
	_update_indicator_position()
	_update_pulsation(delta)

func _update_indicator_position() -> void:
	var viewport_rect = get_viewport().get_visible_rect()
	var screen_pos = _camera.unproject_position(_parent_3d.global_position)
	var is_behind = _camera.is_position_behind(_parent_3d.global_position)
	
	# Vérifier si on est sur l'écran
	var on_screen = viewport_rect.has_point(screen_pos) and not is_behind
	
	# Vérification de la distance maximale
	if max_distance > 0:
		var dist = _camera.global_position.distance_to(_parent_3d.global_position)
		if dist > max_distance:
			_indicator_node.visible = false
			return
	
	if hide_on_screen and on_screen:
		_indicator_node.visible = false
		return
	
	_indicator_node.visible = true
	
	var screen_center = viewport_rect.size / 2.0
	
	# Si l'objet est derrière, on simule une position très loin pour le clamping
	if is_behind:
		screen_pos = screen_center - (screen_pos - screen_center).normalized() * 10000.0
	
	var dir = (screen_pos - screen_center).normalized()
	
	# Intersection Ray/Box 2D
	var half_size = (viewport_rect.size / 2.0) - Vector2(margin, margin)
	
	var tx = abs(half_size.x / dir.x) if dir.x != 0 else INF
	var ty = abs(half_size.y / dir.y) if dir.y != 0 else INF
	var t = min(tx, ty)
	
	var final_pos = screen_center + dir * t
	_indicator_node.position = final_pos
	
	# Rotation
	if rotate_to_target and _arrow_sprite:
		_arrow_sprite.rotation = dir.angle() + PI/2.0

func _update_pulsation(delta: float) -> void:
	_pulse_timer += delta
	var pulse = 1.0 + 0.1 * sin(_pulse_timer * PI * 2.0 / pulse_duration)
	_indicator_node.scale = Vector2(pulse, pulse)
