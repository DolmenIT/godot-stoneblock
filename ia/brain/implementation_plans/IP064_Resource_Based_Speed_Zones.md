# [IP-064] Zones de Vitesse basées sur des Ressources (No-Code friendly)

Ce plan vise à améliorer l'expérience utilisateur dans l'éditeur Godot en remplaçant l'utilisation des `Dictionary` pour les zones de vitesse par des objets `Resource` personnalisés. Cela permettra d'avoir des champs nommés, documentés et typés directement dans l'inspecteur.

## User Review Required

> [!IMPORTANT]
> **MIGRATION DES DONNÉES** : Le passage de `Array[Dictionary]` à `Array[SB_SpeedZone]` réinitialisera les zones de vitesse actuellement configurées dans vos scènes (si vous en aviez déjà). Il faudra les recréer à l'aide du nouveau bouton "Ajouter SB_SpeedZone".

## Proposed Changes

### Core Resource

#### [NEW] [SB_SpeedZone.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/resources/SB_SpeedZone.gd)
-   Créer une classe héritant de `Resource`.
-   Ajouter les propriétés suivantes avec documentation (`##`) :
    -   `start_z` (float) : Début de la zone (Z mondial).
    -   `end_z` (float) : Fin de la zone (Z mondial).
    -   `mainground_speed` (float) : Vitesse de la caméra principale.
    -   `background_speed` (float) : Vitesse du parallax arrière.
    -   `bloom_speed` (float) : Vitesse des effets de bloom (optionnel).
    -   `ui_speed` (float) : Vitesse de l'UI si parallaxée.
    -   `smoothness` (float) : Facteur de transition (interpolation).

### Logic Updates

#### [MODIFY] [SB_GameMode_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_VShmup.gd)
-   Changer le type de `@export var speed_zones: Array[Dictionary]` en `Array[SB_SpeedZone]`.

#### [MODIFY] [SB_CameraManager_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/cameramanagers/SB_CameraManager_VShmup.gd)
-   Changer le type de `@export var speed_zones: Array[Dictionary]` en `Array[SB_SpeedZone]`.
-   Mettre à jour la fonction `_calculate_dynamic_speeds` pour accéder aux propriétés de l'objet (ex: `zone.start_z`) au lieu des clés du dictionnaire (ex: `zone.get("start_z")`).

## Open Questions

- Souhaitez-vous que je pré-remplisse les nouvelles zones avec des valeurs par défaut pour faciliter la saisie ? (Ex: `smoothness` à 2.0).

## Verification Plan

### Manual Verification
- [ ] Dans l'éditeur Godot, ouvrir la scène principale.
- [ ] Sélectionner le nœud `Demo1_Shmup` (GameMode).
- [ ] Ajouter un élément à la liste `Speed Zones` et vérifier qu'un formulaire complet apparaît (au lieu d'un dictionnaire vide).
- [ ] Valider que le défilement change bien de vitesse en jeu en atteignant les coordonnées Z spécifiées.
