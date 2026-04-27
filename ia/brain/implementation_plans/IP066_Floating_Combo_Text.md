# [IP-066] Système de Texte Flottant (Combo Kill)

Ce plan vise à rendre le feedback de combat plus dynamique en affichant le nombre de kills directement sur l'ennemi qui vient d'exploser, tout en épurant le HUD.

## User Review Required

> [!IMPORTANT]
> **CHANGEMENT HUD** : Le compteur "COMBO X" en haut à droite sera masqué pour éviter la redondance avec les textes flottants.
> **BILLBOARD** : Le texte utilisera un mode "Billboard" pour être toujours face à la caméra.

## Proposed Changes

### Logic & Effects

#### [NEW] [SB_FloatingText_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/effects/SB_FloatingText_VShmup.gd)
-   **Classe** : `Label3D`.
-   **Fonctionnalités** :
    -   Initialisation avec un texte (ex: "32 Kill").
    -   Animation `Tween` : Montée verticale (Y+) et fondu de l'opacité (Alpha -> 0).
    -   Auto-nettoyage (`queue_free()`) à la fin de l'animation.
    -   Configuration visuelle : Couleur jaune/dorée par défaut, contour noir pour la lisibilité.

#### [MODIFY] [SB_Enemy_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_Enemy_VShmup.gd)
-   Modifier `_explode()` :
    -   Appeler `add_score_kill()` avant l'instanciation du texte.
    -   Récupérer la valeur `combo_level` depuis le `GameMode`.
    -   Instancier `SB_FloatingText_VShmup` à `global_position` si `combo_level > 1`.

### User Interface

#### [MODIFY] [SB_HUD_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_HUD_VShmup.gd)
-   Désactiver la mise à jour visuelle du `combo_label` dans le `_process` pour laisser le champ libre aux textes flottants.

## Open Questions

- Souhaitez-vous que le texte "Kill" soit localisé ou reste en anglais ?
- Quelle couleur préférez-vous pour le texte ? (Actuellement prévu : Jaune #FFCC00).

## Verification Plan

### Manual Verification
- [ ] Détruire un ennemi et vérifier l'apparition du texte "2 Kill" (si c'est le 2ème).
- [ ] Enchaîner plusieurs destructions pour voir les textes s'empiler et s'animer.
- [ ] Vérifier que le HUD ne montre plus le combo en haut à droite.
