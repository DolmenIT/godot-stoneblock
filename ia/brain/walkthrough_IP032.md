# Walkthrough - [IP-032] Système de Groupes d'Ennemis (Template)

Cette modification transforme le `SB_EnemyGroup_VShmup` en un véritable outil de Level Design pour structurer vos vagues d'ennemis.

## Changements

### 🛸 SB_EnemyGroup_VShmup.gd
- **Générateur Automatique** :
    - Saisissez `enemy_count` (ex: 5).
    - Cochez `rebuild_group` pour instancier instantanément les ennemis selon la `formation_type` choisie.
    - Les ennemis sont créés comme de vrais nœuds de scène (persistence lors de la sauvegarde).
- **Template Centralisé** :
    - Changez `vessel_scene` (le modèle) sur le groupe, et tous les enfants se mettent à jour.
    - Contrôlez la santé (`health`), l'échelle (`vessel_scale`) et la cadence de tir (`fire_interval`) globalement.
    - Activez/Désactivez le tir pour tout le groupe avec `can_shoot`.

### 👾 SB_Enemy_VShmup.gd
- Ajout de setters (`@tool`) pour que les changements de modèle et d'échelle soient répercutés visuellement dans la foulée dans l'éditeur Godot.

## Utilisation recommandée
1. Placez un `SB_EnemyGroup_VShmup` dans votre scène.
2. Réglez le template (ex: Vaisseau Nexus, Santé 2, Tir OFF).
3. Choisissez `Formation: CIRCLE` et `Enemy Count: 8`.
4. Cliquez sur `rebuild_group` -> Votre flotte est prête !

## Tests Effectués
- Validation du `owner` (sauvegarde propre dans le .tscn).
- Test de la synchronisation dynamique du modèle en mode éditeur.
- Vérification du clamping et de la cadence de tir.
