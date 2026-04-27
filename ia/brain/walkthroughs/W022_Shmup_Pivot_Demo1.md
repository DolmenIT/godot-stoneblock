# 🛸 Walkthrough : Pivot Démo 1 - Shoot 'em Up Vertical

Ce walkthrough documente la transformation de la Démo 1 en un prototype fonctionnel de Shoot 'em up vertical utilisant le GDK StoneBlock.

## Architecture Modulaire (StoneBlock Shmup)

Nous avons porté et adapté la logique de **Cosmic HyperSquad** dans une structure propre au GDK StoneBlock, organisée par catégories dans `res://stoneblock/`.

### Composants GDK créés :
1.  **SB_GameMode_VShmup** : Coordinateur central qui orchestre les caméras et les viewports.
2.  **SB_CameraManager_VShmup** : Gère 4 caméras parallax (`Background`, `Midground`, `Foreground`) avec défilement fluide.
3.  **SB_ViewportManager_VShmup** : Gère les `SubViewports` et l'optimisation de la résolution dynamique.
4.  **SB_Player_VShmup** : Contrôleur de vaisseau avec accélération, limites d'écran et effet de "banking" (inclinaison).
5.  **SB_Projectile_VShmup** : Système de base pour les tirs avec support pour trajectoires oscillantes.
6.  **SB_Scroll_VShmup** : Composant pour le défilement infini de décors (ex: champ d'étoiles).

## Scène de Jeu (Demo 1)

La scène `res://demo/demo1/40_game_scene.tscn` a été entièrement reconstruite :
- **Structure 4-couches** : Utilisation de 4 SubViewports superposés pour un effet de profondeur réel sans interférence de rendu (parallax pur).
- **Vaisseau Joueur** : Placé dans la couche `MainMidground`. Utilisez les flèches et `Espace` (ou `Entrée`) pour tester les contrôles et le tir.
- **Décor de test** : Un champ d'étoiles défilant en arrière-plan via `SB_Scroll_VShmup`.

## Résultats de validation
- [x] Défilement vertical constant fonctionnel.
- [x] Mouvement du joueur limité aux bords de l'écran.
- [x] Effet de roulis (banking) fluide lors des déplacements latéraux.
- [x] Tir de projectiles (instanciation dynamique) à cadence réglable.
- [x] Structure de dossiers conforme aux directives utilisateur.

---
*Note : Pour modifier la vitesse de défilement globale, ajustez `main_camera_speed` sur le nœud `Demo1_Shmup`.*
