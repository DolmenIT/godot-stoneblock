# Implementation Plan - Splashscreen Skip Button Styling (20251128_001)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

The goal is to style the "Skip" button in the Splashscreen UI to match the original "Mixed UI" implementation, using a reusable `TweenButton` component that leverages existing tween scripts.

## User Review Required

> [!NOTE]
> I will create a reusable `TweenButton` script that orchestrates animations defined in child nodes.
> I will also generalize existing tween scripts (like `TweenAlphaFromTo`) to work with UI nodes (`Control`) and accept specific targets, making them compatible with this new system.

## Proposed Changes

### Scripts
#### [MODIFY] [scripts/components/tween_alpha_from_to.gd](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scripts/components/tween_alpha_from_to.gd)
- Change type hints from `Node3D` to `Node` (or `Control` check) to support UI.
- Add `@export var target_node: NodePath` to allow targeting specific children (like the Overlay) instead of the main button.

#### [NEW] [scripts/ui/tween_button.gd](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scripts/ui/tween_button.gd)
- Extends `TextureButton`.
- Exports: `duration`, `transition`, `ease`.
- Logic:
    - Listens to `mouse_entered`, `mouse_exited`, `button_down`, `button_up`.
    - Looks for child nodes named `HoverEnter`, `HoverExit`, `Pressed`, `Released`.
    - When an event occurs, creates a `Tween` and executes `_start_tween` on all children of the corresponding state node.

### UI Scene
#### [MODIFY] [000_splashscreen_screen.tscn](file:///D:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_screen/000_splashscreen_screen.tscn)
- Change `BtnSkip` script to `scripts/ui/tween_button.gd`.
- Structure:
    - `BtnSkip` (TweenButton)
        - `Background` (NinePatchRect)
        - `Foreground` (NinePatchRect)
        - `HoverOverlay` (NinePatchRect, alpha=0)
        - `Label` (Label)
        - `HoverEnter` (Node)
            - `FadeIn` (TweenAlphaFromTo): Target=`../HoverOverlay`, From=0, To=1
        - `HoverExit` (Node)
            - `FadeOut` (TweenAlphaFromTo): Target=`../HoverOverlay`, From=1, To=0

### Assets
Using:
- `res://assets/ui/from gamedevmarket.com/by EvilSystem/spaceshift_ui/Buttons/Square Small/SquareSmall_Background.png`
- `res://assets/ui/from gamedevmarket.com/by EvilSystem/spaceshift_ui/Buttons/Square Small/SquareSmall_Foreground.png`
- `res://assets/ui/from gamedevmarket.com/by EvilSystem/spaceshift_ui/Buttons/Square Small/SquareSmall_PressOverlay.png`

## 📅 Timeline

- **Début** : 2025-11-28 ~16:30
- **Statut** : ✅ **COMPLETED** (2025-11-28 ~20:00)

### 1. Implémentation initiale du TweenButton
**Timecode** : 2025-11-28 ~16:30-17:00  
**Statut** : ✅ **COMPLETED**
- Création du script `tween_button.gd`
- Modification de `tween_alpha_from_to.gd` et `tween_scale_from_to.gd` pour supporter UI
- Configuration des animations hover/press dans la scène

### 2. Refactorisation UI (extraction en scènes séparées)
**Timecode** : 2025-11-28 ~17:00-17:30  
**Statut** : ✅ **COMPLETED**
- Extraction de `UserInterface3D_1920x1080` dans `000_splashscreen_ui3d.tscn`
- Extraction de `UserInterface2D_1920x1080` dans `000_splashscreen_debug.tscn`
- Correction des références aux textes 3D

### 3. Correction du style visuel du bouton Skip
**Timecode** : 2025-11-28 ~17:30-20:00  
**Statut** : ✅ **COMPLETED**

#### 3.1 Redimensionnement des textures
- Implémentation de `_scale_texture()` pour redimensionner les textures à 0.5 (comme dans l'ancien code TypeScript)
- Application de `imageOpacity` directement sur les pixels de la texture (0.75 pour Background, 0.25 pour Foreground)
- Ajustement des `patch_margins` à 10 (20 * 0.5) pour tenir compte du scale

#### 3.2 Configuration de la police Chakra Petch
- Ajout de la police `chakra-petch-2.ttf` dans `assets/fonts/`
- Application de la police à tous les Labels (DolmenAGXText, DolmenAGXSentence, StoneBlockText, StoneBlockSentence, BtnSkip/Label)
- Configuration des paramètres de texte :
  - `font_color`: `#eeeeee` (Color(0.933333, 0.933333, 0.933333, 1))
  - `font_outline_color`: `#111111` (Color(0.0666667, 0.0666667, 0.0666667, 1))
  - `outline_size`: 6
  - `font_size`: 26 (pour le bouton Skip)
  - `font_letter_spacing`: 1

#### 3.3 Corrections diverses
- Correction des erreurs de parsing (suppression des commentaires dans .tscn)
- Correction de la variable shadowée `scale` → `scale_factor`
- Correction des références aux textes 3D dans `000_splashscreen_scene.gd`
- Correction de la variable non utilisée `fps_label` → `_fps_label`

## Verification Plan

### Manual Verification
- ✅ Run the Splashscreen scene.
- ✅ Verify the button structure in Remote tree.
- ✅ Test hover/click interactions to ensure animations play correctly via the new `TweenButton` system.
- ✅ Vérifier que les textures sont correctement redimensionnées à 0.5
- ✅ Vérifier que l'opacité des textures correspond à l'ancien code (imageOpacity)
- ✅ Vérifier que la police Chakra Petch est appliquée à tous les textes
- ✅ Vérifier que les dimensions et le style du bouton correspondent à l'ancien design
