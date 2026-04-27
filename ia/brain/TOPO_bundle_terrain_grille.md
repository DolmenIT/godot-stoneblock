# Topo – Système bundle terrain (grille SB_HeightmapGrid)

> Document pour une IA qui reprend le dossier : comment ça marche, ce qui est en place, ce qu’il reste à réparer/améliorer.

---

## 1. Vue d’ensemble

- **Objectif** : Une grille de terrains (N×M chunks) est sauvegardée dans **un seul fichier `.res`** par niveau (`Level_1_Background_Terrains.res`) au lieu de centaines de fichiers (heightmap, mesh, collision, etc. par chunk).
- **Acteurs** :
  - **SB_HeightmapGrid** (`scripts/components/SB_HeightmapGrid.gd`) : manager de la grille, extraction/chargement du bundle.
  - **SB_Heightmap** (`scripts/components/SB_Heightmap.gd`) : un chunk de terrain (heightmap, mesh, collision, peinture).
  - **TerrainChunkData** (`scripts/tools/terrain_chunk_data.gd`) : ressource qui contient les données d’un chunk (sérialisées dans le bundle).
  - **TerrainLevelBundle** (`scripts/tools/terrain_level_bundle.gd`) : ressource avec `Array[TerrainChunkData]` = le fichier `.res`.
  - **TerrainBrushPlugin** (`addons/terrain_brush_plugin/terrain_brush_plugin.gd`) : déclenche l’extraction avant sauvegarde (`_apply_changes`).

---

## 2. Flux actuel

### 2.1 Sauvegarde (Ctrl+S)

1. **Plugin** : `_apply_changes()` → `_extract_all_managers_recursive(scene_root)`.
2. Pour chaque **SB_HeightmapGrid** : `extract_all_resources(null, true, true)` (force_sync + force_extract).
3. **SB_HeightmapGrid.extract_all_resources** :
   - Pour chaque générateur (`heightmap_generators`) : `_build_chunk_from_terrain(gen)` → un `TerrainChunkData` avec :
     - `heightmap_data` (PackedFloat32Array)
     - `colormap_texture`, `splatmaps`
     - **`mesh`** (ArrayMesh du `terrain_mesh_instance`)
     - **`collision_shape`** (ConcavePolygonShape3D dupliquée)
   - `ResourceSaver.save(bundle, bundle_path)` → un seul `.res` (ex. `res://.../Level_1_Background_Terrains.res`).
   - Rechargement du bundle depuis le disque (pour sub-resource paths).
   - Suppression des anciens `Terrain_*_Collision.tres` dans `terrains/`.
   - Application des chunks en mémoire sur les générateurs + mise en cache du bundle.
4. **Godot** : `NOTIFICATION_EDITOR_PRE_SAVE` → **SB_HeightmapGrid** appelle `_clear_serialized_bundle_data()` sur chaque gen :
   - On met à `null` uniquement : `terrain_mesh_instance.mesh`, `material_override`, `c.shape` (collision).
   - On **ne vide pas** `heightmap_data` ni les textures/matériaux (pour garder les données en RAM).
5. Godot écrit le `.tscn` (léger car mesh/material/shape = null).
6. **Godot** : `NOTIFICATION_EDITOR_POST_SAVE` → le grid appelle `update_terrain_mesh()` sur chaque gen pour recréer le mesh visuel depuis les `heightmap_data` conservées.

### 2.2 Ouverture de la scène

1. Chargement du `.tscn` → les `SB_Heightmap` ont `heightmap_data` vide (non exporté, valeur par défaut), mesh/shape à null.
2. **SB_HeightmapGrid._ready()** :
   - `_find_heightmap_generators()`.
   - Si `terrains_bundle_path` non vide : `load(terrains_bundle_path)` → `TerrainLevelBundle`.
   - **Si `bundle.get_chunk_count() != heightmap_generators.size()`** : on n’applique pas le bundle (warning + `terrains_bundle_path = ""`). Évite d’appliquer un ancien 3×3 sur une grille 4×4.
   - Sinon : pour chaque gen, `chunk_index = i` puis `call_deferred("_apply_bundle_to_all_generators")` et `call_deferred("_deferred_apply_bundle_second_pass")`.
3. **Frame suivante** : `_apply_bundle_to_all_generators()` :
   - Pour chaque gen : `_apply_bundle_chunk(chunk)` (heightmap_data, colormap, splatmaps, **mesh**, **collision_shape**).
   - Si chunk a mesh + collision_shape : `call_deferred("update_terrain_mesh", true)` (skip_collision) pour ne pas régénérer la collision.
   - Sinon : `call_deferred("update_terrain_mesh")`.
4. **SB_Heightmap._apply_bundle_chunk** : copie les données du chunk dans le gen, assigne `terrain_mesh_instance.mesh = chunk.mesh` et `c.shape = chunk.collision_shape`, puis diffère `update_terrain_mesh` (avec ou sans skip_collision).
5. `_deferred_sync_borders_after_load()` : un frame après, appelle `_sync_all_borders()` pour les bords entre chunks.

### 2.3 Changement de taille de grille (ex. 3×3 → 4×4)

- **Generate Grid** : dans `generate_grid()`, après `_clear_terrain_container()`, on fait `terrains_bundle_path = ""` et `_cached_bundle = null` pour invalider l’ancien bundle.
- À la fin de `generate_grid()` : `extract_all_resources()` enregistre un **nouveau** bundle avec le bon nombre de chunks.
- À l’ouverture : si le nombre de chunks ≠ nombre de terrains, le bundle est ignoré (voir 2.2).

---

## 3. Fichiers clés

| Fichier | Rôle |
|--------|------|
| `scripts/components/SB_HeightmapGrid.gd` | Manager grille, extraction, chargement bundle, PRE/POST_SAVE, invalidation bundle si taille grille change. |
| `scripts/components/SB_Heightmap.gd` | Un terrain : heightmap, mesh, collision, peinture ; `_apply_bundle_chunk`, `_clear_serialized_bundle_data`, `update_terrain_mesh`, padding height texture (voisins + repli bordure). |
| `scripts/tools/terrain_chunk_data.gd` | Ressource : heightmap_data, mesh, collision_shape, colormap_texture, splatmaps. |
| `scripts/tools/terrain_level_bundle.gd` | Ressource : `@export var chunks: Array[TerrainChunkData]`. |
| `addons/terrain_brush_plugin/terrain_brush_plugin.gd` | `_apply_changes()` → extraction forcée avant sauvegarde (`extract_all_resources(null, true, true)`). |

---

## 4. Ce qui a été corrigé (à ne pas casser)

- **Collisions dans le bundle** : sauvegarde des shapes en `.res` (duplicate), suppression des `Terrain_*_Collision.tres` après extraction ; en mode bundle, plus d’écriture `.tres` dans `_save_collision_shape_to_external()`.
- **Pas de vidage heightmap en PRE_SAVE** : on ne vide que mesh / material_override / shape pour alléger le `.tscn` ; les heightmap et textures restent en RAM pour POST_SAVE.
- **Extraction forcée avant sauvegarde** : le plugin appelle toujours `extract_all_resources(..., true, true)` pour que le bundle soit à jour avant écriture du `.tscn`.
- **Chargement seulement si même taille** : si `chunk_count != generator_count`, le bundle est ignoré et un warning est affiché (évite 3×3 appliqué sur 4×4).
- **Invalidation du bundle à la génération** : `generate_grid()` remet `terrains_bundle_path = ""` et `_cached_bundle = null`.
- **Accès safe aux voisins** : dans `_update_height_image_from_data()` (SB_Heightmap), vérification de la taille de `n_data` pour NORTH/EAST/WEST/SOUTH avant accès ; repli sur la propre bordure du chunk si le voisin est absent ou invalide.
- **Rechargement mesh/collision à l’identique** : on sauve mesh + collision_shape dans le chunk ; à l’application, si les deux sont présents, `update_terrain_mesh(skip_collision=true)` pour ne pas régénérer la collision.
- **Restauration Matériau au Démarrage** : `SB_Heightmap._apply_bundle_chunk` force désormais l'application de `texture_padding`, `paint_resolution` et `terrain_size` sur le matériau restauré. Le grid propage ses settings avant reconstruction.
- **Jupes de Terrain (Skirts)** : Implémentées à 89° vers l'intérieur. La longueur est proportionnelle au padding (`padding * (size/res)`). Normaux orientées horizontalement pour la visibilité.
- **Correction UV Padding** : Plus de "clamping" UV à [0..1] dans le fragment shader pour permettre d'échantillonner le padding sur les jupes. Clamping forcé dans le vertex shader uniquement pour la hauteur (murs verticaux).
- **Fix Sauvegarde Manuelle (Ctrl+S)** : Dans `SB_HeightmapGrid._notification`, l'appel à `extract_all_resources` est désormais forcé **avant** le nettoyage de la RAM (`_clear_serialized_bundle_data`). Cela garantit que le `.res` est à jour même si le flag 'dirty' était faux (race condition avec le plugin).

---

## 5. Ce qu’il reste à réparer / améliorer (pour une autre IA)

1. **Taille du `.res`**  
   Le bundle contient mesh + collision par chunk → fichier lourd (ex. plusieurs centaines de Mo pour une grosse grille). Si besoin de réduire :
   - Option A : ne plus sauver mesh/collision et tout reconstruire à partir de `heightmap_data` au chargement (risque de retrouver trous/coutures si la reconstruction ou le padding n’est pas parfait).
   - Option B : compression, LOD, ou sauvegarde mesh/collision dans des sous-fichiers dédiés au lieu de tout dans un seul `.res`.

2. **Taille du `.tscn`**  
   Si le `.tscn` reste lourd (> 80 Mo) malgré PRE_SAVE :
   - Vérifier qu’aucune autre ressource lourde n’est sérialisée (références, exports, sous-nœuds).
   - S’assurer que `_clear_serialized_bundle_data()` est bien appelé pour tous les générateurs (ex. `chunk_index >= 0`) et que mesh/material/shape sont bien à null au moment de l’écriture.

3. **Trous / jointures**  
   Avec mesh + collision rechargés à l’identique, en théorie plus de trous liés à la reconstruction. Si des trous ou des coutures réapparaissent :
   - Vérifier l’ordre d’application des chunks (tous les chunks appliqués avant tout `update_terrain_mesh`).
   - Vérifier que `_sync_all_borders()` est bien appelée après chargement (`_deferred_sync_borders_after_load`) et que la logique de bord (padding height texture, indices voisins) est cohérente avec la grille (ordre des gens, resolution, etc.).

4. **Logs [DIAG]**  
   Dans `SB_HeightmapGrid` il reste des `print("[Manager2] [DIAG] ...")` (build chunk, rechargement disque, ouverture, apply chunk 0). À retirer ou mettre derrière un flag `debug_verbose_logs` une fois le système stabilisé.

5. **Robustesse chargement**  
   - Gérer le cas où le fichier `.res` est absent ou corrompu (message clair, pas de crash).
   - Si un chunk est partiel (ex. mesh mais pas collision), définir un comportement cohérent (ex. régénérer seulement la collision).

6. **Tests**  
   - Scénario : 3×3 → sauvegarde → changement 4×4 → Generate Grid → Auto-Sculpt → sauvegarde → fermeture → ouverture → vérifier 4×4 correct, pas de mélange 3×3/4×4.
   - Vérifier que les anciens fichiers `Terrain_*_Collision.tres` sont bien supprimés après extraction et qu’aucun code ne les recrée en mode bundle.

---

## 6. Références rapides

- Plan / trace terrain : `ia/brain/implementation_plans/implementation_plan_20260309_002.md`
- Règles projet : `ia/rules_ia.md`, `ia/memory_ia.md`
- Index IA : `ia/ia.md`
