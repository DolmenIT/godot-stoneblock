# [2026-03-12 ~09:45] Walkthrough - Résolution Définitive Bug Sauvegarde Terrain

## Objectifs atteints
- [x] **Fix Perte Texture (Colormap/Splatmaps)** : Les textures ne sont plus perdues lors d'un `Ctrl+S` sans modification.
- [x] **Protection du Bundle (.res)** : Utilisation de la technique "Detached Resource Path" pendant le cycle `PRE_SAVE` pour empêcher Godot de vider le fichier binaire.
- [x] **Isolation des Données** : Implémentation de `_safe_duplicate_texture` dans `TerrainResourceExporter` pour garantir que le bundle possède ses propres instances d'images.
- [x] **Allégement .tscn** : Le fichier de scène reste sous les 5 Ko tout en préservant un bundle de ~74 Mo (pour un niveau standard).

## Détails de la Solution (Claude-method)
Au lieu du refactoring complet vers le type `Image` (CPU), la solution actuelle utilise les signaux de l'éditeur :
1. **PRE_SAVE** : `manager._cached_bundle.resource_path = ""` -> Godot "oublie" le lien avec le fichier disque.
2. **NETTOYAGE** : Les générateurs vident leurs textures `ImageTexture` (GPU) pour ne pas polluer le `.tscn`.
3. **SAUVEGARDE** : Godot sauve le `.tscn` léger et **ne touche pas** au `.res` (car son chemin est vide).
4. **POST_SAVE** : `manager._cached_bundle.resource_path = terrains_bundle_path` -> Le lien est rétabli et les données sont ré-appliquées.

## Tests Effectués
- **Ouverture -> Ctrl+S immédiat** : Taille du `.res` inchangée, textures préservées au rechargement. ✅
- **Modification -> Ctrl+S** : Le bundle est correctement mis à jour avec les nouvelles données. ✅
- **Fermeture -> Réouverture** : Le terrain se reconstruit parfaitement à partir du bundle. ✅

## Documentation technique
Les modifications principales se trouvent dans :
- `SB_HeightmapGrid.gd` (`_notification`)
- `SB_Heightmap.gd` (`_clear_serialized_bundle_data_safe`)
- `TerrainResourceExporter.gd` (`_safe_duplicate_texture`)
