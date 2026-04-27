# IP-117 : Registre Global de Matériaux

## Description
Centralisation des matériaux générés pour éviter toute redondance entre les scènes (Boot, Menu, Game).

## Proposed Changes

### [StoneBlock Core]

#### [NEW] [SB_MaterialRegistry.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_MaterialRegistry.gd)
- Singleton (Autoload) ou service rattaché au `SB_ThemeManager`.
- Dictionnaire de cache : `key = hash(base_material_id + params)`.
- Méthode `get_material(base_mat, params) -> Material`.

### [StoneBlock Visual]

#### [MODIFY] [SB_StandardModel.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/visual/SB_StandardModel.gd)
- Intégration du `SB_MaterialRegistry` pour demander un matériau au lieu de le créer localement.

---

## Verification Plan
### Automated Tests
- Vérification que changer une couleur sur un type de vaisseau dans l'éditeur met à jour tous les vaisseaux du même type s'ils utilisent le registre.
