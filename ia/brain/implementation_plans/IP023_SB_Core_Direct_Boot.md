# [IP-023] Support du démarrage sans Splash Screen

Permettre à `SB_Core` de court-circuiter la séquence de démarrage (Splash Screen) si `use_stoneblock_splash` est désactivé.

## Proposed Changes

### [Core]
#### [MODIFY] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
- **Logique de démarrage (`_ready`)** :
    - Si `use_stoneblock_splash` est **false**, appeler immédiatement `load_scene_async(next_scene_path, false, 0.0, false)`.
- **Filtrage du Template (`_apply_core_template`)** :
    - Si `use_stoneblock_splash` est **false**, ignorer les nœuds nommés `Core_Scene` (ou contenant "Splash" / "Intro") provenant du template. Cela évite le lancement des timers de la séquence d'accueil.

## Verification Plan

### Automated Tests
_Aucun test disponible._

### Manual Verification
1. Dans l'inspecteur de `SB_Core` (dans `00_boot.tscn`), décocher **`Use StoneBlock Splash`**.
2. Lancer la scène `00_boot.tscn`.
3. Le jeu doit passer directement au menu principal (ou à la `next_scene_path`) sans afficher le logo StoneBlock ni faire de fondu initial.
4. Recocher la case et vérifier que le comportement normal (Splash de 1s + redirection) est toujours fonctionnel.
