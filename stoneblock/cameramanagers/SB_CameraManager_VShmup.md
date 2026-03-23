# 🎥 SB_CameraManager_VShmup
Ce composant gère les caméras parallax pour le mode Shoot 'em Up vertical.

## Fonctionnalités
- Gestion de 4 couches de caméras : `Background`, `Back Midground`, `Main Midground`, `Foreground`.
- Support des zones de vitesse dynamiques basées sur la position `Z`.
- Interpolation fluide des vitesses lors des changements de zone.

## Utilisation
1. Attacher ce script à un nœud enfant d'un GameMode.
2. Passer les références des caméras lors de l'initialisation.
3. Configurer les `speed_zones` dans l'inspecteur.
