@tool
extends Node
class_name SB_IntroAnimator_VShmup

## 🎬 SB_IntroAnimator_VShmup : Gère l'entrée cinématique du vaisseau.
## Doit être placé en enfant direct de Player_VShmup.

@export_group("Animation Settings")
## Durée de l'animation d'entrée (secondes).
@export var duration: float = 3.0
## Position cible en % de la hauteur de l'écran (0% = bas, 100% = haut).
@export var target_height_percent: float = 25.0
## Décalage supplémentaire pour commencer bien hors-champ.
@export var start_offset_z: float = 10.0
## Ease type pour le mouvement.
@export var transition_type: Tween.TransitionType = Tween.TRANS_SINE

var _player: SB_Player_VShmup
var _pivot: Node3D
var _current_offset_z: float = 0.0
var _is_animating: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	_player = get_parent() as SB_Player_VShmup
	if not _player:
		push_warning("[IntroAnimator] Le parent doit être de type SB_Player_VShmup.")
		return
		
	# On attend la fin de l'init des autres nœuds pour être sûr de trouver le pivot
	call_deferred("_start_intro")

func _start_intro() -> void:
	# Recherche du pivot (comme le fait le joueur)
	_pivot = get_tree().root.find_child("World_Scroll_Pivot", true, false)
	if not _pivot:
		_pivot = get_tree().root.find_child("Camera_Pivot", true, false)
	
	if not _pivot:
		push_error("[IntroAnimator] Impossible de trouver le pivot de la caméra !")
		return

	# 1. Calcul des positions relatives au pivot
	var limit_z = _player.vertical_limit if "vertical_limit" in _player else 18.0
	
	# Position de départ (hors champ, tout en bas)
	var start_z = limit_z + start_offset_z
	
	# Position cible (25% du bas)
	# Le champ vertical va de -limit_z (haut) à +limit_z (bas)
	# Full height = 2 * limit_z
	var total_height = 2.0 * limit_z
	var target_z = limit_z - (total_height * (target_height_percent / 100.0))
	
	# 2. Initialisation
	_current_offset_z = start_z
	_player.set_controls_enabled(false)
	_is_animating = true
	
	# 3. Tween de l'offset
	var tween = create_tween()
	tween.set_trans(transition_type)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "_current_offset_z", target_z, duration)
	tween.finished.connect(_on_intro_finished)

func _process(_delta: float) -> void:
	if not _is_animating or not _player or not _pivot: return
	
	# Mise à jour forcée de la position du joueur pour compenser le scroll
	# On se place RELATIVEMENT au pivot qui défile
	_player.global_position.z = _pivot.global_position.z + _current_offset_z
	
	# On garde le X du joueur au centre (ou sa position actuelle)
	# _player.global_position.x = _pivot.global_position.x # Optionnel : centrer l'entrée

func _on_intro_finished() -> void:
	_is_animating = false
	if _player:
		_player.set_controls_enabled(true)
	
	if SB_Core.instance:
		SB_Core.instance.log_msg("Intro terminée ! Mission en cours.", "success")
	
	# Le composant a fini son travail, on le retire
	queue_free()
