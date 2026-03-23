# Implementation Plan - Codex Screen (302) - Complétion (20251212_013)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2025-12-12 ~22:31
- **Fin** : 2025-12-12 ~23:30
- **Statut** : ✅ **COMPLETED**

## 🎯 Objectif

Compléter l'implémentation de l'écran Codex (302) selon la spécification dans `302_codex_screen.md`. Le script actuel gère les tabs mais ne charge pas encore les données ni ne gère la sélection d'items.

## 📋 État Actuel

### ✅ Déjà en place
- Structure de scène avec tabs (Ships, Weapons, Shot Types, Ammo Upgrades, Enemies, Bosses, Stories, Levels)
- Conteneurs pour chaque catégorie (GridContainer3D)
- ShipLoader pour charger les vaisseaux depuis JSON
- ShipCard template réutilisable
- TabButton3D avec système de sélection
- Fichier `data/ships.json` avec 30 vaisseaux

### ❌ À implémenter
1. **Chargement des données** : Utiliser ShipLoader pour charger les vaisseaux dans le conteneur Ships
2. **Gestion de la sélection** : Connecter les ShipCards pour afficher les détails dans le RightPanel
3. **RightPanel** : Créer l'affichage des détails d'un item sélectionné
4. **Autres catégories** : Préparer la structure pour les autres catégories (Weapons, etc.)

## 🔧 Étapes d'Implémentation

### 1. Adapter le script 302_codex_screen.gd pour le Codex
**Timecode** : 2025-12-12 ~22:31-22:45  
**Statut** : ✅ **COMPLETED**

- [x] Renommer les références de MainMenu vers Codex
- [x] Ajouter les références aux conteneurs de chaque catégorie
- [x] Ajouter la référence au RightPanel (avec gestion si absent)
- [x] Ajouter la référence au ShipLoader existant dans ShipsCodexContainer
- [x] Connecter le signal `ships_loaded` du ShipLoader pour gérer les ShipCards créés

### 2. Implémenter la gestion de sélection d'items
**Timecode** : 2025-12-12 ~22:45-22:50  
**Statut** : ✅ **COMPLETED**

- [x] Créer un signal `item_selected(ship_card: ShipCard)` dans ShipCard
- [x] Connecter les ShipCards au script principal pour gérer la sélection
- [x] Implémenter la fonction `_on_ship_card_selected()` dans 302_codex_screen.gd
- [x] Gérer le highlight visuel du ShipCard sélectionné (opacité du foreground)

### 3. Créer le RightPanel pour afficher les détails
**Timecode** : 2025-12-12 ~22:50-23:15  
**Statut** : ✅ **COMPLETED**

- [x] Créer la structure du RightPanel global dans la scène
- [x] Créer les RightPanelContent pour chaque catégorie (8 Content : Ships, Weapons, Shot Types, Ammo Upgrades, Enemies, Bosses, Stories, Levels)
- [x] Ajouter les éléments UI de base dans chaque Content :
  - Label3D pour le nom (NameLabel)
  - Image3D pour le visuel/thumbnail (ThumbnailImage)
  - Label3D pour la description (DescriptionLabel)
- [x] Implémenter la fonction `_update_right_panel(item_data: Dictionary)` avec support pour toutes les catégories
- [x] Implémenter l'affichage/masquage des RightPanelContent selon le tab sélectionné
- [x] Connecter la gestion des tabs avec l'affichage du bon RightPanelContent
- [ ] Ajouter les labels pour les statistiques (à faire selon les besoins de chaque catégorie)
- [ ] Ajouter l'indicateur locked/unlocked (à faire plus tard)

### 4. Gérer les items verrouillés
**Timecode** : À définir  
**Statut** : ⏳ **PENDING**

- [ ] Ajouter un système de gestion des items déverrouillés (pour l'instant tous déverrouillés)
- [ ] Modifier ShipCard pour afficher l'état locked/unlocked
- [ ] Gérer l'affichage "???" pour les items verrouillés

### 5. Tests et ajustements
**Timecode** : 2025-12-12 ~23:15-23:30  
**Statut** : ✅ **COMPLETED**

- [x] Tester le chargement des vaisseaux
- [x] Tester la sélection d'un vaisseau (correction des connexions de signaux)
- [x] Tester l'affichage des détails dans le RightPanel
- [x] Tester la navigation entre tabs
- [x] Corriger le problème de chargement de scène (désactivation de l'EventMaster)
- [x] Corriger les références TopBar2 → LeftPanel
- [x] Corriger l'erreur de shadowing de variable
- [x] Ajouter la fonction _connect_all_ship_cards() pour connecter tous les ShipCards

## 📝 Notes Techniques

- Le ShipLoader est déjà présent dans la scène dans `ShipsCodexContainer`
- Utiliser `ship_card_template.tscn` pour créer les ShipCards
- Le GridContainer3D gère automatiquement le positionnement
- Les tabs utilisent `target_group` pour afficher/masquer les conteneurs

## 🔗 Références

- Spécification : `screens/302_codex_screen/302_codex_screen.md`
- Script actuel : `screens/302_codex_screen/302_codex_screen.gd`
- ShipLoader : `scripts/managers/ship_loader.gd`
- ShipCard : `components/ship_card.gd`
- Données : `data/ships.json`

