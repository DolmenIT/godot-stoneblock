# IP-105 : Adaptation de la Carte d'Amélioration 3D (Square Edition)

Ce plan vise à transformer le clone de la `SB_ShipCard_3d` en une véritable `SB_UpgradeCard_3d` dédiée aux améliorations d'armes et de projectiles, avec un format carré et un champ de description.

## État de la demande
- 📅 **Demandé** : 2026-04-17
- 🚀 **Lancé** : 2026-04-17
- ✅ **Terminé** : -

## User Review Required

> [!IMPORTANT]
> - La carte passera d'un format vertical (0.65x0.95) à un format **carré (0.8x0.8)**.
> - Les sections "Armes" et "Ultime" seront retirées.
> - Un nouveau champ **Description** sera ajouté pour expliquer l'effet de l'upgrade.

## Proposed Changes

### [Component] UI - 3D Cards

#### [MODIFY] [SB_UpgradeCard_3d.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/ui/SB_UpgradeCard_3d.tscn)
- Renommer le nœud `Layer1_Ship` en `Layer1_Item`.
- Ajuster la taille des `QuadMesh` (Layer 0, 1, 2) pour un format carré (ex: `0.8x0.8`).
- Ajouter un nœud `Label_Description` (Label3D) sous `Labels`.

#### [MODIFY] [SB_UpgradeCard_3d.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/ui/SB_UpgradeCard_3d.gd)
- **Structure Multi-couches** : Logique de rendu premium (Socle, Item, Deco) avec shaders.
- **Paramètres Upgrade** :
    - `@export var item_description: String` : Texte descriptif.
    - `@export var upgrade_type: UpgradeType` : Weapon vs Projectile.
- **Gestion des Stats** :
    - Mapper les stats selon le type (Cadence/Dégâts/Énergie vs Vitesse/Portée/Taille).
- **Mise à jour Visuelle** :
    - `_update_card()` : Inclut la mise à jour de la **description**.

---

## Open Questions

- Souhaitez-vous que je place la description au-dessus ou en-dessous des statistiques ?
- Avez-vous terminé le nettoyage manuel des nœuds dans la scène ?
