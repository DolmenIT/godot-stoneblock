# 🛠️ Analyse Technologique : Édition des Heightmaps (Addon + StoneBlock)

Ce document détaille le fonctionnement technique de la remise en service de l'édition des terrains dans Godot 4 via le système **StoneBlock (SB)** et l'addon **Terrain Brush**.

## 🏗️ Architecture Globale

Le système repose sur un découpage modulaire en trois couches :

1.  **L'Addon (Interface Éditeur)** : Capture les entrées souris en 3D (`terrain_brush_plugin.gd`) et les transfère à un helper d'input.
2.  **Wrappers StoneBlock (Gestionnaire)** :
    *   `SB_HeightmapGrid` : Gère la grille de terrains, la propagation des paramètres et la synchronisation des bords.
    *   `SB_Heightmap` : Le composant "Unité de terrain" qui détient les données et le maillage.
3.  **Core Logic (Moteur de calcul)** :
    *   `TerrainSculptTool` : Calculs CPU pour modifier les hauteurs (Raise, Lower, etc.).
    *   `TerrainPaintTool` : Calculs CPU pour la peinture de matériaux (Splatmaps).
    *   `terrain.gdshader` : Rendu GPU avec déplacement de vertex en temps réel.

---

## 🏔️ Le Fonctionnement du "Raise" (Sculpture)

L'outil **Raise** (Élévation) suit ce flux de données :

### 1. Capture & Raycasting
L'addon détecte le mouvement de la souris dans le viewport 3D. Le script `terrain_heightmap_input_helper.gd` effectue un **Raycast** (soit via la physique si active, soit via une intersection de plan mathématique) pour trouver la position précise sur le terrain.

### 2. Modification CPU (`TerrainSculptTool`)
La position est transmise à `SB_Heightmap.apply_stamp()`. 
*   Les données de hauteur sont stockées dans une `Array[float]` (`heightmap_data`).
*   Le script calcule l'influence de la brosse (Radius + Strength) sur chaque vertex environnant.
*   **Calcul** : `new_height = current_height + (strength * influence)`.

### 3. Injection Texture GPU
Pour éviter de reconstruire un `ArrayMesh` lourd à chaque frame (ce qui tuerait les performances), le système utilise le **GPU Displacement** :
*   L'Array est converti en une `Image` de format `FORMAT_RF` (32-bit float).
*   Cette image est mise à jour dans une `ImageTexture` (`height_texture`).
*   Le shader reçoit cette texture et déplace les vertex : `VERTEX.y = texture(height_texture, UV).r;`.

> [!TIP]
> **Normales Dynamiques** : Comme le maillage est plat aux yeux du CPU, le shader calcule les normales à la volée via une technique de *Finite Difference* (différence entre les pixels voisins de la texture de hauteur).

---

## 🎨 Système de Shaders et Peinture

La "remise en fonctionnement" a permis d'optimiser le texturing via un shader de **Splatting Dynamique**.

### Dual-Map System
Le shader mélange deux types de données :
*   **Colormap** : Une texture basse résolution représentant la couleur globale du terrain (utilisée pour la vue lointaine).
*   **Splatmap Array** : Une `Texture2DArray` contenant les poids des matériaux (Herbe, Roche, Terre, etc.).

### Édition des Shaders
L'édition des shaders mentionnée concerne la synchronisation temps réel entre les composants SB et le `ShaderMaterial` :
1.  **Textures Externes** : Pour éviter de gonfler les fichiers `.tscn`, toutes les textures (heightmap, splatmaps) sont maintenant extraites dans des fichiers `.res` externes.
2.  **Splatmap Blending** : Le shader itère dynamiquement sur les couches du Splatmap pour mélanger les textures du `material_textures_array`.
3.  **Grid Visualization** : Un système de grille visuelle est injecté directement dans le shader (`show_grid`) pour faciliter le sculpting sans polluer la scène avec des objets gizmos.

---

## 💾 Stockage et Performance (L'allégement .tscn)

L'un des points majeurs de cette remise en service est la **gestion des ressources** :
*   **Avant** : Les données de terrain étaient sérialisées en texte dans le `.tscn` (fichiers de plusieurs Mo).
*   **Après** : 
    *   Le bouton **Extract Resources** déporte les données vers `res://level_path/terrains/`.
    *   Les métadonnées binaires sont activement nettoyées.
    *   Le `.tscn` final ne pèse plus que quelques Ko, ne contenant que des références aux ressources externes.

---

## 🔄 État d'Avancement Actuel

*   ✅ **Sculpting (Raise/Lower)** : Entièrement opérationnel avec mise à jour collision et synchronisation des bords inter-chunks.
*   ✅ **Painting (Splatmaps)** : Supporte jusqu'à 20+ types de matériaux via le `Texture2DArray`.
*   ✅ **Shaders** : Système de displacement stable et mode grille activable.
*   🔄 **Optimisations futures** : Passage de certains calculs de peinture sur GPU via Compute Shaders pour les très grandes brosses.
