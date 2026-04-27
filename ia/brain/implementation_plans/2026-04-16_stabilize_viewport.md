# Stabilisation du Système de Qualité Dynamique

Ce plan vise à éliminer les glitches visuels et les tremblements d'image causés par les changements constants de résolution des viewports. Nous allons introduire deux nouveaux paramètres : la cadence de mise à jour (cadence) et le pas de granularité (step).

## User Review Required

> [!IMPORTANT]
> Les changements affecteront à la fois le Hangar (MenuScreen) et le jeu (VShmup). Les valeurs par défaut seront fixées à 1.0s pour la cadence et 0.1 (10%) pour le pas, ce qui devrait grandement stabiliser l'image.

## Proposed Changes

### [Component] Viewport Manager

#### [MODIFY] [SB_ViewportManager_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/viewportmanagers/SB_ViewportManager_VShmup.gd)

- Ajout de `quality_cadence` (float) et `quality_step` (float).
- Ajout d'un timer interne `_cadence_timer`.
- Ajout de variables d'état pour stocker les cibles quantifiées (`_target_bg`, `_target_mg`, `_target_bl`).
- Modification de `update_dynamic_resolution` :
    - Mise à jour du timer.
    - Recalcul des cibles uniquement si le timer dépasse la cadence.
    - Utilisation de `snappedf()` pour quantifier les cibles.
    - Lerp continu vers ces cibles quantifiées pour garder une transition douce sans tremblements.

---

### [Component] Game Modes

#### [MODIFY] [SB_GameMode_MenuScreen.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_MenuScreen.gd)
- Ajout des exports `@export var quality_cadence` and `quality_step`.
- Injection des valeurs dans `viewport_manager` lors de l'initialisation.

#### [MODIFY] [SB_GameMode_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_VShmup.gd)
- Ajout des mêmes exports pour la cohérence entre les modes de jeu.
- Injection dans `viewport_manager`.

## Verification Plan

### Automated Tests
- Lancer la scène du Hangar (`12_menu_hangar_3d`).
- Observer le compteur FPS et la résolution (via le mode debug ou en observant visuellement les transitions).
- Vérifier que la résolution ne change plus de manière erratique mais par paliers de 10% toutes les secondes.

### Manual Verification
- Tester sur Desktop avec une fenêtre redimensionnée pour forcer des changements de FPS.
- Vérifier qu'il n'y a plus de "tremblement" (flickering des bords) une fois la cible atteinte.
