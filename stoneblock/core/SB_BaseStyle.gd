@tool
class_name SB_BaseStyle
extends Node

## 🎨 SB_BaseStyle : Classe de base abstraite pour les scripts de thèmes spécialisés.
## Permet au SB_ThemeManager d'identifier tous les types de styles (2D, 3D, etc.).

@export_group("Identification")
## Classe Godot cible (ex: Label, Button, SB_Button_3d).
@export var target_class_name: String = "Label"

## Si activé, ce style s'applique par défaut aux composants sans 'Style Class Name' défini.
@export var is_global_default: bool = false
