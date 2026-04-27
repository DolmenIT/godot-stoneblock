# [IP-021] Consolidation Demo 1 : Menus & Platformer Basic

Le focus est mis sur la Demo 1 pour en faire un "petit platformer basique" fonctionnel de bout en bout, tout en nettoyant les menus et le core.

## Proposed Changes

### [Menus]
#### [MODIFY] [10_menu_principal.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/10_menu_principal.tscn)
- **Bug Fix** : Supprimer le nœud `SB_Log` du bouton "Jouer" (il affichait par erreur "Options non disponibles").
- **Bug Fix** : Mettre à jour le message `SB_Log` du bouton "Quitter" pour être plus clair ("Fermeture de l'application..." par exemple).
- **Cleanup** : Le bouton "Options" lancera toujours le `SB_Log` mais ne redirigera pas (ou redirigera vers un popup vide).

#### [MODIFY] [11_menu_levels.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/11_menu_levels.tscn)
- **Redirection** : Changer la cible du premier bouton (L1S1) vers `res://demo/demo1/40_game_scene.tscn` pour rester dans le périmètre de la Demo 1.

### [Gameplay (Platformer)]
#### [MODIFY] [40_game_scene.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/40_game_scene.tscn)
- **Structure** : Renommer le nœud racine en `Demo1_Platformer`.
- **Level Design** : Ajouter 2-3 plateformes supplémentaires pour créer un parcours "basique" mais complet vers le Menhir (Goal).
- **Ajout** : Intégrer un ou deux `SB_Pickable` (Galettes) pour tester le système de stats du Core.

### [Core]
#### [MODIFY] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
- **Refactor Exports** : Retrait de l'exportation pour `core_template_path`, `use_threaded_loading` et `tick_rate`. Ces valeurs sont désormais internes et fixes.
- **Valeurs Fixes** :
    - `core_template_path = "res://stoneblock/core/SB_Core.tscn"`
    - `use_threaded_loading = true`
    - `tick_rate = 0.016`
- **Nettoyage** : Vérification de la cohérence des logs de transition.

## Verification Plan

### Automated Tests
_Aucun test disponible._

### Manual Verification
1. Lancer le Boot (`res://demo/demo1/00_boot.tscn`).
2. Dans le menu principal :
    - Cliquer sur "Jouer" -> Doit ouvrir le sélecteur de niveaux sans message d'erreur.
    - Cliquer sur "Quitter" -> Doit fermer l'app (ou loguer si en éditeur).
3. Dans le sélecteur de niveaux :
    - Cliquer sur le premier bouton -> Doit charger `40_game_scene.tscn`.
4. Dans le niveau :
    - Parcourir les plateformes.
    - Ramasser les Galettes -> Vérifier les stats via `stats_updated`.
    - Atteindre le Menhir -> Doit rediriger vers le menu principal.

**🟥🟨 VALIDATION REQUISE :** _Est-ce que l'ajout de quelques "Galettes" dans la scène de base (40_game_scene) vous semble pertinent pour la démo du Core ?_
