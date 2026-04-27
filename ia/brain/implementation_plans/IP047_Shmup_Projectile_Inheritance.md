# [IP-047] Architecture Démo-Spécifique (Héritage) - Projectiles

Découplage des assets visuels de la Démo 1 du moteur Core StoneBlock en utilisant l'héritage de scènes Godot. 
L'objectif est de capturer l'essence des classiques comme **Gradius/LifeForce**, **Super Aleste** et **Macross Shooting Insight** (mélange de précision rétro et d'éclat moderne).

## Proposed Changes

### [Component] Core Cleaning (StoneBlock)

#### [MODIFY] [SB_Projectile_VShmup.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/projectiles/SB_Projectile_VShmup.tscn)
- Rétablissement d'un visuel neutre (SphereMesh).
- Suppression des dépendances à la planche de sprites spécifique.

### [NEW] Demo Specialization (Demo 1)

#### [NEW] [bullet_player_1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/projectiles/bullet_player_1.tscn)
- Scène héritée de `SB_Projectile_VShmup.tscn`.
- Configuration du Sprite et de la Région.

#### [NEW] [bullet_enemy_1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/projectiles/bullet_enemy_1.tscn)
- Scène héritée de `SB_Projectile_Enemy_VShmup.tscn`.
- Configuration visuelle ennemie.

---

## Verification Plan

### Manual Verification
- Vérifier que la Démo 1 utilise bien les scènes du dossier `demo/demo1/projectiles/`.
- Vérifier que le Core `stoneblock/` reste générique.
