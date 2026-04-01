@tool
class_name SB_SpriteProgressBar
extends Control

## Super-Barre de progression universelle pour StoneBlock.
## Gère le découpage automatique, la segmentation par tuiles et le remplissage multi-directionnel.

enum FillMode {
	LEFT_TO_RIGHT,
	RIGHT_TO_LEFT,
	TOP_TO_BOTTOM,
	BOTTOM_TO_TOP
}

@export_group("Data")
@export var sprite_frames: SpriteFrames:
	set(v):
		sprite_frames = v
		update_minimum_size()
		queue_redraw()

@export var anim_full: StringName = &"full":
	set(v):
		anim_full = v
		update_minimum_size()
		queue_redraw()

@export var anim_empty: StringName = &"empty":
	set(v):
		anim_empty = v
		update_minimum_size()
		queue_redraw()

@export_group("Progress")
@export var value: float = 100.0:
	set(v):
		value = clamp(v, 0, max_value)
		queue_redraw()

@export var max_value: float = 100.0:
	set(v):
		max_value = max(0.1, v)
		queue_redraw()

@export var fill_mode: FillMode = FillMode.LEFT_TO_RIGHT:
	set(v):
		fill_mode = v
		queue_redraw()

@export_group("Visual Style")
## Si vrai, la barre est composée de morceaux individuels (tuiles).
## Sinon, elle utilise la frame 0 comme une texture continue.
@export var is_segmented: bool = true:
	set(v):
		is_segmented = v
		update_minimum_size()
		queue_redraw()

## Si vrai, le remplissage est fluide (clippé).
## Si faux, il bascule morceau par morceau (discret).
@export var is_continuous: bool = true:
	set(v):
		is_continuous = v
		queue_redraw()

@export_group("Safe Area (Pixels)")
## Marges en pixels par rapport aux bords du cadre de fond.
@export var margin_left: int = 0:
	set(v):
		margin_left = v
		queue_redraw()
@export var margin_right: int = 0:
	set(v):
		margin_right = v
		queue_redraw()
@export var margin_top: int = 0:
	set(v):
		margin_top = v
		queue_redraw()
@export var margin_bottom: int = 0:
	set(v):
		margin_bottom = v
		queue_redraw()

@export var spacing: Vector2 = Vector2.ZERO:
	set(v):
		spacing = v
		update_minimum_size()
		queue_redraw()

func _get_minimum_size() -> Vector2:
	if not sprite_frames or not sprite_frames.has_animation(anim_full):
		return Vector2(32, 32)
	
	var frame_count = sprite_frames.get_frame_count(anim_full)
	if frame_count == 0: return Vector2(32, 32)
	
	var first_frame = sprite_frames.get_frame_texture(anim_full, 0)
	if not first_frame: return Vector2(32, 32)
	
	var frame_size = first_frame.get_size()
	if is_segmented:
		# Taille = somme des tuiles + espaces
		if fill_mode == FillMode.LEFT_TO_RIGHT or fill_mode == FillMode.RIGHT_TO_LEFT:
			return Vector2(frame_count * frame_size.x + (frame_count - 1) * spacing.x, frame_size.y)
		else:
			return Vector2(frame_size.x, frame_count * frame_size.y + (frame_count - 1) * spacing.y)
	else:
		return size

func _draw() -> void:
	if not sprite_frames:
		draw_rect(Rect2(Vector2.ZERO, size), Color.RED, false)
		return
		
	if not sprite_frames.has_animation(anim_full):
		return

	var frame_count = sprite_frames.get_frame_count(anim_full)
	if frame_count == 0: return
	
	var ratio = value / max_value
	
	if is_segmented:
		_draw_segmented(frame_count, ratio)
	else:
		_draw_continuous(ratio)

func _draw_segmented(frame_count: int, ratio: float) -> void:
	var first_tex = sprite_frames.get_frame_texture(anim_full, 0)
	var tex_size = first_tex.get_size()
	
	# 1. Calculer la taille totale de l'assemblage
	var total_size = Vector2.ZERO
	if fill_mode == FillMode.LEFT_TO_RIGHT or fill_mode == FillMode.RIGHT_TO_LEFT:
		total_size = Vector2(frame_count * tex_size.x + (frame_count - 1) * spacing.x, tex_size.y)
	else:
		total_size = Vector2(tex_size.x, frame_count * tex_size.y + (frame_count - 1) * spacing.y)
		
	# 2. Définir la zone de progression globale (Safe Area)
	var global_safe_rect = Rect2(
		margin_left, 
		margin_top, 
		total_size.x - margin_left - margin_right, 
		total_size.y - margin_top - margin_bottom
	)
	
	# 3. Calculer le rectangle de remplissage actuel (clippé par le ratio)
	var fill_rect = global_safe_rect
	match fill_mode:
		FillMode.LEFT_TO_RIGHT:
			fill_rect.size.x *= ratio
		FillMode.RIGHT_TO_LEFT:
			var w = fill_rect.size.x * ratio
			fill_rect.position.x += fill_rect.size.x - w
			fill_rect.size.x = w
		FillMode.TOP_TO_BOTTOM:
			fill_rect.size.y *= ratio
		FillMode.BOTTOM_TO_TOP:
			var h = fill_rect.size.y * ratio
			fill_rect.position.y += fill_rect.size.y - h
			fill_rect.size.y = h
			
	# 4. Boucle de dessin tuile par tuile
	for i in range(frame_count):
		var pos = Vector2.ZERO
		if fill_mode == FillMode.LEFT_TO_RIGHT or fill_mode == FillMode.RIGHT_TO_LEFT:
			pos.x = i * (tex_size.x + spacing.x)
		else:
			pos.y = i * (tex_size.y + spacing.y)
			
		var tile_rect = Rect2(pos, tex_size)
		
		# Dessiner le fond (Empty)
		if sprite_frames.has_animation(anim_empty) and i < sprite_frames.get_frame_count(anim_empty):
			draw_texture(sprite_frames.get_frame_texture(anim_empty, i), pos)
			
		# Dessiner la partie pleine (Full) uniquement dans l'intersection avec fill_rect
		var tex_full = sprite_frames.get_frame_texture(anim_full, i)
		var intersection = tile_rect.intersection(fill_rect)
		
		if intersection.size.x > 0 and intersection.size.y > 0:
			# Source rect sur le sprite original (pour prélever le bon morceau)
			var src_rect = Rect2(intersection.position - pos, intersection.size)
			draw_texture_rect_region(tex_full, intersection, src_rect)

func _draw_continuous(ratio: float) -> void:
	var tex_full = sprite_frames.get_frame_texture(anim_full, 0)
	_draw_clipped_texture(tex_full, Vector2.ZERO, ratio)

func _draw_clipped_texture(tex: Texture2D, pos: Vector2, ratio: float) -> void:
	var tex_size = tex.get_size()
	
	var global_safe_rect = Rect2(
		margin_left, 
		margin_top, 
		tex_size.x - margin_left - margin_right, 
		tex_size.y - margin_top - margin_bottom
	)
	
	var tex_empty = null
	if sprite_frames.has_animation(anim_empty):
		tex_empty = sprite_frames.get_frame_texture(anim_empty, 0)
	if tex_empty:
		draw_texture(tex_empty, pos)
		
	var fill_rect = global_safe_rect
	var src_rect = global_safe_rect
	
	match fill_mode:
		FillMode.LEFT_TO_RIGHT:
			fill_rect.size.x *= ratio
			src_rect.size.x *= ratio
		FillMode.RIGHT_TO_LEFT:
			var w = fill_rect.size.x * ratio
			fill_rect.position.x += fill_rect.size.x - w
			fill_rect.size.x = w
			src_rect.position.x += src_rect.size.x - w
			src_rect.size.x = w
		FillMode.TOP_TO_BOTTOM:
			fill_rect.size.y *= ratio
			src_rect.size.y *= ratio
		FillMode.BOTTOM_TO_TOP:
			var h = fill_rect.size.y * ratio
			fill_rect.position.y += fill_rect.size.y - h
			fill_rect.size.y = h
			src_rect.position.y += src_rect.size.y - h
			src_rect.size.y = h
			
	draw_texture_rect_region(tex, fill_rect, src_rect)
