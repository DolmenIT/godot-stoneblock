@tool
extends Node
class_name SB_GameDatas

## 💾 SB_GameDatas : Gestionnaire de progression persistant du joueur.
## Stocke l'or, l'inventaire et les choix du joueur dans un fichier JSON.

# --- Accès Statique (Singleton) ---
static var instance: SB_GameDatas

signal gold_changed(new_amount: int)
signal inventory_updated(data: Dictionary)
signal data_loaded()

const DEFAULT_SAVE_PATH = "user://game_progress.json"

@export_group("Configuration")
## Montant d'or initial (ou pour le debug).
@export var debug_gold: int = 1000:
	set(v):
		debug_gold = v
		if not Engine.is_editor_hint():
			set_value("gold", v)

@export_group("Debug")
## Forcer une réinitialisation des données au prochain chargement.
@export var force_reset: bool = false

# --- Données de Jeu ---
var data: Dictionary = {
	"gold": 1000, # Un peu d'or par défaut pour les tests
	"inventory": {
		"Scout MK-1": { "rarity": 0, "xp": 0, "stats_bonus": 1.0 }
	},
	"selected_ship_id": "Scout MK-1",
	"last_save_date": ""
}

func _enter_tree() -> void:
	instance = self
	if SB_Core.instance:
		SB_Core.instance.log_msg("Manager GameDatas initialisé.", "success")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	if force_reset:
		_initialize_defaults()
		save_to_disk()
		force_reset = false
	else:
		load_from_disk()

# ── API Publique ──────────────────────────────────────────────

## Vérifie si le joueur peut payer un montant.
func can_afford(amount: int) -> bool:
	return data.get("gold", 0) >= amount

## Dépense de l'or si possible. Retourne vrai si la transaction a réussi.
func spend_gold(amount: int) -> bool:
	if can_afford(amount):
		add_gold(-amount)
		return true
	return false

## Récupère une valeur de la sauvegarde.
func get_value(key: String, default = null):
	return data.get(key, default)

## Modifie une valeur et sauvegarde automatiquement.
func set_value(key: String, value, auto_save: bool = true) -> void:
	data[key] = value
	if key == "gold": gold_changed.emit(value)
	if auto_save: save_to_disk()

## Ajoute ou retire de l'or.
func add_gold(amount: int) -> void:
	var current_gold = data.get("gold", 0)
	set_value("gold", current_gold + amount)

## Débloque un vaisseau.
func unlock_ship(ship_id: String) -> void:
	var inventory = data.get("inventory", {})
	if not inventory.has(ship_id):
		inventory[ship_id] = { "rarity": 0, "xp": 0, "stats_bonus": 1.0 }
		set_value("inventory", inventory)
		inventory_updated.emit(data)

## Récupère les stats d'un vaisseau spécifique.
func get_ship_stats(ship_id: String) -> Dictionary:
	var inventory = data.get("inventory", {})
	return inventory.get(ship_id, { "rarity": 0, "xp": 0, "stats_bonus": 1.0 })

## Ajoute de l'XP à un vaisseau (+10% stats par palier).
func add_ship_xp(ship_id: String, amount: int = 20) -> void:
	var inventory = data.get("inventory", {})
	if inventory.has(ship_id):
		var ship = inventory[ship_id]
		ship["xp"] = clampi(ship.get("xp", 0) + amount, 0, 100)
		ship["stats_bonus"] = ship.get("stats_bonus", 1.0) + 0.1
		set_value("inventory", inventory)

## Augmente la rareté d'un vaisseau.
func promote_ship(ship_id: String) -> void:
	var inventory = data.get("inventory", {})
	if inventory.has(ship_id):
		var ship = inventory[ship_id]
		ship["rarity"] = clampi(ship.get("rarity", 0) + 1, 0, 2)
		ship["xp"] = 0 # On reset l'XP pour le prochain palier
		set_value("inventory", inventory)

# ── Gestion du Disque ─────────────────────────────────────────

## Sauvegarde les données actuelles sur le disque.
func save_to_disk(target_path: String = DEFAULT_SAVE_PATH) -> void:
	data["last_save_date"] = Time.get_datetime_string_from_system()
	
	var file = FileAccess.open(target_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t") # Joli formatage pour le debug
		file.store_string(json_string)
		file.close()
		if SB_Core.instance:
			SB_Core.instance.log_msg("Données de jeu sauvegardées : " + target_path.get_file(), "success")
	else:
		if SB_Core.instance:
			SB_Core.instance.log_msg("Erreur : Impossible d'écrire le fichier de sauvegarde !", "error")

## Charge les données depuis le disque.
func load_from_disk(target_path: String = DEFAULT_SAVE_PATH) -> void:
	if not FileAccess.file_exists(target_path):
		if SB_Core.instance: SB_Core.instance.log_msg("Aucune sauvegarde trouvée. Initialisation par défaut.", "info")
		_initialize_defaults()
		save_to_disk(target_path)
		return

	var file = FileAccess.open(target_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var loaded_data = json.get_data()
			if loaded_data is Dictionary:
				# On fusionne avec les clés par défaut pour ne rien perdre si on ajoute des variables au script
				for key in loaded_data:
					data[key] = loaded_data[key]
				
				# Migration d'ancienne structure : owned_ships -> inventory
				if data.has("owned_ships") and not data.has("inventory"):
					var inv = {}
					for s in data["owned_ships"]:
						inv[s] = { "rarity": 0, "xp": 0, "stats_bonus": 1.0 }
					data["inventory"] = inv
					data.erase("owned_ships")
				
				if SB_Core.instance:
					SB_Core.instance.log_msg("Données de jeu chargées (%s)." % target_path.get_file(), "success")
				data_loaded.emit()
		file.close()

## Importe et fusionne des données d'un autre fichier (Ex: DLC, Mission spéciale, etc.)
func import_and_merge(path: String) -> void:
	if not FileAccess.file_exists(path): return
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		if json.parse(json_string) == OK:
			var external_data = json.get_data()
			if external_data is Dictionary:
				for key in external_data:
					# Logique de fusion spécifique
					if key == "gold":
						data[key] += external_data[key]
					elif key == "inventory":
						var inv = data.get("inventory", {})
						var ext_inv = external_data[key]
						for s in ext_inv:
							if not inv.has(s): inv[s] = ext_inv[s]
					else:
						data[key] = external_data[key]
				save_to_disk() # On persiste la fusion
		file.close()

# ── Internes ──────────────────────────────────────────────────

func _initialize_defaults() -> void:
	data = {
		"gold": debug_gold,
		"inventory": {
			"Scout MK-1": { "rarity": 0, "xp": 0, "stats_bonus": 1.0 }
		},
		"selected_ship_id": "Scout MK-1",
		"last_save_date": Time.get_datetime_string_from_system()
	}
	gold_changed.emit(data["gold"])
	inventory_updated.emit(data)
