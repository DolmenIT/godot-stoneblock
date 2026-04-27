# [IP-065] Système d'Alerte "Incoming Enemy" (Indicateurs)

Ce plan vise à ajouter des indicateurs visuels au bord de l'écran pour prévenir le joueur de l'arrivée imminente des ennemis, même s'ils sont encore hors-champ.

## User Review Required

> [!IMPORTANT]
> **COMPOSANT MODULAIRE** : Le système sera basé sur un nouveau composant `SB_EnemyWarning_VShmup`. Pour activer l'alerte sur un type d'ennemi, il suffira de lui ajouter ce composant en enfant dans sa scène `.tscn`.

## Proposed Changes

### UI & Visuals

#### [NEW] [warning_icon_enemy.png](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/assets/warning_icon_enemy.png)
-   Générer une icône d'alerte stylisée (ex: tête de mort ou point d'exclamation rouge pulsant avec une flèche vers le bas).

#### [NEW] [SB_EnemyWarning_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_EnemyWarning_VShmup.gd)
-   Composant à placer sous un ennemi.  
-   **Properties** :
    -   `warning_distance` (float) : Distance Z avant l'activation où l'icône apparaît.
    -   `icon_texture` (Texture2D) : L'icône à afficher.
    -   `color` (Color) : Couleur de l'alerte.
-   **Logic** :
    -   Au `_ready`, crée dynamiquement une instance d'un nœud `Sprite2D` sur le `CanvasLayer` de l'interface (ou un `CanvasLayer` dédié).
    -   Chaque frame : 
        -   Calculer la position 2D projetée du parent (l'ennemi) via la caméra `Mainground_Camera`.
        -   Si l'ennemi est au-delà du haut de l'écran :
            -   Clamper la position X de l'icône sur le bord supérieur.
            -   Afficher l'icône et jouer une animation de pulsation.
        -   Dès que l'ennemi devient visible (Z > limite haute), cacher l'icône.
        -   S'auto-détruire quand l'ennemi meurt ou est supprimé.

### Refactoring Ennemis

#### [MODIFY] [SB_Enemy_VShmup.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_Enemy_VShmup.tscn)
-   Ajouter le composant `SB_EnemyWarning_VShmup` par défaut sur l'ennemi de base.

## Open Questions

- Souhaitez-vous que l'indicateur change de taille ou de vitesse de pulsation selon la proximité de l'ennemi ?
- Devons-nous afficher l'icône uniquement pour les "gros" ennemis ou pour tout le monde (vagues de base incluses) ?

## Verification Plan

### Manual Verification
- [ ] Lancer la démo.
- [ ] Vérifier que des icônes rouges apparaissent en haut de l'écran avant que les ennemis ne descendent.
- [ ] Vérifier que les icônes suivent bien le mouvement horizontal (X) des ennemis.
- [ ] Vérifier que l'icône disparaît pile au moment où le vaisseau ennemi entre dans le champ de vision.
