# IP-134 : Optimisation Drastique des Viewports Bloom (Fix 5 FPS)

## 🎯 Objectif
S'assurer que les viewports de Bloom sont physiquement désactivés (`UPDATE_DISABLED`) dès qu'ils ne sont pas nécessaires, afin de restaurer les performances sur mobile.

## 🛠️ Modifications prévues

### 1. `SB_ViewportManager.gd`
- **`update_dynamic_resolution()`** : Modifier l'appel à `_update_bloom_visibility` pour prendre en compte le réglage local de `bloom_config`.
- **`_update_bloom_visibility(active)`** : S'assurer que le mode `UPDATE_DISABLED` et `visible = false` sont appliqués de manière atomique.

### 2. `SB_BloomManager.gd`
- **`_sync_everything()`** : Ajouter un garde-fou au début pour arrêter toute synchronisation si le bloom est désactivé (via `bloom_config` s'il est accessible ou via la visibilité des containers).

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-30
- 🚀 **Lancé** : 2026-04-30
- ✅ **Terminé** : _En attente_

## 📝 Étapes d'exécution
1. [ ] Modifier `gdk-stoneblock/viewportmanagers/SB_ViewportManager.gd` pour le check local/global.
2. [ ] Modifier `gdk-stoneblock/visual/bloom/SB_BloomManager.gd` pour optimiser `_sync_everything`.
