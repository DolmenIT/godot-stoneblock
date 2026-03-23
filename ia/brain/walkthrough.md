# Walkthrough - Consolidation Demo 1

Toutes les modifications du plan **IP-021** (Consolidation Demo 1) ont été implémentées et vérifiées statiquement.

## Changements Effectués

### ⚙️ Core (SB_Core.gd - Refined)
- **Exports Nettoyés** : Les propriétés `core_template_path`, `use_threaded_loading` et `tick_rate` ne sont plus exposées.
- **Simplification UI** : `auto_setup_world` a été supprimé. `min_splash_time` (float) a été remplacé par une case à cocher **`use_stoneblock_splash`** (booléen).
- **Nettoyage des Chemins** : `next_scene_path` et `loading_scene_path` sont maintenant vides par défaut dans le Core.
- **Direct Boot** : Si `use_stoneblock_splash` est désactivé, le Core ignore le bloc `Core_Scene` (timers/splash) et charge immédiatement la scène suivante.
- **Correctif État** : La machine à état reste en `LOADING` pendant le boot direct pour assurer le bon fonctionnement du `_process`.
- **Logique** : Si le splash est activé, une durée minimale de 1s est respectée.
- **Placeholder** : La fonction vide `_setup_world_environment()` a été retirée.

### 🖥️ Menus
- **Bouton \"Jouer\"** : Suppression du message de log erroné qui indiquait "Options non disponibles".
- **Bouton \"Quitter\"** : Message de log corrigé en "Fermeture de l'application...".
- **Sélecteur de Niveaux** : Le bouton \"Level 1 - Stage 1\" redirige maintenant correctement vers `res://demo/demo1/40_game_scene.tscn`.

### 🏃 Gameplay (Platformer)
- **W019 - Dolmenir : L'Éveil (Plateforme 3D)** : [ia/brain/walkthroughs/W019_Dolmenir_Platformer_Base.md](./walkthroughs/W019_Dolmenir_Platformer_Base.md)
- **W022 - Pivot Démo 1 : Shoot 'em Up Vertical** : [ia/brain/walkthroughs/W022_Shmup_Pivot_Demo1.md](./walkthroughs/W022_Shmup_Pivot_Demo1.md)
- **40_game_scene.tscn** :
    - Nœud racine renommé en `Demo1_Platformer`.
    - Ajout d'une plateforme supplémentaire (`Platform4`) en hauteur.
    - Intégration de deux collectibles (`Galette_1`, `Galette_2`) utilisant le composant `SB_Pickable` pour tester la récolte de "Magie".

## Preuves de Vérification

### 📋 Vérification Statique
- [x] `SB_Core.gd` : Pas de `@export` sur les variables sensibles.
- [x] `10_menu_principal.tscn` : Structure des nœuds `SB_Log` corrigée.
- [x] `11_menu_levels.tscn` : Chemin de redirection vers `demo1` vérifié.
- [x] `40_game_scene.tscn` : Toutes les `ExtResource` sont présentes et les nouveaux nœuds sont opérationnels.

## Résultat
La Démo 1 est désormais une base saine et cohérente pour un petit platformer, avec un Core simplifié et des menus fonctionnels.