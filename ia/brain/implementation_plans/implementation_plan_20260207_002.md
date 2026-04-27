# Implementation Plan - GameMode Shmup Refactoring (Segmentation) (20260207_002)

## Goal Description
Refactor `GameMode_Shmup.gd` to reduce its size (currently ~1600 lines) to under 750 lines by extracting logic into dedicated component scripts. This will improve maintainability and readability before adding new features like JSON Save/Load.

## User Review Required
> [!IMPORTANT]
> This refactoring involves moving valid logic to new files. The `GameMode_Shmup` scene structure might need adjustment if components are added as nodes.
> **Strategy**: We will keep `GameMode_Shmup.gd` as the central coordinator. Components will be instantiated as child nodes (or RefCounted objects if no tree access is needed, but Nodes are preferred for `_process` handling).

## Proposed Changes

### New Components Structure
We will create a specific folder `scripts/gamemode/shmup/components/` (or similar) to house these new scripts.

#### 1. [NEW] `ShmupCameraManager`
**Responsibility**: manages the 4 parallax cameras, their positions, and dynamic speed zones.
- **Moved Variables**: 
    - `main_camera_speed`, `use_dynamic_speed_zones`, `speed_zones`.
    - `*_camera_projection`, `*_camera_y_position`, `*_camera_size`.
    - `current_scroll_speed`, `world_position_z` (or shared).
- **Moved Methods**:
    - `_setup_cameras`, `_apply_camera_settings`.
    - `_calculate_dynamic_speeds`, `_interpolate_camera_speeds`, `_update_camera_positions`.
    - setters for camera properties.

#### 2. [NEW] `ShmupViewportManager`
**Responsibility**: Manages the 4 SubViewports, their resolution scaling, and render intervals for optimization.
- **Moved Variables**:
    - `*_resolution_scale`, `*_render_interval`.
    - `show_*_viewport`.
    - `frame_counters`.
- **Moved Methods**:
    - `_setup_viewport_worlds`.
    - `_update_viewport_visibility`, `_apply_viewport_optimizations`.
    - `_maintain_viewport_resolutions`, `_update_optimized_viewports`.

#### 3. [NEW] `ShmupProgressiveDisplay`
**Responsibility**: Handles the hiding/showing of terrain and enemies based on distance to optimize rendering.
- **Moved Variables**:
    - `enable_progressive_display`, `background_min_distance`, `distance_mode`.
    - `enable_enemy_progressive_display`, `enemy_min_distance`.
- **Moved Methods**:
    - `_initialize_progressive_display`.
    - `_update_progressive_display`, `_update_enemy_progressive_display`.
    - `_find_terrains_recursive`.

#### 4. [NEW] `ShmupDebugVisuals`
**Responsibility**: Manages debug visual aids (Bounding Cylinders, Hitboxes, Outlines) and the Performance Monitor.
- **Moved Variables**:
    - `show_player_bounding_cylinder`, `player_bounding_cylinder_color`, etc.
    - `enable_player_outline`, `player_outline_visibility_assistance`.
    - `global_activation_method` (Oscillating Trajectories config).
- **Moved Methods**:
    - Getters/Setters for visual properties.
    - `_setup_performance_monitor`.
    - `_set_*_outline_visibility_assistance`.

#### 5. [NEW] `ShmupProgression`
**Responsibility**: Tracks game progress, time, and handles the UI overlay for progression.
- **Moved Variables**:
    - `level_start_z`, `level_end_z`, `current_progress`, `game_time`.
    - `show_progress_overlay`.
- **Moved Methods**:
    - `_update_progress`, `get_progress`.
    - `_setup_progress_overlay`.

### Refactoring `GameMode_Shmup.gd`
- Will now instantiate these components (likely in `_ready`).
- `_process` will call `component.update(delta)`.
- Export variables can be moved to components OR kept in GameMode and passed to components during init (to avoid breaking existing .tscn values). 
    - *Decision*: **Keep Exports in GameMode** for now to avoid data loss in the inspector, and pass them/sync them to components. Or, if we use Resources, we could export the Resource.
    - *Hybrid Approach*: We will keep critical config exports that are already set in the level scenes to preserve data.

## Verification Plan
### Automated Tests
- None available currently.

### Manual Verification
1.  **Launch Game**: Run the prototype scene.
2.  **Visual Check**:
    -   Do all 4 parallax layers move correctly?
    -   Is the UI Overlay visible and updating?
3.  **Debug Check**:
    -   Toggle Debug Visuals (if buttons implemented or via code).
    -   Check Performance Monitor.
4.  **Editor Check**:
    -   Ensure Inspector variables still affect the game (might need `tool` script updates or syncing).
