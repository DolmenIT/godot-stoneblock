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

@export_group("Avancé")
## Propriétés personnalisées additionnelles (Dictionnaire de type { "propriété": valeur }).
@export var extra_properties: Dictionary = {}

func _ready() -> void:
	# En mode édition, on peut vouloir un petit feedback visuel ou une icône
	pass
