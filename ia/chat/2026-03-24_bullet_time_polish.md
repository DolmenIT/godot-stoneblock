# Session 2026-03-24 : Bullet Time & Polish Shmup

## 🚀 Résumé de la Session
Cette session a été consacrée à l'ajout de mécaniques de feedback avancées pour le Shmup vertical (Démo 1), en se concentrant sur le **Bullet Time** sélectif.

## 🛠️ Travaux Effectués

### 1. Système de Temps (Slow Motion)
- **SB_TimeManager** : Création d'un gestionnaire centralisé pour `Engine.time_scale`.
- **Transitions fluides** : Utilisation de `Tween` pour l'entrée et la sortie du ralenti.
- **Modes de jeu** :
    - **Hit Slowmo** : 20% de vitesse pendant 1s (sélectif).
    - **Death Slowmo** : 10% de vitesse permanent lors du Game Over (global).

### 2. Visuels (Shaders)
- **SB_BulletTime_Overlay** : Shader de post-processing gérant :
    - Teinte bleue dynamique (Hit).
    - Teinte rouge intense (Mort).
    - Flou de bord (Vignette Blur) pour simuler la concentration/adrénaline.
- Intégration via un `ColorRect` invisible par défaut, piloté par le manager.

### 3. Gameplay & Correction
- **Compensation Flash** : Le vaisseau joueur multiplie ses propres mouvements par `1/time_scale` pour rester rapide pendant que le monde ralentit.
- **Correction Camera** : Le Screen Shake et le suivi horizontal ignorent désormais le `time_scale` pour éviter toute sensation de lourdeur.
- **Game Over Clean** : Les ennemis cessent immédiatement de tirer lors de la défaite.
- **Équilibrage** : Durée d'invulnérabilité du joueur étendue à **2 secondes**.

## 📋 État du Projet
- **Démo 1 (Shmup)** : Très polie, gameplay "arcade" moderne validé.
- **Documentation** : Mise à jour de `ia/todo.md` et `rules_ia.md` (règle !save).
- **Prochaine étape** : Système de vagues (`SB_WaveController`) ou Boss de fin de niveau.

---
*Fin de session - Documentation archivée via !save.*
