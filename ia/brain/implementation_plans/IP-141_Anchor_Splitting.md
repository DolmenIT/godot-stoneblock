# [IP-141] Scission des Ancres : Static vs Dynamic

## 🎯 Objectif
Améliorer les performances et le workflow en séparant les ancres en deux composants distincts :
1. **SB_DynamicAnchor3D** : Pour l'UI réactive (HUD, Viewports).
2. **SB_StaticAnchor3D** : Pour le positionnement fixe (Stage Cards, Level Design) avec bouton manuel.

## 🛠️ Tâches
- [ ] **Phase 1 : Création de SB_DynamicAnchor3D**
    - Copier/Renommer `SB_ScreenAnchor3D.gd` -> `SB_DynamicAnchor3D.gd`.
    - Mettre à jour la `class_name`.
- [ ] **Phase 2 : Création de SB_StaticAnchor3D**
    - Créer le fichier.
    - Supprimer la logique de rafraîchissement automatique.
    - Ajouter le bouton `align_now` dans l'inspecteur.
- [ ] **Phase 3 : Nettoyage**
    - (Optionnel) Garder `SB_ScreenAnchor3D` comme alias ou le supprimer si les scènes sont migrées.
