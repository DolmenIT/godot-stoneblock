# [IP-072] Amélioration du Feedback d'Impact (Hits)

Planification d'une passe de polissage visuel sur les impacts de tirs.

## 🧭 Objectif
Rendre les tirs du joueur plus "percutants" en ajoutant des effets visuels localisés sur les ennemis touchés.

## 📋 Détails de l'Implémentation

### 1. Particules d'Impact (Sparks)
- **Scène** : `res://stoneblock/effects/SB_ImpactSpark_VShmup.tscn`
- **Type** : `GPUParticles3D`
- **Configuration** : One-shot, 8-12 particules, émission radiale.
- **VFX** : Matériau additif avec glow (Layer 11/12).

### 2. Logique de Hit (SB_Enemy_VShmup.gd)
- **Instanciation** : Déclenchée lors de `_on_area_entered` à la position du projectile.
- **Hit-Shake** : Légère vibration transversale de l'ennemi (Tween rapide).
- **Hit-Stop** : Micro-gel de frame via `Engine.time_scale` (Optionnel mais recommandé).

### 3. Synchronisation
- S'assurer que les particules sont rattachées au `Mainground` pour ne pas bouger avec la caméra mais rester à la position mondiale de l'impact.

## 🧪 Plan de Vérification
- Lancer `40_game_scene.tscn`.
- Tirer sur un ennemi.
- Vérifier l'apparition de l'éclat et le ressenti "solide" de l'impact.
