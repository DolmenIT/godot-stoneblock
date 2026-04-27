# [IP-065] Système d'Indicateurs de Cible 360° (Générique)

Ce plan vise à créer un système d'indicateurs flexible capable de suivre des entités hors-champ dans toutes les directions. Ce système sera compatible avec le SHMUP vertical actuel mais aussi avec de futurs modes de jeu plus ouverts (vue libre).

## User Review Required

> [!IMPORTANT]
> **VERSATILITÉ** : Le composant pourra être utilisé pour des ennemis, des alliés ou des objectifs. Il gérera automatiquement le "clamping" au bord de l'écran et l'orientation des flèches.

## Proposed Changes

### UI Assets

#### [NEW] [indicator_arrow_vshmup.png](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/assets/indicator_arrow_vshmup.png)
-   Générer une flèche directionnelle stylisée (Pixel-Art, propre au style StoneBlock).

### Logic Implementation

#### [NEW] [SB_TargetIndicator_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_TargetIndicator_VShmup.gd)
-   **Classe de base** : `Node` (Composant). 
-   **Exports** :
    -   `indicator_texture` (Texture2D) : L'icône (ex: tête de mort).
    -   `arrow_texture` (Texture2D) : La flèche qui pointe vers la cible.
    -   `color` (Color) : Couleur globale de l'indicateur.
    -   `margin` (float) : Distance de sécurité par rapport au bord de l'écran (ex: 20 pixels).
    -   `hide_on_screen` (bool) : Si vrai, l'indicateur disparaît quand la cible est visible (Défaut: true).
    -   `rotate_to_target` (bool) : Si vrai, l'icône/flèche pivote vers la cible (Défaut: true).
-   **Mathématiques de Clamping** :
    1.  Projetter la position 3D de l'entité parente en position 2D écran (`unproject_position`).
    2.  Déterminer si la position est à l'intérieur du `Viewport`.
    3.  Si hors-champ :
        -   Calculer le vecteur entre le centre de l'écran et la cible.
        -   Trouver l'intersection entre ce vecteur et les bords du rectangle de l'écran (en tenant compte de la `margin`).
        -   Positionner l'icône à cet endroit.
        -   Appliquer la rotation pour que la flèche pointe vers la cible.

### Intégration

#### [MODIFY] [SB_Enemy_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_Enemy_VShmup.gd)
-   Ajouter un slot optionnel pour activer l'indicateur ou simplement permettre de l'ajouter manuellement dans la scène `.tscn`.

## Open Questions

- Souhaitez-vous afficher la distance en texte sous l'icône (ex: "45m") ?
- Devons-nous gérer une "priorité" pour que les alertes d'ennemis ne se superposent pas sur les objectifs ?

## Verification Plan

### Manual Verification
- [ ] Ajouter le composant à un ennemi venant du haut.
- [ ] Ajouter le composant à un ennemi placé loin sur la gauche (hors-champ).
- [ ] Vérifier que les indicateurs restent "collés" au bord de l'écran et pointent correctement vers leurs cibles respectives.
- [ ] Déplacer la caméra et vérifier que les indicateurs se déplacent en temps réel le long des bords.
