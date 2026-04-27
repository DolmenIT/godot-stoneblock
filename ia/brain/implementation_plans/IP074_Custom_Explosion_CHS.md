# [IP-074] Explosion Personnalisée (Cosmic HyperSquad)

Planification de la personnalisation de l'explosion pour Cosmic HyperSquad, utilisant une texture de fumée spécifique tout en héritant de la base StoneBlock.

## 🧭 Objectif
Différencier les explosions de vaisseaux pour le jeu Cosmic HyperSquad en utilisant un visuel de fumée plus "arcade" et artistique.

## 📋 Détails de l'Implémentation

### 1. Scène Héritée (CHS)
- **Scène** : `res://cosmic-hypersquad/effects/SB_Explosion_VShmup_CHS.tscn`
- **Héritage** : `res://stoneblock/effects/SB_Explosion_VShmup.tscn`
- **Changements** :
    - Surcharge du matériau de la `draw_pass_1`.
    - Albedo Texture : `res://cosmic-hypersquad/assets/smoke-explode.png`.
    - Transparency : `Alpha`.
    - Shading : `Unshaded`.

### 2. Logique Particules
- Conserver le code de nettoyage `GDScript_cleanup` de la scène de base pour que l'explosion s'auto-détruise après l'émission.

## 🧪 Plan de Vérification
- Prévisualiser `SB_Explosion_VShmup_CHS.tscn` dans l'éditeur.
- S'assurer que le rendu est transparent et utilise bien la nouvelle texture.
