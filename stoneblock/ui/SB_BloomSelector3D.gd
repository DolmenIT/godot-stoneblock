@tool
@icon("res://stoneblock/icons/SB_BloomSelector3D.svg")
class_name SB_BloomSelector3D
extends Node

## Composant StoneBlock pour ajouter un objet au rendu de Bloom Sélectif.
## S'utilise en enfant d'un MeshInstance3D ou d'un modèle complexe.

@export_group("Bloom Settings")
## Le calque de rendu utilisé pour le bloom sélectif (11 = standard du projet).
@export_range(1, 20) var bloom_layer_index: int = 11:
	set(v): bloom_layer_index = v; _apply_bloom()

## Si vrai, applique également le calque à tous les enfants (utile pour les modèles .glb).
@export var apply_to_children: bool = true:
	set(v): apply_to_children = v; _apply_bloom()

func _ready() -> void:
	_apply_bloom()

func _apply_bloom() -> void:
	var target = get_parent()
	if not target or not target is Node3D:
		return
		
	var mask = 1 << (bloom_layer_index - 1)
	_set_layer_recursive(target, mask)

func _set_layer_recursive(node: Node, mask: int) -> void:
	if node is VisualInstance3D:
		node.layers |= mask
		
	if apply_to_children:
		for child in node.get_children():
			_set_layer_recursive(child, mask)
