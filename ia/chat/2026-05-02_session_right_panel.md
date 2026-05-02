# 📓 Session du 02 mai 2026 - Résolution du bug de visibilité du RightPanel

## 1. Problème rencontré
En lançant le jeu en portrait, le panneau droit (`RightPanelAnchor` / `11RightPanel`) ne s'affichait pas, alors qu'il apparaissait correctement dès que l'orientation passait en landscape.

## 2. Cause racine identifiée
Le sous-composant `p11_right_panel.tscn` contenait un node `SB_SetVisibility`.
Par défaut, le script `SB_SetVisibility.gd` a l'option `portrait_visibility = false`.
Ainsi, dès le démarrage en portrait, le node masquait automatiquement tout le panneau droit. Lors du passage en landscape, la visibilité était réévaluée à `true`.

## 3. Solution appliquée
- Retrait complet du node `SB_SetVisibility` dans `p11_right_panel.tscn` car le panneau droit doit être affiché dans les deux orientations (dans la scène paysage et dans la scène portrait).
- Ajout d'une propagation en cascade `signal size_changed` dans `SB_ScreenAnchor3D.gd` pour garantir que tout changement de position du parent/référence notifie les ancres enfants.
- Modification de la valeur par défaut de `text_render_priority` de `10` à `0` dans `SB_Button_3d.gd` pour permettre un tri correct des objets transparents basé sur la profondeur `Z`.
- Amélioration de la méthode `_update_collider` dans `SB_LevelPreview_3d.gd` pour y ajouter une recherche par repli (fallback) sur la taille de ses nœuds enfants lorsque le nœud de preview direct est inexistant. Cela garantit le blocage d'input via occlusion des rayons de picking même si la scène parente possède une structure différente.
- Ajout d'une synchronisation en temps réel de la visibilité dans `SB_GlowObstruct.gd` et `SB_LevelPreview_3d.gd` : les duplicatas noirs de bloom ainsi que l'Area3D de blocage d'input sont automatiquement désactivés (`process_mode = PROCESS_MODE_DISABLED`) si le panneau parent est masqué (`is_visible_in_tree() == false`).
