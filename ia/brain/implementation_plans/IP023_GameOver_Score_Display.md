# [IP-023] Polissage UI Game Over : Affichage du Score Final

Ajout du récapitulatif des performances (Score et Combo Max) sur l'écran de défaite de la Démo 1 (Shmup).

## Proposed Changes

### [StoneBlock UI]

#### [MODIFY] [SB_GameOver_VShmup.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_GameOver_VShmup.tscn)
- **Structure** : Ajout d'un `VBoxContainer` ou de deux `Label` sous le titre "DÉFAITE" pour afficher le Score et le Combo.
- **Style** : Utilisation d'une police plus petite que le titre, couleur dorée/blanche pour le score.
- **Script (Embedded)** : 
    - Ajout d'une fonction `set_results(score: int, combo: int)` pour mettre à jour les labels.

### [StoneBlock GameMode]

#### [MODIFY] [SB_GameMode_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_VShmup.gd)
- **Logique** : Dans `trigger_game_over()`, après l'instanciation de la scène :
    - Appeler `go.set_results(score, combo_max)` (ou via les membres si le script est typé).

## Verification Plan

### Manual Verification
1. Lancer la scène `res://demo/demo1/40_game_scene.tscn`.
2. Détruire quelques ennemis pour augmenter le score et le combo.
3. Se laisser percuter par un ennemi pour déclencher le Game Over.
4. Vérifier que l'écran affiche désormais :
    - "DÉFAITE" (Titre)
    - "SCORE FINAL : [Valeur]"
    - "COMBO MAX : [Valeur]"
5. Cliquer sur "RECOMMENCER" pour vérifier que tout se reset correctement.

**🟥🟨 VALIDATION REQUISE :** _Souhaitez-vous un style visuel spécifique pour ces scores (ex: animation de décompte, particules) ou un affichage textuel simple suffit-il pour le moment ?_
