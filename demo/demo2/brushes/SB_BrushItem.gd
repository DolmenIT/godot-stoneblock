extends Button

## Élément individuel du menu des brosses.
## Gère l'affichage de l'icône et l'état de sélection.

@onready var icon_rect: TextureRect = %Icon
@onready var label: Label = %Label

var brush_id: String = ""
var brush_name: String = ""
var atlas_coords: Vector2i = Vector2i.ZERO # Coordonnées dans la grille 4x3

func setup(id: String, b_name: String, coords: Vector2i, atlas: Texture2D) -> void:
	brush_id = id
	brush_name = b_name
	atlas_coords = coords
	
	if label:
		label.text = b_name
	
	if not atlas:
		push_warning("[SB] Atlas de brosses manquant pour : ", b_name)
		return
	
	# Debug si l'image semble invalide
	if atlas.get_width() <= 1:
		push_error("[SB] L'atlas semble invalide (Longeur <= 1). Problème de .import ?")
		return

	# Configuration de l'AtlasTexture pour découper l'icône
	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = atlas
	
	# On découpe une case de la grille 4x3
	var cell_w = float(atlas.get_width()) / 4.0
	var cell_h = float(atlas.get_height()) / 3.0
	
	# On réduit la hauteur pour ignorer le texte gravé en bas de l'icône originale
	var crop_h = cell_h * 0.75
	atlas_tex.region = Rect2(coords.x * cell_w, coords.y * cell_h, cell_w, crop_h)
	icon_rect.texture = atlas_tex
	
	tooltip_text = b_name

func _on_mouse_entered() -> void:
	# Feedback visuel (Optionnel)
	pass
