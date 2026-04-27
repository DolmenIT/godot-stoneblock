# [IP-032] Système de Groupes d'Ennemis (Template & Génération)

Transformation de `SB_EnemyGroup_VShmup` en un outil de Level Design puissant permettant de gérer des vagues d'ennemis de manière centralisée.

## User Review Required

> [!IMPORTANT]
> - La génération automatique supprimera les enfants existants du groupe pour reconstruire la formation selon le nouveau `enemy_count`.
> - Les modifications sur le groupe (ex: changer le modèle) seront répercutées en temps réel sur tous les enfants en mode éditeur.

## Proposed Changes

### [Enemies]
#### [MODIFY] [SB_EnemyGroup_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/enemies/SB_EnemyGroup_VShmup.gd)

- **Groupe "Enemy Template"** :
    - `enemy_scene`: La scène de base (par défaut `SB_Enemy_VShmup.tscn`).
    - `vessel_scene`: Le modèle 3D global pour le groupe.
    - `vessel_scale`: Échelle globale.
    - `health_override`: Points de vie communs.
    - `can_shoot`: Booléen pour activer/désactiver le tir sur tout le groupe.
    - `fire_interval`: Cadence du groupe.

- **Groupe "Generator"** :
    - `enemy_count`: Nombre d'ennemis à maintenir.
    - `rebuild_formation`: Bouton (bool setter) pour réinitialiser les enfants.

- **Logique** :
    - `_generate_enemies()` : Instancie les scènes, configure le `owner` pour la persistence dans le `.tscn`.
    - `_sync_children()` : Parcourt les enfants et applique les paramètres du template.
    - `update_formation()` : Étendu pour gérer dynamiquement les nouveaux enfants.

## Verification Plan

### Automated Tests
- Vérifier que changer `vessel_scale` sur le groupe change instantanément l'échelle visuelle des enfants dans la scène.
- Vérifier que `rebuild_formation` crée exactement `enemy_count` nœuds dans l'arbre.

### Manual Verification
- Dans l'éditeur, tester la création d'un groupe de 5 ennemis en "V_SHAPE" avec un seul clic.
- Valider que le tir est bien coupé sur tous les ennemis si `can_shoot` est décoché sur le groupe.
