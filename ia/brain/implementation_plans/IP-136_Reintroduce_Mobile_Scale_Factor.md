# IP-136 : Réintroduction du Mobile Scale Factor (Multiplicateur Global)

## 🎯 Objectif
Fournir un contrôle simple et global pour réduire la résolution sur mobile, en complément du système de résolution dynamique.

## 🛠️ Modifications effectuées

### 1. `SB_Core.gd`
- Ajout de `@export_range(0.1, 1.0, 0.05) var mobile_render_scale: float = 0.8`.
- Ce paramètre est visible dans l'inspecteur juste en dessous de **Auto Optimize Mobile**.

### 2. `SB_ViewportManager.gd`
- Modification de `_apply_scale()`.
- Toutes les échelles calculées (Background, Mainground, Bloom) sont désormais multipliées par `mobile_render_scale` si on est sur une plateforme mobile.
- Exemple : Si le système dynamique cible 0.75 et que le facteur mobile est à 0.8, la résolution finale sera de 0.6 (0.75 * 0.8).

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-30
- 🚀 **Lancé** : 2026-04-30
- ✅ **Terminé** : 2026-04-30

## 📝 Étapes d'exécution
1. [x] Ajouter le paramètre dans `SB_Core`.
2. [x] Appliquer le multiplicateur dans `SB_ViewportManager`.
