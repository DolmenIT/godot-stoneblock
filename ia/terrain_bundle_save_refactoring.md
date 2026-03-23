# Refactoring : Correction du Bug de Sauvegarde du Bundle Terrain

**Date de rédaction :** 2026-03-11  
**Priorité :** Haute — provoque la perte de la colormap à chaque CTRL+S  
**Statut :** Analyse complète, implémentation non appliquée

---

## Problème

Quand on ouvre la scène et qu'on fait CTRL+S **sans avoir peint ou sculpté**, le fichier `.res` du bundle terrain passe de **74 Mo à ~500 Ko** et la colormap est perdue.

Après un auto-paint ou un brush en revanche, la sauvegarde fonctionne correctement.

---

## Cause Racine Identifiée

### Le cycle de vie de `ImageTexture` dans Godot 4

Quand Godot charge un `.res` binaire contenant des `ImageTexture`, il :
1. Décode la donnée compressée depuis le fichier
2. Appelle `RenderingServer::texture_2d_create(image)` → upload GPU
3. Libère la référence CPU à l'image pour économiser la RAM

Résultat : `material_texture.get_image()` → appel `RenderingServer::texture_2d_get()` → **peut retourner null** selon l'état du driver GPU/Vulkan au moment de l'appel.

### Le flux actuel de sauvegarde

```
CTRL+S
 └─ NOTIFICATION_EDITOR_PRE_SAVE
     ├─ extract_all_resources()
     │   └─ build_chunk_from_terrain()
     │       └─ _safe_duplicate_texture(gen.material_texture)
     │           └─ tex.get_image()  ← RETOURNE NULL (GPU-only)
     │               └─ chunk.colormap_texture = null
     ├─ _clear_serialized_bundle_data()
     │   └─ material_texture = null  ← effacé sans avoir été sauvé
     └─ .tscn sauvegardé avec références nulles
```

### Pourquoi ça marche après auto-paint ?

Après auto-paint, `material_texture` vient d'être **créée en RAM** (par le pipeline de peinture), donc `get_image()` fonctionne. Ce n'est pas le cas après un simple chargement depuis le `.res`.

---

## Solution : Stocker `Image` dans `TerrainChunkData`

### Principe

Remplacer le stockage `ImageTexture` par `Image` dans `TerrainChunkData`. Un objet `Image` est **purement CPU** — toujours lisible après chargement depuis disque, exactement comme `PackedFloat32Array` pour les heightmaps. Les `ImageTexture` GPU sont recréées à la volée pour le rendu.

### Fichiers à modifier

#### 1. `terrain_chunk_data.gd`

```gdscript
# AVANT
@export var colormap_texture: ImageTexture = null
@export var blurred_texture: ImageTexture = null
@export var height_texture: Texture2D = null
@export var splatmaps: Dictionary = {}  # int -> ImageTexture

# APRÈS
@export var colormap_image: Image = null
@export var blurred_image: Image = null
@export var height_image: Image = null
@export var splatmap_images: Dictionary = {}  # int -> Image
# (mesh, material, collision_shape inchangés)
```

#### 2. `terrain_resource_exporter.gd`

Dans `build_chunk_from_terrain` :

```gdscript
# Colormap : priorité material_image (Image CPU), sinon get_image() en fallback
if gen.material_image != null and not gen.material_image.is_empty():
    chunk.colormap_image = gen.material_image
elif gen.material_texture != null:
    var img = gen.material_texture.get_image()
    if img and not img.is_empty():
        chunk.colormap_image = img
    else:
        push_warning("[Exporter] %s : colormap GPU-only, PERDUE !" % gen.name)

# Blurred, Height, Splatmaps : même pattern

# CRITIQUE : dupliquer le matériau SANS deep copy
chunk.material = gen.base_material.duplicate()  # PAS duplicate(true) !
# duplicate(true) copie récursivement la Texture2DArray → explosion de taille (74Mo → 1.6Go !)
```

Supprimer : `_safe_duplicate_texture`, le debounce de 1 seconde.

#### 3. `SB_Heightmap.gd` — `_apply_bundle_chunk`

```gdscript
# Charger les Image CPU depuis le chunk, créer les ImageTexture GPU à la volée
if chunk.colormap_image != null and not chunk.colormap_image.is_empty():
    material_image = chunk.colormap_image          # Conservé en RAM
    material_texture = ImageTexture.create_from_image(material_image)  # GPU

if chunk.blurred_image != null:
    blurred_image = chunk.blurred_image
    blurred_texture = ImageTexture.create_from_image(blurred_image)

if chunk.height_image != null:
    height_texture = ImageTexture.create_from_image(chunk.height_image)

for k in chunk.splatmap_images.keys():
    local_splatmaps[k] = ImageTexture.create_from_image(chunk.splatmap_images[k])
```

#### 4. `SB_Heightmap.gd` — `_clear_serialized_bundle_data`

```gdscript
# NE PAS vider material_image ni blurred_image :
# ces Images CPU sont la source pour le prochain export (Save).
heightmap_resource = null
material_texture = null   # OK : recréé depuis material_image au POST_SAVE
blurred_texture = null
local_splatmaps.clear()
base_material = null
# material_image → GARDER
# blurred_image  → GARDER
```

---

## Todolist d'Implémentation

```
[ ] 1. terrain_chunk_data.gd
    [ ] Remplacer ImageTexture → Image pour colormap, blurred, height, splatmaps
    [ ] Vérifier resource_name présent (debug)

[ ] 2. terrain_resource_exporter.gd
    [ ] Réécrire build_chunk_from_terrain (stocker Image depuis material_image)
    [ ] Supprimer _safe_duplicate_texture
    [ ] Supprimer le debounce 1s
    [ ] Correction CRITIQUE : utiliser duplicate() sans (true) pour le matériau
    [ ] Mettre à jour les logs de validation

[ ] 3. SB_Heightmap.gd — _apply_bundle_chunk
    [ ] Charger colormap_image → material_image + créer material_texture
    [ ] Blurred, Height, Splatmaps : même pattern

[ ] 4. SB_Heightmap.gd — _clear_serialized_bundle_data
    [ ] Préserver material_image et blurred_image

[ ] 5. SB_HeightmapGrid.gd — _notification
    [ ] Nettoyer commentaires obsolètes (debounce, _force_extract)

[ ] 6. Tests
    [ ] Regenerer le bundle (bouton "Extract All Resources" dans l'inspecteur)
    [ ] Test : Ouvrir + CTRL+S → taille .res identique (~74Mo), colormap OK
    [ ] Test : Brush + CTRL+S → .res mis à jour, modifications persistées
    [ ] Test : auto-paint + CTRL+S → OK
    [ ] Test : Fermer/Rouvrir → colormap intacte
```

---

## Points d'Attention

> [!WARNING]
> Le bundle existant sera dans l'ancien format après cette migration. Il faut le **régénérer une fois** en cliquant sur "Extract All Resources" dans l'inspecteur après avoir appliqué tous les changements.

> [!CAUTION]
> Ne **JAMAIS** utiliser `gen.base_material.duplicate(true)` pour le matériau dans le bundle. Cela deep-copy récursivement la `Texture2DArray` de tous les matériaux terrain → explosion de taille (74Mo → 1.6Go constaté lors du test du 11/03/2026).

> [!NOTE]
> La taille du `.res` après migration devrait rester similaire (~74Mo). `Image` et `ImageTexture` stockent les mêmes données pixel en binaire. La différence de taille n'était pas due au changement de type mais au `duplicate(true)` bugué.
