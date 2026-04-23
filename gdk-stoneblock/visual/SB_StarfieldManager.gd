@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Visual.svg")
extends SB_Manager
class_name SB_StarfieldManager

## 🌌 SB_StarfieldManager : Générateur de champ d'étoiles dynamique.
## Migré depuis Cosmic HyperSquad pour StoneBlock.

@export_group("Configuration")
@export_range(1, 2000) var star_count: int = 500
@export var star_radius_min: float = 200.0
@export var star_radius_max: float = 800.0

# Variants d'étoiles (tailles différentes avec textures)
const STAR_VARIANTS = [
	{"size": 0.025, "weight": 0.94, "texture": "res://gdk-stoneblock/assets/images/stars/dagx-star1.png", "alpha_min": 0.2, "alpha_max": 0.8},
	{"size": 0.05, "weight": 0.03, "texture": "res://gdk-stoneblock/assets/images/stars/dagx-star2.png", "alpha_min": 0.4, "alpha_max": 0.7},
	{"size": 0.1, "weight": 0.02, "texture": "res://gdk-stoneblock/assets/images/stars/dagx-star3.png", "alpha_min": 0.5, "alpha_max": 0.9},
	{"size": 0.15, "weight": 0.01, "texture": "res://gdk-stoneblock/assets/images/stars/dagx-star4.png", "alpha_min": 0.6, "alpha_max": 1.0}
]

const STAR_COLORS = [
	Color.WHITE,
	Color(0.8, 0.9, 1.0), # Bleu
	Color(1.0, 0.9, 0.7), # Jaune
	Color(1.0, 0.8, 0.6), # Orange
]

var twinkle_timer: float = 0.0
const TWINKLE_DELAY = 3.0

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	# Nettoyage et génération au runtime
	for child in get_children():
		child.queue_free()
	
	generate_starfield()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	twinkle_timer += delta
	if twinkle_timer >= TWINKLE_DELAY:
		twinkle_timer = 0.0
		animate_random_stars()

func generate_starfield() -> void:
	print("[Starfield] Génération de ", star_count, " étoiles...")
	
	for i in range(star_count):
		var variant = _choose_variant()
		var pos = _random_sphere_position(star_radius_min, star_radius_max)
		var star = _create_star(variant, pos)
		add_child(star)

func _choose_variant() -> Dictionary:
	var rand = randf()
	var cumulative = 0.0
	for variant in STAR_VARIANTS:
		cumulative += variant.weight
		if rand <= cumulative: return variant
	return STAR_VARIANTS[0]

func _random_sphere_position(min_r: float, max_r: float) -> Vector3:
	var theta = randf() * TAU
	var phi = acos(randf_range(-1.0, 1.0))
	var r = randf_range(min_r, max_r)
	
	return Vector3(
		r * sin(phi) * cos(theta),
		r * cos(phi),
		r * sin(phi) * sin(theta)
	)

func _create_star(variant: Dictionary, pos: Vector3) -> Sprite3D:
	var star = Sprite3D.new()
	star.texture = load(variant.texture)
	star.pixel_size = variant.size
	star.position = pos
	star.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# Billboard pour que l'étoile regarde toujours la caméra
	star.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = STAR_COLORS[randi() % STAR_COLORS.size()]
	mat.albedo_color.a = randf_range(variant.alpha_min, variant.alpha_max)
	
	star.material_override = mat
	star.layers = 1 # Calque 1 pour le BackgroundViewport
	
	return star

func animate_random_stars() -> void:
	var children = get_children()
	if children.is_empty(): return
	
	var to_animate = max(1, children.size() / 20)
	for i in range(to_animate):
		var star = children[randi() % children.size()] as Sprite3D
		if star:
			var tween = create_tween()
			var base_a = star.modulate.a
			tween.tween_property(star, "modulate:a", 0.2, 0.5)
			tween.tween_property(star, "modulate:a", base_a, 0.5)
