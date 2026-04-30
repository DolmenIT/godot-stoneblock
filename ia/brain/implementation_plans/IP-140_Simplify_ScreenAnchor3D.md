# [IP-140] Simplification de SB_ScreenAnchor3D (Refactoring)

## 🎯 Objectif
Supprimer la complexité liée à la double configuration Portrait/Paysage dans les ancres 3D, au profit d'une configuration unique universelle. L'orientation est désormais gérée au niveau supérieur (Dispatcher).

## 🛠️ Tâches
- [ ] **Phase 1 : Consolidation des Exports**
    - Supprimer `anchor_landscape`, `anchor_portrait`, etc.
    - Créer `anchor`, `pivot`, `offset_3d`, `reference_node`.
- [ ] **Phase 2 : Nettoyage de la Logique**
    - Supprimer `_is_portrait()`.
    - Supprimer les getters dynamiques (`_get_current_anchor`).
- [ ] **Phase 3 : Mise à jour du Positionnement**
    - Adapter `_update_position` pour utiliser les nouvelles propriétés.
- [ ] **Phase 4 : Vérification & Sécurité**
    - S'assurer que le mode `@tool` fonctionne toujours bien pour l'édition en temps réel.

## ⚠️ Note sur la Migration
Les scènes existantes utilisant des overrides Portrait perdront ces réglages spécifiques. La scène devra être re-réglée avec la configuration unique.
