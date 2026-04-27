# 🧠 Plan d'Implémentation - IP-124 : Paramètres par défaut Bouton 3D

> [!NOTE]
> **Timecode** : 2026-04-27 ~20:05
> **Statut** : En cours 🚀

## 🎯 Objectif
Appliquer les nouveaux paramètres par défaut pour le composant `SB_Button_3d` conformément à la demande utilisateur (Preview Mix = 0.1, Blend Mode = Screen).

## 🛠️ Modifications
1.  **Fichier** : `demo/demo1/ui/SB_Button_3d.gd`
    - Modifier la valeur par défaut de `@export_range(0.0, 1.0) var preview_mix` de `0.0` à `0.1`.
    - Modifier la valeur par défaut de `@export var preview_blend_mode` de `SBPreviewBlendMode.NORMAL` à `SBPreviewBlendMode.SCREEN`.

## 🧪 Validation
- Vérifier que les nouveaux boutons créés dans l'éditeur héritent de ces valeurs.
- S'assurer que le rendu visuel est correct avec ces nouveaux paramètres par défaut.

---
*Lien vers le suivi : [todo.md](../../todo.md)*
