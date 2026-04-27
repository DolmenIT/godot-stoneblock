# [IP-077] Contrôleur de Boss (Mouvement & Sync Z)

L'objectif est d'assurer une entrée en scène fluide pour le boss et un maintien à distance constante de la caméra une fois sa position atteinte.

## Détails Techniques
- **Cible** : `SB_BossController_VShmup.gd`
- **Initialisation** : Recherche ascendante pour trouver le `GameMode` et récupération manuelle du `camera_pivot` pour éviter les race conditions de chargement.
- **Mouvement Z** : 
    - Le boss attend à sa position initiale.
    - Activation quand `distance_z < 60m`.
    - Accélération progressive (Reverse Thrust) entre -5m et 0m pour égaliser la vitesse de défilement mondiale.
- **Verrouillage Enfants** : Parcours récursif pour forcer `speed = 0` et `follow_group = true` sur tous les segments (Ailes, Scouts, etc.).

## État : Terminé ✅
- Implémentation validée en jeu.
- Debugs console actifs [BossDebug].
