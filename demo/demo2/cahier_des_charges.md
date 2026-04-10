# Cahier des Charges - Projet MockupFlow (demo2)

## 📋 Description du Projet
**MockupFlow** est un outil de dessin à la main levée, optimisé pour les tablettes, permettant de prototyper rapidement des interfaces utilisateur (UI), des fenêtres et des scènes pour les projets StoneBlock. 

La fonctionnalité phare est le concept de **Dessins Imbriqués (Nested Drawings)** : la capacité de créer un petit dessin (un composant), de le sauvegarder, puis de l'instancier et de le manipuler dans un dessin plus grand.

## 📐 Spécifications de l'Interface (Layout Landscape)
L'interface doit être fixe et s'adapter au format paysage de la tablette.

| Zone | Dimensions | Fonction |
| :--- | :--- | :--- |
| **Bandeau Haut** | Hauteur : 50px | Navigation, Nom du fichier, Actions (Save/Load) |
| **Bandeau Bas** | Hauteur : 50px | Infos d'état, Zoom, Coordonnées |
| **Panneau Gauche** | Largeur : 250px (réductible à 50px) | Outils, Couleurs, Composants. Bouton de réduction/expansion. |
| **Panneau Droit** | Largeur : 200px (réductible à 50px) | Arborescence des calques, Propriétés. Bouton de réduction/expansion. |
- **Zone Centrale** | Flexible | Zone de dessin active (Canvas) |

## 🏷️ Classification & États d'Avancement
Chaque dessin ou composant possède un état d'avancement pour faciliter le tri et le filtrage :
1. **Draft (Brouillon)** : Esquisse rapide, traits non nettoyés.
2. **Standard (Affiné)** : Structure validée, proportions correctes.
3. **Final (Gold)** : Rendu final, prêt pour l'intégration ou la présentation.
L'éditeur doit afficher visuellement cet état (badge couleur) sur chaque instance et dans la bibliothèque.
1. **Outils de base** : Pinceau (Brush) avec pression simulée ou réelle, Gomme (Eraser).
2. **Gestion des Couleurs** : Palette rapide et sélecteur de teinte.
- **Calques & États** : Chaque composant stocke son état (`Draft`, `Standard`, `Final`) via une métadonnée.
- **Système de "Composants"** :
    - Transformer un dessin fini en "Composant".
    - Glisser-déposer un composant depuis le panneau gauche vers le canvas.
    - Mise à jour en temps réel : si on modifie le composant source, toutes ses instances dans les autres dessins sont mises à jour.

## ⚙️ Architecture Technique (Godot)
- **Scène de Boot** : `00_boot.tscn` utilisant `SB_Core`.
- **Format de Données** : Les dessins et composants sont sauvegardés en tant que Resources Godot personnalisées (`.tres`) pour une intégration native.
- **Rendu** : Utilisation de `SubViewport` pour chaque composant afin de préserver la résolution et permettre les transformations (rotation, scale) sans perte de qualité.
- **Input** : Support complet du `InputEventMouse` et `InputEventScreenTouch` (pression si disponible).

## 🚀 Prochaines Étapes
1. Création du layout de base en Control Nodes.
2. Implémentation du moteur de Line Drawing (ligne brisée ou texture-brush).
3. Système de stockage/chargement des Resources de dessin.

---
*Rédigé par Léo "Antigrav" Valery le 2026-04-10*
