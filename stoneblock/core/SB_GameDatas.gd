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
## Dictionnaire des prix et paramètres globaux.
@export var game_config: Dictionary = {
	"price_upgrade": 500,
	"price_unlock_rare": 2500,
	"price_unlock_legendary": 10000
}

# --- Données de Jeu ---
var data: Dictionary = {
	"gold": 1000, # Un peu d'or par défaut pour les tests
	"owned_ships": ["Scout MK-1"],
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
	var ships = data.get("owned_ships", [])
	if not ships.has(ship_id):
		ships.append(ship_id)
		set_value("owned_ships", ships)
		inventory_updated.emit(data)

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
					# Logique de fusion spécifique : pour l'or on additionne, pour les ships on concatène
					if key == "gold":
						data[key] += external_data[key]
					elif key == "owned_ships":
						for s in external_data[key]:
							if not data[key].has(s): data[key].append(s)
					else:
						data[key] = external_data[key]
				save_to_disk() # On persiste la fusion
		file.close()

# ── Internes ──────────────────────────────────────────────────

func _initialize_defaults() -> void:
	data = {
		"gold": 0,
		"owned_ships": ["Scout MK-1"],
		"selected_ship_id": "Scout MK-1",
		"last_save_date": Time.get_datetime_string_from_system()
	}
	gold_changed.emit(data["gold"])
	inventory_updated.emit(data)
