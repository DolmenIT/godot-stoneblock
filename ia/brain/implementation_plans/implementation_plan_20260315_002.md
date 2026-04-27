# Implementation Plan - Layer Isolation & Fix Interference (20260315_002)

## Goal
Fix cross-layer interference where overlapping layers affect each other's meshes (seams), normals (border sync), and auto-sculpt rules.

## Proposed Changes

### [Component] TerrainGridSynchronizer
#### [MODIFY] [terrain_grid_synchronizer.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/tools/terrain_grid_synchronizer.gd)
- Update `assign_neighbors` to only match terrains with the same `layer_index`.
- Update `are_adjacent` to only return true for terrains with the same `layer_index`.
- Update `sync_all_borders` to handle layers independently.

### [Component] TerrainSculptOpsStandard
#### [MODIFY] [terrain_sculpt_ops_standard.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/tools/operations/terrain_sculpt_ops_standard.gd)
- Update `_get_global_height` to pass `current_t.chunk_index` (absolute index) to the manager instead of the relative `t_idx`.
- This ensures layer isolation works correctly even when the target terrains list is filtered by the active grid.

### [Component] SB_HeightmapGrid
#### [MODIFY] [SB_HeightmapGrid.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/components/SB_HeightmapGrid.gd)
- Force `TerrainGridSynchronizer.assign_neighbors` call at the beginning of `_sync_all_borders`.
- This ensures that neighbor pointers are refreshed and layer-isolated before any synchronization or mesh update occurs.

## Verification Plan
1. Overlap two layers (Layer 0 at Y=0, Layer 1 at Y=100).
2. Run an Auto-Paint rule on Layer 1 that uses "Slope" as a condition.
3. Verify that the slope is calculated based on Layer 1's shape, not Layer 0's.
4. Run "Smooth" on Layer 0 and verify NO heights from Layer 1 are sampled.
5. Verify normal continuity across chunks of the same layer.
