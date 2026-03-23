# Plan d'implémentation #011 - Amélioration ScreenManager

**Timecode de début** : 2025-12-02 ~12:45  
**Statut** : ✅ Terminé  
**Dernière mise à jour** : 2025-12-02 ~13:10

---

## 📋 Objectif

Améliorer le script `fullscreen_toggle.gd` pour qu'il initialise correctement la fenêtre au démarrage :
- **En mode éditeur** (F5/F6) : **TOUJOURS** ignorer la configuration et forcer 75% de l'écran principal centré
- **En mode production, avec configuration valide** : restaurer la configuration sauvegardée
- **En mode production, avec configuration invalide** : ignorer la config et utiliser 75% centré
- **En mode production, sans configuration** : positionner la fenêtre au centre de l'écran principal avec une taille de 75% de la dimension de l'écran
- **(Optionnel)** : Renommer le script de `fullscreen_toggle.gd` à `screen_manager.gd` pour mieux refléter son rôle étendu

**Validation de configuration** : Une configuration est considérée invalide si la fenêtre sauvegardée n'est pas visible à au moins 50% sur un écran disponible (cas typique : écran débranché).

Le projet est configuré en 1920x1080 et ce comportement initial permettra une meilleure expérience utilisateur au premier lancement.

---

## 🔍 Analyse de l'Existant

### Comportement Actuel

Le script `fullscreen_toggle.gd` dans la fonction `_ready()` (lignes 13-38) :
1. **Force** systématiquement la fenêtre en mode windowed à 1440x880
2. Centre la fenêtre sur l'écran principal
3. **Ne restaure PAS** les paramètres sauvegardés au démarrage
4. La fonction `_restore_window_settings()` existe (lignes 155-223) mais n'est jamais appelée

### Problème Identifié

- Les paramètres sauvegardés ne sont jamais utilisés au démarrage
- La taille forcée (1440x880) ne respecte pas une proportion logique de l'écran
- L'utilisateur souhaite un comportement par défaut à 75% de l'écran

---

## 📝 Changements Proposés

### [scripts/ui/] Gestion des fenêtres

#### [MODIFY] [fullscreen_toggle.gd](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scripts/ui/fullscreen_toggle.gd)

**Modifications dans la fonction `_ready()`** (lignes 13-38) :

1. **Vérifier l'existence de configuration sauvegardée** au lieu de forcer une taille
2. **Valider la configuration** pour s'assurer que la fenêtre sera visible
3. **En mode éditeur** : toujours utiliser 75% (ignorer config)
4. **Si configuration existe ET est valide** : appeler `_restore_window_settings()`
5. **Si aucune configuration OU configuration invalide** : 
   - Calculer 75% de la taille de l'écran principal
   - Positionner la fenêtre au centre de l'écran principal
   - Initialiser les variables de sauvegarde avec ces valeurs

**Nouvelle fonction `_is_window_position_valid()`** :

Valide qu'au moins 50% de la surface de la fenêtre est visible sur un écran disponible. Cela protège contre :
- Écran secondaire débranché
- Changement de configuration multi-écrans
- Changement de résolution d'écran

**Pseudo-code de la nouvelle logique** :

```gdscript
func _ready():
    print("✅ ScreenManager: Appuyez sur F11 pour basculer entre fullscreen et windowed")
    
    var window = get_window()
    var is_editor = OS.has_feature("editor")
    var config = ConfigFile.new()
    var config_exists = config.load(CONFIG_PATH) == OK
    
    # En mode éditeur, TOUJOURS utiliser 75% de l'écran (ignorer la config)
    if is_editor:
        _initialize_default_window_size(window)
        print("🎮 Mode ÉDITEUR : Configuration ignorée, fenêtre à 75% de l'écran")
    elif config_exists:
        # Vérifier si la configuration est valide (fenêtre dans une zone visible)
        var saved_pos_x = config.get_value("window", "position_x", 100)
        var saved_pos_y = config.get_value("window", "position_y", 100)
        var saved_size_x = config.get_value("window", "size_x", 1920)
        var saved_size_y = config.get_value("window", "size_y", 1080)
        
        if _is_window_position_valid(Vector2i(saved_pos_x, saved_pos_y), Vector2i(saved_size_x, saved_size_y)):
            # Configuration valide : restaurer
            _restore_window_settings()
        else:
            # Configuration invalide : ignorer et utiliser le défaut
            _initialize_default_window_size(window)
            print("⚠️ Configuration invalide (hors écran), utilisation des valeurs par défaut")
    else:
        # En production sans configuration : initialisation par défaut à 75% de l'écran
        _initialize_default_window_size(window)
        print("🖥️ Première initialisation : Fenêtre à 75% de l'écran principal")
    
    # Vérifier périodiquement si la position a changé
    _check_window_position()

func _is_window_position_valid(pos: Vector2i, size: Vector2i) -> bool:
    """Vérifie si au moins 50% de la fenêtre est visible sur un écran"""
    var screen_count = DisplayServer.get_screen_count()
    var window_area = size.x * size.y
    var minimum_visible_area = window_area * 0.5  # 50% minimum visible
    
    for screen_index in range(screen_count):
        var screen_pos = DisplayServer.screen_get_position(screen_index)
        var screen_size = DisplayServer.screen_get_size(screen_index)
        
        # Calculer l'intersection entre la fenêtre et l'écran
        var intersect_x1 = max(pos.x, screen_pos.x)
        var intersect_y1 = max(pos.y, screen_pos.y)
        var intersect_x2 = min(pos.x + size.x, screen_pos.x + screen_size.x)
        var intersect_y2 = min(pos.y + size.y, screen_pos.y + screen_size.y)
        
        # Si il y a une intersection
        if intersect_x2 > intersect_x1 and intersect_y2 > intersect_y1:
            var visible_area = (intersect_x2 - intersect_x1) * (intersect_y2 - intersect_y1)
            if visible_area >= minimum_visible_area:
                return true  # Au moins 50% de la fenêtre est visible
    
    return false  # Fenêtre hors zone ou trop peu visible

func _initialize_default_window_size(window: Window):
    """Initialise la fenêtre à 75% de l'écran principal, centrée"""
    window.mode = Window.MODE_WINDOWED
    
    # Obtenir les dimensions de l'écran principal
    var primary_screen = DisplayServer.get_primary_screen()
    var screen_size = DisplayServer.screen_get_size(primary_screen)
    var screen_position = DisplayServer.screen_get_position(primary_screen)
    
    # Calculer 75% de la taille de l'écran
    var window_width = int(screen_size.x * 0.75)
    var window_height = int(screen_size.y * 0.75)
    window.size = Vector2i(window_width, window_height)
    
    # Centrer la fenêtre
    window.position = Vector2i(
        screen_position.x + (screen_size.x - window_width) / 2,
        screen_position.y + (screen_size.y - window_height) / 2
    )
    
    print("   Taille: ", window.size, " Position: ", window.position)
    
    # Initialiser les variables de sauvegarde
    _saved_windowed_size = window.size
    _saved_windowed_position = window.position
    _last_window_position = window.position
```

---

### [OPTIONAL] Renommage du Script

#### [RENAME] fullscreen_toggle.gd → screen_manager.gd

Le script gère maintenant bien plus que le simple toggle fullscreen :
- Initialisation de la fenêtre
- Sauvegarde/restauration de configuration
- Détection de changement d'écran
- Gestion du positionnement

**Fichiers à mettre à jour si renommage** :
- `scripts/ui/fullscreen_toggle.gd` → `scripts/ui/screen_manager.gd`
- `screens/__template_screen/__template_screen.tscn` (ligne 10, ext_resource)
- Tout autre fichier `.tscn` utilisant ce script

> [!NOTE]
> **Question pour l'utilisateur** : Souhaitez-vous procéder au renommage du script en `screen_manager.gd` maintenant, ou préférez-vous le faire plus tard ?

---

## ✅ Plan de Vérification

### Tests Manuels

1. **Test en mode éditeur** (prioritaire pour le développement)
   - Lancer le projet depuis l'éditeur Godot (F5 ou F6)
   - **Résultat attendu** :
     - Fenêtre toujours à 75% de l'écran, centrée
     - Configuration sauvegardée ignorée, même si elle existe
     - Message dans la console : "🎮 Mode ÉDITEUR : Configuration ignorée"
   - Modifier la taille/position et relancer (F5)
   - **Résultat attendu** :
     - Fenêtre à nouveau à 75% de l'écran (changements ignorés)

2. **Test du premier lancement** (sans configuration, mode production)
   - Supprimer le fichier de configuration : `user://window_settings.cfg`
     - Sur Windows : `%APPDATA%\Godot\app_userdata\cosmic-hyper-squad\window_settings.cfg`
   - Lancer le projet
   - **Résultat attendu** :
     - Fenêtre position centrée sur l'écran principal
     - Taille de la fenêtre = 75% de l'écran
     - Message dans la console indiquant "Première initialisation"

2. **Test de la sauvegarde**
   - Déplacer la fenêtre vers un autre emplacement
   - Redimensionner la fenêtre
   - Fermer l'application
   - **Résultat attendu** :
     - Message "💾 Paramètres de fenêtre sauvegardés" dans la console

3. **Test de la restauration**
   - Relancer l'application
   - **Résultat attendu** :
     - Fenêtre restaurée à la position et taille précédentes
     - Message "📂 Paramètres de fenêtre restaurés" dans la console

4. **Test de configuration invalide** (écran débranché simulé)
   - Éditer manuellement le fichier de configuration (`%APPDATA%\Godot\app_userdata\cosmic-hyper-squad\window_settings.cfg`)
   - Modifier `position_x` et `position_y` pour des valeurs hors écran (ex: `position_x=10000`, `position_y=10000`)
   - Lancer le projet
   - **Résultat attendu** :
     - Configuration détectée comme invalide
     - Fenêtre repositionnée à 75% de l'écran, centrée
     - Message "⚠️ Configuration invalide (hors écran)" dans la console

5. **Test du toggle fullscreen (F11)**
   - Appuyer sur F11 pour passer en fullscreen
   - Appuyer à nouveau sur F11 pour revenir en windowed
   - **Résultat attendu** :
     - Transitions fluides entre les modes
     - Position et taille restaurées correctement au retour en windowed

5. **Test multi-écrans** (si disponible)
   - Déplacer la fenêtre sur un écran secondaire
   - Fermer et relancer l'application
   - **Résultat attendu** :
     - Fenêtre restaurée sur le bon écran

---

## 📅 Timecodes

- **2025-12-02 ~12:45** : Début de la planification
- **2025-12-02 ~12:46** : Ajout de la détection du mode éditeur (toujours 75% en dev)
- **2025-12-02 ~12:49** : Ajout de la validation de configuration (protection fenêtre hors écran)
- **2025-12-02 ~12:51** : ✅ Plan approuvé par l'utilisateur - Début de l'implémentation
- **2025-12-02 ~12:52** : ✅ Implémentation terminée - Modifications appliquées à `fullscreen_toggle.gd`
- **2025-12-02 ~13:05** : 🐛 Bug détecté : restauration d'écran après fullscreen
- **2025-12-02 ~13:10** : ✅ Bug corrigé - Détection correcte de l'écran cible
- **2025-12-02 ~13:10** : ✅ Tests validés par l'utilisateur - Plan terminé
