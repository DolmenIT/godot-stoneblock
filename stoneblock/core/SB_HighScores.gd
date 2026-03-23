extends Node
class_name SB_HighScores
## 🏆 SB_HighScores : Gestionnaire de High Scores Persistant.
## Gère le Top 5 des meilleurs scores et les enregistre sur le disque.

static var instance: SB_HighScores

func _enter_tree() -> void:
	instance = self
	if SB_Core.instance:
		SB_Core.instance.log_msg("Système de High Scores enregistré.", "success")

const SAVE_PATH = "user://highscores.json"

## Liste des scores (Array de Dictionnaires : [{"name": "...", "score": 0}, ...])
var _scores: Array = []

func _ready() -> void:
	load_scores()

## Retourne la liste triée des scores.
func get_scores() -> Array:
	return _scores

## Soumet un nouveau score au classement.
func submit_score(p_score: int, p_name: String = "Veuve Noire") -> bool:
	if SB_Core.instance: SB_Core.instance.log_msg("Soumission score : %d (%s)" % [p_score, p_name])
	
	if p_score <= 0: 
		return false
	
	var entry = {"name": p_name, "score": p_score, "date": Time.get_date_string_from_system()}
	_scores.append(entry)
	
	_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	
	if _scores.size() > 5:
		_scores = _scores.slice(0, 5)
	
	save_scores()
	return _scores.has(entry)

## Sauvegarde les scores sur le disque au format JSON.
func save_scores() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(_scores)
		file.store_string(json_string)
		file.close()
		if SB_Core.instance: SB_Core.instance.log_msg("Scores sauvegardés sur le disque.", "success")
	else:
		if SB_Core.instance: SB_Core.instance.log_msg("Erreur de sauvegarde des scores !", "error")

## Charge les scores depuis le disque.
func load_scores() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_scores = []
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			_scores = json.get_data()
			if SB_Core.instance: SB_Core.instance.log_msg("Scores chargés (%d entrées)." % _scores.size(), "info")
		file.close()
