# [IP-027] Démo 1 : Polissage & Variété (Shmup)

## Objectif
Améliorer le ressenti de jeu (Juice), la survie du joueur et la variété du combat dans la Démo 1.

## Changements Implémentés

### 🛡️ Survie & HUD
- **Santé / Bouclier** : Séparation en deux jauges. Bouclier (25) avec régénération après 2s de calme. Santé (100) protégée.
- **HUD Superposé** : ShieldBar affichée par dessus la HealthBar (Cyan sur Rouge/Vert).
- **Textures** : Utilisation des actifs originaux `life_bar_background.png` et `life_bar_foreground.png`.

### 💥 Juice & Effets
- **Camera Shake** : Tremblement lors des impacts via `SB_CameraManager_VShmup`.
- **Hit Flash** : Shader spatial avec émission. Blanc pour les coups reussis, Rouge Glowing pour l'alerte pré-tir ennemi.

### 🔫 Combat & Power-ups
- **Projectiles Ennemis** : Création de la scène et logique de tir.
- **Triple Shot** : Power-up activable pendant 8s via le pickup `SB_Pickup_TripleShot`.
- **World_Scroll_Pivot** : Nouveau point d'ancrage Z-only pour stabiliser les trajectoires de tir en scrolling.

## Bilan
Système de combat arcade complet et stable.
✅ **Terminé le 2026-03-24**
