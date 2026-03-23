# [IP-011] Console de Debug Autonome (All-in-One)

L'objectif est de simplifier l'intégration en fusionnant le script, le style (fond noir arrondi) et l'affichage (RichTextLabel) dans un seul et même composant autonome.

## Architecture du Composant
- **Héritage** : `PanelContainer` (pour bénéficier nativement du background et des marges).
- **Auto-instanciation** : Le script crée lui-même son `RichTextLabel` enfant au démarrage.
- **Auto-Style** : Le script génère et applique un `StyleBoxFlat` (Noir transparent, coins arrondis) dynamiquement.

## Changements Proposés

### [Component] UI
#### [MODIFY] [SB_DebugConsole.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_DebugConsole.gd)
- Changer `extends RichTextLabel` en `extends PanelContainer`.
- Ajouter la création dynamique du `RichTextLabel`.
- Ajouter la gestion du `StyleBoxFlat` via le code.
- Exposer les paramètres de style (Rayon des coins, opacité).

### [Integration] Scènes
#### [MODIFY] [demo1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- Remplacer la hiérarchie `ConsolePanel/DebugConsole` par un nœud unique `SB_DebugConsole`.

## Plan de Vérification

### Tests Automatisés
- Vérifier que le composant s'affiche correctement (carré 300x300 arrondi) avec une seule instance de nœud.

---
**🟥🟨 VALIDATION REQUISE :** _Êtes-vous d'accord avec cette approche "Pure Code" pour l'autonomie du composant ?_
