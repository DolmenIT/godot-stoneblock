extends Node
class_name SB_TimeManager

## ⏳ SB_TimeManager : Gère les effets de Slow-Motion (Bullet Time).
## Ce composant manipule Engine.time_scale avec des transitions fluides (Tweens).

@export var overlay_rect: ColorRect

static var instance: SB_TimeManager

var _hit_tween: Tween
var _death_tween: Tween
var _turbo_tween: Tween

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	if not overlay_rect:
		# Recherche robuste pour le GDK (même si le chemin TSCN échoue)
		var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
		if gm:
			overlay_rect = gm.find_child("BulletTimeOverlay", true, false)
	
	if overlay_rect:
		if overlay_rect.material:
			overlay_rect.material.set_shader_parameter("intensity", 0.0)
		else:
			push_error("TimeManager: L'overlay n'a pas de matériau !")
		overlay_rect.hide() # On le cache par défaut
	else:
		push_warning("TimeManager: overlay_rect est NULL au démarrage. Tentative de récupération dynamique...")

func _exit_tree() -> void:
	if instance == self:
		instance = null
		Engine.time_scale = 1.0

## 🎯 Hit Slowmo : Ralentissement temporaire sélectif.
## Appelé quand le joueur prend un coup.
func hit_slowmo(duration: float = 1.0, factor: float = 0.2) -> void:
	if _death_tween and _death_tween.is_running(): return # La mort prime
	
	if _hit_tween: _hit_tween.kill()
	_hit_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Transition vers le ralenti
	_hit_tween.tween_property(Engine, "time_scale", factor, 0.05)
	
	if overlay_rect:
		overlay_rect.show() # On s'assure qu'il est visible
		if overlay_rect.material:
			# Couleur bleue pour le hit
			overlay_rect.material.set_shader_parameter("filter_color", Color(0.0, 0.4, 0.8, 0.4))
			_hit_tween.parallel().tween_property(overlay_rect.material, "shader_parameter/intensity", 1.0, 0.1)
		else:
			push_error("TimeManager: overlay_rect n'a pas de matériau !")
	else:
		# Tentative de récupération de secours si l'instance a été perdue ou jamais trouvée
		_try_find_overlay()
		if overlay_rect:
			overlay_rect.show()
		else:
			push_error("TimeManager: Impossible de trouver l'overlay pour le hit_slowmo !")
		
	# Attente
	_hit_tween.tween_interval(duration * factor) # Ajusté au time_scale
	
	# Retour à la normale
	_hit_tween.tween_property(Engine, "time_scale", 1.0, 0.2)
	if overlay_rect and overlay_rect.material:
		_hit_tween.parallel().tween_property(overlay_rect.material, "shader_parameter/intensity", 0.0, 0.3)

## 💀 Death Slowmo : Ralentissement global dramatique.
## Appelé lors de la défaite.
func death_slowmo(factor: float = 0.1) -> void:
	if _hit_tween: _hit_tween.kill()
	if _death_tween: _death_tween.kill()
	
	_death_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Transition lente vers un ralenti extrême
	_death_tween.tween_property(Engine, "time_scale", factor, 0.5)
	
	if overlay_rect:
		overlay_rect.show()
		if overlay_rect.material:
			# Couleur rouge pour la mort
			overlay_rect.material.set_shader_parameter("filter_color", Color(0.8, 0.1, 0.1, 0.6))
			_death_tween.parallel().tween_property(overlay_rect.material, "shader_parameter/intensity", 1.0, 0.5)
	
	if SB_Core.instance:
		SB_Core.instance.log_msg("DÉFAITE : Ralentissement temporel activé.", "warning")

## 🔄 Reset Time : Remet le temps à sa vitesse normale.
func reset_time_scale() -> void:
	if _hit_tween: _hit_tween.kill()
	if _death_tween: _death_tween.kill()
	if _turbo_tween: _turbo_tween.kill()
	if overlay_rect:
		if overlay_rect.material:
			overlay_rect.material.set_shader_parameter("intensity", 0.0)
		overlay_rect.hide()
	Engine.time_scale = 1.0

## ⚡ Turbo Mode Visuals : Halo vert lors de l'accélération.
func set_turbo_mode(active: bool) -> void:
	_try_find_overlay()
	if not overlay_rect or not overlay_rect.material: return
	
	if _turbo_tween: _turbo_tween.kill()
	_turbo_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if active:
		overlay_rect.show()
		# Teinte verte pour le turbo
		overlay_rect.material.set_shader_parameter("filter_color", Color(0.1, 0.8, 0.1, 0.4))
		_turbo_tween.tween_property(overlay_rect.material, "shader_parameter/intensity", 1.0, 0.5)
	else:
		_turbo_tween.tween_property(overlay_rect.material, "shader_parameter/intensity", 0.0, 0.3)
		_turbo_tween.finished.connect(func(): if not active: overlay_rect.hide())

func _try_find_overlay() -> void:
	if overlay_rect and is_instance_valid(overlay_rect): return
	
	# Recherche aggressive dans tout l'arbre
	overlay_rect = get_tree().root.find_child("BulletTimeOverlay", true, false)
	
	if not overlay_rect:
		# Tentative via le groupe (au cas où on l'ajoute plus tard)
		var nodes = get_tree().get_nodes_in_group("overlay_bullet_time")
		if not nodes.is_empty():
			overlay_rect = nodes[0]
	
	if overlay_rect:
		print("[TimeManager] Overlay trouvé : ", overlay_rect.get_path())
		if overlay_rect.material:
			overlay_rect.material.set_shader_parameter("intensity", 0.0)
