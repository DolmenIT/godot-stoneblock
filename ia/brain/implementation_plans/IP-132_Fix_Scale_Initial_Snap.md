# IP-132 : Fix de l'Initialisation de Résolution (Scale Snap)

## 🎯 Objectif
Éliminer le flash/ajustement de résolution lors du chargement d'une scène en synchronisant le `SB_QualityConfig` dès l'initialisation du `SB_ViewportManager`.

## 🛠️ Modifications prévues

### 1. `SB_ViewportManager.gd`
- **`apply_initial_scaling()`** :
    - Ajouter la détection du `SB_QualityConfig` (local ou instance statique).
    - Appliquer les `force_scale` et `forced_scale` immédiatement sur les viewports.
    - Synchroniser les variables internes `_target_bg`, `_target_mg` et `_target_bl` avec ces valeurs pour éviter que le `_process` ne déclenche un lerp inutile.

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-30
- 🚀 **Lancé** : 2026-04-30
- ✅ **Terminé** : 2026-04-30

## 📝 Étapes d'exécution
1. [ ] Modifier `gdk-stoneblock/viewportmanagers/SB_ViewportManager.gd`.
2. [ ] Vérification visuelle par l'utilisateur.
