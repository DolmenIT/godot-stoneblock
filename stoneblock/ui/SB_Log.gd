@tool
class_name SB_Log
extends Node

## 📝 SB_Log : Composant pour envoyer un message à la console.

@export var message: String = "Message de log"
@export_enum("info", "success", "error") var type: String = "info"

func start() -> void:
	if SB_Core.instance:
		SB_Core.instance.log_msg(message, type)
	else:
		print("[%s] %s" % [type, message])
