# Implementation Plan - Refonte Opération Slope (20260317_001)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début Discussion** : 2026-03-17 ~15:00
- **Fin Discussion** : 2026-03-17 ~15:30
- **Statut** : ✅ **COMPLETED** (2026-03-17 ~18:30)

## 🎯 Objectifs
1.  **Simplification** : Supprimer les paramètres obsolètes (Global Bounds, Angle, Near/Far Height).
2.  **Profil 5 points** : Implémenter un système de 5 hauteurs (H1-H5) et 5 distances (D1-D5, en %) pour définir la forme de la pente.
3.  **Localisation** : Baser la pente exclusivement sur les points `slope_near_pos` et `slope_far_pos`.
4.  **Stabilité** : Corriger les erreurs d'instanciation de scripts dans Godot 4.

## 📝 Étapes d'exécution

### 1. Refonte de la Ressource (TerrainSculptingOperation.gd)
**Timecode** : 2026-03-17 ~15:35
**Statut** : ✅ **COMPLETED**
- Suppression des `@export` inutiles.
- Ajout des 5 points `slope_pX_h` (hauteurs) et `slope_pX_d` (distances).
- *Décision* : Le point 1 est fixe à 0% et le point 5 à 100% de la distance entre Near et Far.

### 2. Logique de Calcul (terrain_sculpt_ops_standard.gd)
**Timecode** : 2026-03-17 ~16:00
**Statut** : ✅ **COMPLETED**
- Refonte complète de `apply_slope`.
- Utilisation de `Vector2.dot` pour projeter les points sur le segment Near->Far.
- Interpolation linéaire entre les 5 points du profil.
- Fix des conflits de variables (`idx`, `dir`) introduits par erreur.

### 3. Mise à jour de l'UI (terrain_auto_sculpt_item.gd)
**Timecode** : 2026-03-17 ~17:15
**Statut** : ✅ **COMPLETED**
- Grille 5x2 pour les points du profil.
- Inputs pour les positions Near (X, Z) et Far (X, Z).
- Nettoyage des contrôles obsolètes.

### 4. Persistence & Pipeline (terrain_auto_sculpt_view.gd / pipeline.gd)
**Timecode** : 2026-03-17 ~17:45
**Statut** : ✅ **COMPLETED**
- Mise à jour du format JSON (Save/Load).
- Fix de l'instanciation `.new()` sur `GDScript` (Godot 4).
- Ajout de logs de débogage pour tracer la persistence.

## 🧪 Résultats & Validation
- ✅ Opération Slope fonctionnelle avec profil personnalisé.
- ✅ Sauvegarde/Chargement des JSON opérationnels.
- ✅ Plus d'erreurs d'analyse ou d'instanciation au démarrage.
