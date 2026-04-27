# [IP-012] Console de Debug avec Overlay Intégré

L'objectif est de supprimer le besoin d'un nœud `CanvasLayer` parent dans la scène. Le composant `SB_DebugConsole` devient lui-même sa propre couche d'overlay.

## Architecture du Composant
- **Héritage** : `CanvasLayer` (pour garantir l'affichage "on top" indépendamment de la position dans l'arbre).
- **Structure Interne (Auto-générée)** :
    - `CanvasLayer` (Self)
        - `PanelContainer` (Le fond noir arrondi, ancré en bas à gauche)
            - `RichTextLabel` (Le texte des logs)

## Changements Proposés

### [Component] UI
#### [MODIFY] [SB_DebugConsole.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_DebugConsole.gd)
- Changer `extends PanelContainer` en `extends CanvasLayer`.
- Créer dynamiquement le `PanelContainer` et le `RichTextLabel`.
- Gérer les ancres du `PanelContainer` via le code.
- Exposer la propriété `layer` (profondeur de l'overlay).

### [Integration] Scènes
#### [MODIFY] [demo1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- Supprimer `UI_Overlay`.
- Placer `SB_DebugConsole` à la racine ou n'importe où (il s'affichera par-dessus grâce au `CanvasLayer`).

## Plan de Vérification

### Tests Automatisés
- Lancer le projet et vérifier que la console s'affiche toujours en bas à gauche malgré la suppression de `UI_Overlay`.

---
**🟥🟨 VALIDATION REQUISE :** _Confirmez-vous ce passage au mode CanvasLayer (Overlay intégré) ?_
