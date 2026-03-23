# [IP-022] Simplification Configuration SB_Core

Refactorisation des propriétés d'exportation de `SB_Core.gd` pour une interface plus intuitive.

## Proposed Changes

### [Core]
#### [MODIFY] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
- **Nettoyage des Exports** :
    - Suppression de `auto_setup_world`.
    - Remplacement de `@export var min_splash_time: float` par `@export var use_sb_splash: bool = true`.
- **Logique Interne** :
    - Le temps minimal de splash sera désormais de **1.0s** si `use_sb_splash` est vrai, et **0.0s** sinon.
- **Suppression du Placeholder** :
    - Suppression de la fonction `_setup_world_environment()` et de son appel dans `_ready()`.

## Verification Plan

### Automated Tests
_Aucun test disponible._

### Manual Verification
1. Vérifier dans l'inspecteur Godot que `SB_Core` ne propose plus `auto_setup_world` ni `min_splash_time`.
2. Vérifier que la case `Use Sb Splash` est présente.
3. Tester le boot (`res://demo/demo1/00_boot.tscn`) avec `Use Sb Splash` activé : le splash doit durer 1s.
4. Tester avec `Use Sb Splash` désactivé : la transition doit être immédiate (ou selon le chargement réel).

**🟥🟨 VALIDATION REQUISE :** _Souhaitez-vous que je conserve la variable interne `min_splash_time` pour permettre un override technique éventuel via script, ou je la supprime totalement de la logique ?_
