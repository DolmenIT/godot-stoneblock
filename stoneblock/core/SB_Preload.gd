@tool
class_name SB_Preload
extends Node

## 📦 SB_Preload : Composant autonome pour le pooling de scènes.
## Gère le préchargement asynchrone en arrière-plan.

@export_group("Scene Pooling")
## Liste des scènes à charger en arrière-plan dès l'activation de ce nœud.
@export var preload_scenes: PackedStringArray = []

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	# Intelligence de démarrage : fils direct du root uniquement
	var is_root_child = get_parent() == owner or get_parent() == get_tree().current_scene
	if is_root_child:
		start()

func start() -> void:
	if SB_Core.instance:
		# Amorçage du pooling
		for path in preload_scenes:
			SB_Core.instance.preload_scene(path)
			
		SB_Core.instance.log_msg("SB_Preload : Pooling amorcé.", "success")
