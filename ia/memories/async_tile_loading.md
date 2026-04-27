# 🧠 Mémoire : Chargement Asynchrone et Progressif des Tuiles (Async Tile Loading)

## 📌 Objectif et Problématique
Initialement, l'ouverture d'un monde lourd (plusieurs dizaines de tuiles) provoquait un gel complet de Godot pendant le chargement des ressources et la génération des collisions. 
**Solution** : Charger les tuiles à la volée après l'ouverture de la scène, sans bloquer le thread principal.

## 🛠️ Architecture du Système
### 1. Ouverture Instantanée
- Le monde s'ouvre sans aucune tuile chargée (`HeightmapData` vide).
- Le manager de grille identifie les tuiles nécessaires autour de la caméra.

### 2. File d'Attente Prioritaire (Queue)
- Les tuiles sont chargées une par une via des appels différés ou des threads si nécessaire.
- Priorité donnée aux tuiles les plus proches de la caméra.

### 3. Chargement en Deux Étapes (VL -> LOD)
- **Étape 1 : Very Low (VL)** : Chargement ultra-rapide d'une version basse résolution pour boucher les trous visuels.
- **Étape 2 : LOD Sélectionné** : Remplacement progressif par la résolution finale choisie pour le projet.

## 🏗️ Bénéfices
- **Fluidité** : Plus aucun freeze à l'ouverture ou lors des déplacements rapides.
- **Scalabilité** : Permet de gérer des mondes virtuellement infinis en ne chargeant que le "cercle de visibilité".

---
*Dernière mise à jour : 2026-03-18*
*Sources : SB_HeightmapGrid.gd, Conversation 96295cda-6134-4bb1-ba62-a55d0a44a491*
