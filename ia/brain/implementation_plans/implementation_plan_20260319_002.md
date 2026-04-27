# Implementation Plan - Unification Pas de Grille & Simplification Auto-Props (20260319_002)

## 📅 Timeline
- **Début** : 2026-03-18 ~23:00
- **Statut** : ✅ **COMPLETED** (2026-03-19 ~01:00)

## 🎯 Objectif
Unifier le paramètre "Pas de la Grille" entre les outils de placement manuel et l'Auto-Props pour garantir une densité cohérente. Simplifier le pipeline Auto-Props en supprimant les modes redondants.

## 🛠️ Changements Effectués

### 1. Centralisation du Manager
**Fichier** : [terrain_heightmap_manager.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/tools/terrain_heightmap_manager.gd)
- Ajout de `props_grid_step` : variable globale partagée.
- Suppression de la dépendance aux tuiles individuelles pour ce paramètre.

### 2. Simplification Auto-Props
**Fichier** : [terrain_placement_rule.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/addons/terrain_brush_plugin/terrain_placement_rule.gd)
- Suppression de `placement_mode` et `samples_per_chunk`.
- Suppression de `grid_step` (désormais global).

**Fichier** : [terrain_auto_props_pipeline.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/tools/terrain_auto_props_pipeline.gd)
- Utilisation exclusive du balayage par grille.
- Ajout d'un **jitter aléatoire par passe** pour briser l'aspect trop régulier.

### 3. Refonte de l'Interface (UI)
**Fichier** : [prop_placement_view.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/addons/terrain_brush_plugin/ui/prop_placement_view.gd)
- Restauration de la case "Pas Grille :" au sommet de l'onglet Manuel.
- Synchronisation bidirectionnelle avec le Manager.
- Suppression des SpinBoxes redondantes par objet.

**Fichier** : [terrain_autoprops_view.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/addons/terrain_brush_plugin/ui/terrain_autoprops_view.gd)
- Interface ultra-compacte (une seule ligne par règle).
- Nettoyage de la persistance JSON (plus de samples/mode).

### 4. Corrections d'Urgence (Stabilité)
**Fichier** : [terrain_manager_handler.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/addons/terrain_brush_plugin/terrain_manager_handler.gd)
- **Priorisation du Manager** : Correction de l'algorithme de recherche qui confondait les tuiles de terrain avec le manager central. Résout les crashs à l'ouverture et les échecs de chargement JSON.

## 🏁 Bilan & Validation
- ✅ **Synchro** : Changer le pas de grille en manuel affecte immédiatement l'Auto-Props.
- ✅ **Performance** : Pipeline simplifié et plus robuste.
- ✅ **Stabilité** : Plus de crash d'identification au démarrage ou au chargement des presets.
