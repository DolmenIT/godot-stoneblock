# [IP-063] Refactorisation du Système de Loot (Ennemis)

Ce plan vise à rendre le système de drops des ennemis plus flexible en remplaçant les références fixes à l'énergie, au bouclier et aux pièces par des slots de loot génériques.

## User Review Required

> [!IMPORTANT]
> **REFACTORING DES VARIABLES** : Les variables `energy_fragment_scene`, `drop_energy_count`, etc., seront supprimées et remplacées par `loot_1_scene`, `loot_1_count`, etc. 
> Cela signifie que si vous aviez déjà configuré des ennemis dans l'éditeur, il faudra potentiellement ré-assigner les scènes de loot dans ces nouveaux slots.

## Proposed Changes

### Enemy Logic

#### [MODIFY] [SB_Enemy_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_Enemy_VShmup.gd)
-   Supprimer les exports spécifiques : `energy_fragment_scene`, `shield_fragment_scene`, `coin_fragment_scene`, `drop_energy_count`, `drop_shield_count`, `drop_coin_count`.
-   Ajouter les nouveaux exports dans un groupe `@export_group("Loot (Drops)")` :
    -   `loot_1_scene`, `loot_1_count`
    -   `loot_2_scene`, `loot_2_count`
    -   `loot_3_scene`, `loot_3_count`
-   Conserver `triple_shot_scene` et `triple_shot_chance` à part comme demandé.
-   Mettre à jour la méthode `_explode()` pour appeler `_spawn_loot_group()` pour les 3 nouveaux slots de loot.
-   Mettre à jour les `preload` par défaut pour conserver le comportement actuel par défaut (Loot 1 = Energy, Loot 2 = Shield, Loot 3 = Coin).

## Open Questions

- Souhaitez-vous plus de 3 slots de loot par défaut ? (Pour l'instant je m'en tiens aux 3 demandés).

## Verification Plan

### Automated Tests
-   Aucun test automatisé disponible pour les scènes 3D pour le moment.

### Manual Verification
- [ ] Ouvrir l'inspecteur d'un ennemi `SB_Enemy_VShmup`.
- [ ] Vérifier que le groupe "Loot (Drops)" affiche bien les 3 slots avec leurs compteurs.
- [ ] Lancer une démo, détruire un ennemi et vérifier que les loots (Energy, Shield, Coin) tombent toujours correctement selon les configurations par défaut.
- [ ] Tester de changer le `loot_1_scene` par une autre scène et vérifier le drop.
