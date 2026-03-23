extends VBoxContainer
## 📈 SB_HighScoreBoard : Affiche le Top 5 des scores.

@export var title_text: String = "TOP 5 DES HÉROS"
@export var entry_scene: PackedScene # Optionnel, pour des lignes plus complexes

func _ready() -> void:
	refresh()

## Met à jour l'affichage avec les données de SB_HighScores.
func refresh() -> void:
	# Nettoyage
	for child in get_children():
		child.queue_free()
	
	# Titre
	var title = Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1, 0.8, 0)) # Or
	add_child(title)
	
	# Espacement
	add_child(HSeparator.new())
	
	# Récupération des scores via SB_HighScores (Indépendant du Core)
	var scores = []
	if SB_HighScores.instance:
		scores = SB_HighScores.instance.get_scores()
		if SB_Core.instance: SB_Core.instance.log_msg("Tableau : %d scores récupérés." % scores.size())
	else:
		if SB_Core.instance: SB_Core.instance.log_msg("Erreur : SB_HighScores.instance est introuvable !", "error")
	
	if scores.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "AUCUN SCORE ENREGISTRÉ"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.modulate.a = 0.5
		add_child(empty_lbl)
		return
		
	# Affichage des entrées
	var i = 1
	for entry in scores:
		var line = HBoxContainer.new()
		
		var rank_lbl = Label.new()
		rank_lbl.text = "#%d " % i
		rank_lbl.custom_minimum_size.x = 40
		line.add_child(rank_lbl)
		
		var name_lbl = Label.new()
		name_lbl.text = entry["name"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(name_lbl)
		
		var score_lbl = Label.new()
		score_lbl.text = str(entry["score"])
		score_lbl.add_theme_color_override("font_color", Color(0, 1, 0.5)) # Vert/Cyan cyan
		line.add_child(score_lbl)
		
		add_child(line)
		i += 1
