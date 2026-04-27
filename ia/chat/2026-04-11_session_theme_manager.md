# Session 2026-04-11 : Architecture de Thème Dynamique (Style-as-Nodes)

## Résumé
L'objectif de cette session était de centraliser la configuration du style UI (polices, tailles) pour éviter les répétitions manuelles et obtenir l'équivalent d'une feuille de style CSS sous forme de nœuds Godot.

## Décisions et Réalisations
1. **Création du SB_ThemeManager** : Un nœud persistant dans la scène de boot (`00_boot.tscn`) qui génère un `Theme` Godot à partir de sa hiérarchie d'enfants.
2. **Architecture Hiérarchique** :
    - Utilisation de nœuds `SB_ThemeStyle` comme enfants du manager.
    - Le nom du nœud définit la **Type Variation** (ex: `LabelFont`, `ButtonFont`).
    - Possibilité de grouper les styles par contexte (ex: `ThemeForMenu`).
3. **Application Automatique** :
    - Le manager écoute le signal `resource_loaded` du `SB_Core`.
    - Il injecte automatiquement le thème généré dans les nœuds racine de type `Control` des nouvelles scènes.
4. **Unification Visuelle** :
    - Taille de police harmonisée à **10px** pour les boutons et **12px** pour les labels (selon les ajustements utilisateurs).
    - Nettoyage des `theme_overrides` dans `MockupEditor.tscn` et `SB_BrushItem.tscn`.

## Prochaines Étapes
- Étendre le `SB_ThemeManager` pour supporter les **StyleBox** (bordures, arrondis, couleurs de fond).
- Corriger le bug visuel de la boîte de homing (**IP-078**).
