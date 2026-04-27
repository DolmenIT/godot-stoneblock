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

## 🛠️ Travaux en cours : Stabilité & Architecture UI (IP-111/112/113/114) - 2026-04-26
- **Composants** : `SB_Core`, `SB_BloomConfig`, `SB_Button`, `SB_Label`, `SB_Box`, `SB_ThemeManager`, `SB_BloomTagger`, `SB_ScreenAnchor3D`, `SB_WarpStarfield`.
- **Réalisations** : 
    - **Nettoyage GDScript** : Correction massive de warnings (Narrowing conversion, Shadowing, Incompatible Ternary, Unused Variables/Parameters).
    - **Intégrité UTF-8** : Restauration des accents français dans les scripts (SB_Core, SB_BloomConfig, etc.) pour respecter la RÈGLE D'OR.
    - **Correction Chargement** : Renommage de `10_mainmenu_scene.tscn` en `10_menu_principal_3d.tscn` pour corriger l'erreur critique de chargement.
    - **Fix Bouton Quitter** : Remise en fonctionnement du bouton quitter dans `10_mainground.tscn` (Demo 1).
    - **Annotation @tool** : Mise en cohérence de `SB_ThemeStyle` avec sa classe de base.
- **RÈGLE RÉCENTE** : Toujours utiliser des `StringName` (&"") dans les ternaires impliquant des propriétés de thème Godot pour éviter les erreurs d'incompatibilité.


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

## Moteur de Peinture 3D (MockupFlow - Demo 2)
- **Algorithme Silk Smooth (EMA)** : Lissage exponentiel de la pression et de la position pour un tracé organique sur Surface 3D.
- **Stamp Dynamique** : Génération en temps réel de la brosse avec paramètres de `Softness` (dureté des bords via falloff) et `Grain` (bruit procédural).
- **Architecture UI StoneBlock (Standard 2026)** :
    - **Structure de Composant Standard** : Tout composant (`SB_Button`, `SB_Box`, `SB_Label`) hérite de `PanelContainer` et suit la hiérarchie : `Root` -> `_SBMargin (SB_Margin.tscn)` -> `Contenu interne`.
    - **StoneBlock CSS (Inspecteur)** : Propriétés natives pour Margins (SB_Margin), Padding (StyleBox dynamique) et Sizing (min_width/height).
    - **Propagation de Thème** : La propriété `theme_type_variation` est transmise aux nœuds internes (Label, Button) automatiquement par script.
    - **SB_Box** : Remplace l'ancien `SB_Div`. Gère marges et paddings proprement.
    - **SB_Label** : Version instanciable du Label Godot, calquée sur le schéma SB_Button.
- **Gestion de Calques** : Instanciation dynamique de `SB_CanvasLayer3D` (Texture 300 DPI par défaut, fond blanc).

## Système de Thème Hiérarchique (Style-as-Nodes)
- **SB_ThemeManager** : Centralise la vérité du design dans `00_boot.tscn`. Scanne récursivement ses enfants `SB_ThemeStyle`.
- **SB_ThemeCache (IP-113)** : Permet la persistance des propriétés 3D hors-scène pour le support de l'éditeur (Cache .tres).
- **Variations** : Le nom du nœud devient le nom de la *Type Variation* (ex: "Title").
- **Injection** : Application automatique aux `Control` des scènes chargées par le `SB_Core`.
- **Règle de Nettoyage** : Supprimer systématiquement les `theme_override` locaux pour laisser le manager piloter l'unité visuelle.

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
- `SB_LoadingBar` : Barre de progression (ProgressBar) connectée au SB_Core (No-Code).
- `SB_LoadingLabel` : Label de statut connecté au SB_Core (No-Code).
- `SB_BloomSelector3D` : Bloom sélectif sur Render Layer **11** (standard projet, migration depuis layer 10 faite le 03/03).
- **Hierarchy** : Toujours consulter `stoneblock/REPERTOIRE_CALQUES.md` avant de modifier les `CanvasLayer`.
- **Terrain System (Zéro-Fichier)** : Tout est centralisé dans `TerrainLevelBundle` (`.res`). Plus de fichiers individuels. Les jupes (89°) gèrent les jonctions visuelles via le padding UV. Le système garantit l'extraction vers le bundle avant le nettoyage pour le `.tscn` (Fix Ctrl+S).
- **Prop Placement & Grid** : Le pas de grille (`props_grid_step`) est centralisé dans le `TerrainHeightmapManager`. Il est partagé entre le mode manuel (`PropPlacementView`) et l'Auto-Props. L'Auto-Props utilise exclusivement le mode "Grid Scan" avec un jitter par passe pour le naturel.
- **Architecture SHMUP (Demo 1)** :
    - **Modularité** : Séparation stricte entre `Background`, `Mainground`, `Bloom` et `UI` via des Viewports dédiés (`SB_ViewportManager_VShmup`).
    - **Dynamic Content** : Les scènes de niveau et le HUD sont chargés via des exports `@export` dans le GameMode.
    - **Orientation Portrait (IP-037/038/041)** : Forçage via `@export var initial_orientation` dans le `SB_Core`. Redimensionnement et CENTRAGE AUTO de la fenêtre sur Desktop en mode test, avec sécurité anti-débordement (marge 100px).
    - **Dépendances Circulaires (IP-042)** : Découplage des types explicites (`SB_GameMode_VShmup`, `SB_Player_VShmup`) dans `SB_Enemy_VShmup.gd` et `SB_Player_VShmup.gd` pour résoudre l'erreur "Parse Error: Busy" de Godot 4.
    - **Qualité Visuelle (IP-039/040)** : Options `use_anti_aliasing` (MSAA 2x + FXAA) et `show_fps_counter` (Compteur dynamique) dans le Core.
    - **Contrôles Tactiles** : Fix de la dérive (drift). Découplage de l'inclinaison visuelle (banking) et de la physique. Arrêt immédiat au relâchement.
    - **Input No-Code** : `SB_Input_Gamepad` et `SB_Input_TouchMouse` résolvent leurs cibles par **Nom** (`target_name`).
    - **Système d'Énergie & Survie** : Géré par le joueur (`SB_Player_VShmup`), synchronisé avec un HUD via des **Noms Uniques (`%`)** pour une détection robuste.
    - **Adaptive HUD (Portrait/Landscape)** : 
        - `hud_landscape.tscn` (PC/Tablette).
        - `hud_portrait.tscn` (Mobile/TATE).
        - Choix dynamique dans `SB_GameMode_VShmup.gd` selon l'orientation du Core (`SBOrientation`).
    - **SB_SpriteProgressBar** : Nouveau moteur de rendu custom (Pixel-Perfect) remplaçant `TextureProgressBar`. Supporte le mode segmenté (tuiles) et continu.
    - **Système de Santé/Bouclier** : Bouclier (25) régénérable après 2s, Vie (100) protégée dessous. HUD superposé.
    - **Projectile Fix** : Rattachement au `World_Scroll_Pivot` (Z-only) pour des trajectoires droites en scrolling.
- **Système d'Ennemis** : Spawning par groupes. Alerte de tir via shader HitFlash (Color.RED + Emission). 15% chance de drop Triple Shot. 3 slots de loot avec plage de quantité Aléatoire (Min/Max). **Grouping** : Tous les ennemis s'ajoutent au groupe `"enemies"` pour le guidage des tirs.
- **Boss Controller (IP-077)** : Mouvement Z synchronisé avec défilement mondial via `camera_pivot`. Poussée inverse (Reverse Thrust) calculée sur une plage de 5m pour une entrée en scène fluide à 0m distance. Activation à 60m.
- **Guidage Laser (IP-078)** : Projectiles avec auto-ajustement Y. Boîte de détection Forward-only (1m x 10m x 25m). Priorité à l'objet le plus proche sur l'axe frontal.
- **Bloom Sélectif (IP-050 - Update Complexe)** :
    - **Architecture** : Rendu isolé sur Layer 11 -> `BloomViewport` -> `BloomViewportContainer` -> **`SB_BloomBlur.gdshader`**.
    - **Extension Globale** : Tous les éléments "lumineux" partagent le Layer 11 :
        - Projectiles Joueur/Ennemi (+ ghosts).
        - Réacteurs avion (`SB_EngineParticles.tscn`, amount réduit à 24).
        - Loots/Pickups via classes de base (`SB_Loot_Base`, `SB_Pickable`).
    - **Automatisation** : Les classes de base ramassables propagent récursivement le Layer 11 à leurs enfants visuels dans `_ready()`.
- **SB_BloomConfig** : Pilote globalement l'aura via `blur_radius` (def: 5.0) et `bloom_intensity` (def: 1.0) avec précision 0.01.
    - **Qualité Variable (IP-104)** : Sélecteur `BlurQuality` (FAST: 16, BALANCED: 81, ULTRA: 169 samples) disponible par calque.
    - **Gaussian Optimized (IP-108)** : Découplage du sigma-kernel du radius de scan. Garantit un falloff doux et massif même à haut radius (Refonte mathématique du 18/04).
    - **Oscillation Fix (IP-109)** : Désaccouplement du BloomManager (Pre-Draw) et du BloomConfig (Process) pour permettre les pulsations de radius sans conflit de priorité.
    - **⚠️ RÈGLE World3D** : Maintenir `own_world_3d = false` sur le `BloomViewport`.
    - **SB_BloomMiniView (IP-108)** : Debug visuel exploitant désormais le `ShaderMaterial` du container source. Le flou est fidèlement rendu dans les miniatures.
    - **Optimisation Performance (IP-051, IP-104)** :
        - Inversion Hiérarchie : Bloom rendu par-dessus le Mainground (forcé via Layer 100) pour un éclat maximal.
        - Détection Mobile : `SB_Core.is_mobile` et `auto_optimize_mobile` (Désactivation AA et Bloom sur mobile).

- **Système de Thèmes 3D (IP-107/112)** :
    - **Centralisation** : Les presets `buy_button3d`, `upgrade_button3d` et `promo_button3d` gèrent l'aspect visuel (teinte, émission) et le texte par défaut.
    - **Harmonisation Physique** : Valeur par défaut de `base_scale` calée à **35.0** pour tous les boutons 3D de l'Armurerie (évite les sauts visuels au rafraîchissement).
    - **Lien Dynamique** : Les scripts (`SB_Armory_Logic.gd`) ne manipulent plus que `style_class_name`.

- **Power-ups** : `SB_Pickup_TripleShot` active 3 tirs en éventail (duration=8s).
- **Loot Dynamique** : Fragments d'énergie expulsés puis attirés par le joueur.
- **Scoring & Combo** : Logique centralisée dans le GameMode (10 pts + 10%/combo). Le `combo_label` du HUD est masqué au profit de l'IP-066.
- **Feedback & Indicateurs (IP-065, IP-066)** :
    - **Indicateurs 360°** : `SB_TargetIndicator_VShmup.gd` (Label3D avec shader chroma-key). Suit les cibles hors-champ avec clamping et rotation. Configurable via `warning_max_distance`.
    - **Textes Flottants (Combo Kill)** : `SB_Floating_Text_CHS.tscn` (Scène héritée dans `cosmic-hypersquad/effects/`). Affiche "X KILL" à la mort. Billboard et Tween (0.4s) vers le haut.
- **Bullet Time (IP-029)** :
    - `SB_TimeManager` : Gère le ralenti (Hit: 0.2 / Mort: 0.1) via Tweens.
    - **Sélectivité** : Compensation de vitesse chez le Joueur et la Caméra (Shake/Follow) pour garder une réponse en temps réel (`delta / Engine.time_scale`).
    - **FX (Overlay)** : Shader `SB_BulletTime_Overlay` (Filtre bleu au hit, Rouge à la mort, vignette blur intensifiable).
- **Suivi Caméra (IP-030)** :
    - **Deadzone** : Zone morte horizontale `follow_deadzone_x` évitant les micro-mouvements.
    - **Vitesse Proportionnelle** : Suivi via `Distance * Facteur` pour un rattrapage fluide.
    - **Debug** : Visualisation 3D Cyan (25% opacité) intégrée.
- **Réacteurs & Propulsion (IP-031)** :
    - **Visual** : Système `SB_EngineParticles.tscn` (GPUParticles3D) avec modulation dynamique (`amount_ratio`).
    - **Config** : Nombre, écartement et offsets Y/Z éditables dans l'inspecteur via `@tool`.
    - **Gameplay** : Mécanique de Boost (vitesse x1.5, conso 10/s) et Frein (vitesse x0.4) sur l'axe vertical.
- **Groupes d'Ennemis (IP-032)** :
    - **Template** : Propriétés communes (Modèle, PV, Tir, Cadence) centralisées dans `SB_EnemyGroup_VShmup.gd`.
    - **Générateur** : Bouton `rebuild_group` pour instancier dynamiquement `enemy_count` enfants selon la formation choisie.
    - **Sécurité** : Alerte visuelle de tir désactivée si l'ennemi ne peut pas tirer.
- **Intégration Tiled (IP-067)** :
    - **Plugin** : **YATI** (Yet Another Tiled Importer) recommandé pour Godot 4.3+. Gère les textures animées.
    - **Workflow** : Importation des fichiers `.tmx` en tant que scènes héritées dans le `Mainground` 3D.
    - **Installation** : Dossier `addons/YATI` à placer à la racine `res://`. (Correction détectée nécessaire depuis `GDScript/addons/`).
- **Level Design** : Placement MANUEL des ennemis privilégié. Pas de système de vagues (`IP-028` abandonné).
- **Menu Workshop / Boot** : Fix de l'affichage du bouton Workshop et de la redirection de scène depuis `00_boot.tscn` (résolution des conflits d'UID).
- **Game Over Suite** : État `is_game_over` (public) stoppe le monde + UI Overlay + Arrêt des tirs ennemis.
- **Architecture No-Code (IP-044)** : Chargement (`90_loading_scene.tscn`) géré par composants individuels (`SB_LoadingBar`, `SB_LoadingLabel`) sans aucun script monolithique à la racine.
- **Stabilité Technique** : Correction des erreurs de typage de signaux (conversion `Node`/`Resource` via `Object`) et suppression systématique des warnings d'inutilisation (unused parameters/variables).

- [x] **Optimisation Android (IP-051)** : Détection auto, désactivation Bloom/AA, réduction particules. ✅
- [x] **Contrôleur de Boss** : Mouvement dynamique, Sync Z et Reverse Thrust implémentés. ✅
- [x] **Guidage Laser Projectiles** : Auto-correction de hauteur Y pour les cibles surélevées. ✅
- [x] **Isolation Transitions (IP-111)** : Nettoyage synchrone et localisation du bloom. ✅
- [x] **Sélecteur de Niveaux 3D (IP-112)** : Refonte layout 3x3 et format multiline. ✅
- [x] **Support Thème Éditeur (IP-113)** : Cache de styles persistant pour le rendu WYSIWYG. ✅
- [x] **Hitbox Bouton 3D (IP-114)** : Alignement et synchronisation de l'Area3D sur le mesh. ✅
- [ ] **IA Ennemis Avancée** : Comportements de groupe et évitement.
- [ ] **DEBUG VISUEL (Box Homing)** : Fix de la visibilité de la boîte de détection debug dans le Shmup Viewport. ⚠️
