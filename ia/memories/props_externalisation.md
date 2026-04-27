# 🧠 Mémoire : Abstraction et Externalisation des Accessoires

## 📌 Vision Globale
L'externalisation des **Accessoires** (arbres, rochers, décors) suit le même principe que le système **Zéro-Fichier** du terrain. L'objectif est de maintenir le fichier de scène `.tscn` sous une taille de quelques kilo-octets en déportant les milliers d'instances d'objets générés dans une scène externe `.scn` dédiée.

## 🏗️ Structure des Données
Le système repose sur deux types de ressources et un pipeline dédié :

### 1. Ressource d'Accessoire (`PropResource`)
Définit l'objet lui-même et ses contraintes physiques :
- **Scène** : Le fichier `.tscn` ou `.scn` de l'objet à instancier.
- **Échelle** : Plage de variation (`min_scale` / `max_scale`).
- **Espacement** : Distance minimale entre deux objets du même type (`min_spacing`).
- **Alignement** : Option pour aligner l'objet sur la normale du terrain.

### 2. Règle de Placement (`TerrainPlacementRule`)
Définit la logique de distribution spatiale :
- **Mode de Placement** :
    - **Échantillonnage Aléatoire** : Idéal pour des forêts ou des rochers dispersés.
    - **Balayage par Grille** : Utilisé pour une couverture dense (herbe, buissons).
- **Contraintes Terrain** :
    - **Altitude** : Tranches de hauteur autorisées (`min_height` / `max_height`).
    - **Pente** : Angle maximum toléré (`max_slope_degrees`).
    - **Texture** : Filtrage par canal de **Splatmap** (ne placer que sur l'herbe, par exemple).
- **Clustering** : Probabilité augmentée à proximité d'un objet identique pour créer des groupes naturels.

## ⚙️ Pipeline de Génération (`TerrainAutoPropsPipeline`)
Le pipeline traite chaque bloc de terrain individuellement :
1. **Échantillonnage** : Génère des points candidats selon la règle choisie.
2. **Filtrage** : Vérifie pour chaque point la hauteur, la pente, la planéité et la texture du terrain.
3. **Optimisation** : Vérifie la densité (proximité) avant d'instancier.
4. **Hiérarchie** : Les objets sont rangés dans une structure organisée : `GeneratedProps` -> `Grid_X` -> `Field_X_Y`.

## 💾 Cycle d'Externalisation
Le mécanisme est piloté par le gestionnaire de grille (`SB_HeightmapGrid`) :

- **Avant Sauvegarde** :
    - Tous les accessoires sont regroupés sous un nœud racine unique.
    - Ce nœud est **empaqueté** (Packed) dans un fichier externe (ex: `Level_1_Props.scn`).
    - Le nœud est ensuite **supprimé** de l'arbre pour que le `.tscn` soit enregistré vide.
- **Après Sauvegarde / Ouverture** :
    - La scène externe est chargée et instanciée.
    - Elle est rattachée comme enfant du gestionnaire.
    - La **possession** (`owner`) est intelligemment gérée pour que l'utilisateur voie les objets sans que Godot ne cherche à les ré-enregistrer dans la scène principale.

---
*Dernière mise à jour : 2026-03-13*
*Statut : Système stabilisé et documenté.*
