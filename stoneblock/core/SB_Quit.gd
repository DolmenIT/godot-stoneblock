@tool
class_name SB_Quit
extends Node

## 🚪 SB_Quit : Composant pour quitter l'application.

func start() -> void:
	if SB_Core.instance:
		SB_Core.instance.log_msg("Fermeture de l'application...", "info")
	
	get_tree().quit()
