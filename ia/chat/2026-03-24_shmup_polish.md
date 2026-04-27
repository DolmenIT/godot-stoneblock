# 📓 Notes de Session - DAGX StoneBlock

## 📅 Session 2026-03-24 : Polissage Shmup (Demo 1)

### 🚀 Objectifs
- Rafraîchir le gameplay de la Démo 1 (Shmup).
- Ajouter un système de bouclier et de santé robuste.
- Introduire des Power-ups et du feedback visuel.

### 📑 Décisions & Actions
- **Mécanique de Vie** : Adoption d'un système à deux niveaux (Bouclier temporaire de 25 pts + Santé permanente de 100 pts).
- **HUD** : Choix de superposer le bouclier sur la vie pour un gain de place et une meilleure lecture.
- **Projectiles** : Correction structurelle via un `World_Scroll_Pivot` pour aligner les tirs avec le scrolling vertical sans dérive horizontale.
- **Power-up** : Premier bonus opérationnel (Triple Shot) via un système de loot sur les ennemis.

### ✅ Statut
- Démo 1 polie et prête pour l'intégration de Boss ou d'autres niveaux.
- Tous les systèmes de base du Shmup sont validés.
