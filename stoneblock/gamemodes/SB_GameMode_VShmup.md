# 🚀 SB_GameMode_VShmup
Le coordinateur principal pour les jeux de type Shoot 'em Up vertical dans StoneBlock GDK.

## Fonctionnalités
- Orchestration des modules de caméra et de viewport.
- Gestion du défilement vertical constant (`Z`).
- Support pour 4 plans de parallax (`Background`, `Midground`, `Foreground`).
- Configuration centralisée de la projection et des vitesses de défilement.

## Structure de Scène recommandée
- SB_GameMode_VShmup
    - BackgroundViewportContainer / SubViewport / Camera3D
    - BackMidgroundViewportContainer / SubViewport / Camera3D
    - MainMidgroundViewportContainer / SubViewport / Camera3D
    - ForegroundViewportContainer / SubViewport / Camera3D

## Utilisation
1. Instancier `SB_GameMode_VShmup` dans votre scène de jeu.
2. Configurer les containers et viewports en respectant la hiérarchie ou en les assignant via l'inspecteur (si étendu).
3. Définir la `main_camera_speed` initiale.
