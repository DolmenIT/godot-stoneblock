# 🧠 Mémoire : Analyse Approfondie de l'Abstraction de Stockage (Zéro-Fichier)

## 📌 Architecture de Synchronisation et Continuité
Pour garantir un terrain sans **coutures** tout en restant granulaire par **blocs**, le système utilise une approche de **Moyennage des Frontières**.

### 1. Synchronisation Géométrique (`TerrainGridSynchronizer`)
- **Bords** : Les hauteurs des deux blocs voisins sont extraites, moyennées (`(H_a + H_b) / 2`), puis réappliquées simultanément. Cela garantit une jointure mathématiquement parfaite.
- **Coins** : Une passe spécifique traite les 4 coins des blocs adjacents en diagonale pour éviter les petits trous aux intersections.
- **Voisinage Dynamique** : Les voisins (**Nord, Sud, Est, Ouest**) sont recalculés par le gestionnaire au chargement selon la distance monde, offrant une flexibilité totale de la grille.

### 2. Continuité Visuelle et Jupes
Pour masquer les micro-espaces persistants dus à la précision flottante du GPU ou de la structure des mailles :
- **Jupes à 89°** : Le `TerrainMeshBuilder` génère des faces internes aux bords, plongeant légèrement vers le bas.
- **Marge UV et Normales** : Le programme de rendu (**Shader**) est paramétré pour ignorer le bridage [0..1] sur les jupes. Cela permet d'échantillonner le voisinage (grâce à la **marge de texture**) et d'obtenir des normales horizontales aux bords pour une transition fluide.

## 🏗️ Stratégies de Robustesse (Sauvegarde et Chargement)
### 1. Le Modèle d'Isolation des Ressources
L'utilisation de `_safe_duplicate_texture` est vitale. En créant une nouvelle texture d'image à partir des données brutes plutôt que de copier la référence, on découple la mémoire vive de la Scène de celle du lot de données (**Bundle**). Sans cela, le cycle de pré-sauvegarde de Godot supprimerait involontairement les données du lot en mémoire.

### 2. Persistance Totale (`TerrainChunkData`)
Le lot de données ne sauvegarde pas juste l'altitude, mais l'état complet du bloc :
- **Maillages et Collisions** : Sauvegardés par défaut pour un **chargement rapide**.
- **État du Matériau** : Le shader `terrain.gdshader` reçoit ses paramètres critiques directement restaurés par le gestionnaire, évitant les rendus erronés après un chargement.

### 3. Cycle de Sauvegarde Sécurisé
1. **Extraction** : Le terrain est lu et transféré dans la mémoire vive du lot.
2. **Persistance** : Le lot est écrit sur le disque au format `.res`.
3. **Détachement** : La suppression du chemin de ressource protège le fichier contre les accès concurrents pendant le nettoyage du fichier de scène `.tscn`.
4. **Nettoyage final** : Le fichier `.tscn` est enregistré, libéré de ses mégaoctets de données binaires.

## 🎯 Évolutions Futures
- **Compression de Données** : Actuellement, le fichier de données peut être volumineux sur de grandes cartes. Un mode de reconstruction au chargement permettrait de réduire considérablement la taille de stockage.

---
*Dernière mise à jour : 2026-03-13 ~14:45*
*Sources : SB_HeightmapGrid.gd, TerrainGridSynchronizer.gd, TOPO_bundle_terrain_grille.md*
