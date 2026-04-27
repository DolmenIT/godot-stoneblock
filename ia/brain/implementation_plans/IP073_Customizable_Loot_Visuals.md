# [IP-073] Système de Loot Personnalisable (Shmup)

Planification de la refactorisation du système de Loot pour permettre une personnalisation visuelle via des scènes externes.

## 🧭 Objectif
Différencier les loots des étincelles d'impact en permettant l'utilisation de modèles 3D spécifiques (vaisseaux, cristaux, orbes) tout en conservant la logique de base (magnétisme, friction, collecte).

## 📋 Détails de l'Implémentation

### 1. Script de Base (SB_Loot_Base.gd)
- **Ajout d'exports** :
    - `visual_scene` (PackedScene) pour le modèle 3D.
    - `visual_scale` et `visual_rotation` pour les ajustements fins.
- **Logique** :
    - Masquage des meshs par défaut si `visual_scene` est présent.
    - Instanciation du nouveau visuel dans un pivot de rotation.
    - Propagation récursive du Bloom Layer 13.

### 2. Organisation (Cosmic HyperSquad)
- Encourager l'utilisation d'héritage de scènes dans `res://cosmic-hypersquad/pickups/`.

## 🧪 Plan de Vérification
- Vérifier que les loots traditionnels (cubes) fonctionnent toujours par défaut.
- Vérifier qu'un loot avec `visual_scene` affiche bien le bon modèle et tourne correctement.
- Vérifier que le magnétisme cible toujours le joueur.
