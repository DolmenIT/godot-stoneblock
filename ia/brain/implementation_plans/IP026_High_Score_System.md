# [IP-026] Système de High Scores (Top 5)

Implémentation d'un système de classement persistant (High Scores) pour conserver les 5 meilleurs scores entre les sessions de jeu.

## Proposed Changes

### [StoneBlock Core]

#### [NEW] [SB_HighScores.gd](file:///d:/Projets/DAGX StoneBlock/current/dagx-stone-block/stoneblock/core/SB_HighScores.gd)
- Gestionnaire de scores persistants.
- **Architecture** : Singleton indépendant (`static var instance`) intégré comme enfant/frère dans `00_boot.tscn`.
- **Méthodes** :
    - `get_scores()` : Retourne la liste triée des scores.
    - `submit_score(score: int, player_name: String)` : Ajoute un score et garde le top 5.
    - `save_scores()` / `load_scores()` : Persistence via `user://highscores.json`.

### [StoneBlock UI]

#### [NEW] [SB_HighScoreBoard.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_HighScoreBoard.tscn)
- Composant UI pour afficher le tableau des scores (Nom + Score).
- Utilisable dans l'écran de Game Over ou le Menu Principal.

#### [MODIFY] [SB_GameOver_VShmup.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_GameOver_VShmup.tscn) (Script associé)
- Lors de l'affichage du score final, soumettre le score au `SB_HighScores`.
- Afficher le `SB_HighScoreBoard` à côté des résultats de la session.

## Verification Plan

### Automated Tests
- Script de test unitaire pour vérifier le tri et la persistence du Top 5.

### Manual Verification
1. Faire une partie et atteindre un score élevé.
2. Vérifier que le score apparaît dans le Top 5 sur l'écran de Game Over.
3. Redémarrer le jeu et vérifier que le Top 5 est toujours présent.
