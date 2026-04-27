# Implementation Plan - Fix Invalid Node Path (20251129_003)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2025-11-29 ~22:05
- **Statut** : ✅ **COMPLETED**

## 📅 Timeline
### 1. Correction Scène
**Timecode** : 2025-11-29 ~22:15-22:18
**Statut** : ✅ **COMPLETED**

### 2. Correction Script
**Timecode** : 2025-11-29 ~22:18-22:20
**Statut** : ✅ **COMPLETED**

## Description du problème
L'erreur `ERROR: Path to node is invalid: '../../MultiPassRendering/SelectiveBloomViewport'` survient au chargement de la scène. Elle est causée par une `ViewportTexture` dans `000_splashscreen_scene.tscn` qui pointe vers un nœud (`MultiPassRendering`) qui n'existe pas encore (car il est créé dynamiquement par le script).

## Changements proposés

### Fichier Scène
#### [MODIFIER] [000_splashscreen_scene.tscn](file:///d:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_scene/000_splashscreen_scene.tscn)
- Supprimer l'assignation `viewport_path` dans la sous-ressource `ViewportTexture_bloom`.
- Cela empêchera le moteur de tenter de résoudre le chemin au chargement.

### Scripts
#### [MODIFIER] [000_splashscreen_scene.gd](file:///d:/Projets/Cosmic%20HyperSquad/2025/cosmic-hyper-squad/scenes/000_splashscreen_scene/000_splashscreen_scene.gd)
- Dans `_ensure_multipass_nodes_exist` (ou une fonction dédiée), assigner dynamiquement la texture du viewport au paramètre du shader qui l'utilise (`ShaderMaterial_darken_overlay`), une fois que le viewport est créé.

## Plan de vérification

### Vérification Manuelle
- Lancer le projet/la scène.
- Vérifier que l'erreur `Path to node is invalid` a disparu de la console.
- Vérifier que l'effet de bloom (et le darken overlay) fonctionne toujours correctement.
