# IP-137 : Orchestration Avancée de la Performance Mobile

## 🎯 Objectif
Fournir un groupe de réglages dédiés pour optimiser le rendu sur mobile, incluant un facteur de résolution global et une cible FPS spécifique.

## 🛠️ Modifications effectuées

### 1. `SB_Core.gd`
- Création du groupe **"Mobile Optimization"**.
- Renommage de `mobile_render_scale` en **`mobile_render_factor`**.
- Ajout de **`mobile_dynamic_factor`** (bool) : Prépare le terrain pour des ajustements automatiques du facteur.
- Ajout de **`mobile_target_fps`** (défaut 30.0) : Permet de définir une cible de fluidité plus basse sur mobile pour économiser la batterie et stabiliser la résolution.

### 2. `SB_ViewportManager.gd`
- **Cibles Adaptatives** : Dans `update_dynamic_resolution()`, si on est sur mobile, le système utilise désormais `mobile_target_fps` comme référence au lieu des 60 FPS par défaut.
- **Calcul des seuils** : Les seuils de dégradation (`min_fps`) sont automatiquement recalculés à 50-60% de la cible mobile.
- **Multiplication Factor** : Application du `mobile_render_factor` sur toutes les échelles (Background, Mainground, Bloom) lors du calcul final.

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-30
- 🚀 **Lancé** : 2026-04-30
- ✅ **Terminé** : 2026-04-30

## 📝 Étapes d'exécution
1. [x] Renommer et grouper les paramètres dans `SB_Core`.
2. [x] Adapter `SB_ViewportManager` pour utiliser la cible FPS mobile.
