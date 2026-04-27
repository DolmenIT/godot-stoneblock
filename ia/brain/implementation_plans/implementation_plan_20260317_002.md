# Implementation Plan - Fix Splatting Shader & TextureArray (20260317_002)

## 📅 Timeline
- **Début** : 2026-03-17 ~18:45
- **Statut** : 🔄 **IN PROGRESS**

## 🎯 Problématique
Le shader de splatting ne fonctionne plus car la `Texture2DArray` globale (contenant les textures HD du terrain) n'est pas reconstruite lors de l'ouverture du projet ou du rechargement du manager `SB_HeightmapGrid`. De plus, le script `TerrainTextureManager` est trop restrictivement typé, ce qui empêche son usage avec le nouveau manager de grille.

## 📝 Étapes d'exécution

### 1. Assouplissement du TerrainTextureManager
**Fichier** : `res://scripts/tools/terrain_texture_manager.gd`
- Changer le type de `manager` de `TerrainHeightmapManager` vers `Node` (ou supprimer le type hint).
- Vérifier que les propriétés `custom_materials` et `material_textures_array` sont utilisées via `get`/`set` ou vérification de présence.

### 2. Initialisation dans le Manager de Grille
**Fichier** : `res://scripts/components/SB_HeightmapGrid.gd`
- Dans `_initialize_bundle_on_startup`, ajouter une étape pour reconstruire la `Texture2DArray` des matériaux.
- Utiliser `TerrainTextureManager.new(self).build_material_textures_array()`.

### 3. Renforcement de la propagation
**Fichier** : `res://scripts/components/SB_Heightmap.gd`
- S'assurer que `_apply_bundle_chunk` et `_update_shader_params` ré-appliquent bien la `material_textures_array` du manager si elle est disponible.

## 🧪 Vérification
- Ouvrir un niveau.
- Vérifier que le terrain n'est plus blanc/gris mais affiche les textures HD au pied de la caméra.
- Tester la peinture de textures pour vérifier que l'update de l'array fonctionne toujours.
