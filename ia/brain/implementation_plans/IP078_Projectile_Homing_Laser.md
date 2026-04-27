# [IP-078] Guidage Vertical Laser (Précision Boîte)

L'objectif est de s'assurer que les projectiles touchent les points faibles élevés du boss malgré l'inclinaison 3D.

## Détails Techniques
- **Cible** : `SB_Projectile_VShmup.gd`
- **Fenêtre de Détection** : Boîte relative (1m Largeur, 25m Hauteur, 10m Profondeur).
- **Logique "Forward"** : Utilisation du produit scalaire (`dot product`) pour ignorer les ennemis derrière le projectile.
- **Ajustement Y** : Interpolation (`move_toward`) vers le Y de la cible la plus proche dans le "couloir".
- **Vitesse** : 12m/s par défaut.

## État : Terminé ✅ (Logique) / ⚠️ (Debug Visuel)
- Guidage validé en jeu.
- Boîte de debug `debug_show_homing_box` invisible (problème de rendu/layers à corriger).
