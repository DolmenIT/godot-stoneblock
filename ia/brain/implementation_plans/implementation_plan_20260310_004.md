# Implementation Plan - Startup Material Fix (20260310_004)

## 📅 Timeline
- **Début** : 2026-03-10 ~19:00
- **Statut** : ✅ **COMPLETED**

### Summary
Fixed the issue where terrain materials were not correctly restored on scene reload/startup because shader parameters (padding, resolution) were not reapplied.

### 1. Script Updates
**Timecode** : 2026-03-10 ~19:05-19:20  
**Statut** : ✅ **COMPLETED**
- Updated `SB_Heightmap._apply_bundle_chunk` to force `set_shader_parameter` for resolution and padding.
- Updated `SB_HeightmapGrid._apply_bundle_to_all_generators` to propagate settings to children before mesh reconstruction.

### 2. Verification
**Timecode** : 2026-03-10 ~19:25 
**Statut** : ✅ **COMPLETED**
- Verified visual persistence after reloading the scene in Godot.
