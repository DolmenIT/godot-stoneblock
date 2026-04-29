@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
class_name SB_Redirect
extends SB_1_Foundation

## 🚀 SB_Redirect : Composant de navigation StoneBlock.
## Peut être automatique (Splash) ou manuel (Enfant de SB_Button).

@export_group("Navigation Settings")
## La scène vers laquelle rediriger par défaut.
@export_file("*.tscn") var target_scene: String = ""
## Scène spécifique pour le mode Paysage (si vide, utilise Target Scene).
@export_file("*.tscn") var target_scene_landscape: String = ""
## Scène spécifique pour le mode Portrait (si vide, utilise Target Scene).
@export_file("*.tscn") var target_scene_portrait: String = ""

@export_group("Advanced Options")
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
	var final_target = target_scene
	
	if SB_Core.instance:
		var current_orient = SB_Core.instance.get_current_orientation()
		if current_orient == SB_Core.SBOrientation.LANDSCAPE and not target_scene_landscape.is_empty():
			final_target = target_scene_landscape
		elif current_orient == SB_Core.SBOrientation.PORTRAIT and not target_scene_portrait.is_empty():
			final_target = target_scene_portrait
			
	if final_target.is_empty():
		push_warning("[SB_Redirect] Aucune scène cible définie pour cette orientation.")
		return
		
	if SB_Core.instance:
		# Déclenchement de tous les enfants (ex: Fondus de sortie)
		for child in get_children():
			if child.has_method("start"):
				child.start()
				
		# Injection des paramètres de niveau
		SB_Core.instance.level_data = level_params.duplicate()
		
		SB_Core.instance.load_scene_async(final_target, use_inner_progress, -1.0, use_loading_screen)
		SB_Core.instance.log_msg("SB_Redirect : Lancement de la redirection vers " + final_target, "info")
	else:
		get_tree().change_scene_to_file(final_target)

