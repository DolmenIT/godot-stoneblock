# Implementation Plan - Fix Persistent Invalid Node Path (20251129_004)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2025-11-29 ~22:25
- **Statut** : 🔄 **IN PROGRESS**

## Description du problème
L'erreur `ERROR: Path to node is invalid: '../../MultiPassRendering/SelectiveBloomViewport'` (ou similaire) persiste. L'analyse a révélé une autre référence statique invalide dans `000_splashscreen_scene.tscn` : la propriété `fallback_viewport_path` du script `darken_bloom_overlay.gd` attaché au nœud `DarkenBloomOverlayRect`.

## Changements proposés

### Fichier Scène
#### [MODIFIER] [000_splashscreen_scene.tscn](file:///d:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_scene/000_splashscreen_scene.tscn)
- Supprimer l'assignation `fallback_viewport_path` dans le nœud `DarkenBloomOverlayRect`.
- Cela forcera le script à utiliser la logique de fallback ou à attendre l'assignation dynamique.

### Scripts
#### [MODIFIER] [scripts/ui/debug/darken_bloom_overlay.gd](file:///d:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scripts/ui/debug/darken_bloom_overlay.gd)
- Vérifier si ce script gère correctement l'absence de `fallback_viewport_path` (optionnel, mais recommandé pour éviter des erreurs runtime).

## Plan de vérification

### Vérification Manuelle
- Lancer le projet/la scène.
- Vérifier que plus aucune erreur "Path to node is invalid" n'apparaît.
- Vérifier que l'overlay fonctionne (assignation dynamique déjà en place via le plan 003).
