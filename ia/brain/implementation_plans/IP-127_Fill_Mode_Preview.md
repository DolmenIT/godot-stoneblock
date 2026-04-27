# 🧠 Plan d'Implémentation - IP-127 : Mode de Remplissage (Fill/Cover) pour les Previews

> [!NOTE]
> **Timecode** : 2026-04-27 ~21:35
> **Statut** : En cours 🚀

## 🎯 Objectif
Permettre aux textures de preview dans `SB_Button_3d` de s'afficher en mode "Fill" (Aspect Cover) au lieu d'être étirées ("Stretch"), afin de conserver leur ratio d'aspect original tout en remplissant la zone du bouton.

## 🛠️ Modifications
1.  **Fichier** : `gdk-stoneblock/visual/SB_NineSlice3D.gd`
    - Ajouter une énumération `SBStretchMode { STRETCH, COVER }`.
    - Ajouter une variable `@export var stretch_mode: SBStretchMode = SBStretchMode.STRETCH`.
    - Mettre à jour le shader pour gérer le mode `COVER` :
        - Calculer le ratio d'aspect de la zone (mesh) et de la texture.
        - Ajuster les UV pour centrer et recadrer la texture sans déformation.
    - Passer le paramètre au shader dans `_update_visual()`.

2.  **Fichier** : `demo/demo1/ui/SB_Button_3d.gd`
    - Ajouter une variable `@export var preview_stretch_mode: SB_NineSlice3D.SBStretchMode = SB_NineSlice3D.SBStretchMode.COVER`.
    - Dans `_update_ui()`, appliquer ce mode à la couche `Layer1_Preview`.

## 🧪 Validation
- Vérifier qu'une image de preview (ex: capture d'écran 16:9) ne s'étire pas sur un bouton de format différent.
- Vérifier que le masquage par le fond du bouton fonctionne toujours correctement.

---
*Lien vers le suivi : [todo.md](../../todo.md)*
