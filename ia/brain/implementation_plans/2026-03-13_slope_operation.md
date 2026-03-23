# Plan d'implémentation : Opération Slope (Pente)
Date : 13 Mars 2026

## Objectif
Ajouter une opération de sculpture automatique "Slope" permettant de créer des pentes linéaires avec orientation et seuil de hauteur.

## Changements
### 1. Resource `TerrainSculptingOperation`
- Ajout de `SLOPE` à l'énumération `OperationType`.
- Nouvelles propriétés : `slope_height_near`, `slope_height_far`, `slope_angle_degrees`, `slope_add_mode`, `slope_height_threshold`, `slope_use_global_bounds`, `slope_apply_grid_mask`.

### 2. Pipeline `TerrainAutoSculptPipeline`
- Dispatch de l'opération vers `_standard_helper.apply_slope`.

### 3. Logique `TerrainSculptOpsStandard`
- Implémentation de `apply_slope`.
- Utilisation de la projection vectorielle pour la linéarité.
- Support du mode additif (`y += value`) et du mode remplacement (`y = value`).
- Condition de seuil (`current_y < threshold`).

### 4. Interface `TerrainAutoSculptItem` & `TerrainAutoSculptView`
- Mise à jour de la liste des opérations (📐 Slope).
- Implémentation des contrôles UI pour les nouveaux paramètres.
- Mise à jour de la sauvegarde/chargement des présets JSON.

## Validation
- [x] Calcul de pente linéaire raccord sur multi-grilles.
- [x] Mode additif fonctionnel pour creuser les fonds marins.
- [x] Persistance dans les présets JSON.
- [x] Fix de l'erreur `get_vertex_positions` (calcul manuel des positions globales).
