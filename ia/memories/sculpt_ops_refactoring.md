# 🧠 Mémoire : Refonte des Opérations de Sculpture (Sculpting Ops Refactoring)

## 📌 Évolution de l'Opération Slope (Pente)
L'ancienne approche basée sur une courbe de Bézier était jugée trop imprévisible et difficile à régler.
- **Profil à 5 points** : La pente est désormais définie par 5 couples (Distance %, Hauteur m). Cela permet des profils complexes (ex: fossé avec rebord, plateau intermédiaire) avec une précision totale.
- **Calcul Vectoriel Local** : Utilisation d'une projection scalaire entre deux points `Near` et `Far` définis dans l'espace monde.

## 🌊 Érosion Physique et Répartition Uniforme
L'érosion physique simule le trajet de gouttes d'eau pour sculpter des rivières réalistes.
- **Social Physics** : Les gouttes se repoussent mutuellement si elles sont trop proches (Grid Spatial Indexing), évitant qu'elles ne s'empilent toutes dans le même sillon.
- **Répartition Dynamique (Mode Grille)** : Calcul automatique de l'espacement optimal pour répartir uniformément le nombre de gouttes demandé sur toute la surface, quel que soit l'aspect ratio de la carte.

## 🏗️ Mode Additif vs Remplacement
Toutes les opérations de sculpture supportent désormais le `slope_add_mode` ou équivalent, permettant soit de remplacer le relief actuel, soit de s'y ajouter (cumulatif), offrant beaucoup plus de flexibilité pour le level design.

---
*Dernière mise à jour : 2026-03-18*
*Sources : terrain_sculpt_ops_standard.gd, terrain_sculpt_ops_erosion_phys.gd*
