# [IP-071] Refactorisation de la Barre de Vie 3D (Ennemis)

Planification de la refactorisation de la barre de vie ennemie en composant 3D indépendant (IP-071).

## 🧭 Objectif
Corriger les problèmes visuels de la barre de vie des ennemis (absence d'arrière-plan et centrage forcé lors de la réduction) en créant un composant 3D réutilisable et robuste.

## 📋 Détails de l'Implémentation

### 1. Composant SB_HealthBar3D
- **Script** : `res://stoneblock/ui/SB_HealthBar3D.gd`
- **Type** : `Node3D`
- **Structure** :
    - `Background` (MeshInstance3D - BoxMesh noir)
    - `Foreground` (MeshInstance3D - BoxMesh vert/jaune/rouge)
    - `Label3D` (PV actuels/max)
- **Logique** :
    - Calcul de la position X du Foreground pour simuler un ancrage à gauche : `pos.x = (width/2) * (ratio - 1)`.
    - Mise à jour de la couleur selon le ratio (Vert > 0.5, Jaune > 0.2, Rouge <= 0.2).

### 2. Migration SB_Enemy_VShmup
- **Script** : `res://stoneblock/enemies/SB_Enemy_VShmup.gd`
- **Changements** :
    - Instanciation de `SB_HealthBar3D` au lieu de la construction manuelle.
    - Synchronisation automatique des PV lors du `take_damage`.

## 🧪 Plan de Vérification
- Lancer `40_game_scene.tscn`.
- Vérifier l'arrière-plan noir.
- Vérifier la réduction vers la gauche.
