# 📊 SB_SpriteProgressBar

Composant de barre de progression hautement configurable pour le Pixel Art.

## 🚀 Fonctionnalités
- **Rendu Pixel-Perfect** : Utilise le filtrage `NEAREST` et un snapping automatique des pixels pour éviter tout flou ou artefact de bordure.
- **Option `ignore_hud_scaling`** : Permet à la barre de compenser dynamiquement le scale de ses parents. Utile pour garder des barres nettes même quand le HUD change de taille pour s'adapter à l'écran.
- **Modes de Remplissage** : Supporte les 4 directions cardinales.
- **Types de Rendu** :
    - **Continu** : Texture unique clippée.
    - **Segmenté** : Utilisation de `SpriteFrames` pour dessiner des tuiles individuelles (ex: coeurs, segments d'énergie).
- **Safe Area** : Marges configurables en pixels pour le remplissage.

## 🛠️ Usage
1. Ajouter un nœud `SB_SpriteProgressBar`.
2. Assigner un `SpriteFrames` dans l'inspecteur.
3. Définir `anim_full` et `anim_empty`.
4. Activer `ignore_hud_scaling` si vous souhaitez que la barre reste à sa taille de design (pixels 1:1) indépendamment du HUD.

## ⚙️ Détails Techniques
- **Snapping** : Toutes les coordonnées de dessin (`_draw`) sont arrondies avec `round()` pour correspondre à la grille de l'écran.
- **Scale Compensation** : La barre recalcule son scale local dans `_process` par rapport au scale global de son parent (`get_global_transform().get_scale()`).
