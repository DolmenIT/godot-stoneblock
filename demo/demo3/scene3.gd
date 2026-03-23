extends Control

## ⏳ Scene3 : Écran de chargement universel StoneBlock GDK.
## Se connecte dynamiquement à SB_Core pour afficher la progression.

@onready var progress_bar = $CenterContainer/VBoxContainer/ProgressBar
@onready var status_label = $CenterContainer/VBoxContainer/StatusLabel

func _ready() -> void:
	# Initialisation
	progress_bar.value = 0
	status_label.text = "Préparation du niveau..."
	
	# Connexion aux signaux globaux du Core
	if SB_Core.instance:
		SB_Core.instance.progress_updated.connect(_on_progress_updated)
		SB_Core.instance.message_logged.connect(_on_message_logged)
		
		# Si le Core est déjà en train de charger quelque chose, on récupère le dernier message
		status_label.text = "Chargement en cours..."

func _on_progress_updated(percent: float) -> void:
	progress_bar.value = percent

func _on_message_logged(text: String, _type: String) -> void:
	status_label.text = text
