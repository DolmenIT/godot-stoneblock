# 🧠 Plan d'Implémentation - IP-125 : Rotation de Teinte (Hue Shift) pour Boutons 3D

> [!NOTE]
> **Timecode** : 2026-04-27 ~20:10
> **Statut** : En cours 🚀

## 🎯 Objectif
Ajouter un slider de rotation de teinte (Hue Shift) global pour le composant `SB_Button_3d`, permettant d'ajuster la couleur du bouton sans modifier individuellement les 4 teintes d'état (Normal, Hover, Pressed, Disabled).

## 🛠️ Modifications
1.  **Fichier** : `demo/demo1/ui/SB_Button_3d.gd`
    - Ajouter une variable `@export_range(0.0, 360.0) var tint_hue_shift: float = 0.0` dans le sous-groupe "Teintes du Bouton".
    - Mettre à jour la méthode `_update_ui()` pour appliquer ce décalage de teinte à `target_tint` avant de le passer aux couches (layers).
    - Logique GDScript : `target_tint.h = fmod(target_tint.h + tint_hue_shift / 360.0, 1.0)`.

## 🧪 Validation
- Vérifier dans l'éditeur que le slider modifie bien la teinte du bouton en temps réel.
- Vérifier que le décalage s'applique correctement à tous les états (au survol, au clic, etc.).

---
*Lien vers le suivi : [todo.md](../../todo.md)*
