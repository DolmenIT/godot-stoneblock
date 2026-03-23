# Mémoire IA d'Antigravity

## Environnement
- **OS** : Windows
- **Moteur** : Godot 4.6.1.stable
- **Shell** : PowerShell / CMD (Get-ChildItem / dir)
- **Commandes BANnies (Windows)** : `fd`, `grep`, `ls`, `rm -rf`, `cp -r`.
- **Alternatives** :
    - `grep` -> `Select-String`
    - `fd`/`find` -> `Get-ChildItem -Recurse`
    - `ls` -> `dir` ou `ls` (alias PS ok mais attention aux flags)
    - **SÉCURITÉ RM** : INTERDICTION de supprimer des fichiers via console (voir règle 56 de rules_ia.md).
- **Taille** : Maintenir ce fichier (`memory_ia.md`) sous **200 lignes**.

## Conventions du Projet CHS
- **Asset Registry** : Tous les assets doivent être appelés via `GameConfig.get_asset_path(name, category)`.
- **Import Manager** : Gère la synchronisation entre le dossier externe `imports` et le dossier interne `assets`.
- **Organisation des dossiers** :
    - `res://assets/images/` : Pour les textures, sprites, UI.
    - `res://assets/models/` : Pour les fichiers .glb.
    - `res://assets/musics/` : Pour les musiques.
    - `res://assets/sounds/` : Pour les bruitages.

## Tâches récurrentes / Points d'attention
- Toujours vérifier l'existence des fichiers `.import` lors des manipulations d'assets.
- Éviter les chemins en dur `res://assets/...` dans les scripts `.gd`, les remplacer par le registre.
- Dans les scènes `.tscn`, s'assurer que les liens pointent vers les emplacements définitifs dans `res://assets/`.
- **SÉCURITÉ (CRITIQUE)** : Interdiction absolue d'éditer, d'injecter du texte ou de SUPPRIMER des fichiers via console pour tout ce qui appartient au projet (Leçon du 12/03/2026).

## Architecture Core & Boot
- **Persistent Wrapper** : `SB_Core.gd` est présent dans `00_boot.tscn`. Il utilise un template (`SB_Core.tscn`) pour s'auto-configurer.
- **Simplification UI** : `auto_setup_world` supprimé. `min_splash_time` (float) remplacé par **`use_stoneblock_splash`** (bool).
- **Direct Boot** : Si `use_stoneblock_splash` est désactivé, le Core ignore le bloc `Core_Scene` (timers) et charge immédiatement `next_scene_path`.
- **Hierarchy Split** : 
    - `Core_Scene` : Contient l'intro/splash. Ignoré en mode Direct Boot, sinon détruit après transition.
    - `Active_Scene` : Contient la scène de jeu chargée.
- **Async Loading** : `load_scene_async` avec `use_loader` optionnel. Les chemins par défaut sont vides (`""`) pour rester neutre.

- **Stats System** : Un dictionnaire `_stats` et un signal `stats_updated(stats)` centralisent le score/magie.
- **Composants StoneBlock (SB)** :
- `SB_BlurScreen` : Flou progressif lié au temps. Calque standard : **111** (sous UI Story).
- `SB_FadeToColor` : Fondu progressif lié au temps. Calque standard : **121** (sur UI Story).
- `SB_BloomSelector3D` : Bloom sélectif sur Render Layer **11** (standard projet, migration depuis layer 10 faite le 03/03).
- **Hierarchy** : Toujours consulter `stoneblock/REPERTOIRE_CALQUES.md` avant de modifier les `CanvasLayer`.
- **Terrain System (Zéro-Fichier)** : Tout est centralisé dans `TerrainLevelBundle` (`.res`). Plus de fichiers individuels. Les jupes (89°) gèrent les jonctions visuelles via le padding UV. Le système garantit l'extraction vers le bundle avant le nettoyage pour le `.tscn` (Fix Ctrl+S).
- **Prop Placement & Grid** : Le pas de grille (`props_grid_step`) est centralisé dans le `TerrainHeightmapManager`. Il est partagé entre le mode manuel (`PropPlacementView`) et l'Auto-Props. L'Auto-Props utilise exclusivement le mode "Grid Scan" avec un jitter par passe pour le naturel.
