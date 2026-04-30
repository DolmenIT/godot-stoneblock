# IP-135 : Centralisation des Optimisations Mobiles (MSAA & Shadows)

## 🎯 Objectif
Permettre de gagner les FPS manquants sur mobile en désactivant physiquement les fonctionnalités lourdes (MSAA, Shadow Atlas) sur les SubViewports.

## 🛠️ Modifications effectuées

### 1. `SB_QualityManager.gd`
- Ajout du groupe **"Mobile Performance Defaults"**.
- `mobile_disable_msaa` (défaut true) : Pour couper l'anti-aliasing sur les viewports secondaires.
- `mobile_optimize_shadows` (défaut true) : Pour couper le shadow atlas sur les viewports secondaires.

### 2. `SB_QualityConfig.gd`
- Ajout du groupe **"Mobile Performance Overrides"**.
- Permet de forcer ou d'activer le MSAA/Ombres par scène.
- Mise à jour des presets **VERY_LOW** et **LOW** pour forcer ces optimisations.

### 3. `SB_ViewportManager.gd`
- Implémentation de `_apply_mobile_optimizations(vp)`.
- Applique les réglages de MSAA (MSAA_DISABLED) et d'Ombres (atlas_size = 0) sur chaque viewport détecté lors de l'initialisation.

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-30
- 🚀 **Lancé** : 2026-04-30
- ✅ **Terminé** : 2026-04-30

## 📝 Étapes d'exécution
1. [x] Ajouter les paramètres dans `SB_QualityManager`.
2. [x] Ajouter les overrides et presets dans `SB_QualityConfig`.
3. [x] Appliquer les paramètres dans `SB_ViewportManager`.
