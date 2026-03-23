# Implementation Plan - Fix Manual Save (Ctrl+S) Data Loss (20260310_005)

## 📅 Timeline
- **Début** : 2026-03-10 ~23:35
- **Statut** : ✅ **COMPLETED**

### Summary
Fixed a critical data loss issue occurring during manual saves (`Ctrl+S`). The problem was caused by a race condition where memory was cleared for `.tscn` lightness before the resource extraction (to `.res`) was complete.

### 1. Script Analysis & Troubleshooting
**Timecode** : 2026-03-10 ~23:36-23:40  
**Statut** : ✅ **COMPLETED**
- Identified from logs that `Colormap: Non` was appearing specifically during manual saves.
- Determined that `NOTIFICATION_EDITOR_PRE_SAVE` was clearing data too early if the `dirty` flag was not set.

### 2. Implementation of the Fix
**Timecode** : 2026-03-10 ~23:42-23:45  
**Statut** : ✅ **COMPLETED**
- Modified `SB_HeightmapGrid.gd`'s `_notification(NOTIFICATION_EDITOR_PRE_SAVE)`.
- Reordered logic: Always call `extract_all_resources()` (to `.res`) before looping through generators to call `_clear_serialized_bundle_data()` (for `.tscn`).
- Internal debounce in `TerrainResourceExporter` ensures no performance hit.

### 3. Verification
**Timecode** : 2026-03-10 ~23:47 
**Statut** : ✅ **COMPLETED**
- Verified with user: Manual save now preserves all texture data in the bundle.
- Verified that `.tscn` weight remains minimal (< 5KB).
