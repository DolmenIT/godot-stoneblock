# IP-066 : Amélioration de l'effet "Pop" des Textes Flottants

Ce plan vise à rendre l'apparition des textes de combo plus dynamique avec des effets d'échelle, de rotation orbitale et de mouvement fluide.

## User Review Required

> [!IMPORTANT]
> **LOGIQUE DE ROTATION :** Pour simuler la rotation autour du centre de l'ennemi sans ajouter de nœud pivot complexe, nous allons animer un angle et un rayon en local dans le script `Label3D`.
> **ÉCHELLE :** Le texte partira de 0 pour monter à 1.2 (effet d'écrasement/rebond) avant de se stabiliser sur sa taille finale.

## Proposed Changes

### Effets visuels (StoneBlock)

#### [MODIFY] [SB_FloatingText_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/effects/SB_FloatingText_VShmup.gd)
- Ajout de paramètres `@export` : `start_scale`, `overshoot_scale`, `rotation_arc` (amplitude de la courbe).
- Mise à jour de `_ready()` :
    - Initialisation de `scale` à `Vector3.ZERO`.
    - Animation `scale` : `0 -> 1.2` (Back Out) sur 0.1s, puis stabilisation à 1.0.
    - Animation `position` : Calcul d'un décalage sinusoïdal sur l'axe X/Z pendant la montée en Y pour simuler la rotation orbitale.
    - Animation `rotation` : Application d'un tilt (rotation Z) progressif.

## Open Questions

- Souhaites-tu que tous les textes tournent dans le même sens (ex: toujours vers la droite) ou que ce soit aléatoire à chaque mort ?

## Verification Plan

### Manual Verification
- Détruire un ennemi dans la démo.
- Vérifier que le texte "X KILL" surgit avec un effet de rebond (scale).
- Vérifier que la trajectoire n'est plus purement verticale mais suit une légère courbe orbitale par rapport au point d'explosion.
