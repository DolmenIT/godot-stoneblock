# [IP-062] Animation d'Entrée du Vaisseau (Intro)

Ce plan vise à ajouter une séquence cinématique simple au démarrage du niveau : le vaisseau entre par le bas de l'écran et vient se positionner à 25% de la hauteur totale en 3 secondes.

## User Review Required

> [!IMPORTANT]
> - Pendant l'animation (3 secondes), les contrôles du joueur et le tir seront **désactivés**.
> - L'animation utilise le système de `Tween` de Godot pour un mouvement fluide (Ease Out).
> - Le point de destination est calculé dynamiquement par rapport aux limites verticales définies (`vertical_limit`).

## Proposed Changes

### Child-Node Component Approach

Le composant sera conçu pour être glissé en **enfant direct** du nœud `Player_VShmup`. Cela facilite l'accès aux stats de limites du joueur et permet d'activer/désactiver l'intro scène par scène.

#### [NEW] [SB_IntroAnimator_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/visual/SB_IntroAnimator_VShmup.gd)
-   **duration** (float) : 3.0s.
-   **target_height_percent** (float) : 25% du bas.
-   **Logic** :
    -   Au `_ready`, récupère la référence du parent (`Player_VShmup`).
    -   Lit la `vertical_limit` du parent pour calculer les positions.
    -   Désactive les contrôles via `parent.set_controls_enabled(false)`.
    -   Tween la `position.z` (locale au parent de l'avion, donc synchronisée avec le scroll).
    -   Réactive les contrôles à la fin.

### Player Logic Updates

#### [MODIFY] [SB_Player_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/players/SB_Player_VShmup.gd)
-   Ajouter `var controls_enabled: bool = true`.
-   Ajouter `func set_controls_enabled(v: bool)`.
-   Bloquer le mouvement et le tir dans `_process` si `controls_enabled` est faux.

### Game Mode Sync

#### [MODIFY] [SB_GameMode_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_VShmup.gd)
- S'assurer que le défilement du monde commence immédiatement (ou attendre la fin de l'intro ? L'utilisateur n'a pas précisé, mais généralement le scroll commence direct).
- Le joueur doit continuer à subir le `position.z -= scroll_delta` même pendant l'intro pour rester synchronisé avec la caméra.

## Open Questions

- Souhaitez-vous que le défilement du niveau (scrolling) attende que le vaisseau soit en position, ou doit-il commencer dès le chargement ? Par défaut, je vais le laisser commencer immédiatement.

## Verification Plan

### Manual Verification
- [ ] Lancer la scène de jeu.
- [ ] Vérifier que le vaisseau apparaît bien du bas.
- [ ] Chronométrer environ 3 secondes pour l'arrivée.
- [ ] Vérifier que les contrôles ne répondent pas pendant la montée.
- [ ] Vérifier qu'une fois arrivé, le vaisseau est parfaitement contrôlable.
