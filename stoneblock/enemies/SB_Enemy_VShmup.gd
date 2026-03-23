extends Area3D
class_name SB_Enemy_VShmup

## 👾 SB_Enemy_VShmup : Enemi de base pour le mode SHMUP.
## Se déplace vers le bas et explose au contact ou sous les tirs.

@export var speed: float = 0.0
@export var health: float = 1.0
@export var damage: float = 10.0

@export var explosion_scene: PackedScene = preload("res://stoneblock/effects/SB_Explosion_VShmup.tscn")
@export var fragment_scene: PackedScene = preload("res://stoneblock/pickups/SB_EnergyFragment_VShmup.tscn")

var _pivot_ref: Node3D

func _ready() -> void:
	# Connexion aux signaux de collision
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Recherche du pivot pour le cleanup
	var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
	if gm and "camera_pivot" in gm:
		_pivot_ref = gm.camera_pivot

func _process(delta: float) -> void:
	# Mouvement vers le bas (Z positif car on descend l'écran)
	# Mais attention : le monde descend aussi. 
	# Pour que l'ennemi approche le joueur, il doit aller plus vite que le scrolling ou dans la direction opposée.
	# Si direction.z = 1, il descend l'écran. 
	global_position.z += speed * delta
	
	_check_cleanup()

func _check_cleanup() -> void:
	if not _pivot_ref: return
	
	# Si l'ennemi est trop loin derrière le pivot (en bas de l'écran)
	if global_position.z > _pivot_ref.global_position.z + 40.0:
		queue_free()

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		_explode()

func _explode(silent: bool = false) -> void:
	# Signalement du kill au GameMode (Score & Combo)
	if not silent:
		var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
		if gm and gm.has_method("add_score_kill"):
			gm.add_score_kill()
	
	# Explosion visuelle
	if explosion_scene:
		var exp_instance = explosion_scene.instantiate()
		get_parent().add_child(exp_instance)
		exp_instance.global_position = global_position
	
	# Loot de fragments d'énergie (5 à 10)
	if fragment_scene:
		var count = randi_range(5, 10)
		for i in range(count):
			var frag = fragment_scene.instantiate()
			get_parent().add_child(frag)
			# Position de départ
			frag.global_position = global_position
			# Éjection aléatoire (Vitesse et direction propre)
			var force = randf_range(5.0, 15.0)
			var angle = randf_range(0, PI * 2)
			frag.velocity = Vector3(cos(angle), 0, sin(angle)) * force
	
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	# Si touché par un projectile
	if area is SB_Projectile_VShmup or area.name.contains("Projectile"):
		take_damage(1.0)
		if area.has_method("explode"):
			area.explode()
		else:
			area.queue_free()

func _on_body_entered(body: Node3D) -> void:
	# Si collision avec le joueur -> GAME OVER
	if body.name.contains("Player") or body is SB_Player_VShmup:
		if body.has_method("die"):
			body.die()
		_explode(true)
