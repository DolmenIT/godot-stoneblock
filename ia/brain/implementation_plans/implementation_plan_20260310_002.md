# Implementation Plan - Fix Compilation & Path Regressions (20260310_002)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2026-03-10 ~13:43
- **Statut** : 🔄 **IN PROGRESS**

## 📋 Contexte & Objectifs
Suite au refactor amorcé dans le plan `001`, plusieurs erreurs de compilation bloquent le projet :
1. `SB_HeightmapGrid.gd` tente de précharger `SB_Heightmap.tscn` qui n'existe plus (passage au mode script pur / "composant").
2. Les erreurs de parsing empêchent Godot de reconnaître la `class_name SB_HeightmapGrid`, causant des erreurs d'affectation dans `SB_SplattingConfig.gd`.
3. L'addon `terrain_brush_plugin` ne compile plus par dépendance.

L'objectif est de restaurer la compilation en corrigeant les références de chemins et en s'assurant que les scripts sont correctement chargés.

## 🏗️ Modifications Proposées

### [Scripts]

#### [MODIFY] [SB_HeightmapGrid.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/components/SB_HeightmapGrid.gd)
- Supprimer le `preload` de `res://scenes/components/terrain/SB_Heightmap.tscn` à la ligne 19.
- Initialiser `SB_Heightmap_Scene` à `null` par défaut.
- Changer le type de l'argument `progress_dialog` de `Object` à `Variant` dans `extract_all_resources` (ligne 363) et `generate_grid` (ligne 336).
- **CRITIQUE** : Ajouter `await` devant `TerrainGridBuilder.generate_grid(self, progress_dialog)` à la ligne 338.

#### [MODIFY] [SB_Heightmap.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/components/SB_Heightmap.gd)
- Renforcer `_clear_serialized_bundle_data()` (ligne 365) pour un nettoyage total :
    - Déconnecter `material_texture_storage` de la scène (`set_owner(null)`).
    - Mettre `heightmap_resource`, `material_texture`, `blurred_texture`, `local_splatmaps`, `base_material` à `null` pour la sauvegarde.
    - Vider les collisions (`c.shape = null`).
    - Cela garantira que Godot ne sauve strictement rien dans le `.tscn`.

#### [MODIFY] [TerrainResourceExporter.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/tools/terrain_resource_exporter.gd)
- **CRITIQUE** : Supprimer l'appel à `gen.update_terrain_mesh()` à la ligne 93 qui réinjectait les ressources juste avant la sauvegarde réelle.

#### [MODIFY] [TerrainLevelBundle.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/tools/terrain_level_bundle.gd)
- Ajouter la fonction `add_chunk(chunk: TerrainChunkData)` manquante.

## 🚀 Étapes d'exécution

### 1. Correction de SB_HeightmapGrid
**Timecode** : 2026-03-10 ~13:45-13:52
**Statut** : ✅ **COMPLETED**
- Modifier la ligne 19 pour supprimer le preload erroné.

### 2. Correction du typage extract_all_resources
**Timecode** : 2026-03-10 ~13:58-14:02
**Statut** : ✅ **COMPLETED**
- Modifier `SB_HeightmapGrid.gd`, `TerrainResourceExporter.gd` et `TerrainGridBuilder.gd` pour utiliser `Variant` à la place de `Object`.

### 3. Correction de la disparition de la grille
**Timecode** : 2026-03-10 ~14:05
**Statut** : ✅ **COMPLETED**
- Supprimer l'appel à `_clear_serialized_bundle_data()` dans `TerrainResourceExporter.gd`.

### 4. Vérification de la compilation
**Timecode** : 2026-03-10 ~14:08
**Statut** : ✅ **COMPLETED**
- Validation par l'utilisateur du rétablissement de l'addon.

## 🧪 Plan de Vérification Terminé
- [x] Chargement du projet dans Godot : OK.
- [x] Panneau d'erreurs vidé des Parse Errors : OK.
- [x] Grille visible après génération : OK.
