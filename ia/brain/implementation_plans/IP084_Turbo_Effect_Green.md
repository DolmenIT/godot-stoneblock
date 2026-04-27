# [IP-084] Fix Overlay & Ajout Effet Turbo (Vert)

Nous allons corriger la détection de l'overlay et implémenter l'effet visuel vert pour le mode Turbo.

## User Review Required

> [!IMPORTANT]
> L'effet Turbo (Vert) sera activable via le Clic Droit du mode Debug actuel.
> La recherche de l'overlay sera simplifiée pour éviter les erreurs de chemin.

## Proposed Changes

### [Component] TimeManager

#### [MODIFY] [SB_TimeManager.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_TimeManager.gd)

- **Fix Recherche** : Remplacer la recherche par nom de scène par une recherche récursive plus large depuis le root ou via le singleton `SB_Core`.
- **Méthode `set_turbo_mode(active: bool)`** :
    - Si `true` : Change la `filter_color` du shader en Vert et anime l'intensité à 1.0 en 0.5s (comme demandé).
    - Si `false` : Désactive l'effet.

### [Component] GameMode

#### [MODIFY] [SB_GameMode_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_VShmup.gd)

- Appeler `SB_TimeManager.instance.set_turbo_mode(true/false)` dans la boucle du mode Turbo Debug.

## Verification Plan

### Manual Verification
- Lancer le jeu.
- Vérifier que le message d'erreur "Impossible de trouver l'overlay" a disparu lors d'un hit.
- Tester le Clic Droit : Le jeu doit accélérer et un halo vert doit apparaître en 0.5s.
