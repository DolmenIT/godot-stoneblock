# 🧠 Plan d'Implémentation - IP-128 : Création du composant SB_Image3D

> [!NOTE]
> **Timecode** : 2026-04-27 ~21:55
> **Statut** : En cours 🚀

## 🎯 Objectif
Transformer le script `SB_BackgroundFit` en un composant plus générique et puissant nommé `SB_Image3D`. Ce composant permettra d'afficher des images dans l'espace 3D avec une gestion automatique du mesh, du ratio d'aspect et de l'orientation.

## 🛠️ Modifications
1.  **Nouveau Fichier** : `gdk-stoneblock/visual/SB_Image3D.gd`
    - Héritage : `Node3D`.
    - Propriétés exportées :
        - `texture` : La texture à afficher.
        - `view_mode` : `FRONT` (face caméra) ou `TOP_DOWN` (au sol).
        - `stretch_mode` : `STRETCH` ou `COVER` (préserve le ratio).
        - `size` : Dimensions manuelles.
        - `auto_fit_camera` : Si activé, se comporte comme l'ancien `BackgroundFit` (remplit l'écran).
    - Logique interne :
        - Création automatique d'un `MeshInstance3D` interne (QuadMesh).
        - Utilisation d'un shader simple supportant le mode `COVER`.
        - Mise à jour de l'orientation selon `view_mode`.

2.  **Migration** :
    - Supprimer `gdk-stoneblock/visual/SB_BackgroundFit.gd` (ou le remplacer par une redirection si nécessaire, mais ici on privilégie le nouveau composant).

## 🧪 Validation
- Tester le placement d'une image simple en mode `TOP_DOWN` (décor au sol).
- Tester le mode `auto_fit_camera` pour s'assurer que les fonds d'écran fonctionnent toujours.
- Vérifier que le changement de texture met bien à jour le visuel immédiatement.

---
*Lien vers le suivi : [todo.md](../../todo.md)*
