# Implementation Plan - Migration Welcome Scene & Screen (20251130_006)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Statut** : ✅ **COMPLETED**
- **Fin** : 2025-11-30 ~09:20

## Objectif
Migrer la scène `200_welcome_scene` et l'écran `200_welcome_screen` de TypeScript vers Godot, en reproduisant fidèlement le comportement et le rendu visuel.

> [!IMPORTANT]
> **ARCHITECTURE DE BASE** : Utiliser la structure exacte de `000_splashscreen_scene` et `000_splashscreen_screen` comme template :
> - MultiPassRendering (SelectiveBloomViewport, BloomCompositeLayer, DarkenBloomOverlay)
> - UserInterface2D_1920x1080
> - UserInterface3D_1920x1080 (SubViewport + Camera3D orthographique)
> - UserInterfaceDebug_1920x1080 (mini-vues, debug overlay)
> - Structure de managers (LightingManager, StarfieldManager, RenderingManager, etc.)

## État des lieux
- **Source** :
    - `200_welcome_scene.ts` : Scène 3D avec Starfield, Lighting et Bloom sélectif.
    - `200_welcome_screen.ts` : UI avec Logos animés et Bouton "Press to continue".
- **Assets** :
    - `Starfield` : Disponible (`assets/textures/dagx-star*.png`).
    - `Logos` : Disponibles dans `assets/images/branding/` (`Cosmic.png`, `HyperSquad.png`).
    - `Font` : `chakra-petch` (Disponible).

## Changements proposés

### 1. Structure Scène (`scenes/200_welcome_scene/`)
#### [NEW] [200_welcome_scene.tscn](file:///d:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/200_welcome_scene/200_welcome_scene.tscn)
- **Root** : `Node3D`
- **Managers** :
    - `LightingManager` (Ambient Light: Color `6699ff`, Intensity `0.2`)
    - `StarfieldManager` (500 stars, twinkling)
    - `MultiPassRendering` (Bloom sélectif)
- **Script** : `200_welcome_scene.gd`
    - Gestion du Fade In au démarrage (Blanc -> Transparent).
    - Chargement de l'écran UI.

### 2. Structure Écran (`screens/200_welcome_screen/`)
#### [NEW] [200_welcome_screen.tscn](file:///d:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/screens/200_welcome_screen/200_welcome_screen.tscn)
- **Root** : `Control` (Anchor: Full Rect)
- **Background** : `GradientBackground` (ColorRect avec Shader ou Texture).
    - **Spécification** : Dégradé vertical Rouge (Haut) vers Transparent (Bas).
    - Valeurs TS ref : `[0, 100, 50, 0.75]` (Rouge) -> `[0, 0, 0, 0.25]` (Noir/Transparent).
- **Logos** :
    - Container centré (`Control` ou `VBoxContainer`).
    - `TextureRect` pour "Cosmic" et "HyperSquad".
    - Animations : Tween Scale/Opacity à l'apparition + Idle Yoyo (Scale/Rotation).
- **Bouton** :
    - `TweenButton` ("Press to continue").
    - Action : Fade to Black -> Load `201_mainmenu_scene`.

### 3. Scripts
#### [NEW] `scenes/200_welcome_scene/200_welcome_scene.gd`
- Hérite de `Node3D` (ou classe de base Scene si existante).
- Logique d'initialisation et de transition.

#### [NEW] `screens/200_welcome_screen/200_welcome_screen.gd`
- Hérite de `Control` (ou `DagxScreen` équivalent).
- Gestion des animations des logos (Tween).
- Gestion du clic bouton.

## Plan de vérification
1. **Lancement** : La scène se lance sans erreur.
2. **Visuel** :
    - Le fond étoilé est visible avec le bloom.
    - Le fade in blanc fonctionne.
    - Les logos apparaissent avec l'animation prévue.
    - Le bouton est stylisé correctement.
3. **Interaction** :
    - Le clic sur le bouton déclenche le fade out noir.
    - (Note : La scène `201_mainmenu_scene` n'existant pas encore, le chargement échouera ou sera mocké).

## 📅 Étapes
### 1. Création de la Scène 3D
**Timecode** : 2025-11-30 ~HH:MM-HH:MM
**Statut** : 🔄 **IN PROGRESS**

### 2. Création de l'Écran UI
**Timecode** : 2025-11-30 ~HH:MM-HH:MM
**Statut** : 🔴 **TODO**

### 3. Intégration et Scripts
**Timecode** : 2025-11-30 ~HH:MM-HH:MM
**Statut** : 🔴 **TODO**
