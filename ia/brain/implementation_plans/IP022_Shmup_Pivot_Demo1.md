# [IP-022] Pivot Démo 1 : Shoot 'em Up Vertical

Ce plan détaille la transformation de la Démo 1 (Launcher/Platformer) en un prototype de Shoot 'em up vertical utilisant des composants portés depuis Cosmic HyperSquad.

## Proposed Changes

### [StoneBlock GDK - SHMUP Components]
Création de la couche de base pour le gameplay SHMUP avec une structure par catégories.

#### [NEW] [SB_GameMode_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_VShmup.gd)
- **Logique** : Coordinateur principal.

#### [NEW] [SB_CameraManager_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/cameramanagers/SB_CameraManager_VShmup.gd)
- **Logique** : Gestion des caméras.

#### [NEW] [SB_ViewportManager_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/viewportmanagers/SB_ViewportManager_VShmup.gd)
- **Logique** : Gestion des viewports.

#### [NEW] [SB_Player_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/players/SB_Player_VShmup.gd)
- **Logique** : Vaisseau joueur avec contraintes d'écran et suivi du défilement Z.

#### [NEW] [SB_Projectile_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/projectiles/SB_Projectile_VShmup.gd)
- **Logique** : Projectiles.

### [Nouveaux Comportements]
- **Synchronisation Z** : Le joueur avance à la même vitesse que la caméra principale.
- **Clamping Écran** : Le joueur est restreint aux limites visibles de la caméra (Frustum/ViewRect).
- **Suivi Horizontal Dynamique** : La caméra suit le joueur latéralement avec un amorti, jusqu'aux limites de la "map".

#### [NEW] [SB_Scroll_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/scrolls/SB_Scroll_VShmup.gd)
- **Logique** : Défilement parallax.

#### [NEW] [SB_ShmupScroll.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/shmup/SB_ShmupScroll.gd)
- **Logique** : Déplacement vertical constant d'une liste de nœuds (Parallax possible).

### [Demo 1]
Refonte de la scène de jeu pour le nouveau genre.

#### [MODIFY] [40_game_scene.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/40_game_scene.tscn)
- Remplacement du controleur 3D par `SB_ShmupPlayer`.
- Configuration de la caméra en vue de dessus (Top-Down).
- Mise en place du défilement vertical via `SB_ShmupScroll`.

## Verification Plan

### Manual Verification
1. Lancer la scène `res://demo/demo1/40_game_scene.tscn`.
2. Vérifier que le vaisseau se déplace fluidement avec les flèches ou le joystick.
3. Vérifier l'effet de "banking" (roulis) lors des virages.
4. Appuyer sur "Action" (ou Espace) pour tirer des projectiles.
5. Vérifier que le décor défile verticalement de haut en bas.
