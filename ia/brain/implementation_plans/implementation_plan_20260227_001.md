# Plan d'Implémentation - Support des Imports Externes (20260227_001)

L'objectif est de permettre au `import_manager` de scanner un dossier source situé en dehors du répertoire `res://`. Le dossier cible est : `D:\Projets\Cosmic HyperSquad\imports\`.

## 📅 Timeline
- **Début** : 2026-02-27 ~17:22
- **Statut** : 🔄 **IN PROGRESS**

## Changements Proposés

### [Component] Import Manager (Addon)

#### [MODIFY] [import_manager_view.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/addons/import_manager/import_manager_view.gd)
- Adapter `_on_scan_usages_pressed` pour détecter l'utilisation réelle des assets.
- La logique doit :
    1. Scanner tous les fichiers du projet (`.tscn`, `.gd`, `.tres`, etc.) à la recherche de chaînes `res://assets/`.
    2. Pour chaque item de l'arbre d'imports, calculer son chemin cible théorique dans `res://assets/`.
    3. Si ce chemin cible est trouvé dans les références du projet, cocher l'item.
- Cela permet de n'exporter que ce qui est réellement utilisé dans le projet.
- **Auto-collapse** : Ajouter une passe finale pour replier (`collapsed = true`) tous les dossiers qui ne contiennent aucun élément coché (directement ou récursivement).

## Vérification
- Scanner le dossier externe.
- Vérifier que les exports vers `res://assets/` fonctionnent toujours.
- Vérifier que les remappages d'UID et de liens textuels sont corrects.
