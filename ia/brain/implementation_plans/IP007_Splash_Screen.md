# [IP-007] Écran de Splash Dynamique et Transition de Scène

L'objectif est d'offrir un feedback visuel immédiat au démarrage (Logo StoneBlock tournant) et de gérer proprement la transition vers la scène de jeu chargée asynchronement.

## Cycle de Vie du Bootstrapper
1. **Démarrage** : `SBCore` (Singleton) se lance et démarre le chargement de `scene1.tscn`.
2. **Affichage** : `demo1.tscn` affiche le logo 3D animé.
3. **Transition** : Une fois `scene1.tscn` chargée, `SBCore` instancie le niveau, supprime `demo1.tscn` (le splash) et définit le nouveau niveau comme scène courante.

## Changements Proposés

### [Component] Core
#### [MODIFY] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
- Automatiser la suppression de la scène de boot après instanciation du niveau.
- S'assurer que le niveau devient la `current_scene` pour le SceneTree de Godot.

### [Integration] Scènes
#### [MODIFY] [demo1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- Importer `res://assets/logo_stoneblock.glb`.
- Ajouter une `Camera3D` et une `DirectionalLight3D`.
- Attacher `SB_Rotate3D` au logo.

## Plan de Vérification

### Tests Automatisés
- Lancement du projet et observation de la transition visuelle.

### Vérification Manuelle
- Vérifier que `demo1.tscn` a bien disparu de l'arbre des scènes (Remote Debug) après le chargement.

---
**🟥🟨 VALIDATION REQUISE :** _Confirmez-vous cette logique de nettoyage automatique de l'écran de splash ?_
