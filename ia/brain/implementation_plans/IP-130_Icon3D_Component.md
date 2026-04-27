# 🧠 Plan d'Implémentation - IP-130 : Composant SB_Icon3D

> [!NOTE]
> **Timecode** : 2026-04-27 ~23:59
> **Statut** : Terminée ✅

## 🎯 Objectif
Créer un composant `SB_Icon3D` ultra-simplifié qui affiche une texture sur un plan XY tout en préservant son ratio d'aspect original via un paramètre `base_scale`.

## 🛠️ Modifications
1.  **Nouveau Fichier** : `gdk-stoneblock/visual/SB_Icon3D.gd`
    - Hérite de `Node3D`.
    - Gère un `MeshInstance3D` interne avec `QuadMesh`.
    - Propriétés : `texture`, `albedo_color`, `base_scale`.
    - Logique de calcul automatique de la taille du mesh pour respecter le ratio (Paysage/Portrait).

## 🧪 Validation
- Tester l'instanciation dans une scène.
- Vérifier que changer la texture ajuste bien les proportions du plan.
- Valider que le `base_scale` agit comme multiplicateur global.

---
*Lien vers le suivi : [todo.md](../../todo.md)*
