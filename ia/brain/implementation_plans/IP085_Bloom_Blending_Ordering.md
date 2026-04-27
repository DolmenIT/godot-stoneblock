# [IP-085] Refonte du Layering et Modes de Blend du Bloom

Nous allons placer le Bloom par-dessus les objets et permettre de choisir entre le mode Additif (brillant) et Mix (vaporeux) pour chaque couche.

## Proposed Changes

### [Component] Scène de Jeu

#### [MODIFY] [40_game_scene.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/40_game_scene.tscn)

- Réorganiser `Viewports_Layer` pour placer `BloomLongContainer`, `BloomMedContainer` et `BloomShortContainer` **APRÈS** `MaingroundViewportContainer`.

### [Component] Shaders

#### [NEW] [SB_BloomBlur_Mix.gdshader](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/shaders/SB_BloomBlur_Mix.gdshader)
- Une copie de `SB_BloomBlur.gdshader` mais sans le `render_mode blend_add;`.

### [Component] Bloom Config

#### [MODIFY] [SB_BloomConfig.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/visual/bloom/SB_BloomConfig.gd)

- Ajouter une énumération `BloomBlendMode { ADD, MIX }`.
- Ajouter des propriétés `@export` pour chaque couche.
- Mettre à jour `_apply_internal` pour charger le bon shader dynamiquement.

## Verification Plan

### Manual Verification
- Lancer le jeu.
- Le Bloom doit maintenant déborder sur le Boss.
- Tester le passage d'une couche en mode `MIX` dans l'inspecteur : l'effet doit devenir plus "mat" et moins blanc.
