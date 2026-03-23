# Implementation Plan - Refactorisation UI Splashscreen (20251128_002)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline

- **Début** : 2025-11-28 ~16:30
- **Statut** : 🔄 **IN PROGRESS** → ✅ **COMPLETED** (2025-11-28 ~17:00)

## Objectif

Refactoriser l'architecture des UI de la scène splashscreen pour avoir une structure cohérente et modulaire, en extrayant les UI directement intégrées dans la scène principale vers des scènes séparées.

## Problème Actuel

L'architecture actuelle est incohérente :
- ✅ `SplashscreenScreen` → Scène séparée (bien organisé)
- ❌ `UserInterface3D_1920x1080` → Directement dans la scène principale (22k+ lignes)
- ❌ `UserInterface2D_1920x1080` → Directement dans la scène principale

**Conséquences** :
- Scène principale trop lourde et difficile à naviguer
- Architecture incohérente
- Maintenance difficile

## Solution Proposée

Extraire les UI dans des scènes séparées pour avoir une architecture cohérente :

```
scenes/
├── 000_splashscreen_scene/          # Scène 3D principale (légère)
├── 000_splashscreen_screen/         # UI 2D overlay (bouton Skip) ✅
├── 000_splashscreen_ui3d/          # UI 3D (textes Label3D) ← À CRÉER
└── 000_splashscreen_debug/         # UI Debug (FPS, stats) ← À CRÉER
```

## Changements à Effectuer

### 1. Créer la scène UI3D (`000_splashscreen_ui3d`)

**Timecode** : 2025-11-28 ~16:30-16:45  
**Statut** : ✅ **COMPLETED**

#### [NEW] [scenes/000_splashscreen_ui3d/000_splashscreen_ui3d.tscn](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_ui3d/000_splashscreen_ui3d.tscn)
- Structure : `Node3D` (racine)
- Contenu : Extraire `UserInterface3D_1920x1080` de la scène principale
  - `DolmenAGX` (Node3D)
    - `DolmenAGXText` (Label3D) + tweens
    - `DolmenAGXSentence` (Label3D) + tweens
  - `StoneBlock` (Node3D)
    - `StoneBlockText` (Label3D) + tweens
    - `StoneBlockSentence` (Label3D) + tweens

#### [NEW] [scenes/000_splashscreen_ui3d/000_splashscreen_ui3d.gd](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_ui3d/000_splashscreen_ui3d.gd)
- Script minimal pour gérer l'UI3D si nécessaire
- Référence à la scène parente pour communication

**Résultat** : ✅ Scène créée avec tous les textes 3D et animations extraits

### 2. Créer la scène Debug UI (`000_splashscreen_debug`)

**Timecode** : 2025-11-28 ~16:45-16:50  
**Statut** : ✅ **COMPLETED**

#### [NEW] [scenes/000_splashscreen_debug/000_splashscreen_debug.tscn](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_debug/000_splashscreen_debug.tscn)
- Structure : `Node2D` (racine)
- Contenu : Extraire `UserInterface2D_1920x1080` de la scène principale
  - `DebugUIScaler` (Node)
  - `DebugUILayer` (CanvasLayer)
    - `DebugPanel` (Panel)
      - `DebugContainer` (VBoxContainer)
        - `FPSLabel`, `QualityLabel`, `StatsLabel`
  - `BloomDebugLayer` (CanvasLayer)
    - `BloomDebugFrame` (Panel)
      - `BloomDebugTexture` (TextureRect)
  - `DarkenBloomDebugLayer` (CanvasLayer)
    - `BloomDebugFrame` (Panel)
      - `BloomDebugTexture` (TextureRect)

#### [NEW] [scenes/000_splashscreen_debug/000_splashscreen_debug.gd](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_debug/000_splashscreen_debug.gd)
- Script pour gérer les références aux managers (RenderingManager, QualityManager)
- Configuration des chemins de nœuds

**Résultat** : ✅ Scène créée avec tous les composants debug (FPS, qualité, stats, mini-vues bloom)

### 3. Modifier la scène principale

**Timecode** : 2025-11-28 ~16:50-16:55  
**Statut** : ✅ **COMPLETED**

#### [MODIFY] [scenes/000_splashscreen_scene/000_splashscreen_scene.tscn](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_scene/000_splashscreen_scene.tscn)
- Supprimer `UserInterface3D_1920x1080` (ligne ~22523)
- Supprimer `UserInterface2D_1920x1080` (ligne ~22674)
- Ajouter instance de `000_splashscreen_ui3d.tscn` dans `MultiPassRendering/UI3DRendering/UI3DViewport`
- Ajouter instance de `000_splashscreen_debug.tscn` à la racine

#### [MODIFY] [scenes/000_splashscreen_scene/000_splashscreen_scene.gd](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_scene/000_splashscreen_scene.gd)
- Mettre à jour les références aux UI si nécessaire
- S'assurer que la communication entre scènes fonctionne
- **Modification importante** : Debug UI chargé dynamiquement avec `load_debug_ui()` au démarrage
- Retiré les références `@onready` au debug UI (fps_label, quality_label, stats_label)
- Ajouté fonction `load_debug_ui()` pour chargement dynamique
- Ajouté gestion F3 pour toggle debug UI

**Résultat** : ✅ Scène principale allégée, UI3D instanciée dans le viewport, Debug UI chargé dynamiquement

## Points d'Attention

1. **Références de nœuds** : Les scripts dans les UI peuvent avoir des références à d'autres nœuds de la scène principale (ex: `RenderingQualityManager`). Il faudra utiliser des `NodePath` ou des références via la scène parente.

2. **UI3D Viewport** : L'UI3D doit être dans le bon viewport (`MultiPassRendering/UI3DRendering/UI3DViewport`) pour le rendu multi-passe.

3. **Layers CanvasLayer** : Vérifier que les layers des CanvasLayer sont corrects après extraction.

4. **Scripts avec chemins relatifs** : Vérifier tous les scripts qui utilisent des chemins de nœuds relatifs.

## Vérification

### Tests à Effectuer
- [x] La scène principale se charge sans erreur ✅
- [x] Les textes 3D (DolmenAGX, StoneBlock) s'affichent correctement ✅
- [x] Les animations des textes 3D fonctionnent ✅
- [x] Le debug UI s'affiche (FPS, qualité, stats) ✅ (chargé dynamiquement)
- [x] Le bloom debug fonctionne ✅ (mini-vues restaurées)
- [x] Le bouton Skip fonctionne toujours ✅
- [x] Aucune référence cassée dans les scripts ✅

### Vérification de la Structure
- [x] La scène principale est plus légère ✅ (UI extraites)
- [x] Les scènes UI sont bien séparées et modulaires ✅
- [x] L'architecture est cohérente avec `SplashscreenScreen` ✅

## 📝 Notes d'Implémentation

### Modifications Apportées

1. **Scène UI3D** (`000_splashscreen_ui3d`)
   - Créée avec tous les textes 3D (DolmenAGX, StoneBlock)
   - Tous les tweens et animations préservés
   - Instanciée dans `MultiPassRendering/UI3DRendering/UI3DViewport`

2. **Scène Debug** (`000_splashscreen_debug`)
   - Créée avec tous les composants debug
   - Mini-vues bloom incluses
   - **Changement important** : Chargée dynamiquement au démarrage (pas d'instance dans la scène)
   - Fonction `load_debug_ui()` pour chargement à la demande
   - Touche F3 pour toggle visibility

3. **Scène Principale**
   - `UserInterface3D_1920x1080` supprimé (remplacé par instance de scène)
   - `UserInterface2D_1920x1080` supprimé (chargé dynamiquement)
   - Références `@onready` au debug UI retirées
   - Code de configuration du debug UI retiré

### Points d'Attention Résolus

1. ✅ **Références de nœuds** : Chemins corrigés dans `load_debug_ui()` pour pointer vers la scène principale
2. ✅ **UI3D Viewport** : Instance placée dans le bon viewport
3. ✅ **Layers CanvasLayer** : Préservés dans les scènes extraites
4. ✅ **Scripts avec chemins relatifs** : Corrigés lors du chargement dynamique

## ✅ Conclusion

**Statut Final** : ✅ **COMPLETED** (2025-11-28 ~17:00)

L'architecture est maintenant cohérente avec toutes les UI dans des scènes séparées. Le debug UI est chargé dynamiquement pour garder la scène principale légère tout en permettant un accès facile avec F3.

