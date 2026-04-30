# IP-139 : Détection Matérielle Intelligente (Auto-Bloom Logic)

## 🎯 Objectif
Empêcher l'activation du système de Bloom (Viewports multiples) sur les appareils mobiles dont le GPU est techniquement trop faible pour supporter la charge, même si le réglage est sur "AUTO".

## 🛠️ Modifications effectuées

### 1. `SB_QualityManager.gd`
- **Scoring Matériel** : Ajout d'une fonction `_detect_hardware_performance()` qui analyse :
    - **GPU** : Blacklist des puces faibles (`Mali-G5x`, `Adreno 61x`) et Whitelist des puces puissantes.
    - **RAM** : Seuil minimal de 4 Go recommandé pour les viewports multiples.
    - **CPU** : Nombre de coeurs comme indicateur de gamme.
- **is_hardware_bloom_capable()** : Nouvelle méthode publique pour interroger cette capacité.

### 2. `SB_ViewportManager.gd`
- **Vérification Hardware** : Dans `update_dynamic_resolution()`, le système vérifie désormais `is_hardware_bloom_capable()` avant d'autoriser l'activation physique des viewports de Bloom.
- Si l'appareil est marqué comme "LIMITED", le Bloom reste éteint physiquement, garantissant la fluidité.

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-30
- 🚀 **Lancé** : 2026-04-30
- ✅ **Terminé** : 2026-04-30

## 📝 Étapes d'exécution
1. [x] Créer la grille de score matérielle dans `SB_QualityManager`.
2. [x] Analyser le GPU au démarrage (`_ready`).
3. [x] Connecter la décision au rendu physique dans `SB_ViewportManager`.
