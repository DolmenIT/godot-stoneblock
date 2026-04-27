# [IP-075] Système de Loot Aléatoire (Min/Max)

L'objectif est de permettre aux concepteurs de niveaux de définir une plage de quantité pour les récompenses (loots) lâches par les ennemis à leur mort, au lieu d'un nombre fixe.

## User Review Required

> [!IMPORTANT]
> Cette modification remplace les variables existantes `loot_X_count`. Si vous aviez réglé ces valeurs dans vos scènes d'ennemis, elles devront être ajustées (mais je vais mettre des valeurs par défaut cohérentes).

## Proposed Changes

### [Component] Scripts Ennemis

#### [MODIFY] [SB_Enemy_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_Enemy_VShmup.gd)

- **Suppression** des exports :
    - `loot_1_count`
    - `loot_2_count`
    - `loot_3_count`
- **Ajout** des exports (Min/Max) pour chaque slot :
    - `loot_X_min: int`
    - `loot_X_max: int`
- **Mise à jour** de la fonction `_explode()` pour calculer une valeur aléatoire entre le minimum et le maximum avant de générer le groupe de loot.

```gdscript
# Exemple de logique cible dans _explode :
var count_1 = randi_range(loot_1_min, loot_1_max)
_spawn_loot_group(loot_1_scene, count_1)
```

## Étapes de travail

1. [ ] Remplacer les variables de loot dans `SB_Enemy_VShmup.gd`.
2. [ ] Adapter la logique de spawn dans `_explode`.
3. [ ] Vérifier que les défauts sont raisonnables pour ne pas "vider" le jeu au redémarrage.

## Verification Plan

### Manual Verification
1. Ouvrir une scène d'ennemi (ex: `SB_Enemy_1.tscn`).
2. Régler un slot de loot avec `Min: 1` et `Max: 5`.
3. Lancer la scène de jeu et détruire l'ennemi plusieurs fois pour vérifier que la quantité de loot varie.
