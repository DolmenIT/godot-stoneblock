# Walkthrough - [IP-031] Système de Réacteurs & Propulsion

Cette mise à jour ajoute une dimension visuelle et tactique au pilotage du vaisseau.

## Changements

### 📦 SB_EngineParticles.tscn
- Nouveau système de particules **GPUParticles3D**.
- Dégradé de couleur **Cyan/Bleu** stylisé.
- Émission proportionnelle à la poussée.

### 🚀 SB_Player_VShmup.gd
- **Réacteurs** : Instanciation dynamique de 2 réacteurs (positions ajustables via `engine_positions`).
- **Propulsion** :
    - **Boost (Z / Fleche Haut)** : Augmente la vitesse (x1.5) au prix de **10 pts d'énergie/sec**.
    - **Frein (S / Fleche Bas)** : Ralentit le vaisseau (x0.4) pour des esquives précises.
- **Feedback** : La taille et la quantité de particules diminuent au freinage et augmentent au repos/boost.

## Tests Effectués
- Validation de l'orientation (180° Y) pour que les flammes aillent vers l'arrière.
- Vérification de la consommation d'énergie (arrêt du boost si énergie < 0).
- Test du clamping des particules (`amount_ratio`).

## Utilisation
Les contrôles par défaut (Flèches Haut/Bas ou Stick Vertical) pilotent désormais la vitesse relative du vaisseau dans l'écran.
