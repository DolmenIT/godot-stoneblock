@tool
class_name SB_HUD
extends CanvasLayer

## 🔮 SB_HUD : Affichage des statistiques de jeu.
## Se connecte à SB_Core pour mettre à jour les compteurs (Magie, Score).

@export_group("UI References")
## Chemin vers le label affichant le compteur de Magie.
@export var magie_label_path: NodePath
## Chemin vers le label affichant le score.
@export var score_label_path: NodePath
## Chemin vers le label affichant le nom du stage actuel.
@export var stage_label_path: NodePath

@onready var _magie_label: Label = get_node_or_null(magie_label_path) if magie_label_path else null
@onready var _score_label: Label = get_node_or_null(score_label_path) if score_label_path else null
@onready var _stage_label: Label = get_node_or_null(stage_label_path) if stage_label_path else null

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	if SB_Core.instance:
		SB_Core.instance.stats_updated.connect(_on_stats_updated)
		_update_display(SB_Core.instance.get_stats())
		
		# Affichage du nom du stage si disponible
		if _stage_label and not SB_Core.instance.level_data.get("stage_name", "").is_empty():
			_stage_label.text = SB_Core.instance.level_data["stage_name"]
	else:
		push_warning("[SB_HUD] SB_Core non trouvé.")

func _on_stats_updated(stats: Dictionary) -> void:
	_update_display(stats)

func _update_display(stats: Dictionary) -> void:
	if _magie_label:
		_magie_label.text = "Magie : " + str(stats.get("magie", 0))
	if _score_label:
		_score_label.text = "Score : " + str(stats.get("score", 0))

	# Animation subtile (Flash ou Scale)
	var tween = create_tween()
	tween.tween_property(self, "offset:y", -5.0, 0.1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "offset:y", 0.0, 0.1).set_trans(Tween.TRANS_CUBIC)
