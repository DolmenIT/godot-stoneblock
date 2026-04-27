# [IP-031] Système de Réacteurs & Propulsion

Ajout d'effets visuels de réacteurs (particules) et d'une mécanique de propulsion (Accélération/Freinage) pour le vaisseau joueur.

## User Review Required

> [!IMPORTANT]
> - L'accélération consommera une portion fixe d'énergie par seconde.
> - Le freinage permettra de mieux esquiver mais limitera la mobilité offensive.
> - Les particules seront automatiquement modulées (taille/quantité) selon l'effort du moteur.

## Proposed Changes

### [VFX]
#### [NEW] [SB_EngineParticles.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/effects/SB_EngineParticles.tscn)
- Système de particules `GPUParticles3D`.
- Look stylisé : Gradient de couleur (Bleu/Cyan vers Orange/Transparent) pour simuler la chaleur.
- Émission en cône vers l'arrière du vaisseau.

### [Player]
#### [MODIFY] [SB_Player_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/players/SB_Player_VShmup.gd)
- **Exports** :
    - `engine_points`: Array de Vector3 pour positionner les réacteurs sur le modèle.
    - `thrust_particle_scene`: Scène des particules.
    - `boost_speed_mult`: Multiplicateur de vitesse en accélération.
    - `brake_speed_mult`: Multiplicateur en freinage.
    - `energy_cost_boost`: Coût en énergie par seconde.
- **Logique** :
    - Instanciation des particules aux points définis.
    - Gestion des touches (Z/S ou Stick Vertical) pour moduler la vitesse.
    - Mise à jour de l'intensité des particules via `amount_ratio` ou un paramètre de shader.

## Verification Plan

### Automated Tests
- Vérifier que l'énergie descend lors du maintien de la touche d'accélération.
- Vérifier que les particules s'orientent correctement avec le vaisseau (suivi du pivot).

### Manual Verification
- Tester le ressenti du freinage pour les esquives de précision.
- Valider l'esthétique des flammes de réacteurs.
