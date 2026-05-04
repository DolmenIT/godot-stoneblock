@tool
class_name SB_Button_3d
extends Node3D

## 🔘 SB_Button_3d : Composant hautement personnalisable
signal pressed
signal hovered(data: Dictionary)

enum SBViewMode { TOP_DOWN, FRONT }
enum SBPreviewBlendMode { NORMAL, MULTIPLY, ADD, SCREEN, OVERLAY, DARKEN, LIGHTEN, DIFFERENCE }

@export_group("Layout")
## Mode de vue (TOP_DOWN = au sol, FRONT = face à la caméra).
@export var view_mode: SBViewMode = SBViewMode.FRONT:
	set(v): 
		view_mode = v
		if is_node_ready(): _update_orientation()

@export_group("Thème & Styles")
## Nom de la classe de style dans le ThemeManager (ex: BTN_Play).
@export var style_class_name: String = "":
	set(v): 
		style_class_name = v
		_request_theme_refresh()
		_update_ui()

@export var metadata: Dictionary = {}

@export_group("Texte & Couleurs")
@export_multiline var text: String = "Button":
	set(v): text = v; _update_ui()
@export var font_size: int = 32:
	set(v): font_size = v; _update_ui()
@export var autowrap_mode: TextServer.AutowrapMode = TextServer.AUTOWRAP_OFF:
	set(v): autowrap_mode = v; _update_ui()
@export var text_width: float = 500.0:
	set(v): text_width = v; _update_ui()
@export var outline_size: int = 0:
	set(v): outline_size = v; _update_ui()
@export var outline_color: Color = Color.BLACK:
	set(v): outline_color = v; _update_ui()
@export var text_render_priority: int = 0:
	set(v): text_render_priority = v; _update_ui()
@export var mesh_size: Vector2 = Vector2(0.3, 0.1):
	set(v): mesh_size = v; _update_ui()

@export_subgroup("Couleurs du Texte")
@export var text_color_normal: Color = Color.WHITE:
	set(v): text_color_normal = v; _update_ui()
@export var text_color_hover: Color = Color.WHITE:
	set(v): text_color_hover = v; _update_ui()
@export var text_color_pressed: Color = Color.WHITE:
	set(v): text_color_pressed = v; _update_ui()
@export var text_color_disabled: Color = Color(0.6, 0.6, 0.6):
	set(v): text_color_disabled = v; _update_ui()

@export_subgroup("Teintes du Bouton (Modulate)")
## Décalage global de la teinte (Hue Rotation).
@export_range(0.0, 360.0) var tint_hue_shift: float = 0.0:
	set(v): tint_hue_shift = v; _update_ui()
@export var tint_normal: Color = Color.WHITE:
	set(v): tint_normal = v; _update_ui()
@export var tint_hover: Color = Color.WHITE:
	set(v): tint_hover = v; _update_ui()
@export var tint_pressed: Color = Color.WHITE:
	set(v): tint_pressed = v; _update_ui()
@export var tint_disabled: Color = Color(0.4, 0.4, 0.4):
	set(v): tint_disabled = v; _update_ui()

@export_group("Textures (Style Nineslice)")
@export var use_only_normal_texture: bool = false:
	set(v): use_only_normal_texture = v; _update_ui()
@export var normal_bg_texture: Texture2D:
	set(v): normal_bg_texture = v; _update_ui()
@export var hover_bg_texture: Texture2D:
	set(v): hover_bg_texture = v; _update_ui()
@export var pressed_bg_texture: Texture2D:
	set(v): pressed_bg_texture = v; _update_ui()

@export_subgroup("Multi-Layers Content")
## Mélange entre la photo et le fond (0 = Photo seule, 1 = Fond seul).
@export_range(0.0, 1.0) var preview_mix: float = 0.1:
	set(v): preview_mix = v; _update_ui()
## Mode de fusion entre la photo et le fond.
@export var preview_blend_mode: SBPreviewBlendMode = SBPreviewBlendMode.SCREEN:
	set(v): preview_blend_mode = v; _update_ui()
## Mode d'étirement de la photo (STRETCH = étiré, COVER = remplissage avec ratio).
@export var preview_stretch_mode: SB_NineSlice3D.SBStretchMode = SB_NineSlice3D.SBStretchMode.COVER:
	set(v): preview_stretch_mode = v; _update_ui()
## Texture de la couche intermédiaire (Layer1_Preview).
@export var image_preview_texture: Texture2D:
	set(v): image_preview_texture = v; _update_ui()
## Texture de la couche de finition (Layer2_Frame).
@export var image_frame_texture: Texture2D:
	set(v): image_frame_texture = v; _update_ui()

@export_subgroup("Slice Margins")
@export var slice_margin_left: float = 32.0:
	set(v): slice_margin_left = v; _update_ui()
@export var slice_margin_top: float = 32.0:
	set(v): slice_margin_top = v; _update_ui()
@export var slice_margin_right: float = 32.0:
	set(v): slice_margin_right = v; _update_ui()
@export var slice_margin_bottom: float = 32.0:
	set(v): slice_margin_bottom = v; _update_ui()

@export_subgroup("Texture Cropping (Empty Margins)")
@export var crop_left: float = 10.0:
	set(v): crop_left = v; _update_ui()
@export var crop_top: float = 10.0:
	set(v): crop_top = v; _update_ui()
@export var crop_right: float = 10.0:
	set(v): crop_right = v; _update_ui()
@export var crop_bottom: float = 10.0:
	set(v): crop_bottom = v; _update_ui()

@export_group("Transitions & Animations")
@export var is_enabled: bool = true:
	set(v): is_enabled = v; _update_ui()
@export var transition_duration: float = 0.15

@export_subgroup("Echelles (Scale) par état")
@export var base_scale: float = 1.0:
	set(v): base_scale = v; _update_ui()
@export var hover_scale_factor: float = 1.1:
	set(v): hover_scale_factor = v; _update_ui()
@export var pressed_scale_factor: float = 0.95:
	set(v): pressed_scale_factor = v; _update_ui()




@export var price: int = 0:
	set(v): price = v; _update_ui()
@export var currency_icon: Texture2D:
	set(v): currency_icon = v; _update_ui()
@export var auto_deduct: bool = true:
	set(v): auto_deduct = v; _update_ui()

@export_subgroup("Intensité Lumineuse (Pour Custom Bloom)")
@export var emission_energy_normal: float = 0.0:
	set(v): emission_energy_normal = v; _update_ui()
@export var emission_energy_hover: float = 1.5:
	set(v): emission_energy_hover = v; _update_ui()
@export var emission_energy_pressed: float = 3.75:
	set(v): emission_energy_pressed = v; _update_ui()

@export_subgroup("Layers (Cull Masks)")
@export_flags_3d_render var layer_normal: int = 1:
	set(v): layer_normal = v; _update_ui()
@export_flags_3d_render var layer_hover: int = 2049:
	set(v): layer_hover = v; _update_ui()
@export_flags_3d_render var layer_pressed: int = 3073:
	set(v): layer_pressed = v; _update_ui()
@export_flags_3d_render var layer_disabled: int = 1:
	set(v): layer_disabled = v; _update_ui()

@onready var _label: Label3D = $Label
@onready var _area: Area3D = $Area3D
var _price_display: Node3D
var _price_label: Label3D
var _price_icon: Sprite3D

var _is_hovered: bool = false
var _is_pressed: bool = false
var _tween: Tween

# Cache pour les couches visuelles (NineSlice/ThreeSlice)
var _layers: Array = []

func _ready() -> void:
	# Capturer l'échelle visuelle comme base par défaut si non définie (évite le "shrink" à 1.0)
	if base_scale == 1.0 and scale.x != 1.0:
		base_scale = scale.x

	# 1. Initialisation Thème (IP-112)
	_request_theme_refresh()
	
	# 2. Initialisation Visuelle
	_refresh_layers_cache()
	
	# Rendre la hitbox unique également
	if _area:
		var col = _area.get_node_or_null("CollisionShape3D")
		if col and col.shape:
			col.shape = col.shape.duplicate()
	
	if not Engine.is_editor_hint():
		if _area:
			_area.mouse_entered.connect(_on_mouse_entered)
			_area.mouse_exited.connect(_on_mouse_exited)
			_area.input_event.connect(_on_input_event)
	
	_update_ui()

func _update_ui() -> void:
	if not is_inside_tree(): return
	_refresh_layers_cache()
	
	# --- CIBLES (Scale & Layers & Couleurs) ---
	var target_scale_val = base_scale
	var target_emission: float = emission_energy_normal
	var target_layer: int = layer_normal
	var target_tint: Color = tint_normal
	var target_text_color: Color = text_color_normal
	
	if not Engine.is_editor_hint() and is_enabled:
		# Vérification stricte de l'occlusion pour éviter de traverser la 3D (IP-130)
		var visually_hovered = _is_hovered
		var visually_pressed = _is_pressed
		
		if (_is_hovered or _is_pressed) and _check_occlusion():
			visually_hovered = false
			visually_pressed = false
			
		if visually_pressed: 
			target_scale_val *= pressed_scale_factor
			target_emission = emission_energy_pressed
			target_layer = layer_pressed
			target_tint = tint_pressed
			target_text_color = text_color_pressed
		elif visually_hovered: 
			target_scale_val *= hover_scale_factor
			target_emission = emission_energy_hover
			target_layer = layer_hover
			target_tint = tint_hover if tint_hover != Color.WHITE else tint_normal.lightened(0.2)
			target_text_color = text_color_hover
		
		if not visually_pressed and not visually_hovered:
			target_tint = tint_normal
	
	if not Engine.is_editor_hint() and is_enabled and _is_pressed and not _check_occlusion():
		target_tint = tint_pressed if tint_pressed != Color.WHITE else tint_normal.darkened(0.2)
	elif Engine.is_editor_hint() and is_enabled:
		target_layer = layer_hover
		target_emission = emission_energy_hover
		
	if not is_enabled:
		target_layer = layer_disabled
		target_tint = tint_disabled
		target_text_color = text_color_disabled
		target_emission = 0.0

	# Application du Hue Shift global (IP-125)
	if tint_hue_shift != 0.0:
		target_tint.h = fmod(target_tint.h + tint_hue_shift / 360.0, 1.0)

	var sat = 1.0 if is_enabled else 0.0
	
	# Texture cible
	var target_tex = normal_bg_texture
	if not is_enabled:
		target_tex = normal_bg_texture
	elif not use_only_normal_texture:
		if _is_pressed:
			target_tex = pressed_bg_texture if pressed_bg_texture else normal_bg_texture
		elif _is_hovered:
			target_tex = hover_bg_texture if hover_bg_texture else normal_bg_texture

	# 1. Mise à jour des Couches (Layers)
	var first_layer = true
	for layer in _layers:
		# Synchronisation Taille
		if "size" in layer: layer.size = mesh_size
		
		# Synchronisation State Effects
		if "albedo_color" in layer: layer.albedo_color = target_tint
		if "emission_energy" in layer: layer.emission_energy = target_emission
		if "saturation" in layer: layer.saturation = sat
		
		# Synchronisation des paramètres de découpe (IP-123)
		var btn_margins = Vector4(slice_margin_left, slice_margin_top, slice_margin_right, slice_margin_bottom)
		var btn_crop = Vector4(crop_left, crop_top, crop_right, crop_bottom)
		
		if "mask_slice_margins" in layer: layer.mask_slice_margins = btn_margins
		if "mask_crop" in layer: layer.mask_crop = btn_crop

		# Application des textures spécifiques sur la PREMIÈRE couche uniquement
		if first_layer:
			if "texture" in layer: layer.texture = target_tex
			if "slice_margins" in layer: layer.slice_margins = btn_margins
			if "crop" in layer: layer.crop = btn_crop
			first_layer = false
		else:
			# Gestion des couches nommées spécifiques
			if layer.name == "Layer1_Preview" and image_preview_texture:
				layer.texture = image_preview_texture
				if "mask_texture" in layer:
					layer.mask_texture = target_tex
					layer.mask_mix = preview_mix
					layer.mask_blend_mode = preview_blend_mode
					layer.mask_albedo_color = target_tint
				if "stretch_mode" in layer:
					layer.stretch_mode = preview_stretch_mode
			elif layer.name == "Layer2_Frame" and image_frame_texture:
				layer.texture = image_frame_texture
		
		# Synchronisation Layers
		if "layers" in layer: layer.layers = target_layer
		elif layer is Node3D:
			# Si c'est un NineSlice/ThreeSlice, il a un MeshInstance3D interne
			var mesh = layer.get_node_or_null("InternalMesh")
			if mesh: mesh.layers = target_layer
	
	# 2. Mise à jour de la Collision (IP-114)
	if _area:
		var col = _area.get_node_or_null("CollisionShape3D")
		if col and col.shape is BoxShape3D:
			col.shape.size = Vector3(mesh_size.x, mesh_size.y, 0.05)
	
	if _label:
		_label.modulate = target_text_color
		_label.layers = target_layer
		_label.text = text
		_label.font_size = font_size
		_label.autowrap_mode = autowrap_mode
		_label.width = text_width
		_label.outline_size = outline_size
		_label.outline_modulate = outline_color
		_label.render_priority = text_render_priority
		_label.outline_render_priority = text_render_priority - 1
		_label.position.z = 0.02 # Sécurité Z-fighting (IP-114)
	
	# 4. Transitions fluides (Scale et Émission Shader)
	_update_orientation()
	if Engine.is_editor_hint():
		scale = Vector3.ONE * target_scale_val
	else:
		if _tween: _tween.kill()
		_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "scale", Vector3.ONE * target_scale_val, transition_duration)
	
	# 5. Affichage du Prix
	_update_price_display()

func _update_orientation() -> void:
	if not is_inside_tree(): return
	
	var nodes_to_rotate = []
	nodes_to_rotate.append(_label)
	if _price_display: nodes_to_rotate.append(_price_display)
	for l in _layers: nodes_to_rotate.append(l)
	
	for node in nodes_to_rotate:
		if not node: continue
		if view_mode == SBViewMode.TOP_DOWN:
			node.rotation_degrees.x = -90
			if node == _label or node == _price_display:
				node.position.y = 0.1
		else:
			node.rotation_degrees.x = 0
			if node == _label or node == _price_display:
				node.position.y = 0.0
	
	# Mise à jour de la hitbox pour correspondre au visuel (on prend la rotation du premier layer ou self)
	if _area:
		if _layers.size() > 0:
			_area.rotation = _layers[0].rotation
			_area.position = _layers[0].position
		else:
			_area.rotation_degrees.x = -90 if view_mode == SBViewMode.TOP_DOWN else 0

func _update_price_display() -> void:
	if price <= 0:
		if has_node("PriceDisplay"):
			var existing_pd = get_node("PriceDisplay")
			existing_pd.name = "DELETING" # Évite les conflits de nom pendant le free
			existing_pd.free()
		return
		
	# Création dynamique si nécessaire
	var pd = get_node_or_null("PriceDisplay")
	if not pd:
		pd = Node3D.new()
		pd.name = "PriceDisplay"
		add_child(pd)
		pd.owner = owner if owner else self
		pd.position = Vector3(0, 0, 0.01)
		
		_price_label = Label3D.new()
		_price_label.name = "PriceLabel"
		_price_label.pixel_size = 0.0008
		_price_label.outline_size = 3
		_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_price_label.uppercase = true
		_price_label.position = Vector3(0.09, 0.08, 0.02)
		pd.add_child(_price_label)
		_price_label.owner = owner if owner else self
		
		_price_icon = Sprite3D.new()
		_price_icon.name = "PriceIcon"
		_price_icon.pixel_size = 0.0001
		_price_icon.scale = Vector3(0.35, 0.35, 0.35)
		_price_icon.position = Vector3(0.115, 0.08, 0.03)
		pd.add_child(_price_icon)
		_price_icon.owner = owner if owner else self
		
		# On verrouille pour éviter de les bouger par erreur (Optionnel, retiré à la demande de l'utilisateur)
		# _recursive_lock(pd)
	else:
		_price_label = pd.get_node("PriceLabel")
		_price_icon = pd.get_node("PriceIcon")
	
	_price_display = pd
	pd.visible = true
	
	# Mise à jour synchronisée des layers
	var current_layer = layer_normal if not _is_hovered and not _is_pressed else (layer_hover if _is_hovered else layer_pressed)
	if not is_enabled: current_layer = layer_disabled
	
	_price_label.layers = current_layer
	_price_icon.layers = current_layer
	
	_price_label.text = str(price)
	_price_icon.texture = currency_icon
	_price_icon.visible = currency_icon != null
	
	# Logic Affordability
	var can_pay = true
	if not Engine.is_editor_hint() and SB_GameDatas.instance:
		can_pay = SB_GameDatas.instance.can_afford(price)
	
	var mod_color = Color.WHITE if can_pay else Color(1, 0.3, 0.3)
	_price_label.modulate = mod_color
	_price_icon.modulate = mod_color
	
	# Laisser l'utilisateur gérer la position de l'icône dans l'éditeur

func _on_mouse_entered() -> void:
	if not is_enabled: return
	_is_hovered = true
	hovered.emit(metadata)
	_update_ui()

func _on_mouse_exited() -> void:
	_is_hovered = false
	_is_pressed = false
	_update_ui()

func _check_occlusion() -> bool:
	if not _area or not is_inside_tree(): return false
	var camera = get_viewport().get_camera_3d()
	if not camera: return false
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space = _area.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var hit = space.intersect_ray(query)
	if hit and hit.collider != _area:
		return true # Occlus par un autre objet en face
		
	return false # Pas occlus, on est bien le premier

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not is_enabled: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if _check_occlusion(): return # Bloque le clic si quelque chose est devant
		
		if event.pressed:
			_is_pressed = true
			get_viewport().set_input_as_handled()
		else:
			if _is_pressed:
				var can_interact = true
				if price > 0 and auto_deduct and SB_GameDatas.instance:
					if not SB_GameDatas.instance.spend_gold(price):
						can_interact = false
				
				if can_interact:
					pressed.emit()
					
					# Déclenchement automatique des composants "sous-événements" StoneBlock (IP-115)
					for child in get_children():
						if child.has_method("start"):
							child.start()
							
				get_viewport().set_input_as_handled()
			_is_pressed = false
		_update_ui()


# --- SYSTÈME DE THÈMES MODULAIRE ---

## Appliqué par le SB_ThemeManager si style_class_name correspond.
func apply_theme_style(style: SB_BaseStyle) -> void:
	if style is SB_Button3d_Theme:
		var s: SB_Button3d_Theme = style as SB_Button3d_Theme
		
		# Injection des propriétés du thème
		if not s.default_text.is_empty():
			text = s.default_text
		tint_normal = s.tint_normal
		tint_hover = s.tint_hover
		tint_pressed = s.tint_pressed
		if "tint_hue_shift" in s: tint_hue_shift = s.tint_hue_shift
		if "preview_stretch_mode" in s: preview_stretch_mode = s.preview_stretch_mode
		
		emission_energy_normal = s.emission_energy_normal
		emission_energy_hover = s.emission_energy_hover
		emission_energy_pressed = s.emission_energy_pressed
		
		layer_normal = s.layer_normal
		layer_hover = s.layer_hover
		layer_pressed = s.layer_pressed
		layer_disabled = s.layer_disabled
		
		font_size = s.font_size
		mesh_size = s.mesh_size
		
		# Support outline dans le thème
		if "outline_size" in s: outline_size = s.outline_size
		if "outline_color" in s: outline_color = s.outline_color
			
		base_scale = s.base_scale
		hover_scale_factor = s.hover_scale_factor
		
		_update_ui()


## Appliqué en mode éditeur via le cache
func _apply_style_from_dict(data: Dictionary) -> void:
	if data.has("default_text") and not data["default_text"].is_empty():
		text = data["default_text"]
	
	if data.has("tint_normal"): tint_normal = data["tint_normal"]
	if data.has("tint_hover"): tint_hover = data["tint_hover"]
	if data.has("tint_pressed"): tint_pressed = data["tint_pressed"]
	if data.has("tint_hue_shift"): tint_hue_shift = data["tint_hue_shift"]
	if data.has("preview_stretch_mode"): preview_stretch_mode = data["preview_stretch_mode"]
	
	if data.has("emission_energy_normal"): emission_energy_normal = data["emission_energy_normal"]
	if data.has("emission_energy_hover"): emission_energy_hover = data["emission_energy_hover"]
	if data.has("emission_energy_pressed"): emission_energy_pressed = data["emission_energy_pressed"]
	
	if data.has("layer_normal"): layer_normal = data["layer_normal"]
	if data.has("layer_hover"): layer_hover = data["layer_hover"]
	if data.has("layer_pressed"): layer_pressed = data["layer_pressed"]
	if data.has("layer_disabled"): layer_disabled = data["layer_disabled"]
	
	if data.has("font_size"): font_size = data["font_size"]
	if data.has("mesh_size"): mesh_size = data["mesh_size"]
	
	if data.has("base_scale"): base_scale = data["base_scale"]
	if data.has("hover_scale_factor"): hover_scale_factor = data["hover_scale_factor"]
	
	_update_ui()


func _request_theme_refresh() -> void:
	if not is_inside_tree(): return
	
	# Accès direct via Singleton (IP-112)
	var manager = SB_ThemeManager.instance
	
	if manager:
		if manager.has_method("request_style_update"):
			manager.call("request_style_update", self)
	elif Engine.is_editor_hint():
		# --- FALLBACK EDITEUR (WYSIWYG) ---
		# Permet de voir le style même si on n'est pas dans la scène de boot.
		var cache_path = "res://demo/demo1/ui/demo1_styles.tres"
		if FileAccess.file_exists(cache_path):
			var cache = load(cache_path)
			if cache and cache.has_method("get_style_data"):
				var data = cache.call("get_style_data", style_class_name)
				if not data.is_empty():
					_apply_style_from_dict(data)
	else:
		# Fallback vers le groupe si le singleton n'est pas encore prêt (In-Game)
		var managers = get_tree().get_nodes_in_group("SB_ThemeManager")
		if managers.size() > 0:
			managers[0].call("request_style_update", self)

func _refresh_layers_cache() -> void:
	_layers.clear()
	for child in get_children():
		if child is SB_NineSlice3D or child is SB_ThreeSlice3D:
			_layers.append(child)
