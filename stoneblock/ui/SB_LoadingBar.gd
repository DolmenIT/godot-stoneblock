@tool
class_name SB_LoadingBar
extends ProgressBar

## 📊 SB_LoadingBar : Barre de progression automatique (Composant No-Code).
## Capte les signaux de SB_Core pour mettre à jour sa valeur.

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	# Connexion au Singleton global SB_Core
	if SB_Core.instance:
		SB_Core.instance.progress_updated.connect(_on_progress_updated)
		
		# Initialisation immédiate
		if SB_Core.instance._current_state == SB_Core.State.LOADING:
			value = 0.0
	else:
		push_warning("[SB_LoadingBar] SB_Core non trouvé. Le composant sera inactif.")

func _on_progress_updated(percent: float) -> void:
	# Godot 4 : value est entre 0 et 100 par défaut pour une ProgressBar
	value = percent * 100
