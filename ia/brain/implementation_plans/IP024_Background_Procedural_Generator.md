# [IP-024] Générateur de Décor Procédural (Background Shmup)

Ajout d'un système de génération aléatoire de décors (prismes, cubes, etc.) pour enrichir le fond de la Démo 1.

## Proposed Changes

### [StoneBlock Visual]

#### [NEW] [SB_BackgroundGenerator.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/visual/SB_BackgroundGenerator.gd)
- **Logic** : Script `@tool` qui génère des `MeshInstance3D` à la volée. Les nœuds ne sont **pas enregistrés** dans le fichier `.tscn` (non-persistants), ce qui garde la scène légère et propre.
- **Paramètres `@export`** :
    - `mesh_template`: Ressource `Mesh` à utiliser.
    - `target_node`: Nœud (ex: un plan) servant de zone de référence pour le spawn.
    - `base_color`: Couleur appliquée au matériau.
    - `count`: Nombre d'éléments.
    - `area_size`: Zone de spawn.
    - `min_scale` / `max_scale`: Plage de taille aléatoire (Vector3 pour contrôle par axe).
    - `min_rotation` / `max_rotation`: Plage de rotation aléatoire.
    - `generate_now`: Bouton pour déclencher la génération.

### [Demo 1 - Level 1]

#### [MODIFY] [background.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/levels/level1/stage1/background.tscn)
- Ajout d'un nœud `DecorGenerator` utilisant `SB_BackgroundGenerator.gd`.

## Verification Plan

### Manual Verification
1. Ouvrir `res://demo/demo1/levels/level1/stage1/background.tscn`.
2. Sélectionner `DecorGenerator`.
3. Cliquer sur `Generate Now`.
4. Vérifier la variété des formes et couleurs.
