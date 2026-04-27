# [IP-083] Correction du Post-Process Bullet Time (Shader & Layering)

L'effet visuel du Bullet Time (overlay bleu) ne s'affiche pas car il tente de lire la texture d'écran alors qu'il se trouve sur la même couche de rendu que les éléments qu'il doit filtrer.

## Proposed Changes

### [Component] Scène de Jeu

#### [MODIFY] [40_game_scene.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/40_game_scene.tscn)

- Ajouter un `CanvasLayer` nommé `BulletTimeLayer` avec `layer = 50`.
- Déplacer `BulletTimeOverlay` sous ce nouveau layer.

### [Component] Shaders

#### [MODIFY] [SB_BulletTime_Overlay.gdshader](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/shaders/SB_BulletTime_Overlay.gdshader)

- Améliorer l'algorithme de vignette pour plus d'impact sur les bords.
- Renforcer la teinte bleue.

### [Component] TimeManager

#### [MODIFY] [SB_TimeManager.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_TimeManager.gd)

- Mettre à jour la recherche dynamique de l'overlay.

## Verification Plan

### Manual Verification
- Lancer le jeu et se faire toucher.
- Vérifier l'apparition instantanée de l'effet bleu et du flou sur les bords.
