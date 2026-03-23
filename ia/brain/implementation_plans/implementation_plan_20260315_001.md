# Implementation Plan - Rework Grid Layers Offset (20260315_001)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2026-03-15 ~09:15
- **Statut** : 🔄 **IN PROGRESS**

## 🎯 Objectif
Refondre la génération de grille dans `SB_HeightmapGrid` pour supporter des décalages de couches (layers) flexibles (ex: décalage X/Z au lieu d'un simple empilement vertical) et restaurer la gestion de la couche active.

## 🛠️ Étapes

### 1. Modification de SB_HeightmapGrid.gd
**Timecode** : 2026-03-15 ~09:15-09:20
**Statut** : ✅ **COMPLETED**
- Ajouter `@export var grid_initial_offset: Vector3 = Vector3.ZERO` pour le premier calque.
- Ajouter `@export var layer_offsets: Array[Vector3]` pour les calques spécifiques.
- Exposer `active_grid_index: int` comme propriété `@export`.

### 2. Mise à jour de TerrainGridBuilder.gd
**Timecode** : 2026-03-15 ~09:20-09:25
**Statut** : ✅ **COMPLETED**
- Modifier la boucle de génération des couches :
  - Si `i < layer_offsets.size()` : utiliser `layer_offsets[i]`.
  - Sinon : calculer `grid_initial_offset + (grid_separation_offset * i)`.
  - Assigner `layer_index` à chaque chunk.

### 3. Intégration dans l'UI de l'Addon (Initialisation)
**Timecode** : 2026-03-15 ~09:20-09:35
**Statut** : ✅ **COMPLETED**
- Modifier `terrain_generation_view.gd` :
  - Ajouter des champs pour `grid_initial_offset` et `grid_separation_offset`.
  - Transmettre ces valeurs au manager lors du clic sur "GENERATE GRID".
- Modifier `terrain_sculpting_view.gd` :
  - Ajouter un sélecteur "Active Layer" pour filtrer l'édition par couche.

### 4. Validation UI & Génération
**Timecode** : 2026-03-15 ~09:40
**Statut** : ✅ **COMPLETED**
- Tester la génération via l'onglet d'initialisation de l'addon.
- Vérifier que les offsets sont bien pris en compte dans la scène.
- Vérifier que le changement de calque actif via l'UI de l'addon fonctionne.

## 🧪 Vérification Plan
- Vérifier la hiérarchie dans Godot : `GeneratedTerrains/Layer_1` doit être à la bonne position.
- Vérifier que les chunks de la Layer 1 sont bien alignés avec leur conteneur de couche.
- S'assurer que le bouton "Clear Grid" et "Generate Grid" fonctionnent toujours sans erreur.
