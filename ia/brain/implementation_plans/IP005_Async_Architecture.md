# [IP-005] Architecture Asynchrone : Bootstrapper et Niveau

L'objectif est d'utiliser le `SB_Core` pour charger le contenu du jeu de manière asynchrone, conformément au pilier central du GDK.

## Architecture "Bootstrapper"
- **demo1.tscn** : Scène de démarrage légère contenant uniquement le `SB_Core`.
- **scene1.tscn** : Scène de contenu (le Cube RGB) chargée en arrière-plan.

## Changements Proposés

### [Component] Core
#### [MODIFY] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
- Ajouter une propriété `@export_file` pour la "Scène à charger au démarrage".
- Implémenter l'instanciation automatique de la scène chargée.

### [Integration] Scènes
#### [NEW] [scene1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/scene1.tscn)
- Contiendra le `RGBCube`, la caméra et la lumière.
#### [MODIFY] [demo1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- Nettoyer le contenu (supprimer le cube/caméra).
- Configurer `SB_Core` pour pointer vers `scene1.tscn`.

## Plan de Vérification

### Tests Automatisés
- Lancer `demo1.tscn` et vérifier que `scene1.tscn` s'affiche après un court instant.

### Vérification Manuelle
- Observer les logs console pour confirmer le passage par l'état `LOADING`.

---
**🟥🟨 VALIDATION REQUISE :** _Confirmez-vous ce passage à une architecture Bootstrapper / Scène ?_
