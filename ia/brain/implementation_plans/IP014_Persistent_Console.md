# [IP-014] Console de Debug Persistante (Singleton)

L'objectif est de transformer `SB_DebugConsole` en un service global (Autoload) pour qu'il ne soit pas détruit lors des changements de scènes et qu'il reste visible partout.

## Architecture
- **Type** : Singleton (Autoload).
- **Nom Global** : `SBDebug`.
- **Héritage** : `CanvasLayer` (persistance visuelle au-dessus du `SceneTree`).

## Changements Proposés

### [Configuration] Projet
#### [MODIFY] [project.godot](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/project.godot)
- Ajouter `SBDebug="*res://stoneblock/ui/SB_DebugConsole.gd"` dans la section `[autoload]`.

### [Integration] Scènes
#### [DELETE] [SB_DebugConsole](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- Supprimer le nœud local `SB_DebugConsole` de toutes les scènes (il est maintenant géré globalement).

### [Component] UI
#### [MODIFY] [SB_DebugConsole.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_DebugConsole.gd)
- Ajouter une option pour masquer/afficher la console via une touche (ex: `F12`).

## Plan de Vérification

### Tests Automatisés
- Lancer `demo1`.
- Attendre la transition vers `scene1`.
- Vérifier que la console est TOUJOURS visible après le chargement.
