@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
class_name SB_ThemeCache
extends Resource

## 📦 SB_ThemeCache : Stocke les propriétés des styles 3D pour l'éditeur.
## Permet aux composants diégétiques (boutons, etc.) de s'auto-mettre à jour dans le Viewport Godot
## même si le ThemeManager n'est pas instancié.

## Dictionnaire des styles : NomStyle -> { propriete: valeur }
@export var styles: Dictionary = {}

## Date de dernière mise à jour (pour forcer le rafraîchissement)
@export var last_update: float = 0.0

## Récupère les données d'un style spécifique sous forme de dictionnaire.
func get_style_data(style_name: String) -> Dictionary:
	if styles.has(style_name):
		return styles[style_name]
	return {}
