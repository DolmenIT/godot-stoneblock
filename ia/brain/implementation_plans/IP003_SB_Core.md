# [IP-003] Implémentation du Composant SB_Core - La Base Game Loop

L'objectif est de créer le composant **`SB_Core`**, qui servira de point d'entrée et de gestionnaire de la boucle de jeu pour tout projet **DAGX StoneBlock**.

## Architecture "High-End & Async" GDK
Pour rivaliser avec Unreal (Nanite/Lumen) et supporter un TPS type Fortnite, le `SB_Core` doit :
- **Chargement Asynchrone (Pierre Angulaire)** : Système intégré de chargement de ressources et de scènes en arrière-plan via `ResourceLoader.load_threaded_request`.
- **Gestionnaire de "World"** : Setup automatique de l'environnement (SDFGI/VoxelGI pour Lumen-like, VisibilityNotifier pour Nanite-like).
- **Data-Driven & No-Code** : Configuration via l'Inspecteur pour limiter le besoin de scripts utilisateur.
- **Support TPS** : Hooks pour les caméras et les contrôleurs de personnages.

## Changements Proposés

### [Component] Core / Foundation
#### [NEW] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
Le composant maître :
- Hérite de `Node`.
- Gère les phases du jeu (Pre-Init, Gameplay, Finalize).
- Expose des signaux pour la boucle de jeu (`on_tick`, `on_pause`).

### [Integration] Démo
#### [MODIFY] [demo1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- Ajout du nœud `SB_Core` comme premier enfant de `Demo1`.

## Plan de Vérification

### Tests Automatisés
- Lancement de la scène `demo1.tscn` et vérification des logs d'initialisation du `SB_Core`.

### Vérification Manuelle
- Vérifier que l'icône du `SB_Core` apparaît bien dans l'arborescence Godot (si l'icône existe ou via placeholder).

---
**🟥🟨 VALIDATION REQUISE :** _Êtes-vous d'accord pour que je crée ce composant `SB_Core` et que je l'ajoute à votre scène de démo ?_
