@tool
extends Node3D
class_name SB_BossController_VShmup

## 👑 SB_BossController_VShmup : Gère le mouvement global du Boss.
## Maintient une distance Z fixe par rapport à la caméra et gère le balayage X.

@export_group("Z Dynamic Movement")
## Distance par rapport au pivot où le boss commence à bouger (vitesse 0).
@export var z_start_dist: float = -5.0
## Vitesse initiale à la distance de départ.
@export var z_start_speed: float = 0.0
## Distance par rapport au pivot où le boss atteint sa vitesse de croisière.
@export var z_target_dist: float = 0.0
## Vitesse cible (vitesse de défilement du niveau).
@export var z_target_speed: float = -10.0

@export_group("Horizontal Movement (Sine Wave)")
## Amplitude du balayage horizontal (en mètres de chaque côté).
@export var sweep_amplitude: float = 12.0
## Vitesse du balayage (fréquence).
@export var sweep_speed: float = 0.8
## Si vrai, le balayage horizontal est actif dès l'activation.
@export var is_sweeping: bool = true

var _pivot_ref: Node3D
var _game_mode_ref: Node
var _is_active: bool = false
var _initial_x: float = 0.0
var _time: float = 0.0

@export_group("Activation")
## Distance (Z) à partir de laquelle le boss s'active par rapport au pivot caméra.
@export var activation_threshold: float = 55.0

func _ready() -> void:
	_initial_x = global_position.x
	
	if Engine.is_editor_hint(): return
	
	# Recherche robuste : on remonte l'arbre pour trouver le GameMode
	var node = self
	while node:
		if node.name == "Demo1_Shmup" or node.has_method("add_score_kill"):
			_game_mode_ref = node
			break
		node = node.get_parent()
	
	if _game_mode_ref:
		_pivot_ref = _game_mode_ref.camera_pivot
		# Si la variable n'est pas encore remplie (problème d'init dans le GameMode), on cherche le nœud manuellement
		if not _pivot_ref:
			_pivot_ref = _game_mode_ref.get_node_or_null("Viewports_Layer/MaingroundViewportContainer/MaingroundViewport/Camera_Pivot")
		
		if _pivot_ref:
			print("[BossDebug] Pivot trouvé (Manuel) : ", _pivot_ref.name, " à Z=", _pivot_ref.global_position.z)
		else:
			print("[BossDebug] ERREUR : Impossible de trouver le nœud 'Camera_Pivot' dans le GameMode")
	else:
		print("[BossDebug] ERREUR : Impossible de trouver le GameMode 'Demo1_Shmup' en remontant l'arbre")
	
	# On s'assure que les enfants (segments) ne bougent pas de façon autonome
	_configure_children()
	
	# On s'assure que les enfants (segments) ne bougent pas de façon autonome
	_configure_children()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if not _pivot_ref: return
	
	# Gestion de l'activation par proximité Z
	if not _is_active:
		var dist_z = global_position.z - _pivot_ref.global_position.z
		# Log de distance pour comprendre pourquoi ça ne s'active pas
		if Engine.get_frames_drawn() % 60 == 0:
			print("[BossDebug] En attente d'activation... DistZ: %.2f / Seuil: %.2f" % [dist_z, -activation_threshold])
		
		if dist_z >= -activation_threshold:
			_activate()
		return

	# 1. Calcul de la vitesse dynamique Z
	var current_offset = global_position.z - _pivot_ref.global_position.z
	
	# Interpolation de la vitesse entre Start et Target
	# t = (pos - start) / (target - start)
	var t = 0.0
	if abs(z_target_dist - z_start_dist) > 0.001:
		t = clamp((current_offset - z_start_dist) / (z_target_dist - z_start_dist), 0.0, 1.0)
	
	var current_speed = lerp(z_start_speed, z_target_speed, t)
	
	# DEBUG
	if Engine.get_frames_drawn() % 10 == 0:
		print("[BossDebug] OffsetZ: %.2f | T: %.2f | Speed: %.2f | PivotZ: %.2f" % [current_offset, t, current_speed, _pivot_ref.global_position.z])
	
	# Application du mouvement mondial
	global_position.z += current_speed * delta
	
	# 2. Balayage X (Mouvement sinusoïdal)
	if is_sweeping:
		_time += delta * sweep_speed
		global_position.x = _initial_x + sin(_time) * sweep_amplitude

func _activate() -> void:
	_is_active = true
	# Ré-exécution forcée de la configuration
	_configure_children()
	
	print("[BossController] Boss activé ! Début accélération vers ", z_target_speed, "m/s")

func _configure_children() -> void:
	# Parcourt récursivement les enfants pour désactiver leur mouvement propre
	for child in get_children():
		_setup_node_as_follower(child)

func _setup_node_as_follower(node: Node) -> void:
	if node is SB_Enemy_VShmup:
		node.follow_group = true
		node.speed = 0.0 # Force la vitesse à 0 pour éviter le défilement indépendant
	
	for child in node.get_children():
		_setup_node_as_follower(child)
