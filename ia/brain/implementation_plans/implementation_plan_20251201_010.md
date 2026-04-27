# Implementation Plan - Migration MainMenu Scene & Screen + Templates (20251201_010)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2025-12-01 ~18:23
- **Statut** : 🔄 **IN PROGRESS**

## Objectif

Migrer la scène MainMenu (`201_mainmenu_scene.ts` et `201_mainmenu_screen.ts`) depuis TypeScript vers Godot, en créant d'abord des templates réutilisables pour faciliter les futures migrations.

## État des lieux

### Fichiers source TypeScript
- `DAGX Src/cosmic_hypersquad/scenes/201_mainmenu_scene.ts` : Scène 3D avec starfield, bloom sélectif, lumière ambiante
- `DAGX Src/cosmic_hypersquad/screens/201_mainmenu_screen/201_mainmenu_screen.ts` : Écran UI avec logos, dégradé de fond, panel de menu avec 7 boutons

### Fichiers de référence Godot
- `scenes/200_welcome_scene/200_welcome_scene.tscn` : Structure de base pour scène 3D
- `screens/200_welcome_screen/200_welcome_screen.tscn` : Structure de base pour écran UI

## Changements proposés

### 1. Créer les templates
#### [NEW] `scenes/__template_scene.tscn`
- Template basé sur `200_welcome_scene.tscn`
- Structure complète : GameScene3D, MultiPassRendering, FullScreen_Overlays, WorldEnvironment
- Commentaires pour indiquer les parties à personnaliser

#### [NEW] `screens/__template_screen.tscn`
- Template basé sur `200_welcome_screen.tscn`
- Structure complète : UserInterface2D_1920x1080, UserInterface3D_1920x1080, UserInterfaceDebug_1920x1080
- Commentaires pour indiquer les parties à personnaliser

### 2. Créer la scène MainMenu
#### [NEW] `scenes/201_mainmenu_scene/201_mainmenu_scene.tscn`
- Basé sur le template
- Starfield avec 250 étoiles (au lieu de 500)
- Bloom sélectif configuré
- Lumière ambiante douce (0x6699ff, intensity 0.2)
- Fade from black au démarrage (au lieu de fade from white)

#### [NEW] `scenes/201_mainmenu_scene/201_mainmenu_scene.gd`
- Script de scène basé sur `200_welcome_scene.gd`
- Configuration starfield : 250 étoiles, twinkle enabled
- Configuration bloom : bloomStrength 2.0, bloomRadius 0.4, bloomThreshold 0.0, exposure 1.5
- Fade from black au démarrage

### 3. Créer l'écran MainMenu
#### [NEW] `screens/201_mainmenu_screen/201_mainmenu_screen.tscn`
- Basé sur le template
- Dégradé de fond : Rouge (HSLA: [0, 100, 50, 0.50]) → Transparent (HSLA: [0, 0, 0, 0]) à 90°
- Logo container avec logos Cosmic et HyperSquad animés
- Panel de menu avec 7 boutons :
  - Story Mode (avec badge Demo)
  - Survival Mode (avec badge Demo, charge 401_survivalmode_scene)
  - Workshop Hangar (charge 301_hangar_scene)
  - Codex (charge 311_codex_scene)
  - Options
  - Crédits
  - Exit

#### [NEW] `screens/201_mainmenu_screen/201_mainmenu_screen.gd`
- Script d'écran basé sur `200_welcome_screen.gd`
- Gestion des boutons du menu
- Animations des logos
- Gestion des transitions de scène

## Étapes d'implémentation

### Étape 1 : Créer les templates
**Timecode** : 2025-12-01 ~18:23  
**Statut** : 🔄 **IN PROGRESS**

1. Créer `scenes/__template_scene.tscn` basé sur `200_welcome_scene.tscn`
2. Créer `screens/__template_screen.tscn` basé sur `200_welcome_screen.tscn`
3. Ajouter des commentaires pour indiquer les parties à personnaliser

### Étape 2 : Créer la scène MainMenu
**Timecode** : TBD  
**Statut** : ⏳ **PENDING**

1. Copier le template vers `scenes/201_mainmenu_scene/201_mainmenu_scene.tscn`
2. Ajuster les paramètres (starfield: 250 étoiles, fade from black)
3. Créer `201_mainmenu_scene.gd` avec la logique appropriée

### Étape 3 : Créer l'écran MainMenu
**Timecode** : TBD  
**Statut** : ⏳ **PENDING**

1. Copier le template vers `screens/201_mainmenu_screen/201_mainmenu_screen.tscn`
2. Ajouter le dégradé de fond
3. Ajouter les logos animés
4. Créer le panel de menu avec les 7 boutons
5. Créer `201_mainmenu_screen.gd` avec la logique des boutons

## Décisions techniques

### Templates
- **Format** : Fichiers `.tscn` avec commentaires dans les noms de nœuds ou sections
- **Structure** : Identique aux scènes de référence mais avec des valeurs par défaut génériques
- **Usage** : Copier et personnaliser pour chaque nouvelle scène/écran

### MainMenu Scene
- **Starfield** : 250 étoiles (vs 500 pour Welcome)
- **Fade** : From black (vs from white pour Welcome)
- **Bloom** : Même configuration que Welcome (bloomStrength 2.0)

### MainMenu Screen
- **Boutons** : Utiliser le système EventMaster + ActionTrigger/SceneLoader
- **Panel** : Container centré avec les boutons alignés verticalement
- **Logos** : Animations similaires à Welcome mais positionnés différemment

## Notes

- Les templates serviront de base pour toutes les futures migrations
- La structure MainMenu est plus complexe que Welcome (7 boutons vs 1)
- Les boutons doivent utiliser le système ActionTrigger pour charger les scènes

