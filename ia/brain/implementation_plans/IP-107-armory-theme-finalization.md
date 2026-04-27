# IP-107 : Finalisation Thèmes Armurerie 3D

Ce plan vise à stabiliser l'architecture diégétique de l'Armurerie en migrant la gestion visuelle des boutons vers le `SB_ThemeManager`.

## User Review Required

> [!IMPORTANT]
> L'échelle de base (`base_scale`) sera harmonisée à **35.0** pour tous les boutons de l'Armurerie afin d'éviter les "sauts" visuels lors du rafraîchissement du thème.

## Proposed Changes

### [Core] Système de Thème

#### [MODIFY] [SB_Button3d_Theme.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Button3d_Theme.gd)
- Ajuster le défaut de `base_scale` à **35.0** pour s'aligner sur le layout actuel de l'Armurerie.

#### [MODIFY] [00_boot.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/00_boot.tscn)
- Mettre à jour `upgrade_button3d` : changer "AMELIORER" en "AMÉLIORER".
- S'assurer que les presets `buy`, `upgrade` et `promo` n'écrasent pas inutilement le `base_scale` (sauf si exception).

---

### [UI] Armurerie

#### [MODIFY] [SB_Armory_Logic.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/scenes/armory/SB_Armory_Logic.gd)
- Supprimer les constantes `COLOR_BUY` et `COLOR_UPGRADE`.
- Dans `_update_item_ui` :
    - Remplacer l'assignation de `tint_normal` par `style_class_name = "buy_button3d"`, `"upgrade_button3d"` ou `"promo_button3d"`.
    - Supprimer l'appel à `btn._update_ui()` manuel (il est déjà déclenché par le setter de `style_class_name`).
    - Garder la logique de texte dynamique pour les cas spécifiques ("VERS LÉGENDAIRE", etc.).

#### [MODIFY] [armory_3d_content.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/scenes/armory/armory_3d_content.tscn)
- Assigner les `style_class_name` par défaut aux boutons pour un rendu propre dès l'édition.

## Verification Plan

### Manual Verification
- Lancer la scène `13_menu_armory_3d.tscn`.
- Vérifier que les boutons "ACHETER" sont bien bleus.
- Acheter une amélioration et vérifier qu'elle passe en vert ("AMÉLIORER") sans changer de taille.
- Atteindre le niveau de XP max et vérifier le passage au thème "PROMOTION" (Jaune/Or).
- Vérifier que le bouton "RETOUR" garde son style orange (style local ou preset par défaut).
