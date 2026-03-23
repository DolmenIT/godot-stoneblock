# Implementation Plan - Refactoring btnSkip : Extraction vers Scripts Dédiés (20251201_007)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2025-12-01 ~11:44
- **Fin** : 2025-12-01 ~11:48
- **Statut** : ✅ **COMPLETED**

## Objectif

Refactoriser le code du bouton `btnSkip` pour extraire toute la logique spécifique vers des scripts dédiés attachés au bouton ou à ses enfants, réduisant ainsi la complexité du fichier `000_splashscreen_screen.gd`.

## État des lieux

### Problème identifié
Le fichier `000_splashscreen_screen.gd` contient trop de code lié au bouton `btnSkip` :
- **Références** : 7 références `@onready` pour les éléments du bouton (lignes 15, 19-22, 25)
- **Configuration EventMaster** : Logique de connexion des signaux (lignes 50-60)
- **Handler** : Fonction `_on_skip_pressed` (lignes 69-74)
- **Scaling textures** : Fonction `_scale_button_textures` (lignes 76-132) - ~60 lignes
- **Helper texture** : Fonction `_scale_texture` (lignes 134-192) - ~60 lignes
- **Positionnement** : Logique dans `_update_ui_scale` (lignes 235-285) - ~50 lignes

**Total** : ~200 lignes de code liées au bouton dans le screen.

### Structure actuelle du bouton
```
BtnSkip (TextureButton avec script TweenButton)
├── BackgroundRect (ColorRect)
├── Background (NinePatchRect)
├── Foreground (NinePatchRect)
├── HoverOverlay (NinePatchRect)
├── PressedOverlay (NinePatchRect)
├── Label
└── EventMaster (Node2D avec script EventMaster)
    ├── HoverEnter
    ├── HoverExit
    ├── Pressed
    └── Released
```

## Changements proposés

### 1. Créer un script dédié pour le bouton Skip
#### [NEW] `scripts/ui/skip_button.gd`
- **Classe** : `SkipButton extends TweenButton`
- **Responsabilités** :
  - Gestion du scaling des textures au démarrage
  - Gestion du positionnement adaptatif (bas-droite avec marges)
  - Configuration automatique de l'EventMaster
  - Émission d'un signal `skip_pressed` au lieu d'appeler directement la scène

**Fonctionnalités à migrer** :
- `_scale_button_textures()` → `_setup_textures()`
- `_scale_texture()` → `_scale_texture()` (helper privé)
- Logique de positionnement dans `_update_ui_scale()` → `_update_position()`
- Configuration EventMaster → `_setup_event_master()`

### 2. Créer un script pour la gestion du scaling UI
#### [NEW] `scripts/components/skip_button_ui_scaler.gd` (optionnel)
- **Alternative** : Intégrer directement dans `SkipButton`
- **Responsabilité** : Gérer le scaling et le positionnement du bouton en fonction de la résolution

### 3. Modifier le screen pour utiliser le nouveau script
#### [MODIFY] `screens/000_splashscreen_screen/000_splashscreen_screen.gd`
- **Supprimer** :
  - Références `@onready` pour les éléments internes du bouton (garder seulement `btn_skip`)
  - Fonction `_scale_button_textures()`
  - Fonction `_scale_texture()`
  - Logique de positionnement du bouton dans `_update_ui_scale()`
  - Configuration EventMaster dans `_ready()`
- **Modifier** :
  - `_update_ui_scale()` : Ne gérer que le scaling du container UI, pas du bouton
  - `_on_skip_pressed()` : Se connecter au signal `skip_pressed` du bouton
- **Simplifier** : Le screen ne fait plus que coordonner, le bouton gère sa propre logique

### 4. Mettre à jour la scène
#### [MODIFY] `screens/000_splashscreen_screen/000_splashscreen_screen.tscn`
- Changer le script du bouton `BtnSkip` de `tween_button.gd` vers `skip_button.gd`

## Étapes d'implémentation

### Étape 1 : Créer le script SkipButton
**Timecode** : 2025-12-01 ~11:44-11:46  
**Statut** : ✅ **COMPLETED**

1. ✅ Créer `scripts/ui/skip_button.gd`
2. ✅ Étendre `TweenButton`
3. ✅ Migrer `_scale_button_textures()` → `_setup_textures()`
4. ✅ Migrer `_scale_texture()` (helper privé)
5. ✅ Migrer la logique de positionnement → `_update_position()`
6. ✅ Ajouter signal `skip_pressed`
7. ✅ Configurer EventMaster dans `_ready()`

**Résultats** : Script créé avec toutes les fonctionnalités migrées. Le bouton gère maintenant son propre scaling des textures, positionnement adaptatif et émission de signal.

### Étape 2 : Simplifier le screen
**Timecode** : 2025-12-01 ~11:46-11:47  
**Statut** : ✅ **COMPLETED**

1. ✅ Supprimer les références `@onready` inutiles (7 références supprimées)
2. ✅ Supprimer les fonctions migrées (`_scale_button_textures()`, `_scale_texture()`)
3. ✅ Supprimer `_update_ui_scale()` (fonction complète supprimée)
4. ✅ Connecter le signal `skip_pressed` du bouton
5. ✅ Nettoyer les commentaires obsolètes

**Résultats** : Le screen est maintenant beaucoup plus simple (~200 lignes supprimées). Il ne fait plus que coordonner, le bouton gère sa propre logique.

### Étape 3 : Mettre à jour la scène
**Timecode** : 2025-12-01 ~11:47-11:48  
**Statut** : ✅ **COMPLETED**

1. ✅ Modifier le script du bouton dans `.tscn` (de `tween_button.gd` vers `skip_button.gd`)
2. ✅ Vérifier que tous les chemins de nœuds sont corrects

**Résultats** : Le fichier `.tscn` utilise maintenant `skip_button.gd`. La structure des nœuds reste inchangée.

### Étape 4 : Tests et vérification
**Timecode** : 2025-12-01 ~11:48  
**Statut** : ⏳ **PENDING** (À tester par l'utilisateur)

1. Vérifier que le bouton s'affiche correctement
2. Vérifier que les textures sont bien scalées
3. Vérifier que le positionnement est correct
4. Vérifier que le clic fonctionne
5. Vérifier que les animations (hover, pressed) fonctionnent
6. Vérifier le scaling adaptatif en changeant la résolution

## Décisions techniques

### Signal vs Callback direct
- **Choix** : Utiliser un signal `skip_pressed` émis par le bouton
- **Raison** : Découplage, le bouton ne connaît pas la scène parente
- **Implémentation** : Le screen se connecte au signal et appelle `splashscreen_scene.skip_splashscreen()`

### Gestion du scaling UI
- **Choix** : Intégrer dans `SkipButton` plutôt que créer un composant séparé
- **Raison** : Logique spécifique au bouton, pas besoin de réutilisabilité
- **Alternative** : Si d'autres boutons ont besoin de la même logique, extraire en composant

### Références aux enfants
- **Choix** : Le bouton utilise `get_node()` pour accéder à ses enfants
- **Raison** : Pas besoin de références `@onready` dans le screen
- **Structure** : `Background`, `Foreground`, `HoverOverlay`, `PressedOverlay`, `EventMaster`

## Notes

- Le script `TweenButton` existant reste inchangé
- Le script `EventMaster` reste inchangé
- La structure des nœuds dans `.tscn` reste inchangée
- Seul le script attaché au bouton change

## Résumé de l'implémentation

### Fichiers créés
- `scripts/ui/skip_button.gd` : Script dédié au bouton Skip avec toutes les fonctionnalités

### Fichiers modifiés
- `screens/000_splashscreen_screen/000_splashscreen_screen.gd` : Simplifié (~200 lignes supprimées)
- `screens/000_splashscreen_screen/000_splashscreen_screen.tscn` : Script du bouton changé

### Réduction de code
- **Avant** : ~200 lignes de code liées au bouton dans le screen
- **Après** : ~10 lignes (seulement la connexion du signal)
- **Réduction** : ~95% de code en moins dans le screen

### Avantages
- ✅ Séparation des responsabilités : Le bouton gère sa propre logique
- ✅ Réutilisabilité : Le script `SkipButton` peut être réutilisé ailleurs
- ✅ Maintenabilité : Code plus facile à comprendre et maintenir
- ✅ Testabilité : Le bouton peut être testé indépendamment

