@tool
@icon("res://stoneblock/icons/SB_Alignement3D.svg")
class_name SB_Alignement3D
extends Node

## Composant d'alignement 3D pour StoneBlock.
## Aligne le parent sur une ancre cible (Caméra) avec gestion d'offset et d'ancres internes.

enum Anchor {
	TOP_LEFT, TOP_CENTER, TOP_RIGHT,
	CENTER_LEFT, CENTER, CENTER_RIGHT,
	BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT
}

@export_group("Layout")
## Point de référence sur le parent.
@export var parent_anchor: Anchor = Anchor.CENTER:
	set(v): parent_anchor = v; _queue_update()
## Point de référence sur l'écran (Cible).
@export var target_anchor: Anchor = Anchor.TOP_LEFT:
	set(v): target_anchor = v; _queue_update()
## Décalage final en pixels (X: droite, Y: haut).
@export var offset_pixels: Vector2 = Vector2.ZERO:
	set(v): offset_pixels = v; _queue_update()

@export_group("Parent Dimensions")
## Si vrai, tente de détecter la taille du parent (Sprite3D, Label3D, etc.) automatiquement.
@export var auto_detect_dimensions: bool = true:
	set(v): auto_detect_dimensions = v; _queue_update()
## Taille du parent en pixels (utilisé pour calculer l'ancre du parent). 
## Ignoré si auto_detect est actif et que le parent est détecté.
@export var parent_width_px: float = 0.0:
	set(v): parent_width_px = v; _queue_update()
## Hauteur du parent en pixels.
@export var parent_height_px: float = 0.0:
	set(v): parent_height_px = v; _queue_update()
## Taille d'un pixel en unités 3D.
@export var pixel_size: float = 0.01:
	set(v): pixel_size = v; _queue_update()

@export_group("Target")
## Caméra cible (si vide, utilise la caméra active).
@export var target_camera: Camera3D:
	set(v): target_camera = v; _queue_update()

var _update_queued := false

func _ready() -> void:
	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)
	_update_alignment()

func _on_viewport_size_changed() -> void:
	_update_alignment()

func _process(_delta: float) -> void:
	if _update_queued:
		_update_alignment()
		_update_queued = false

func _queue_update() -> void:
	if Engine.is_editor_hint():
		_update_alignment()
	else:
		_update_queued = true

func _update_alignment() -> void:
	if not is_inside_tree(): return
	var parent = get_parent() as Node3D
	if not parent: return
	
	# 1. Calcul de la zone visible (Fallback 1080p-ish si pas de caméra ortho)
	var view_h = 10.0 
	var view_w = 17.77
	
	var cam = target_camera
	if not cam:
		cam = get_viewport().get_camera_3d()
	
	if cam and cam.projection == Camera3D.PROJECTION_ORTHOGONAL:
		var viewport_size = get_viewport().get_visible_rect().size
		var aspect = viewport_size.x / viewport_size.y
		view_h = cam.size
		view_w = cam.size * aspect
	
	# 2. Calcul du point cible
	var target_pos = Vector2.ZERO
	match target_anchor:
		Anchor.TOP_LEFT:      target_pos = Vector2(-view_w/2,  view_h/2)
		Anchor.TOP_CENTER:    target_pos = Vector2(0,          view_h/2)
		Anchor.TOP_RIGHT:     target_pos = Vector2(view_w/2,   view_h/2)
		Anchor.CENTER_LEFT:   target_pos = Vector2(-view_w/2,  0)
		Anchor.CENTER:        target_pos = Vector2(0,          0)
		Anchor.CENTER_RIGHT:  target_pos = Vector2(view_w/2,   0)
		Anchor.BOTTOM_LEFT:   target_pos = Vector2(-view_w/2, -view_h/2)
		Anchor.BOTTOM_CENTER: target_pos = Vector2(0,         -view_h/2)
		Anchor.BOTTOM_RIGHT:  target_pos = Vector2(view_w/2,  -view_h/2)

	# 3. Récupération des dimensions du parent (Auto ou Manuel)
	var final_pw = parent_width_px
	var final_ph = parent_height_px
	var final_ps = pixel_size
	var p_is_centered = true
	
	if auto_detect_dimensions:
		if "pixel_size" in parent:
			final_ps = parent.pixel_size
			
		if "width_pixels" in parent and "height_pixels" in parent:
			final_pw = parent.width_pixels
			final_ph = parent.height_pixels
		elif parent is Sprite3D or parent is AnimatedSprite3D:
			p_is_centered = parent.centered
			var tex: Texture2D = null
			if parent is Sprite3D: tex = parent.texture
			else: 
				if parent.sprite_frames:
					tex = parent.sprite_frames.get_frame_texture(parent.animation, parent.frame)
			
			if tex:
				final_pw = tex.get_width()
				final_ph = tex.get_height()
				if parent is Sprite3D and parent.region_enabled:
					final_pw = parent.region_rect.size.x
					final_ph = parent.region_rect.size.y
					
		elif parent is Label3D:
			var aabb = parent.get_aabb()
			final_pw = aabb.size.x / final_ps
			final_ph = aabb.size.y / final_ps

		# Synchronisation avec l'inspecteur pour que l'utilisateur voit les valeurs
		if final_pw != parent_width_px or final_ph != parent_height_px or final_ps != pixel_size:
			parent_width_px = final_pw
			parent_height_px = final_ph
			pixel_size = final_ps
			notify_property_list_changed()

	# Fallback manuel si détection nulle
	if final_pw <= 0: final_pw = parent_width_px
	if final_ph <= 0: final_ph = parent_height_px

	if Engine.is_editor_hint():
		print("SB_Alignement3D: Update sur " + parent.name + " (" + str(final_pw) + "x" + str(final_ph) + ") PS:" + str(final_ps))

	# 4. Calcul de l'offset de l'ancre parent
	var parent_off = Vector2.ZERO
	var pw = final_pw * final_ps
	var ph = final_ph * final_ps
	
	# Correction position origine
	var base_origin_offset = Vector2.ZERO
	if not p_is_centered:
		base_origin_offset = Vector2(-pw/2, ph/2)

	match parent_anchor:
		Anchor.TOP_LEFT:      parent_off = Vector2(-pw/2,  ph/2)
		Anchor.TOP_CENTER:    parent_off = Vector2(0,      ph/2)
		Anchor.TOP_RIGHT:     parent_off = Vector2(pw/2,   ph/2)
		Anchor.CENTER_LEFT:   parent_off = Vector2(-pw/2,  0)
		Anchor.CENTER:        parent_off = Vector2(0,      0)
		Anchor.CENTER_RIGHT:  parent_off = Vector2(pw/2,   0)
		Anchor.BOTTOM_LEFT:   parent_off = Vector2(-pw/2, -ph/2)
		Anchor.BOTTOM_CENTER: parent_off = Vector2(0,     -ph/2)
		Anchor.BOTTOM_RIGHT:  parent_off = Vector2(pw/2,  -ph/2)
		
	parent_off -= base_origin_offset

	# 5. Position Finale
	var final_pos_2d = target_pos - parent_off + (offset_pixels * final_ps)
	
	# Appliquer (On préserve le Z du parent)
	parent.position = Vector3(final_pos_2d.x, final_pos_2d.y, parent.position.z)
