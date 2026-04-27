# 🧠 Plan d'Implémentation - IP-129 : Restauration et Correction de SB_Image3D

> [!NOTE]
> **Timecode** : 2026-04-27 ~22:05
> **Statut** : En cours 🚀

## 🎯 Objectif
Réintégrer les paramètres manquants (`Texture Aspect Ratio`, `Padding Factor`) dans `SB_Image3D` et corriger le bug de redimensionnement qui rend l'image minuscule.

## 🛠️ Modifications
1.  **Fichier** : `gdk-stoneblock/visual/SB_Image3D.gd`
    - Réintroduire `@export var texture_aspect_ratio: float = 0.0` (0 = auto).
    - Réintroduire `@export var padding_factor: float = 1.0`.
    - Rendre la détection de la caméra plus robuste :
        - Vérifier que le viewport et la caméra sont valides.
        - Gérer les divisions par zéro.
        - S'assurer que le mode `auto_fit_camera` force un rafraîchissement correct lors du redimensionnement de la fenêtre.
    - Correction du bug de taille : S'assurer que si la détection de caméra échoue dans l'éditeur, on garde une taille par défaut raisonnable au lieu de `1x1`.

## 🧪 Validation
- Tester le redimensionnement de la fenêtre en jeu.
- Vérifier dans l'éditeur que l'image remplit bien l'espace avec `auto_fit_camera`.
- Valider que le `Padding Factor` permet bien d'ajouter un surplus de sécurité.

---
*Lien vers le suivi : [todo.md](../../todo.md)*
