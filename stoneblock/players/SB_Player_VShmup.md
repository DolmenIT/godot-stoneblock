# 🚀 SB_Player_VShmup
Contrôleur de vaisseau pour les jeux de type Shoot 'em Up vertical.

## Fonctionnalités
- Mouvement 2D fluide avec accélération et amortissement.
- Effet de "banking" (inclinaison visuelle) basé sur le mouvement latéral.
- Contraintes de position pour rester dans les limites de l'écran.
- Axe de mouvement : `X` pour l'horizontale, `Z` pour la verticale (Top-Down 3D).

## Utilisation
1. Placer le vaisseau dans la scène.
2. S'assurer que les actions `ui_left`, `ui_right`, `ui_up`, `ui_down` sont configurées dans l'Input Map.
3. Ajuster les limites (`horizontal_limit`, `vertical_limit`) pour correspondre à votre champ de vision (Frustum/Ortho).
