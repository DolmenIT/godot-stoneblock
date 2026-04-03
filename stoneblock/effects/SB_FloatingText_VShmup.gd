extends Label3D
class_name SB_FloatingText_VShmup

## ✉️ SB_FloatingText : Affiche un texte flottant éphémère (ex: Combo Kill).
## S'anime vers le haut (Y+) et disparaît en fondu.

@export var duration: float = 0.4
@export var lift_height: float = 2.0
@export var font_color: Color = Color("#FFCC00") # Jaune doré
@export var outline_color: Color = Color.BLACK
@export_group("Text Parameters")
# Note : pixel_size et fixed_size sont déjà des propriétés natives de Label3D, 
# on ne les redéclare pas mais on peut les régler dans l'inspecteur.

func _ready() -> void:
	# Configuration visuelle
	modulate = font_color
	outline_modulate = outline_color
	outline_size = 8
	# On utilise les variables @export
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	render_priority = 20 # S'affiche par dessus les autres objets
	
	# Initialisation position (Y=0 par défaut, on part un peu plus haut que l'explosion)
	position.y += 1.0
	modulate.a = 0.0 # On commence invisible
	
	# Animation
	var tween = create_tween().set_parallel(true)
	
	# Apparition (Fade In rapide pour éviter le pop)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	# Montée (Y+)
	tween.tween_property(self, "position:y", position.y + lift_height, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Disparition (Alpha)
	tween.tween_property(self, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Auto-destruction
	tween.chain().tween_callback(queue_free)

## Définit le texte et optionnellement la couleur.
func setup(text_val: String, color_val: Color = font_color) -> void:
	text = text_val
	modulate = color_val
