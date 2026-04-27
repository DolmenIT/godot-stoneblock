# 🛠️ Plan d'implémentation : Correction Hitbox SB_Button_3d

L'analyse des images et du code montre que le `Background` (le visuel du bouton) a une rotation de -90° sur X, alors que la `CollisionShape3D` est à 0°. Comme le script applique `mesh_size.y` à l'axe Y de la collision, la surface de détection devient verticale au lieu de suivre la surface "couchée" du bouton.

## 📌 Analyse Technique
- `Background.rotation` = `(-PI/2, 0, 0)`
- `CollisionShape3D.rotation` = `(0, 0, 0)`
- `CollisionShape3D.shape.size` = `Vector3(mesh_size.x, mesh_size.y, 0.05)`
- Conséquence : La détection est décalée et ne correspond pas au visuel dès que `mesh_size` (X/Y) change ou que le bouton est incliné.

## 🟥🟨 VALIDATION REQUISE
> [!IMPORTANT]
> Je vais synchroniser la rotation de l' `Area3D` avec celle du `Background` au démarrage (`_ready`) et dans l'éditeur. Cela garantira que la hitbox suit toujours parfaitement l'orientation du visuel.
> 
> **🟥🟨 VALIDATION REQUISE :** Approuves-tu l'alignement automatique de la rotation de la hitbox sur celle du mesh de fond ?

## 🛠️ Modifications proposées

### 🔘 Composant Bouton 3D

#### [MODIFY] [SB_Button_3d.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/ui/SB_Button_3d.tscn)
- Aligner la rotation de l'`Area3D` sur celle du `Background` (Rotation X: -90°).

#### [MODIFY] [SB_Button_3d.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/ui/SB_Button_3d.gd)
- Dans `_ready()`, ajouter la synchronisation de rotation entre `_mesh` et `_area`.
- Dans `_update_ui()`, s'assurer que la taille de la collision (`shape.size`) est mise à jour avec une épaisseur cohérente (Z = 0.05).

## 🧪 Plan de Vérification
- Activer "Afficher les formes de collision" dans le menu Godot.
- Vérifier dans `11_menu_levels_3d.tscn` que les formes de collision englobent bien les boutons.
- Tester le survol en jeu pour valider la réactivité des bords.
