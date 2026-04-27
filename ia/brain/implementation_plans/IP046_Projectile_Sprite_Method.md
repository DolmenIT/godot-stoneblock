# [IP-046] Projectiles Basés sur Sprites (Méthode Robuste) - Cycle SHMUP

Suite aux difficultés rencontrées avec les systèmes de particules, ce plan propose d'utiliser une approche par Sprite (Image) unique pour les projectiles. Cela garantit une forme de "goutte" parfaite et une traînée constante.

## User Review Required

> [!IMPORTANT]
> - Tous les anciens systèmes (Particules, Glow fictif, Mesh sphérique) seront supprimés au profit d'un seul `Sprite3D`.
> - La texture utilisée sera extraite de la pochette de sprites générée ([ia/resources/macross_insight/projectiles_spritesheet.png](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/ia/resources/macross_insight/projectiles_spritesheet.png)).

## Proposed Changes

### [Component] Projectiles (Base & Ennemis)

#### [MODIFY] [SB_Projectile_VShmup.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/projectiles/SB_Projectile_VShmup.tscn)
- Suppression des nœuds : `MeshInstance3D`, `GlowSprite`, `TrailVFX`.
- Ajout d'un nœud : `Sprite3D` ("BulletSprite").
- Configuration du `Sprite3D` : Billboard activé, Texture Region utilisée pour isoler une goutte.

#### [MODIFY] [SB_Projectile_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/projectiles/SB_Projectile_VShmup.gd)
- Simplification du script pour ne piloter que le `modulate` du nouveau `BulletSprite`.

#### [MODIFY] [SB_Projectile_Enemy_VShmup.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/projectiles/SB_Projectile_Enemy_VShmup.tscn)
- Même simplification, avec une version rouge/rose de la même texture.

---

## Open Questions

- **Choix du Sprite** : Dans la planche générée, préfères-tu une goutte **très longue** (plus dynamique) ou **courte et compacte** (plus précise) ?
- **Region Godot** : Souhaites-tu que je configure la région du sprite moi-même en essayant d'isoler la meilleure "goutte" ?

## Verification Plan

### Manual Verification
- Test en jeu pour vérifier que la goutte garde sa forme quelle que soit la vitesse.
- Vérification de la lisibilité sur mobile.
