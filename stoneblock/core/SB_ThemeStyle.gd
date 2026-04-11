@tool
class_name SB_ThemeStyle
extends Node

## 🎨 SB_ThemeStyle : Définition d'une règle de style pour le ThemeManager.
## Le nom du nœud sera utilisé comme nom de la "Type Variation" dans le thème.

@export_group("Cible")
## Le type d'élément Godot visé (ex: Label, Button, PanelContainer).
@export var target_type: String = "Label"
## Si coché, définit le style par défaut pour tous les éléments du type cible.
@export var is_global_default: bool = false

@export_group("Police")
## Taille de la police de caractères (-1 pour ignorer).
@export var font_size: int = -1
## Couleur de la police de caractères.
@export var font_color: Color = Color.WHITE

@export_group("StyleBox (Fond/Coins)")
## Active la création d'un StyleBox (fond et bordures) pour cet élément.
@export var use_stylebox: bool = false
## Couleur du fond du composant.
@export var bg_color: Color = Color.TRANSPARENT
## Couleur secondaire pour le dégradé (Laisse vide si pas de dégradé).
@export var bg_color_2: Color = Color.TRANSPARENT
## Active la forme en "pillule" (coins arrondis au maximum).
@export var is_pill_shape: bool = false
## Rayon de l'arrondi des coins (ex: Studio = 20-24).
@export var corner_radius: int = 0

@export_group("Ombres & Relief")
## Taille de l'ombre portée (shadow).
@export var shadow_size: int = 0
## Couleur de l'ombre.
@export var shadow_color: Color = Color(0, 0, 0, 0.5)
## Décalage de l'ombre (Vector2).
@export var shadow_offset: Vector2 = Vector2.ZERO

@export_group("Borders & Shapes")
## Active la forme circulaire parfaite (ignore corner_radius).
@export var is_circle: bool = false
## Épaisseur de la bordure.
@export var border_width: int = 0
## Couleur de la bordure.
@export var border_color: Color = Color.WHITE
## Inclinaison de l'élément (mo.co utilise souvent entre 0.05 et 0.1).
@export var skew: float = 0.0
## Dessiner le centre (Faux pour n'avoir que le contour).
@export var draw_center: bool = true

@export_group("Layout (CSS Style)")
@export_subgroup("Padding (Interne)")
## Padding Gauche.
@export var padding_left: int = 0
## Padding Haut.
@export var padding_top: int = 0
## Padding Droite.
@export var padding_right: int = 0
## Padding Bas.
@export var padding_bottom: int = 0

@export_subgroup("Margins (Externe)")
## Marge Gauche (Fonctionne si la cible est un MarginContainer).
@export var margin_left: int = -1
## Marge Haut.
@export var margin_top: int = -1
## Marge Droite.
@export var margin_right: int = -1
## Marge Bas.
@export var margin_bottom: int = -1

@export_group("Avancé")
## Propriétés personnalisées additionnelles (Dictionnaire de type { "propriété": valeur }).
@export var extra_properties: Dictionary = {}

func _ready() -> void:
	# En mode édition, on peut vouloir un petit feedback visuel ou une icône
	pass
