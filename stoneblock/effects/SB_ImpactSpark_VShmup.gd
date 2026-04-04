extends GPUParticles3D
class_name SB_ImpactSpark_VShmup

## ✨ SB_ImpactSpark_VShmup : Petit éclat lumineux à l'impact des projectiles.

func _ready() -> void:
	emitting = true
	# Auto-destruction après l'émission
	var timer = get_tree().create_timer(lifetime + 0.1)
	timer.timeout.connect(queue_free)

func setup(color: Color) -> void:
	# Appliquer la couleur au matériau
	if draw_pass_1:
		var mat = draw_pass_1.surface_get_material(0)
		if mat is StandardMaterial3D:
			var new_mat = mat.duplicate()
			new_mat.albedo_color = color
			new_mat.emission = color
			new_mat.emission_energy_multiplier = 4.0 # Très lumineux
			draw_pass_1.surface_set_material(0, new_mat)
	
	# Optionnel : Ajouter une lumière omni très brève
	var light = OmniLight3D.new()
	light.light_color = color
	light.omni_range = 3.0
	light.light_energy = 5.0
	add_child(light)
	
	var lt = create_tween()
	lt.tween_property(light, "light_energy", 0.0, 0.1)
	lt.finished.connect(light.queue_free)
