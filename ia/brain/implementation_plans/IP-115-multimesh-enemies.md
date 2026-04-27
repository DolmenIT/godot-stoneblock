# IP-115 : Rendu MultiMesh Hybride pour Ennemis

## Description
Optimisation massive du rendu des ennemis pour réduire les Draw Calls sur mobile. Au lieu que chaque ennemi dessine son propre modèle, un `SB_MultiMeshManager` centralise les meshes identiques et les dessine en une seule passe via `MultiMeshInstance3D`.

## User Review Required
> [!IMPORTANT]
> Les ennemis garderont leur nœud `Area3D` pour la logique et les collisions, mais leur visuel sera masqué au profit du MultiMesh.
> Les effets de flash (HitFlash) devront être adaptés pour passer par les `instance_custom` data du MultiMesh.

## Proposed Changes

### [StoneBlock Core]

#### [NEW] [SB_MultiMeshManager.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_MultiMeshManager.gd)
- Gère un dictionnaire de `MultiMeshInstance3D` indexé par le `Mesh` source.
- Offre des méthodes `register_instance(mesh, transform, custom_data)` et `update_instance(...)`.
- Nettoyage automatique des instances orphelines.

### [StoneBlock Enemies]

#### [MODIFY] [SB_Enemy_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_Enemy_VShmup.gd)
- Ajout d'une option `@export var use_multimesh: bool = true`.
- Si activé, masque le `VesselPivot` et s'enregistre auprès du `SB_MultiMeshManager`.
- Mise à jour du transform dans `_process`.

---

## Verification Plan
### Automated Tests
- Comparaison des FPS et du nombre de Draw Calls dans le Debugger de Godot avant/après.
- Vérification que la mort d'un ennemi retire bien son visuel du MultiMesh.
