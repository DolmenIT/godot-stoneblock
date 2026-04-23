@tool
@icon("res://gdk-stoneblock/assets/icons/SB_UI.svg")
class_name SB_Quit
extends SB_1_Foundation

## 🚪 SB_Quit : Composant pour quitter l'application.

func start() -> void:
	if SB_Core.instance:
		SB_Core.instance.log_msg("Fermeture de l'application...", "info")
	
	get_tree().quit()
