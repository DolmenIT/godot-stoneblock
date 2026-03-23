# 🚀 SB_Projectile_VShmup
Base pour tous les projectiles (joueur, ennemis, bonus) dans le mode SHMUP.

## Fonctionnalités
- Mouvement rectiligne basé sur une direction normalisée.
- Option de trajectoire oscillante (sinusoïdale) configurable.
- Auto-destruction par durée de vie (`life_time`) ou par distance (`distance_limit`).

## Utilisation
1. Créer une scène héritée pour vos types de projectiles (ex: `PlayerBullet.tscn`).
2. Configurer la vitesse et la direction.
3. Utiliser un nœud parent spécifique pour regrouper les instances de projectiles.
