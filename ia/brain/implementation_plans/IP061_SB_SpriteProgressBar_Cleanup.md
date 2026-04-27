# [IP-061] Nettoyage et Optimisation SB_SpriteProgressBar

Ce plan vise à finaliser l'option `ignore_hud_scaling` et à simplifier le rendu de la barre de progression pour garantir un affichage pixel-perfect sans calculs d'intersection complexes quand ce n'est pas nécessaire.

## User Review Required

> [!IMPORTANT]
> Nous remplaçons définitivement `use_pixel_perfect` par `ignore_hud_scaling`. Cette option permet à la barre de compenser le scale de ses parents (souvent le HUD qui s'adapte à l'écran) pour rester à sa taille de design originale.

## Proposed Changes

### UI Component

#### [MODIFY] [SB_SpriteProgressBar.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_SpriteProgressBar.gd)
- Force `texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST` dans `_ready` pour éviter le lissage.
- Utilisation de `floor()` ou `round()` sur les coordonnées de `fill_rect` et `src_rect` pour garantir un alignement parfait sur la grille de pixels.
- Retrait définitif de toute référence à `use_pixel_perfect` (si encore présente).
- Optimisation de `_draw_segmented` : suppression du calcul d'intersection si `is_continuous` est faux ou si la tuile est totalement pleine/vide.
- Utilisation de `draw_texture` simple au lieu de `draw_texture_rect_region` quand le remplissage est complet (pour éviter les erreurs de flottants).
- S'assurer que `_design_scale` et `_design_position` sont correctement capturés.

## Open Questions

- Aucune pour le moment.

## Verification Plan

### Manual Verification
- [ ] Lancer la scène de démo.
- [ ] Modifier la taille de la fenêtre Godot.
- [ ] Vérifier que les barres de vie/bouclier marquées `ignore_hud_scaling = true` restent nettes et à taille fixe (pixels).
- [ ] Vérifier que le remplissage (clipping) fonctionne toujours correctement en mode continu et segmenté.
