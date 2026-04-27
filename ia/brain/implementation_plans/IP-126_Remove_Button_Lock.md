# 🧠 Plan d'Implémentation - IP-126 : Suppression du Verrouillage Éditeur (SB_Button_3d)

> [!NOTE]
> **Timecode** : 2026-04-27 ~20:38
> **Statut** : En cours 🚀

## 🎯 Objectif
Supprimer le système de verrouillage récursif dans l'éditeur pour `SB_Button_3d`, car il empêche l'utilisateur de valider ses modifications (notamment les couleurs) et n'est pas jugé nécessaire.

## 🛠️ Modifications
1.  **Fichier** : `demo/demo1/ui/SB_Button_3d.gd`
    - Supprimer l'appel à `_recursive_lock(self)` dans `_ready()`.
    - Supprimer la définition de la fonction `_recursive_lock(node: Node)`.
    - Supprimer la ligne `set_meta("_edit_lock_", false)`.

## 🧪 Validation
- Vérifier que les boutons et leurs enfants sont à nouveau sélectionnables et modifiables sans contrainte dans l'éditeur.
- S'assurer que les changements de propriétés (couleurs, etc.) sont bien conservés après sauvegarde.

---
*Lien vers le suivi : [todo.md](../../todo.md)*
