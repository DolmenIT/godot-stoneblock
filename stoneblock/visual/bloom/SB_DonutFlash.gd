extends MeshInstance3D

## 🍩 SB_DonutFlash : Effet d'anneau expansif pour le bloom.

func setup(p_layers: int, p_color: Color, p_duration: float) -> void:
	# Configuration initiale
	layers = p_layers
	
	# DUPLICATION CRUCIALE : On duplique le matériau pour que chaque donut 
	# ait sa propre animation (sinon les suivants restent invisibles/finis)
	var base_mat = get_active_material(0)
	if base_mat:
		var mat = base_mat.duplicate()
		set_surface_override_material(0, mat)
		
		mat.set_shader_parameter("bloom_color", p_color)
		
		var tween = create_tween().set_parallel(true)
		
		# Animation du rayon [0.0 -> 0.2] 
		# Sur un mesh de 500, 0.15 couvre l'écran diagonalement. 0.2 assure de sortir proprement.
		tween.tween_property(mat, "shader_parameter/radius", 0.2, p_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
		# Animation de l'alpha [1.0 -> 0.0]
		tween.tween_property(mat, "shader_parameter/alpha", 0.0, p_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
		# Nettoyage automatique
		tween.chain().tween_callback(queue_free)
