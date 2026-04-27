# IP-066 : Refonte de SB_FloatingText pour l'Inspecteur

## User Review Required

> [!IMPORTANT]
> **EXPOSITION TOTALE** : Tous les paramètres magiques seront remplacés par des `@export` pour permettre un réglage fin via l'inspecteur Godot.

## Proposed Changes

### [MODIFY] [SB_FloatingText_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/effects/SB_FloatingText_VShmup.gd)
- Ajout des exports suivants :
    - `@export_group("Animation Échelle")` : `start_scale`, `max_pop_scale`, `final_scale`, `pop_duration`.
    - `@export_group("Animation Mouvement")` : `duration`, `lift_height`, `spread_angle`.
    - `@export_group("Animation Rotation")` : `max_rotation_degrees`, `use_orbital_rotation`.
    - `@export_group("Rendu")` : `font_color`, `outline_color`, `outline_size_override`.
- Mise à jour de `_ready()` pour consommer ces variables dynamiquement.

## Open Questions

- Faut-il ajouter un paramètre pour l'atténuation (Easing) du mouvement ?
