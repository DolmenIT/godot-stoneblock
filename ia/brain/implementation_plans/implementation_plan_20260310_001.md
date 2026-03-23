# Implementation Plan - Refactorisation Terrain (20260310_001)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2026-03-10 ~11:47
- **Statut** : 🔄 **IN PROGRESS**

## 📋 Contexte & Objectifs
Les scripts `SB_Heightmap.gd` (1365 lignes) et `SB_HeightmapGrid.gd` (995 lignes) sont trop volumineux et contreviennent à la règle des 1000 lignes (cible < 750 lignes).
L'objectif est d'extraire la logique métier dans des classes d'assistance (`RefCounted`) pour rendre le code plus lisible, maintenable et modulaire.

## 🏗️ Architecture Cible

### 1. Gestion des Bords (Manager)
**Nouvel outil** : `res://scripts/tools/terrain_grid_synchronizer.gd`
- Extrait : `_sync_all_borders`, `_sync_border_pair`, `_sync_corners`, `_assign_neighbors`.
- Gain estimé : ~200 lignes dans `SB_HeightmapGrid.gd`.

### 2. Gestion des Ressources & Bundles
**Nouvel outil** : `res://scripts/tools/terrain_resource_exporter.gd`
- Extrait : `extract_all_resources`, `_build_chunk_from_terrain`, `_extract_resources_to_disk`.
- Gain estimé : ~150 lignes combinées.

### 3. Gestion des Matériaux & Textures (Chunk)
**Nouvel outil** : `res://scripts/tools/terrain_material_helper.gd`
- Extrait : `apply_blur_to_material_texture`, `_update_height_texture`, `_create_base_material`.
- Gain estimé : ~250 lignes dans `SB_Heightmap.gd`.

### 4. Accesseurs de Bords & Géométrie
**Nouvel outil** : `res://scripts/tools/terrain_geometry_helper.gd`
- Extrait : `get_border_x/z`, `set_border_x/z`, `get_height_at_local_position`.
- Gain estimé : ~150 lignes dans `SB_Heightmap.gd`.

## 🚀 Étapes d'exécution

### 1. Préparation & Documentation
**Timecode** : 2026-03-10 ~11:47  
**Statut** : 🔄 **IN PROGRESS**
- [ ] Créer les fichiers `.md` de documentation pour chaque futur script `.gd` selon les règles.
- [ ] Mettre à jour `ia/memory_ia.md` si nécessaire.

### 2. Extraction du Synchroniseur (Grid)
**Timecode** : TBD  
**Statut** : 📋 **TODO**
- [ ] Créer `terrain_grid_synchronizer.gd`.
- [ ] Migrer la logique de `SB_HeightmapGrid.gd`.
- [ ] Vérifier la continuité des coutures.

### 3. Extraction du MaterialHelper (Chunk)
**Timecode** : TBD  
**Statut** : 📋 **TODO**
- [ ] Créer `terrain_material_helper.gd`.
- [ ] Alléger `SB_Heightmap.gd`.

### 4. Finalisation & Nettoyage
**Timecode** : TBD  
**Statut** : 📋 **TODO**
- [ ] Vérifier que `SB_Heightmap.gd` est bien passé sous la barre des 750 lignes.
- [ ] Effectuer un Walkthrough complet.

## 🧪 Plan de Vérification
- [ ] Bouton "Reconstruct All" : toujours fonctionnel.
- [ ] Pinceau Sculpt : la synchronisation des bords doit rester fluide.
- [ ] Sauvegarde Bundle : l'extraction des ressources doit fonctionner à l'identique.
