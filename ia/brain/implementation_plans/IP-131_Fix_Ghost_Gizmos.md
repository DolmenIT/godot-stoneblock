# IP-131 : Correction des Gizmos Fantômes et Amélioration du FlexContainer3D

## 🎯 Objectif
Résoudre le problème des lignes orange persistantes ("fantômes") dans l'éditeur pour le composant `SB_FlexContainer3D` et améliorer la visualisation du layout.

## 🛠️ Modifications prévues

### 1. `SB_FlexContainer3D.gd`
- **Correction des Orphelins** : Modifier `_update_gizmo` pour détecter et supprimer les nœuds `EditorGizmo` résiduels dans les enfants.
- **Persistance de Référence** : S'assurer que le script retrouve son gizmo après un rechargement de script dans l'éditeur.
- **Visualisation du Flux** : Dessiner les lignes de séparation des rangées (rows) pour confirmer visuellement le Wrap.

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-29
- 🚀 **Lancé** : 2026-04-29
- ✅ **Terminé** : _En attente_

## 📝 Étapes d'exécution
1. [ ] Modifier `SB_FlexContainer3D.gd`.
2. [ ] Vérification visuelle dans l'éditeur.
