# Implementation Plan - GameMode Shmup JSON Save/Load (20260207_003)

## Goal Description
Implement functionality to save the current configuration of `GameMode_Shmup` (Inspector variables) to a JSON file and load it back. This allows for quick preset switching and backing up configurations.

## User Review Required
> [!NOTE]
> The Save/Load system will use a predefined file path defined in a constant (e.g., `res://config/gamemode_shmup_settings.json` or `user://...`).
> **Current Decision**: Use `res://settings/gamemode_shmup_settings.json` (or similar) to allow version control of settings, or `user://` if strictly local.
> *Assumption*: User wants to save "profiles" or a main config for the game design. Editor-time saving usually implies `res://`.

## Proposed Changes

### 1. Update `GameMode_Shmup.gd`
#### New Constants & Variables
- `const SETTINGS_FILE_PATH = "res://settings/gamemode_shmup_config.json"`
- `@export_group("Configuration Manager")`
- `@export var save_config: bool` (Button)
- `@export var load_config: bool` (Button)

#### New Methods
- `save_settings_to_json()`:
    - Creates a Dictionary containing all relevant `@export` variables.
    - Serializes to JSON.
    - Writes to `SETTINGS_FILE_PATH`.
- `load_settings_from_json()`:
    - Checks if file exists.
    - Reads and parses JSON.
    - Updates `self` variables (triggering setters).
    - For variables without setters or complex types (Arrays/Dictionaries), manually updates the relevant components.

### 2. Variables to Save
We will save all groups:
- `Scrolling` (speed)
- `Dynamic Speed Zones`
- `Progression` (start/end Z)
- `Performance Monitor` (bool)
- `Bounding Cylinders & Hitboxes` (all bools/colors)
- `Oscillating Trajectories` (all params)
- `Ship Outline` (all params)
- `Progressive Display` (all params)
- `Viewport Visibility` (all params)
- `Cameras (Editor)` (projections, positions, sizes)

## Verification Plan
### Manual Verification
1.  **Modify Settings**: Change camera speeds, outline colors, etc. in Inspector.
2.  **Save**: Click "Save Config". check file creation.
3.  **Reset/Change**: Change settings to something else.
4.  **Load**: Click "Load Config". Verify settings revert to saved values and valid Visuals update in viewport.
