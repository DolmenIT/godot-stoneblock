@tool
class_name SB_Button3d_Theme
extends SB_BaseStyle

## 🔘 SB_Button3d_Theme : Script de personnalisation dédié aux boutons 3D diégétiques.

@export_group("Couleurs & Teintes")
## Teinte du bouton en état normal.
@export var tint_normal: Color = Color.WHITE
## Teinte du bouton lors du survol.
@export var tint_hover: Color = Color.WHITE
## Teinte du bouton lors du clic.
@export var tint_pressed: Color = Color.WHITE

@export_group("Éclairage & Bloom")
## Intensité de l'émission lumineuse en état normal.
@export var emission_energy_normal: float = 0.0
## Intensité de l'émission lumineuse lors du survol.
@export var emission_energy_hover: float = 2.0
## Intensité de l'émission lumineuse lors du clic.
@export var emission_energy_pressed: float = 1.0

@export_subgroup("Layers (Cull Masks)")
## Calque par défaut (souvent 1 + un calque de bloom).
@export_flags_3d_render var layer_normal: int = 4097
## Calque lors du survol (ex: Layer 1 + Layer 11).
@export_flags_3d_render var layer_hover: int = 1025
## Calque lors du clic (ex: Layer 1 + Layer 12).
@export_flags_3d_render var layer_pressed: int = 2049
## Calque en état désactivé.
@export_flags_3d_render var layer_disabled: int = 1

@export_group("Texte 3D")
## Texte par défaut appliqué au bouton (ex: ACHETER). Laisse vide pour ne pas forcer le texte.
@export var default_text: String = ""
## Taille de la police pour le Label3D du bouton.
@export var font_size: int = 32
## Couleur du texte en état normal.
@export var text_color_normal: Color = Color.WHITE
## Couleur du texte lors du survol.
@export var text_color_hover: Color = Color.BLACK
## Couleur du texte lors du clic.
@export var text_color_pressed: Color = Color.BLACK

@export_group("Layout & Transform")
## Échelle de base du bouton dans l'espace 3D.
@export var base_scale: float = 35.0
## Facteur multiplicateur lors du survol (ex: 1.1 pour +10%).
@export var hover_scale_factor: float = 1.1

func _init() -> void:
	target_class_name = "SB_Button_3d"
