# Plan d'implémentation #012 - Corrections et Optimisations (02-03/12/2025)

**Timecode de début** : 2025-12-02 ~14:00  
**Statut** : ✅ **COMPLETED**  
**Dernière mise à jour** : 2025-12-03 ~[heure actuelle]

---

## 📋 Objectif

Corriger plusieurs problèmes identifiés et optimiser le comportement du système :
1. Correction du freeze lors du chargement de la scène welcome
2. Nettoyage des références inutilisées (BtnContinue)
3. Correction du cull_mask de la caméra principale
4. Optimisation du WindowManager pour éviter les resize multiples

---

## 🔍 Problèmes Identifiés

### 1. Freeze dans EventMaster3D
**Symptôme** : Le jeu se freezait lors du chargement de `200_welcome_scene.tscn`  
**Cause** : Les actions asynchrones dans `_play_event_actions()` bloquaient le thread principal

### 2. Références inutilisées
**Symptôme** : Références à `BtnContinue` dans `200_welcome_screen.gd` alors que le bouton a été remplacé par `BtnSkip`

### 3. Cull_mask incorrect
**Symptôme** : La caméra principale de `200_welcome_scene.tscn` voyait le layer 1024 (UI3D)  
**Cause** : Le `cull_mask` incluait le layer 1024 alors que seule la caméra du SubViewport doit le voir

### 4. WindowManager resize multiple
**Symptôme** : Le `WindowManager` resize la fenêtre à chaque changement de scène  
**Cause** : Pas de vérification pour savoir si c'est la première scène

---

## 📝 Changements Implémentés

### 1. Correction du freeze dans EventMaster3D

#### [MODIFY] [scripts/ui/event_master3d.gd](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scripts/ui/event_master3d.gd)

**Timecode** : 2025-12-02 ~14:00-14:15  
**Statut** : ✅ **COMPLETED**

**Modifications** :
- Utilisation de `call_deferred()` dans `_play_event_actions()` pour éviter les freezes
- Création d'une méthode `_play_event_actions_internal()` qui exécute réellement les actions de manière asynchrone
- Les actions sont maintenant exécutées sans bloquer le thread principal

**Code modifié** :
```gdscript
func _play_event_actions(event_node: Node):
	"""Joue les actions d'un nœud d'événement (tweens, etc.)"""
	# [IA CODING] 2025-01-XX : MODIFICATION : Utiliser call_deferred pour éviter les freezes
	call_deferred("_play_event_actions_internal", event_node)

func _play_event_actions_internal(event_node: Node):
	"""Version interne qui exécute réellement les actions"""
	# ... code existant ...
```

---

### 2. Nettoyage des références BtnContinue

#### [MODIFY] [screens/200_welcome_screen/200_welcome_screen.gd](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/screens/200_welcome_screen/200_welcome_screen.gd)

**Timecode** : 2025-12-02 ~14:20-14:25  
**Statut** : ✅ **COMPLETED**

**Modifications** :
- Commenté les `@onready` pour `btn_continue` et `continue_event_master`
- Ajout de commentaires expliquant que c'est temporaire (remplacé par BtnSkip)

**Code modifié** :
```gdscript
# Références aux éléments UI
# [IA CODING] 2025-01-XX : MODIFICATION : BtnContinue remplacé par BtnSkip temporairement
# @onready var btn_continue: ButtonNineSlice3D = $UserInterface3D_1920x1080/SubViewport/UserInterface3D/BtnContinue
@onready var ui_2d_container: Control = $UserInterface2D_1920x1080
# @onready var continue_event_master: EventMaster3D = $UserInterface3D_1920x1080/SubViewport/UserInterface3D/BtnContinue/EventMaster
```

---

### 3. Correction du cull_mask de la caméra principale

#### [MODIFY] [scenes/200_welcome_scene/200_welcome_scene.tscn](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/200_welcome_scene/200_welcome_scene.tscn)

**Timecode** : 2025-12-02 ~14:30-14:35  
**Statut** : ✅ **COMPLETED**

**Modifications** :
- Modification du `cull_mask` de la caméra principale
- Passage de `cull_mask = 1048573` à `cull_mask = 1047549` (exclusion du layer 1024)
- Seule la caméra du SubViewport doit voir le layer 1024 (UI3D)

**Ligne modifiée** :
```
cull_mask = 1047549  # Exclut le layer 1024 (UI3D)
```

---

### 4. Optimisation du WindowManager

#### [MODIFY] [scripts/ui/window_manager.gd](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scripts/ui/window_manager.gd)

**Timecode** : 2025-12-02 ~14:40-14:55  
**Statut** : ✅ **COMPLETED**

**Modifications** :
- Ajout d'une variable statique `_window_initialized` pour savoir si la fenêtre a déjà été initialisée
- Vérification que c'est la première scène (`000_splashscreen_scene.tscn`) avant de resize
- Le resize ne se fait maintenant que lors du démarrage de la première scène

**Code ajouté** :
```gdscript
# Variable statique pour savoir si la fenêtre a déjà été initialisée
static var _window_initialized: bool = false

func _ready():
	# Vérifier si c'est la première scène (000_splashscreen_scene.tscn)
	var current_scene = get_tree().current_scene
	var is_first_scene = current_scene and current_scene.scene_file_path.ends_with("000_splashscreen_scene.tscn")
	
	# Ne resize la fenêtre que si c'est la première scène et qu'elle n'a pas encore été initialisée
	if not _window_initialized and is_first_scene:
		# ... code d'initialisation ...
		_window_initialized = true
	else:
		print("ℹ️ WindowManager: Fenêtre déjà initialisée, pas de resize")
```

---

## ✅ Vérification

### Tests Effectués

1. **Test du freeze** ✅
   - Chargement de `200_welcome_scene.tscn` sans freeze
   - Les actions EventMaster3D s'exécutent correctement

2. **Test du cull_mask** ✅
   - La caméra principale ne voit plus l'UI 3D
   - Seule la caméra du SubViewport voit l'UI 3D

3. **Test du WindowManager** ✅
   - La fenêtre ne se resize que lors du démarrage de la première scène
   - Les changements de scène suivants ne modifient plus la taille/position

---

## 📅 Timeline

- **2025-12-02 ~14:00** : Début de la session de corrections
- **2025-12-02 ~14:15** : ✅ Correction du freeze dans EventMaster3D
- **2025-12-02 ~14:25** : ✅ Nettoyage des références BtnContinue
- **2025-12-02 ~14:35** : ✅ Correction du cull_mask
- **2025-12-02 ~14:55** : ✅ Optimisation du WindowManager
- **2025-12-03 ~[heure]** : ✅ Documentation et création du plan

---

## 📌 Notes

- Les références à `BtnContinue` sont commentées et pourront être réactivées plus tard
- Le `cull_mask` est maintenant correctement configuré pour séparer la scène 3D de l'UI 3D
- Le `WindowManager` utilise une variable statique pour éviter les réinitialisations multiples
- Tous les problèmes identifiés ont été résolus

---

## 🎯 Résumé

**Fichiers modifiés** :
1. `scripts/ui/event_master3d.gd` - Correction du freeze avec `call_deferred()`
2. `screens/200_welcome_screen/200_welcome_screen.gd` - Nettoyage des références BtnContinue
3. `scenes/200_welcome_scene/200_welcome_scene.tscn` - Correction du cull_mask
4. `scripts/ui/window_manager.gd` - Optimisation pour ne resize que la première scène

**Problèmes résolus** :
- ✅ Freeze lors du chargement de la scène welcome
- ✅ Caméra principale qui voyait l'UI 3D
- ✅ WindowManager qui resize à chaque changement de scène

**Améliorations** :
- ✅ Meilleure gestion asynchrone des événements dans EventMaster3D
- ✅ Code plus propre avec suppression des références inutilisées
- ✅ Optimisation des performances avec WindowManager

