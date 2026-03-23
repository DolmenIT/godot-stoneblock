# Implementation Plan - Collisions dans le bundle terrain unique (20260309_002)

> [!IMPORTANT]
> **PROTOCOL** : Trace de l’inclusion des collisions dans le fichier bundle unique `*_Terrains.res`.

## 📅 Timeline
- **Début** : 2026-03-09
- **Statut** : ✅ **COMPLETED**

## 🎯 Objectif
Les données des grids sont extraites dans un seul fichier externe `Level_1_Background_Terrains.res`, mais les collisions restaient dans des fichiers `Terrain_X_Y_Collision.tres` séparés. Il fallait inclure les collisions dans le bundle et supprimer les .tres devenus inutiles.

## Modifications effectuées

### 1. `scripts/components/SB_HeightmapGrid.gd`

- **`_build_chunk_from_terrain()`** : lors de l’extraction, la forme de collision est **dupliquée** (`c.shape.duplicate(true)`) avant d’être assignée au chunk. Ainsi le bundle embarque une copie des données de collision au lieu d’une référence vers les fichiers `.tres` externes.

- **`extract_all_resources()`** :
  - Après `ResourceSaver.save(bundle, bundle_path)`, le bundle est **rechargé depuis le disque** pour que les shapes aient des sub-resource paths vers le `.res`. À la sauvegarde de la scène, Godot référence alors le bundle au lieu d’embarquer les collisions dans le `.tscn`.
  - Suppression des anciens `Terrain_*_Collision.tres` dans `terrains/` après une extraction réussie (les collisions sont désormais dans le bundle).

- **`_clean_terrain_resources()`** : le nettoyage supprime aussi les fichiers `Terrain_*_Collision.tres` (en plus des `Terrain_*.res`) dans `terrains/` lors du clear de la grille.

### 2. Ressources concernées

- **`TerrainChunkData`** : déjà doté de `collision_shape: ConcavePolygonShape3D` — aucune modification.
- **`SB_Heightmap._apply_bundle_chunk()`** : appliquait déjà `chunk.collision_shape` au `CollisionShape3D` — aucune modification.

## Résultat

- Un seul fichier `*_Terrains.res` par niveau contient mesh, heightmap, textures **et** formes de collision.
- Les 25 fichiers `Terrain_X_Y_Collision.tres` sont supprimés après extraction (ou lors du clear de la grille).
- La scène `.tscn` référence les shapes via le bundle (sub-ressources), elle reste légère.

## 📝 Notes

- Pour un niveau déjà extrait avec l’ancien comportement : relancer **Extract All Resources** (ou le bouton d’extraction) pour régénérer le bundle avec les collisions et supprimer les `.tres`.
