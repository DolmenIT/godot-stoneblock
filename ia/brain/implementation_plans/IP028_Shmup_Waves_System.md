# [IP-028] Extension SHMUP : Vagues d'Ennemis & Formations

Ce plan vise à structurer le gameplay du Shmup en remplaçant le spawn aléatoire par un système de vagues ordonnées et de formations visuelles.

## Proposed Changes

### [SHMUP Engine]

#### [NEW] [SB_WaveController.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_WaveController.gd)
- **Rôle** : Gérer la progression du niveau par vagues successives.
- **Fonctionnalités** :
    - Déclenchement de vagues basées sur le temps ou le nettoyage de la vague précédente.
    - Support de formations prédéfinies :
        - `LINE` : Ennemis alignés horizontalement.
        - `V_SHAPE` : Point vers l'avant ou l'arrière.
        - `RANDOM_CLUSTER` : Groupe aléatoire (système actuel).
    - Signal `all_waves_completed` pour transitionner vers un Boss.

#### [MODIFY] [SB_GameMode_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_VShmup.gd)
- **Désactiver** `_handle_spawning` par défaut si un `WaveController` est présent.
- **Intégrer** le `WaveController` comme enfant optionnel ou composant assigné.

### [Content]

#### [MODIFY] [demo1_shmup.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1_shmup.tscn)
- Ajouter le nœud `SB_WaveController` sous le `GameMode`.
- Configurer une séquence de 3 vagues de test :
    - Vague 1 : 3 ennemis en formation `V_SHAPE`.
    - Vague 2 : 5 ennemis en formation `LINE`.
    - Vague 3 : Nuée aléatoire (Cluster).

## Verification Plan

### Manual Verification
1. Lancer la scène `res://demo/demo1/demo1_shmup.tscn`.
2. Vérifier que les ennemis apparaissent désormais par "vagues" distinctes plutôt qu'en flux continu aléatoire.
3. Valider visuellement les formations :
    - Les ennemis en V doivent former un triangle pointe vers le joueur.
    - Les ennemis en ligne doivent être bien espacés horizontalement.
4. Vérifier que le score et les combos fonctionnent toujours normalement avec ce nouveau système.
