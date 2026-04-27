# [IP-029] Système de Bullet Time (Slow Motion) au Hit

Ce plan vise à ajouter un effet de ralentissement temporel sélectif déclenché lorsque le joueur reçoit des dégâts, afin d'améliorer le feedback de combat et de donner une chance de survie supplémentaire.

## Proposed Changes

### [Core Engine]

#### [NEW] [SB_TimeManager.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_TimeManager.gd)
- **Rôle** : Gérer les variations de `Engine.time_scale` avec des transitions fluides.
- **Fonctionnalités** :
    - `hit_slowmo(duration, factor)` : Transition vers `factor`, attend, puis revient à `1.0`. Ralentissement sélectif (le joueur compense sa vitesse).
    - `death_slowmo(factor)` : Ralentissement global (jusqu'au restart). Tout ralentit, explosion comprise.
    - Utilisation de `create_tween()` pour des transitions non saccadées.

### [SHMUP Engine]

#### [MODIFY] [SB_Player_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/players/SB_Player_VShmup.gd)
- **Combat** : Appeler `SB_TimeManager.hit_slowmo()` dans `take_damage()`.
- **Mort** : Appeler `SB_TimeManager.death_slowmo(0.1)` dans `die()` avant l'attribution du score et l'UI Game Over.
- **Mouvement** : Compenser le `delta` réduit pour que le joueur garde sa vitesse réelle pendant le Bullet Time des impacts.
    - Utiliser `delta / Engine.time_scale` pour les calculs de position.
- **Visuels** : Idem pour la vitesse d'inclinaison (banking).

#### [MODIFY] [SB_GameMode_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_VShmup.gd)
- S'assurer que le `world_scroll_pivot` suit le temps ralenti (comportement par défaut avec `delta`).

## Verification Plan

### Manual Verification
1. Lancer la scène `res://demo/demo1/demo1_shmup.tscn`.
2. Se faire toucher par un ennemi ou un projectile.
3. Vérifier que :
    - Tout le jeu ralentit instantanément pendant 1 seconde.
    - Le joueur peut toujours se déplacer à une vitesse normale (sensation de "Flash").
    - Le temps revient à sa vitesse normale après le délai.
    - Pas de saccades lors de la transition.
