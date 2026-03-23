@tool
class_name SB_LoadingLabel
extends Label

## 📊 SB_LoadingLabel : Indicateur de progression automatique.
## Capte les signaux de SB_Core pour afficher l'état du chargement.

@export_group("Formatage")
## Masquer le label une fois le chargement terminé ?
@export var hide_on_complete: bool = false
## Format du texte. Utilisez {scene} et {progress} comme balises.
@export var text_format: String = "{scene} : Chargement {progress}%"

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	# Connexion au Singleton global SB_Core
	if SB_Core.instance:
		SB_Core.instance.progress_updated.connect(_on_progress_updated)
		SB_Core.instance.resource_loaded.connect(_on_resource_loaded)
		
		# Forcer une mise à jour immédiate si déjà en chargement
		if SB_Core.instance._current_state == SB_Core.State.LOADING:
			_on_progress_updated(0.0) 
		else:
			# Initialisation du texte par défaut
			_update_display("StoneBlock", 0.0)
	else:
		push_warning("[SB_LoadingLabel] SB_Core non trouvé. L'indicateur sera inactif.")

func _on_progress_updated(percent: float) -> void:
	var current_path = SB_Core.instance._current_loading_path if SB_Core.instance else ""
	var scene_name = current_path.get_file() if not current_path.is_empty() else "Scène"
	_update_display(scene_name, percent)

func _on_resource_loaded(_path: String, _res: Resource) -> void:
	if hide_on_complete:
		hide()
	else:
		_update_display(_path.get_file(), 100.0)

func _update_display(scene_name: String, percent: float) -> void:
	text = text_format.format({
		"scene": scene_name,
		"progress": str(round(percent))
	})
