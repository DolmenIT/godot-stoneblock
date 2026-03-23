# 📺 SB_ViewportManager_VShmup
Gère l'affichage et l'optimisation des SubViewports pour le mode SHMUP.

## Fonctionnalités
- Gestion de 4 couches de viewports : `Background`, `Back Midground`, `Main Midground`, `Foreground`.
- Résolution dynamique basée sur le framerate (FPS).
- Configuration automatique du `stretch` et du `scaling_3d_mode`.

## Utilisation
1. Attacher ce script à un nœud enfant d'un GameMode.
2. Passer les références des containers et viewports lors de l'initialisation.
3. Ajuster les échelles (`max_scale` / `min_scale`) selon les performances visées.
