# Résumé de Session : SHMUP HUD & Énergie
📅 **Date** : 2026-03-23

## 🎯 Objectifs
- Implémenter un système d'énergie pour le vaisseau.
- Créer un HUD modulaire chargé dynamiquement.
- Corriger le bug de portée des projectiles en scrolling.
- Unifier la configuration des viewports en "No-Code".

## 🛠️ Réalisations
- **HUD Modulaire** : Création de `res://demo/demo1/hud/hud.tscn` utilisant un `TextureProgressBar` avec des assets fournis par l'utilisateur.
- **Gestion Énergie** :
    - Régénération : 2% / s.
    - Coût Tir : 1%.
    - Coût Tonneau : 20%.
- **Fix Projectiles** : Parentage au `Camera_Pivot` pour que les tirs héritent du scroll du monde.
- **Refactoring** : Tous les viewports (`Background`, `Mainground`, `Bloom`, `UI`) sont désormais gérés par `@export` avec des fallbacks automatiques dans le code sil ils ne sont pas liés manuellement.
- **"No-Code"** : Les composants (Gamepad, HUD) se connectent à leurs cibles par **Nom** uniquement.

## 💾 Sauvegarde
- Commit Git effectué et poussé sur `main`.
- Documentation `/ia` mise à jour (`todo.md`, `memory_ia.md`, `rules_ia.md`).
