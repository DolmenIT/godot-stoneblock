@tool
class_name SB_Redirect
extends Node

## 🚀 SB_Redirect : Composant de navigation StoneBlock.
## Peut être automatique (Splash) ou manuel (Enfant de SB_Button).

@export_group("Navigation Settings")
## La scène vers laquelle rediriger.
@export_file("*.tscn") var target_scene: String = ""
## Si vrai, utilise l'écran de chargement défini dans le Core.
@export var use_loading_screen: bool = true
## Si vrai, attend le signal report_ready() de la scène cible.
@export var use_inner_progress: bool = false
## Paramètres optionnels à passer à la scène cible (via SB_Core.level_data).
@export var level_params: Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	# Intelligence de démarrage : 
	# On ne redirige automatiquement que si on est à la racine de la scène
	var is_root_child = get_parent() == owner or get_parent() == get_tree().current_scene
	if is_root_child:
		# On diffère légèrement pour laisser l'arbre se stabiliser
		start.call_deferred()

func start() -> void:
	if target_scene.is_empty():
		push_warning("[SB_Redirect] Aucune scène cible définie.")
		return
		
	if SB_Core.instance:
		# Déclenchement de tous les enfants (ex: Fondus de sortie)
		for child in get_children():
			if child.has_method("start"):
				child.start()
				
		# Injection des paramètres de niveau
		SB_Core.instance.level_data = level_params.duplicate()
		
		SB_Core.instance.load_scene_async(target_scene, use_inner_progress, -1.0, use_loading_screen)
		SB_Core.instance.log_msg("SB_Redirect : Lancement de la redirection vers " + target_scene, "info")
	else:
		get_tree().change_scene_to_file(target_scene)
