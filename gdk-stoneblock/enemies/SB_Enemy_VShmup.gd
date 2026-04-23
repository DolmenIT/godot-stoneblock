@tool
@icon("res://gdk-stoneblock/assets/icons/SB_Core.svg")
extends SB_4_VShmup
class_name SB_Enemy_VShmup
signal destroyed(pos: Vector3)

## 👾 SB_Enemy_VShmup : Enemi de base pour le mode SHMUP.
## Se dÃ©place vers le bas et explose au contact ou sous les tirs.

@export var speed: float = 0.0
@export var health: float = 15.0
@export var health_max: float = 15.0
@export var damage: float = 10.0

@export_group("UI Feedback")
@export var show_health_bar: bool = true
@export var health_bar_y_offset: float = -1.5

@export_group("Combat")
## ScÃ¨ne du projectile tirÃ© par l'ennemi.
@export var projectile_scene: PackedScene = preload("res://gdk-stoneblock/projectiles/SB_Projectile_Enemy_VShmup.tscn")
## Intervalle entre deux tirs (secondes).
@export var fire_interval: float = 1.6
## Chance de tirer Ã  chaque intervalle (0 Ã  1).
@export var fire_chance: float = 0.8
## DurÃ©e de l'alerte avant le tir (secondes).
@export var warning_duration: float = 0.6

@export var explosion_scene: PackedScene = preload("res://gdk-stoneblock/effects/SB_Explosion_VShmup.tscn")
## ScÃ¨ne du texte flottant de combo Ã  la mort.
@export var floating_text_scene: PackedScene = preload("res://gdk-stoneblock/effects/SB_Floating_Text_CHS.tscn")
## ScÃ¨ne des Ã©tincelles d'impact (IP-072).
@export var impact_spark_scene: PackedScene = preload("res://gdk-stoneblock/effects/SB_ImpactSpark_VShmup.tscn")

@export_group("Loot (Drops)")
@export_subgroup("Static Loots")
## Premier slot de loot (ex: Ã©nergie).
@export var loot_1_scene: PackedScene = preload("res://gdk-stoneblock/pickups/SB_Loot_Energy.tscn")
@export var loot_1_min: int = 1
@export var loot_1_max: int = 3

## DeuxiÃ¨me slot de loot (ex: bouclier).
@export var loot_2_scene: PackedScene = preload("res://gdk-stoneblock/pickups/SB_Loot_Shield.tscn")
@export var loot_2_min: int = 0
@export var loot_2_max: int = 1

## TroisiÃ¨me slot de loot (ex: piÃ¨ces).
@export var loot_3_scene: PackedScene = preload("res://gdk-stoneblock/pickups/SB_Loot_Coin.tscn")
@export var loot_3_min: int = 2
@export var loot_3_max: int = 4

@export_subgroup("Dynamic Loots")
@export var triple_shot_scene: PackedScene = preload("res://gdk-stoneblock/pickups/SB_Pickup_TripleShot.tscn")
@export var triple_shot_chance: float = 0.15

@export_group("Vessel Parameters")
## ModÃ¨le 3D de l'ennemi (ScÃ¨ne GLB/TSCN). Si dÃ©fini, remplace le visuel par dÃ©faut.
@export var vessel_scene: PackedScene :
	set(v):
		vessel_scene = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()
## Rotation corrective Ã  appliquer au modÃ¨le 3D.
@export var vessel_rotation: Vector3 = Vector3.ZERO :
	set(v):
		vessel_rotation = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()
## Ã‰chelle du modÃ¨le 3D.
@export var vessel_scale: float = 1.25 :
	set(v):
		vessel_scale = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

@export_group("Visual Style (PBR Override)")
## Si activÃ©, Ã©crase les rÃ©glages Metallic/Roughness du modÃ¨le importÃ©.
@export var use_pbr_override: bool = true:
	set(v):
		use_pbr_override = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()
## Aspect mÃ©tallique (0=Plastique/Mat, 1=MÃ©tal).
@export_range(0.0, 1.0) var vessel_metallic: float = 0.0:
	set(v):
		vessel_metallic = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()
## RugositÃ© (0=Miroir, 1=Mat/Rugueux).
@export_range(0.0, 1.0) var vessel_roughness: float = 1.0:
	set(v):
		vessel_roughness = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()
## RÃ©flexion spÃ©culaire.
@export_range(0.0, 1.0) var vessel_specular: float = 0.0:
	set(v):
		vessel_specular = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

@export_group("Visual Style (Advanced Rendering)")
## Mode de diffusion (Burley, Lambert, etc.).
@export var vessel_diffuse_mode: BaseMaterial3D.DiffuseMode = BaseMaterial3D.DIFFUSE_BURLEY:
	set(v):
		vessel_diffuse_mode = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()
## Mode spÃ©culaire (Schlick/GGX, etc.).
@export var vessel_specular_mode: BaseMaterial3D.SpecularMode = BaseMaterial3D.SPECULAR_SCHLICK_GGX:
	set(v):
		vessel_specular_mode = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

@export_group("Visual Style (Styling AvancÃ©)")
## Teinte du modÃ¨le.
@export var vessel_albedo_color: Color = Color.WHITE:
	set(v):
		vessel_albedo_color = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

@export_group("Visual Style (Shell Shield)")
## Active une coque Ã©nergÃ©tique.
@export var vessel_use_shell: bool = false:
	set(v):
		vessel_use_shell = v
		if Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

## Couleur de la coque.
@export var vessel_shell_color: Color = Color(1, 0, 0, 0.3):
	set(v):
		vessel_shell_color = v
		if _pbr_manager:
			_pbr_manager.shell_color = v
			_pbr_manager.apply_standard_settings()
		elif Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

## Ã‰paisseur de la coque.
@export_range(0.0, 0.5) var vessel_shell_thickness: float = 0.02:
	set(v):
		vessel_shell_thickness = v
		if _pbr_manager:
			_pbr_manager.shell_thickness = v
			_pbr_manager.apply_standard_settings()
		elif Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

## Active l'Ã©clat de la coque.
@export var vessel_enable_shell_glow: bool = false:
	set(v):
		vessel_enable_shell_glow = v
		if _pbr_manager:
			_pbr_manager.enable_shell_glow = v
			_pbr_manager.apply_standard_settings()
		elif Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

## IntensitÃ© de l'Ã©clat.
@export_range(0.0, 16.0) var vessel_shell_glow_energy: float = 1.0:
	set(v):
		vessel_shell_glow_energy = v
		if _pbr_manager:
			_pbr_manager.shell_glow_energy = v
			_pbr_manager.apply_standard_settings()
		elif Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

## CatÃ©gorie de Bloom pour ce vaisseau.
@export var vessel_bloom_category: SB_StandardModel.BloomCategory = SB_StandardModel.BloomCategory.NONE:
	set(v):
		vessel_bloom_category = v
		if _pbr_manager:
			_pbr_manager.bloom_category = v
			_pbr_manager.apply_standard_settings()
		elif Engine.is_editor_hint() and is_node_ready(): _refresh_visuals()

var _pivot_ref: Node3D
var _visual_nodes: Array[Node3D] = []
var _flash_material: ShaderMaterial = ShaderMaterial.new()
var _pbr_manager: SB_StandardModel # Le composant de maÃ®trise visuelle
var _fire_timer: float = 0.0
var _is_warning: bool = false
var _warning_tween: Tween
var _game_mode_ref: Node
var _is_visible: bool = true # Par dÃ©faut visible pour ne pas bloquer les tirs
var _health_bar: SB_HealthBar3D

@export_group("Movement & Activation")
## Distance (Z) Ã  partir de laquelle l'ennemi s'active par rapport au pivot camÃ©ra.
@export var activation_threshold: float = 45.0
## Si activÃ©, l'ennemi ignore son propre mouvement pour suivre celui de son parent (vague/groupe).
@export var follow_group: bool = false
## Afficher un indicateur 360Â° quand l'ennemi est hors-champ.
@export var show_incoming_warning: bool = true
## Distance maximale d'affichage de l'alerte (en mÃ¨tres).
@export var warning_max_distance: float = 105.0
var _is_active: bool = false

func _refresh_visuals() -> void:
	if not _flash_material.shader:
		_flash_material.shader = load("res://gdk-stoneblock/shaders/SB_HitFlash.gdshader")

	# Instanciation dynamique si spÃ©cifiÃ©
	if vessel_scene:
		_hide_mesh()
		
		var pivot = get_node_or_null("VesselPivot")
		if not pivot:
			pivot = Node3D.new()
			pivot.name = "VesselPivot"
			add_child(pivot)
		
		pivot.scale = Vector3(vessel_scale, vessel_scale, vessel_scale)
		
		# On nettoie uniquement les vaisseaux (pas le manager PBR s'il existe)
		for child in pivot.get_children():
			if child != _pbr_manager:
				child.queue_free()
		
		var vessel = vessel_scene.instantiate()
		pivot.add_child(vessel)
		vessel.rotation_degrees = vessel_rotation
		
		# On applique l'override de matÃ©riau si demandÃ© (MaÃ®trise du glossy)
		if use_pbr_override:
			if not _pbr_manager:
				_pbr_manager = SB_StandardModel.new()
				_pbr_manager.name = "PBR_Manager"
				pivot.add_child(_pbr_manager)
			
			_pbr_manager.target_node = vessel
			_pbr_manager.albedo_color = vessel_albedo_color
			
			_pbr_manager.metallic = vessel_metallic
			_pbr_manager.roughness = vessel_roughness
			_pbr_manager.specular = vessel_specular
			_pbr_manager.diffuse_mode = vessel_diffuse_mode
			_pbr_manager.specular_mode = vessel_specular_mode
			
			# ParamÃ¨tres de coque
			_pbr_manager.enable_shell = vessel_use_shell
			_pbr_manager.shell_color = vessel_shell_color
			_pbr_manager.shell_thickness = vessel_shell_thickness
			_pbr_manager.enable_shell_glow = vessel_enable_shell_glow
			_pbr_manager.shell_glow_energy = vessel_shell_glow_energy
			_pbr_manager.bloom_category = vessel_bloom_category
			
			_pbr_manager.apply_standard_settings()
		elif _pbr_manager:
			_pbr_manager.queue_free()
			_pbr_manager = null
		
		# On rÃ©cupÃ¨re les meshs pour le flash
		_visual_nodes.clear()
		_find_visual_nodes(vessel)
	else:
		_visual_nodes.clear()
		_find_visual_nodes(self)

func _ready() -> void:
	_refresh_visuals()
	
	# Connexion aux signaux de collision (SÃ©curisÃ©e)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	_setup_health_ui()
	
	# Debug Log
	print("[Enemy] Spawned with Health: ", health, " / ", health_max)
	
	if Engine.is_editor_hint(): return
	
	# Ajout au groupe pour la dÃ©tection par les projectiles
	add_to_group("enemies")
	
	# Recherche du pivot pour le cleanup
	var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
	if gm:
		_game_mode_ref = gm
		if "camera_pivot" in gm:
			_pivot_ref = gm.camera_pivot
	
	# Ajout dynamique de l'indicateur d'alerte
	if show_incoming_warning:
		var indicator = SB_TargetIndicator_VShmup.new()
		indicator.max_distance = warning_max_distance
		add_child(indicator)

func _process(delta: float) -> void:
	# Gestion du rÃ©veil si inactif (IgnorÃ© si gÃ©rÃ© par un groupe)
	if not _is_active:
		if not follow_group and _game_mode_ref and _game_mode_ref.camera_pivot:
			# Distance relative au pivot (Z nÃ©gatif = au-dessus de l'Ã©cran)
			var dist_z = global_position.z - _game_mode_ref.camera_pivot.global_position.z
			if dist_z >= -activation_threshold:
				_activate()
		return

	# Mouvement vers le bas (Z positif) - DÃ©sactivÃ© si gÃ©rÃ© par le groupe
	if not follow_group:
		global_position.z += speed * delta
	
	if _mm_active:
		SB_MultiMeshManager.instance.update_transform(self)
		# On synchronise aussi l'intensitÃ© du flash si nÃ©cessaire (pour les tweens en cours)
		if _mm_flash_intensity > 0.0:
			SB_MultiMeshManager.instance.set_instance_flash(self, _mm_flash_intensity, _mm_flash_color)
	
	_process_combat(delta)
	_check_cleanup()

var _mm_active: bool = false

func _activate() -> void:
	_is_active = true
	
	# Tentative d'enregistrement MultiMesh (IP-115)
	if SB_MultiMeshManager.instance and vessel_scene:
		var mesh: Mesh = null
		var mat: Material = null
		
		# On cherche le mesh dans les visual_nodes
		var layer_mask = 1
		for node in _visual_nodes:
			if node is MeshInstance3D:
				mesh = node.mesh
				layer_mask = node.layers
				mat = node.get_surface_override_material(0)
				if not mat: mat = mesh.surface_get_material(0)
				break
		
		if mesh:
			var mm_inst = SB_MultiMeshManager.instance.register(self, mesh, mat, layer_mask)
			if mm_inst:
				_mm_active = true
				# On masque le visuel local pour Ã©viter le double rendu
				var pivot = get_node_or_null("VesselPivot")
				if pivot: pivot.visible = false
				
				# On active la compatibilitÃ© MultiMesh sur le modÃ¨le pour obtenir le bon shader via le registre
				for child in get_children():
					if child is SB_StandardModel:
						child.force_multimesh_compatibility = true
						child.apply_standard_settings()

func _exit_tree() -> void:
	if _mm_active and SB_MultiMeshManager.instance:
		SB_MultiMeshManager.instance.unregister(self)

func _process_combat(delta: float) -> void:
	if _game_mode_ref and _game_mode_ref.is_game_over: return
	
	if not _is_visible: return
	
	if not projectile_scene: return
	
	_fire_timer += delta
	
	# Gestion de l'alerte prÃ©-tir (Uniquement si l'ennemi a une chance de tirer)
	var warning_start_time = max(0.0, fire_interval - warning_duration)
	if fire_chance > 0 and _fire_timer >= warning_start_time and not _is_warning:
		_is_warning = true
		_start_warning()
	
	if _fire_timer >= fire_interval:
		_fire_timer = 0.0
		if _is_warning:
			_is_warning = false
			_stop_warning()
		if randf() < fire_chance:
			_fire()

func _start_warning() -> void:
	if _mm_active:
		_mm_flash_color = Color.RED
		_mm_flash_intensity = 1.0
	else:
		# Clignotement rouge (Mode Standard)
		for node in _visual_nodes:
			if node is MeshInstance3D:
				node.material_override = _flash_material
		
		_flash_material.set_shader_parameter("flash_color", Color.RED)
	
	if _warning_tween: _warning_tween.kill()
	_warning_tween = create_tween().set_loops()
	_warning_tween.tween_method(_update_flash_intensity.bind(null), 0.0, 1.0, 0.1)
	_warning_tween.tween_method(_update_flash_intensity.bind(null), 1.0, 0.0, 0.1)

func _stop_warning() -> void:
	if _warning_tween:
		_warning_tween.kill()
		_warning_tween = null
	
	if _mm_active:
		_mm_flash_intensity = 0.0
		SB_MultiMeshManager.instance.set_instance_flash(self, 0.0)
	else:
		for node in _visual_nodes:
			if node is MeshInstance3D:
				node.material_override = null

func _fire() -> void:
	var bullet = projectile_scene.instantiate()
	_get_objects_container().add_child(bullet)
	
	bullet.global_position = global_position
	# Tirer vers le bas (Z+)
	bullet.direction = Vector3(0, 0, 1)

func _get_objects_container() -> Node:
	# PrioritÃ© 1 : Le parent de l'ennemi (Souvent le MaingroundViewport ou une Vague)
	# C'est l'endroit idÃ©al pour que les loots soient dÃ©posÃ©s dans le monde.
	var p = get_parent()
	if p and p is Node3D or p is SubViewport:
		return p
		
	# PrioritÃ© 2 : Le Viewport Mainground via le GameMode
	if _game_mode_ref and _game_mode_ref.get("mainground_viewport"):
		return _game_mode_ref.mainground_viewport
		
	# PrioritÃ© 3 : Recherche agressive (Secours ultime)
	var root = get_tree().root
	var target = root.find_child("MaingroundViewport", true, false)
	
	if target:
		return target
	
	# Fallback root
	return get_tree().root

func _check_cleanup() -> void:
	if not _pivot_ref: return
	
	# Si l'ennemi est trop loin derriÃ¨re le pivot (en bas de l'Ã©cran)
	if global_position.z > _pivot_ref.global_position.z + 40.0:
		queue_free()

func take_damage(amount: float) -> void:
	health -= amount
	_update_health_ui()
	_hit_flash()
	if health <= 0:
		_explode()

func _hit_flash() -> void:
	if _is_warning: _stop_warning()
	
	if _mm_active:
		_mm_flash_color = Color.WHITE
		var tween = create_tween()
		tween.tween_property(self, "_mm_flash_intensity", 1.0, 0.0) # Instant set
		tween.tween_property(self, "_mm_flash_intensity", 0.0, 0.15)
		tween.finished.connect(func(): SB_MultiMeshManager.instance.set_instance_flash(self, 0.0))
		return

	for node in _visual_nodes:
		if node is MeshInstance3D:
			var old_layers = node.layers
			node.layers |= (1 << 12) # Ajout au Bloom Short (Layer 13)
			
			node.material_override = _flash_material
			_flash_material.set_shader_parameter("flash_color", Color.WHITE)
			_flash_material.set_shader_parameter("flash_modifier", 1.0)
			
			var tween = create_tween()
			tween.tween_method(_update_flash_intensity.bind(node), 1.0, 0.0, 0.15)
			tween.finished.connect(func(): 
				node.material_override = null
				node.layers = old_layers # Restauration des calques d'origine
			)

func _update_flash_intensity(value: float, node: MeshInstance3D = null) -> void:
	if _mm_active:
		_mm_flash_intensity = value
		SB_MultiMeshManager.instance.set_instance_flash(self, value, _mm_flash_color)
	elif node:
		_flash_material.set_shader_parameter("flash_modifier", value)
	else:
		# Pour l'alerte prÃ©-tir
		_flash_material.set_shader_parameter("flash_modifier", value)

var _mm_flash_intensity: float = 0.0
var _mm_flash_color: Color = Color.WHITE




func _explode(silent: bool = false) -> void:
	destroyed.emit(global_position)
	# Signalement du kill au GameMode (Score & Combo)
	if not silent:
		var gm = get_tree().root.find_child("Demo1_Shmup", true, false)
		if gm and gm.has_method("add_score_kill"):
			gm.add_score_kill()
			
			# Texte flottant (IP-066)
			var combo = gm.get("combo_level")
			if combo > 0 and floating_text_scene:
				var ft = floating_text_scene.instantiate()
				_get_objects_container().add_child(ft)
				ft.global_position = global_position
				ft.setup(str(combo) + " KILL")
	
	# Explosion visuelle
	if explosion_scene:
		var exp_instance = explosion_scene.instantiate()
		get_parent().add_child(exp_instance)
		exp_instance.global_position = global_position
	
	# Loot : Chance de lÃ¢cher un Power-up Triple Shot
	if triple_shot_scene and randf() < triple_shot_chance:
		var spawn_pos = global_position
		var ts = triple_shot_scene.instantiate()
		_get_objects_container().add_child(ts)
		ts.global_position = spawn_pos
	
	# Drops Fixes (GÃ©nÃ©riques)
	_spawn_loot_group(loot_1_scene, randi_range(loot_1_min, loot_1_max))
	_spawn_loot_group(loot_2_scene, randi_range(loot_2_min, loot_2_max))
	_spawn_loot_group(loot_3_scene, randi_range(loot_3_min, loot_3_max))
	
	queue_free()

func _spawn_loot_group(scene: PackedScene, count: int) -> void:
	if not scene: 
		print("[Enemy] SKIP Drop : ScÃ¨ne de loot null.")
		return
	if count <= 0: return
	
	var container = _get_objects_container()
	
	var spawn_pos = global_position
	for i in range(count):
		var loot = scene.instantiate()
		container.add_child(loot)
		loot.global_position = spawn_pos
		
		# Ã‰jection alÃ©atoire pour l'effet visuel de dispersion
		var force = randf_range(4.0, 12.0)
		var angle = randf_range(0, PI * 2)
		if "velocity" in loot:
			loot.velocity = Vector3(cos(angle), 0, sin(angle)) * force

func _on_area_entered(area: Area3D) -> void:
	# Si touchÃ© par un projectile
	if area is SB_Projectile_VShmup or area.name.contains("Projectile"):
		# Utilisation des dÃ©gÃ¢ts portÃ©s par le projectile
		var dmg = area.get("damage") if "damage" in area else 1.0
		
		# Feedback d'impact (IP-072)
		var color = area.get("bullet_color") if "bullet_color" in area else Color.WHITE
		var dir = area.get("direction") if "direction" in area else Vector3.ZERO
		_spawn_impact_visual(area.global_position, color)
		_hit_shake(dir)
		
		take_damage(dmg)
		
		if area.has_method("explode"):
			area.explode()
		else:
			area.queue_free()

func _spawn_impact_visual(pos: Vector3, color: Color) -> void:
	if not impact_spark_scene: return
	var spark = impact_spark_scene.instantiate()
	_get_objects_container().add_child(spark)
	spark.global_position = pos
	if spark.has_method("setup"):
		spark.setup(color)

func _hit_shake(dir: Vector3) -> void:
	var pivot = get_node_or_null("VesselPivot")
	if not pivot: return
	
	var strength = 0.25
	var impulse = dir.normalized() * strength
	
	var st = create_tween()
	# On pousse dans la direction du tir
	st.tween_property(pivot, "position", impulse, 0.04).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Rebond en arriÃ¨re (attÃ©nuÃ©)
	st.tween_property(pivot, "position", -impulse * 0.4, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	# Retour au centre
	st.tween_property(pivot, "position", Vector3.ZERO, 0.05)

func _on_body_entered(body: Node3D) -> void:
	# Si collision avec le joueur -> DEGATS
	if body.name.contains("Player") or body.has_method("take_damage"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		_explode(true)

func _hide_mesh() -> void:
	# On cherche tous les meshs enfants pour Ãªtre sÃ»r
	for child in get_children():
		if child is VisualInstance3D: child.visible = false
		for sub_child in child.get_children():
			if sub_child is VisualInstance3D: sub_child.visible = false

func _find_visual_nodes(root: Node) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			_visual_nodes.append(child)
		_find_visual_nodes(child)

func _setup_health_ui() -> void:
	if Engine.is_editor_hint() or not show_health_bar: return
	
	_health_bar = SB_HealthBar3D.new()
	_health_bar.name = "HealthBar3D"
	_health_bar.max_value = health_max
	_health_bar.value = health
	_health_bar.text_pixel_size = 0.01 # Un peu plus grand (x2)
	_health_bar.position = Vector3(0, 0, health_bar_y_offset)
	add_child(_health_bar)
	
	# --- AJOUT AU BLOOM MEDIUM (IP-102) ---
	# Mask 2049 = Calque 1 (Jeu) + Calque 12 (Bloom Medium / Balanced)
	_health_bar.set_layers(1 | (1 << 11)) 
	
	_update_health_ui()

func _update_health_ui() -> void:
	if not _health_bar: return
	_health_bar.value = health
	_health_bar.value = health
