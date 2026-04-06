@tool
extends SB_Enemy_VShmup
class_name SB_BossPart_VShmup

## 🛡️ SB_BossPart_VShmup : Partie de Boss indestructible tant qu'il y a des enfants ennemis.
## La partie devient vulnérable uniquement quand tous ses enfants de type SB_Enemy_VShmup sont détruits.

@export var is_invulnerable: bool = true
var _protector_count: int = 0

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	
	# Scanner les enfants pour trouver les protecteurs
	# On cherche les SB_Enemy_VShmup qui ne sont pas nous-mêmes
	_protector_count = 0
	for child in get_children():
		if child is SB_Enemy_VShmup and child != self:
			_protector_count += 1
			if not child.destroyed.is_connected(_on_protector_destroyed):
				child.destroyed.connect(_on_protector_destroyed)
	
	# Vérification récursive dans les sous-nœuds si nécessaire (Optionnel)
	# Pour l'instant on s'en tient aux enfants directs pour la clarté.
	
	is_invulnerable = (_protector_count > 0)
	print("[BossPart] ", name, " initialized with ", _protector_count, " protectors. Invulnerable: ", is_invulnerable)

func _on_protector_destroyed(_pos: Vector3) -> void:
	_protector_count -= 1
	if _protector_count <= 0:
		is_invulnerable = false
		print("[BossPart] ", name, " is now VULNERABLE!")
		# On pourrait ajouter un petit effet sonore ou visuel de déverrouillage ici

func take_damage(amount: float) -> void:
	if is_invulnerable:
		_shield_flash()
		return
	super.take_damage(amount)

func _shield_flash() -> void:
	# Feedback visuel de bouclier (Cyan/Bleu) pour indiquer l'indestructibilité
	for node in _visual_nodes:
		if node is MeshInstance3D:
			node.material_override = _flash_material
			_flash_material.set_shader_parameter("flash_color", Color.CYAN)
			_flash_material.set_shader_parameter("flash_modifier", 1.0)
			
			var tween = create_tween()
			tween.tween_method(_update_flash_intensity.bind(node), 1.0, 0.0, 0.1)
			tween.finished.connect(func(): if is_instance_valid(node): node.material_override = null)
