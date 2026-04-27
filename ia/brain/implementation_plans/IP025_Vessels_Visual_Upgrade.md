# [IP-025] Remplacement des Modèles 3D (Vaisseaux)

Amélioration visuelle de la Démo 1 en permettant l'utilisation de modèles 3D (.glb) via des paramètres dans les scripts Player et Enemy.

## Proposed Changes

### [StoneBlock Players & Enemies]

#### [MODIFY] [SB_Player_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/players/SB_Player_VShmup.gd)
- Ajouter `@export var vessel_scene: PackedScene`.
- Dans `_ready()`, si `vessel_scene` est défini, l'instancier et l'ajouter comme enfant.
- Assigner l'instance à `visual_node` pour que les rotations et le banking s'appliquent dessus.
- Cacher automatiquement le `MeshInstance3D` par défaut s'il existe.

#### [MODIFY] [SB_Enemy_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_Enemy_VShmup.gd)
- Ajouter `@export var vessel_scene: PackedScene`.
- Dans `_ready()`, si `vessel_scene` est défini, l'instancier et l'ajouter comme enfant.
- Cacher automatiquement le `MeshInstance3D` par défaut.

### [Demo 1 Configuration]

#### [MODIFY] [mainground.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/levels/level1/stage1/mainground.tscn)
- Assigner `res://assets/demo1/polygonal_phantom_jet.glb` au champ `vessel_scene` du joueur.

#### [MODIFY] [SB_Enemy_VShmup.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_Enemy_VShmup.tscn)
- Assigner `res://assets/demo1/emerald_nexus_disk.glb` au champ `vessel_scene` de l'ennemi de base.

## Verification Plan

### Manual Verification
1. Lancer la Démo 1.
2. Vérifier l'apparence des vaisseaux.
3. Vérifier que le banking du joueur fonctionne toujours.
