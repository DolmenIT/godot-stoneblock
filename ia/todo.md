# 📋 TODO & Bilan de Migration DAGX StoneBlock

## 🚀 ROADMAP GLOBALE (1-39)

### 🟦 Cycle UI 2D (Démos 1-9)
#### **[ ] Demo 1 : Boot & Vertical Shmup**
- 📅 Demandé : 2026-03-23
- 🚀 Lancé : 2026-03-23
- ✅ Terminé : -
- **Composants** :
    - `SB_ShmupPlayer` : (Mouvement 2D, Banking)
    - `SB_ShmupProjectile` : (Gestion des tirs)
    - `SB_ShmupScroll` : (Défilement vertical multi-plans)
- **Objectif** : Transformer la démo de base en un prototype de Shoot 'em up vertical.

#### **[x] Demo 2 : Dolmenir - L'Éveil (Plateforme 3D)** ✅
- 📅 Demandé : 2026-03-21
- 🚀 Lancé : 2026-03-21
- ✅ Terminé : 2026-03-22
- **Composants** :
    - `SB_PlayerController3D` : (Fait) ✅
    - `SB_Follow3D` / `SB_Camera` : (Fait - Suivi 3rd Person) ✅
    - `SB_World` / `SB_Goal` : (Fait - Décor minimaliste & Fin) ✅
- **Objectif** : Un jeu de plateforme 3D minimaliste avec la mascotte Dolmenir.

- [ ] Demo 3 : Magie Celtique (Collectibles & UI)
- 📅 Demandé : 2026-03-21
- 🚀 Lancé : 2026-03-22
- ✅ Terminé : -
- **Composants** :
    - `SB_Pickable` : (Galettes, Kouign-amanns)
    - `SB_HUD` : (Compteur de magie/items)
- **Objectif** : Ramasser des ressources pour restaurer la magie.
- [x] `SB_Pickable` : (Galettes, Kouign-amanns) ✅
- [x] `SB_HUD` : (Compteur de magie/score) ✅
- [x] `SB_Pickable` : (Galettes, Kouign-amanns) ✅
- [x] `SB_HUD` : (Compteur de magie/score) ✅

#### **[ ] Demo 4 : Le Grand Menhir (Objectif & Niveaux)**
- 📅 Demandé : 2026-03-21
- 🚀 Lancé : -
- ✅ Terminé : -
- **Composants** :
    - `SB_Goal` : (Le Menhir entouré de dolmens)
    - `SB_Progression` : (Déblocage de niveaux/pouvoirs)
- **Objectif** : Atteindre l'arrivée pour restaurer la zone Celtic.

#### **[ ] Demo 5 : Pouvoirs Celtes (Double Saut / Dash)**
- 📅 Demandé : 2026-03-21
- 🚀 Lancé : -
- ✅ Terminé : -
- **Objectif** : Débloquer et utiliser de nouvelles capacités de mouvement.

#### **[ ] Demo 6 : Ennemis & Dangers (Esprits de la Forêt)**
- 📅 Demandé : 2026-03-21
- 🚀 Lancé : -
- ✅ Terminé : -

#### **[ ] Demo 7 : Synthèse Dolmenir (Monde 1 Complet)**
- 📅 Demandé : 2026-03-21
- 🚀 Lancé : -
- ✅ Terminé : -

### 🟩 Cycle SHMUP (Démos 8-10)
- [ ] Demo 8 : Ennemis & Waves (Formations)
- [ ] Demo 9 : Boss & Fin de Niveau
- [ ] Demo 10 : Power-ups & Upgrades

---

### 🟨 Cycle UI 3D (Démos 10-19)
- [ ] Interfaces dans le monde 3D, Gizmos, Panneaux flottants.

### 🟥 Cycle Gameplay 3D (Démos 20-39)
- [ ] Objets 3D complexes, Mouvements, Combat, Systèmes de jeu.


## ✅ Ce qui a été fait aujourd'hui (2026-03-23)
### Pivot SHMUP (Demo 1)
- [x] Analyse de l'architecture Cosmic HyperSquad pour portage des composants SHMUP.
- [x] Initialisation du plan **IP-022** pour le pivot de la Démo 1.

## ✅ Ce qui a été fait aujourd'hui (2026-03-22)
### Consolidation Demo 1 & Core
- [x] Raffinement de `SB_Core.gd` : Retrait des exports inutiles, simplification de l'interface (remplacement de `min_splash_time` par `use_stoneblock_splash`, suppression de `auto_setup_world`) et **nettoyage des chemins par défaut** (mis à vide).
- [x] Support du **Direct Boot** : Démarrage instantané si le splash est désactivé (fix de la machine à état pour assurer la transition).
- [x] Correction des menus de la Demo 1 : Fix des logs erronés sur les boutons Jouer et Quitter.
- [x] Pivot Demo 1 : Transformation en "Petit Platformer Basique" complet.
- [x] Mise à jour du sélecteur de niveaux pour pointer vers `40_game_scene.tscn`.
- [x] Amélioration de `40_game_scene.tscn` : Ajout de plateformes et de collectibles (Galettes) pour valider les stats du Core.

## ✅ Ce qui a été fait aujourd'hui (2026-03-21)
### Refonte Dolmenir & Menu
- [x] Pivot du Roadmap vers "Dolmenir : Le Petit Magicien Breton" (Plateforme 3D).
- [x] Refonte complète du menu de `sb_boot.tscn` (Jouer, Options, Quitter).
- [x] Intégration du composant `SB_Quit` pour la fermeture propre de l'app.
- [x] Correction des erreurs de ressources : Création des icônes manquantes (`SB_Follow3D.svg`, `SB_PlayerController3D.svg`).
- [x] Intégration des visuels 3-Slice pour `SB_Button` (Support textures normal/hover/pressed, marges et étirement).

## ✅ Ce qui a été fait aujourd'hui (2026-03-20)
### Initialisation du GDK & Analyse
- [x] Scan complet du dossier `ia/` et lecture des règles.
- [x] Inventaire des scripts (12 fichiers .gd).
- [x] Initialisation de l'infrastructure de planification dans `ia/brain/`.
- [x] Conception du `SB_Core` orienté **TPS Asynchrone**.
- [x] Création du `SB_Core.gd` et intégration dans `project.godot` (Autoload).
- [x] Implémentation de la **Console de Debug 100% Autonome** (Overlay intégré).
- [x] Correctif Critique : Positionnement UI (Ancres & Offsets) de la console.
- [x] Stylisation dynamique (Fond noir arrondi, 300x300, CanvasLayer).
- [x] Mise en place de l'architecture **Bootstrapper** (`demo1`) / **Niveau** (`scene1`).
- [x] Écran de **Splash Screen** avec logo 3D, Console autonome et transition.
- [x] Chargement et instanciation asynchrone fonctionnels via `SBCore`.

## ✅ Ce qui a été fait aujourd'hui (2026-03-19)
### Unification Grille & Auto-Props (Pipeline de Placement)
1. **Unification Pas de Grille :** Centralisation du paramètre `props_grid_step` dans le Manager. Les outils manuels et automatiques partagent désormais la même densité.
2. **Simplification Auto-Props :** Suppression du mode Aléatoire/Samples au profit d'une grille robuste avec jitter (décalage aléatoire) par passe pour un rendu naturel.
3. **Optimisation UI Auto-Props :** Refonte de l'interface des règles sur une seule ligne ultra-compacte.
4. **Correction Stabilité Manager :** Modification du `TerrainManagerHandler` pour prioriser le vrai Manager (évite les crashs d'identification avec les tuiles de terrain).
5. **Restauration UI Manuel :** Réactivation de la case "Pas Grille :" globale dans l'onglet manuel avec synchronisation temps réel.

## ✅ Ce qui a été fait aujourd'hui (2026-03-18)
... (Suite identique)
