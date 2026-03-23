# SB_Move3D

Un composant du SDK **StoneBlock** pour créer des séquences de mouvements 3D complexes directement dans l'inspecteur.

## Comment l'utiliser
1. Ajoutez un nœud `SB_Move3D` à votre scène.
2. Assignez une **Target Node** (automatiquement le parent si c'est un Node3D).
3. Dans la liste **Steps**, ajoutez des éléments `SB_MoveStep`.
4. Pour chaque étape, définissez :
    - `Start Time` / `End Time` (en secondes).
    - `Start Position` / `End Position`.
    - Les courbes d'accélération (Transition et Ease).
5. Activez **Play In Editor** pour prévisualiser le mouvement sans lancer le jeu.

## Propriétés
- **Auto Play** : Lance la séquence au démarrage du jeu.
- **Loop** : Recommence la séquence à la fin.
- **Play In Editor** : Permet de tester dans l'éditeur.

## Structure
- Script : `res://stoneblock/animation/SB_Move3D.gd`
- Ressource : `res://stoneblock/resources/SB_MoveStep.gd`
