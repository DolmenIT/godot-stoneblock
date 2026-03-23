# [IP-018] Demo 2 : Layouts & Responsive (Grid/Scroll)

L'objectif de cette démo est de maîtriser les outils de mise en page natifs de Godot (`VBoxContainer`, `HBoxContainer`, `GridContainer`, `ScrollContainer`, `MarginContainer`) avant d'implémenter des composants StoneBlock plus complexes.

## Proposed Changes

### [Demos]
#### [NEW] [demo2_layouts.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo2/demo2_layouts.tscn)
- Scène de démonstration contenant :
    - Un `VBoxContainer` pour un menu latéral.
    - Un `HBoxContainer` pour une barre de titre/statut en haut.
    - Un `GridContainer` (4 colonnes) pour afficher une grille d'icônes/boutons.
    - Un `ScrollContainer` enveloppant la grille pour gérer le débordement vertical.
    - Utilisation systématique de `MarginContainer` pour le padding.
- Bouton de retour vers `scene1`.

#### [NEW] [demo2_layouts.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo2/demo2_layouts.gd)
- Script simple pour initialiser la grille avec des éléments dynamiques (pour tester le défilement).

#### [MODIFY] [scene1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/scene1.tscn)
- Ajout d'un bouton `SB_Button` dans le menu actuel pour lancer la Demo 2.

## Verification Plan

### Manual Verification
1. **Lancer la scène demo2_layouts.tscn** directement par l'utilisateur ou via `scene1`.
2. **Vérifier l'alignement** : Les éléments doivent être correctement espacés et alignés.
3. **Tester le Scrolling** : La molette de la souris ou le drag doit permettre de faire défiler la grille si elle contient assez d'éléments.
4. **Redimensionnement de la fenêtre** : Les conteneurs doivent adapter la position des éléments (Responsive).
5. **Bouton Retour** : Vérifier le retour fluide vers `scene1`.
