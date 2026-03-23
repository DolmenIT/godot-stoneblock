# Implementation Plan - Refactoring VoxelStairsEditor (20260221_014)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2026-02-21 ~22:58
- **Statut** : 🔄 **IN PROGRESS**

## Objectifs
Refactoriser `voxel_stairs_editor.gd` pour passer de **1105 lignes** à moins de **750 lignes**, conformément aux nouvelles règles de `ia.md`.

## Stratégie de Refactorisation
1. **Extraction de la Voxelization** : Créer `VoxelStairsVoxelizer.gd` pour isoler tout l'algorithme de conversion mesh-to-voxel, incluant l'échantillonnage de couleur et de texture.
2. **Extraction du Cursor/Helper Mesh Logic** : Déplacer la création et gestion des maillages d'aide (highlight, selection) vers une classe dédiée ou simplifier.
3. **Nettoyage des fonctions de débug/legacy** : Supprimer ou isoler les fonctions de test.

## Proposed Changes

### [Component: Voxel Editor]

#### [NEW] [VoxelStairsVoxelizer.gd](file:///d:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/500_gameplay_prototype_scene/prefabs_objects/prop_stairs/VoxelStairsVoxelizer.gd)
- Contiendra :
    - `voxelize_from_mesh`
    - `_collect_geometry_recursive`
    - `_process_voxel_voxelization`
    - `_sample_mesh_color`
    - `_is_point_inside_mesh`
    - `_mesh_intersects_box`

#### [MODIFY] [voxel_stairs_editor.gd](file:///d:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/500_gameplay_prototype_scene/prefabs_objects/prop_stairs/voxel_stairs_editor.gd)
- Délèguera les appels de voxelization au `VoxelStairsVoxelizer`.
- Nettoyage des fonctions extraites.

## Verification Plan
1. Vérifier que le bouton **Voxelize** fonctionne toujours à l'identique.
2. Vérifier que la capture de couleur reste fonctionnelle.
3. Vérifier que le fichier fait moins de 750 lignes.

### Automated Tests
- N/A (Editor Script)

### Manual Verification
- Test de voxelization sur le robot GLB.
- Test de peinture et destruction.
