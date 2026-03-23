# [IP-002] Création du Composant de Base SB_GameManager

L'objectif est de poser les fondations du GDK **DAGX StoneBlock** avec un composant central, le `SB_GameManager`, capable de piloter le jeu à la manière d'un "GameInstance" ou "GameMode" dans Unreal Engine.

## Objectif "Concurencer Unreal"
Pour rivaliser avec Unreal, notre base doit offrir :
- **Centralisation** : Gestion des paramètres globaux et des états de jeu.
- **Registre d'Assets** : Intégration avec `GameConfig` pour un accès propre aux ressources.
- **Workflow Développeur** : Facilité d'utilisation via l'Inspecteur Godot (Export Variables).
- **Extensibilité** : Permettre d'ajouter des modules (UI, Audio, Terrain) facilement.

## Changements Proposés

### [Component] Core / Architecture
Création d'un dossier `core/` pour les composants structurels.

#### [NEW] [SB_GameManager.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_GameManager.gd)
Composant singleton (ou racine de scène) gérant :
- L'initialisation du GDK.
- La configuration globale (Debug, Qualité).
- L'accès simplifié aux autres modules `SB_*`.

## Plan de Vérification

### Tests Automatisés
- Vérification du chargement du script et de son exposition dans l'éditeur.

### Vérification Manuelle
- Validation par l'utilisateur du rôle du `SB_GameManager` comme "nerve central" du projet.

---
**🟥🟨 VALIDATION REQUISE :** _Êtes-vous d'accord pour que le "SB_GameManager" soit notre composant de base, ou préférez-vous une approche type "SB_Actor" ?_
