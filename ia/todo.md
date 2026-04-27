# 📋 TODO & Bilan de Migration DAGX StoneBlock

## 🚀 ROADMAP GLOBALE (1-39)

### 🟦 Cycle SHMUP (Demo 1 & Extensions)
#### **[x] Demo 1 : Boot & Vertical Shmup** ✅
- 📅 Demandé : 2026-03-23
- 🚀 Lancé : 2026-03-23
- ✅ Terminé : 2026-03-23
- **Composants** :
    - `SB_Player_VShmup` : (Mouvement 3D, Banking, Barrel Roll) ✅
    - `SB_Input_Gamepad` : (Mapper explicite No-Code par nom) ✅
    - `SB_CameraManager_VShmup` : (Edge Clamping & Limits) ✅
    - `SB_Enemy_VShmup` : (Système d'ennemis, Spawning, Loot) ✅
    - `SB_ScoreSystem` : (Combo, Scoring Arcade, HUD) ✅
    - `SB_GameOver` : (Suite complète, World Pause, UI) ✅
- **Objectif** : Transformer la démo de base en un prototype de Shoot 'em up vertical pilotable à la manette avec combat et progression.

#### **[x] Demo 1.1 : Ennemis & Formations (Level Design)** ✅
- 📅 Demandé : 2026-03-21
- 🚀 Lancé : 2026-03-26
- ✅ Terminé : 2026-03-31
- **Objectif** : Placer manuellement des groupes d'ennemis pour structurer le défi du niveau (Pas de WaveController). ✅

#### **[ ] IP-115 : Rendu MultiMesh Hybride (Optimisation Draw Calls)**
- 📅 Demandé : 2026-04-22
- 🚀 Lancé : -
- ✅ Terminé : -
- **Objectif** : Réduire drastiquement le nombre de Draw Calls sur mobile en groupant les vaisseaux.

#### **[ ] IP-116 : Optimisation SB_StandardModel (Partage Intelligent)**
- 📅 Demandé : 2026-04-22
- 🚀 Lancé : -
- ✅ Terminé : -

#### **[ ] IP-117 : Registre Global de Matériaux (Cache Centralisé)**
- 📅 Demandé : 2026-04-22
- 🚀 Lancé : -
- ✅ Terminé : -

#### **[ ] Demo 1.2 : Boss & Fin de Niveau**
- 📅 Demandé : 2026-03-21
- 🚀 Lancé : -
- ✅ Terminé : -

#### **[ ] Demo 1.3 : Power-ups & Upgrades**
- 📅 Demandé : 2026-03-21
- 🚀 Lancé : -
- ✅ Terminé : -

#### [x] IP-105 : Carte d'Amélioration 3D (Square Edition) ✅
- 📅 Demandé : 2026-04-17
- 🚀 Lancé : 2026-04-17
- ✅ Terminé : 2026-04-17
- **Objectif** : Transformer le clone de la carte vaisseau en carte d'amélioration carrée avec stats dynamiques et description. ✅

#### [x] IP-106 : Menu des Niveaux 3D (Diegetic UI) ✅
- 📅 Demandé : 2026-04-17
- 🚀 Lancé : 2026-04-17
- ✅ Terminé : 2026-04-17
- **Objectif** : Transformer le menu de sélection des niveaux en interface 3D diégétique avec cartes interactives et panneau d'aperçu dynamique. ✅

---



## ✅ Ce qui a été fait aujourd'hui (2026-04-27)
### Système de Preview 3D Avancé (IP-123)
- [x] **SB_NineSlice3D** : Système Double UV, Masquage Alpha et Moteur de Fusion (8 modes). ✅
- [x] **SB_Button_3d** : Intégration des contrôles de fusion et correction des erreurs d'éditeur. ✅
- [x] **SB_Button_3d** : Mise à jour des paramètres par défaut (Mix 0.1, Mode Screen). ✅
- [x] **SB_Button_3d** : Ajout d'un slider "Hue Shift" (0-360) complémentaire aux teintes. ✅
- [x] **SB_Button_3d** : Suppression du verrouillage récursif (Edit Lock) pour libérer l'édition. ✅
- [x] **SB_Button_3d** : Support du mode "Fill" (Aspect Cover) pour les previews afin d'éviter l'étirement. ✅
- [x] **SB_Image3D** : Nouveau composant remplaçant BackgroundFit, gérant lui-même son mesh et son orientation (Front/TopDown). ✅
- [x] **SB_Icon3D** : Nouveau composant ultra-simple pour afficher des icônes en respectant leur ratio. ✅
- [x] **SB_Image3D** : Correction du bug de redimensionnement et restauration des paramètres Ratio/Padding. ✅
- [x] **Git** : Nettoyage de l'historique (image sous licence) et correction du `.gitignore`. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-26)
### Système d'Ancrage HUD 3D (IP-121)
- [x] **SB_ScreenAnchor3D** : Nouveau composant d'ancrage aux bords de l'écran avec détection automatique de la taille (AABB) et pivot intelligent. ✅
- [x] **Modes de Coordonnées** : Support des axes Normal (Y+ Haut) et Inversé (Y- Haut, Standard UI). ✅
- [x] **SB_VirtualScreen3D** : Définition d'une zone de travail fixe (88x50 par défaut) pour l'éditeur, permettant un placement stable sans influence du zoom. ✅
- [x] **Hybridation Éditeur/Jeu** : Bascule automatique entre le VirtualScreen (aide au placement) et le Viewport réel (en jeu). ✅
- [x] **Fix Bouton Quitter** : Remise en fonctionnement du bouton quitter dans `10_mainground.tscn` (Demo 1). ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-25)
### Système d'Overrides et Presets de Qualité (IP-120)
- [x] **Presets de Qualité** : Ajout des modes (Ultra, Medium, Low, Very Low) avec configuration automatique. ✅
- [x] **Overrides Manuels** : Support du forçage individuel pour BG Scale, MG Scale, Bloom Scale et Bloom Mode. ✅
- [x] **SB_ViewportManager** : Intégration de la logique de court-circuit pour ignorer les calculs FPS si un forçage est actif. ✅

### Système Bloom Multi-Couleurs (IP-119 / Architecture Parent-Enfant)
- [x] **SB_BloomTagger_Color** : Nouveau nœud pour définir des zones de bloom par couleur. ✅
- [x] **Multi-Slot Shader** : Le tagger génère désormais un shader spatial gérant jusqu'à 16 couleurs sur une seule surface. ✅
- [x] **Hierarchy Workflow** : Support des nœuds enfants pour une organisation claire (Bleu, Rouge, etc.). ✅
- [x] **Correction de Crashs** : Résolution des erreurs `has_shader_parameter` et des problèmes de chemins `res://stoneblock`. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-23)
### Restauration de l'Intégrité UTF-8 & Standardisation UI (IP-118)
- [x] **Nettoyage UTF-8 (Core/UI/Anim)** : Restauration manuelle de l'encodage sur `SB_Core`, `SB_ThemeManager`, `SB_Button`, `SB_Label`, `SB_Particles3D` et `SB_Trail3D`. ✅
- [x] **Respect "No-Script-Modification"** : Toutes les modifications ont été effectuées manuellement pour protéger les fichiers `.tscn`. ✅
- [x] **Standardisation Hiérarchie** : Mise à jour des règles `rules_ia.md` pour imposer une structure stricte (`SB_Config` pour configs, `SB_Manager` pour managers). ✅
- [x] **Walkthrough Final** : Génération de la documentation de fin de session dans `ia/brain/walkthrough.md`. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-21)
### Correction Hitbox Bouton 3D (IP-114)
- [x] **Alignement Rotation** : Synchronisation de l'Area3D sur celle du mesh (Background) dans le composant `SB_Button_3d`. ✅
- [x] **Mise à jour Dynamique** : Sécurité ajoutée dans le script pour garantir que la collision suit le transform du mesh par défaut. ✅
- [x] **Documentation & Outils** : Ajout du raccourci `!salut` en tant qu'équivalent de `!ia.md`. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-20)
### Isolation des Scènes & Correction Bloom (IP-111)
- [x] **Nettoyage Synchrone Core** : Implémentation de `remove_child` avant `queue_free` dans `SB_Core.gd`. Élimine les conflits de recherche (`find_child`) lors des transitions. ✅
- [x] **Localisation SB_BloomConfig** : Refonte de la recherche des viewports et environnements. Priorité à la scène locale (`owner`) pour éviter de configurer par erreur une scène en cours de suppression. ✅
- [x] **Validation Cycle** : Confirmation du bon fonctionnement du bloom dès le premier chargement (`Boot -> Splash -> Menu`). ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-18)
### Correction Visualisation Bloom (IP-108)
- [x] **Système de MiniViews** : Forçage de l'utilisation du `ShaderMaterial` du container source dans les miniatures. Le flou est désormais visible dans les fenêtres de debug. ✅
- [x] **Optimisation Shader Bloom** : Refonte de la répartition gaussienne. Découplage du sigma-kernel du radius de scan pour un falloff doux et massif même à haut radius. ✅

### Finalisation Thèmes Armurerie (IP-107)
- [x] **Migration SB_Armory_Logic** : Suppression des réglages de couleurs manuels au profit des presets `buy_button3d`, `upgrade_button3d` et `promo_button3d`. ✅
- [x] **Harmonisation Physique** : Alignement de l'échelle par défaut des boutons 3D (`base_scale`) à 35.0 pour éviter les sauts visuels dans l'Armurerie. ✅
- [x] **Configuration Scène** : Initialisation des `style_class_name` sur tous les boutons de `armory_3d_content.tscn`. ✅

### Correction Oscillation Bloom (IP-109)
- [x] **Désaccouplement Manager/Config** : Suppression de l'écrasement systématique des paramètres de flou lors du pre_draw. ✅
- [x] **Priorisation de l'Animation** : Le script de BloomConfig protège désormais le radius s'il est en train d'osciller, garantissant un rendu fluide en jeu. ✅
- [x] **Réactivité Editor** : Ajout de setters sur les modes d'oscillation pour un feedback immédiat dans l'inspecteur Godot. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-17)
### Refonte Premium des Menus (IP-106)
- [x] **Composant SB_LevelCard_3d** : Création d'une carte de sélection premium avec miniature du niveau et feedbacks d'interaction. ✅
- [x] **Composant SB_LevelPreview_3d** : Panneau d'affichage large pour les détails du stage (Hologramme Large). ✅
- [x] **Architecture 3D Diégétique** : Migration de `11_menu_levels.tscn` vers un système multi-viewport avec Bloom sélectif. ✅
- [x] **Logique de Sélection Dynamique** : Mise à jour en temps réel de l'aperçu au survol des cartes. ✅
- [x] **Redirection Menu Principal** : Activation de l'expérience 3D depuis le bouton "Jouer". ✅

### Équilibrage Performance & Stabilité (Hangar)
- [x] **Moteur de Performance Hangar** : Allongement de `startup_delay` et `interpolation_smoothness` dans `SB_GameMode_MenuScreen.gd`. ✅
- [x] **Fix Tremblement UI** : Utilisation de `disable_physical_stretch` sur `SB_ShipCard` pour stabiliser le layout au survol. ✅
- [ ] **Stabilisation Résolution** : Ajout de la cadence et de la granularité dans `SB_ViewportManager_VShmup.gd`.

## ✅ Ce qui a été fait aujourd'hui (2026-04-12)
### Restauration SB_Button & Rétro-compatibilité
- [x] **Script Hybride SB_Button** : Support du mode "Direct" (sur nœud Button) et "Component" (sur PanelContainer). ✅
- [x] **Support Textures/Nineslice** : Réintroduction des propriétés `normal_texture`, `hover_texture`, `pressed_texture` et des marges de slice. ✅
- [x] **Déclenchement Enfants (Sous-événements)** : Les boutons appellent désormais automatiquement `start()` sur leurs enfants (Redirect, Timer, Fade) lors du clic. ✅
- [x] **Compatibilité Demo 1** : Restauration du fonctionnement de `11_menu_levels.tscn`. ✅
- [x] **Moteur Shader Premium (Cross-Fade)** : Réintégration du shader original pour un rendu nineslice de haute qualité et des transitions fluides entre les états. ✅
- [x] **Animations de Scale** : Restauration des effets de "gonflement" (hover) et "écrasement" (pressed) via Tweens. ✅

### 🐛 Bugs & Dette Technique
- [ ] **SB_Button Editor Refresh** : L'aperçu du texte dans le viewport de l'éditeur ne se met pas toujours à jour en temps réel lors de la modification dans l'inspecteur (nécessite un rechargement de scène/éditeur). [Priorité : Basse]

### Stabilisation de l'Architecture UI StoneBlock
- [x] **Composants Élite (SB_Button, SB_Box, SB_Label)** : Migration vers une architecture unifiée `PanelContainer` + `SB_Margin`. ✅
- [x] **StoneBlock CSS** : Implémentation des exports pour Margins, Padding et Sizing directement dans l'inspecteur. ✅
- [x] **Injection Physique Thème** : Adaptation du `SB_ThemeManager` pour propager marges et paddings hérités des thèmes. ✅
- [x] **Correction MockupEditor** : Nettoyage des nœuds Title et remplacement par le nouveau `SB_Label` modulaire. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-11)
### Système de Thème Hiérarchique (SB_ThemeManager)
- [x] **Architecture Style-as-Nodes** : Création du `SB_ThemeManager` et `SB_ThemeStyle` permettant de définir le thème via des nœuds dans `00_boot.tscn`. ✅
- [x] **Unification des Polices** : Centralisation de la taille de police (10px/12px) pour les `Label` et `Button` sans overrides manuels. ✅
- [x] **Injection Dynamique** : Mise en place du pont entre le Core et le ThemeManager pour appliquer le style lors de chaque chargement de scène. ✅
- [x] **Nettoyage UI** : Retrait des overrides locaux dans `MockupEditor.tscn` et `SB_BrushItem.tscn`. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-10)
### Studio Artistique & Moteur de Peinture (Demo 2)
- [x] **Moteur Silk Smooth** : Implémentation du lissage EMA et de la peinture haute fidélité. ✅
- [x] **Système de Brosses (12 catégories)** : Menu statique avec icônes (atlas 4x3) et labels, configuration automatisée. ✅
- [x] **Gomme & Nettoyage** : Ajout du mode gomme (peinture blanche) et du bouton "Vider" le calque. ✅
- [x] **Layout Header PRO** : Centrage parfait de la barre d'outils centrale via spacers équilibrés. ✅
- [x] **Nettoyage Assets** : Allègement radical du `.tscn` de Demo 2 et correction des imports d'images corrompus. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-08)
### Optimisation Bloom & Qualité Variable (IP-104)
- [x] **Modes de Qualité** : Implémentation de l'énumération `BlurQuality` (FAST, BALANCED, ULTRA) avec samples variables (16 à 169). ✅
- [x] **Sélectivité des Calques** : Possibilité de régler la qualité individuellement pour Long, Med et Short dans `SB_BloomConfig`. ✅
- [x] **Simplification Interface** : Suppression des modes de Blend superflus (on garde ADD) et du mode `On Top` (désormais standard). ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-07)
### Maîtrise des Matériaux PBR & Anti-Glossy (IP-079)
- [x] **Composant `SB_StandardModel.gd`** : Création d'un outil de nettoyage matériel pour forcer l'aspect mat/métallique sur les modèles importés (GLB). ✅
- [x] **Intégration Composition** : Ajout automatique du manager PBR sur le vaisseau des ennemis sans casser l'héritage `Area3D`. ✅
- [x] **Exports Avancés** : Ajout des modes Diffuse (Burley, Lambert) et Specular (GGX, Schlick). ✅
- [x] **Correction Godot 4** : Suppression des warnings de compatibilité `specular` via détection de type dynamique. ✅

### Styling Avancé & Coque Énergétique (IP-080)
- [x] **Teinte Albedo (Tint)** : Option pour colorer/teinter la texture originale directement depuis l'inspecteur ennemi. ✅
- [x] **Coque (Shell Shield)** : Implémentation d'une aura protectrice via `Next Pass` avec paramètre `Grow` (Épaisseur). ✅
- [x] **Effet Glow** : Option d'émission (éclat) sur la coque avec contrôle de l'intensité pour le Bloom. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-06)
### Contrôleur de Boss & Mouvement (IP-077)
- [x] **Verrouillage Z** : Implémentation du script `SB_BossController_VShmup.gd` pour synchroniser la position du boss avec le défilement de la caméra. ✅
- [x] **Fix Dérive (Segments)** : Forçage de `speed = 0.0` et `follow_group = true` sur tous les sous-composants du boss pour éviter qu'ils ne "s'échappent". ✅
- [x] **Balayage X (Sweep)** : Ajout d'un mouvement sinusoïdal paramétrable pour rendre le boss dynamique. ✅

### Architecture Boss Multi-Segments (IP-076)
- [x] **Signal `destroyed`** : Ajout d'un signal standard dans `SB_Enemy_VShmup.gd` pour la communication Parent/Enfant. ✅
- [x] **Composant `SB_BossPart`** : Création du script de bouclier récursif (indestructible tant qu'un enfant ennemi existe). ✅
*   [x] **Intégration Boss 1** : Mise à jour des scènes `BODY`, `LEFT_ARM`, `RIGHT_ARM` avec les points de vie (1000/250) et la logique de protection. ✅
- [x] **Feedback Visuel** : Ajout d'un flash Cyan lors des impacts sur une partie protégée. ✅

### Système de Loot Aléatoire (IP-075)
- [x] **Plage de Quantité (Min/Max)** : Remplacement du nombre de loot fixe par une plage aléatoire paramétrable dans l'inspecteur. ✅
- [x] **Logique `randi_range`** : Mise à jour de l'instanciation pour varier les drops à chaque destruction d'ennemi. ✅

### Guidage Vertical Projectiles (IP-078)
- [x] **Auto-Height Homing** : Implémentation du guidage vertical laser (1m x 25m x 10m). ✅
- [x] **Logique "Forward-Only"** : Priorité à la cible la plus proche devant le projectile. ✅
- [ ] **DEBUG VISUEL (BUG)** : La boîte de détection `debug_show_homing_box` n'est pas visible malgré les forcages de layers (1, 11, 12, 13). À corriger. ⚠️
    - *Note Technique* : La boîte est créée via `MeshInstance3D` dans `_apply_vfx_settings` (call_deferred).

## ✅ Ce qui a été fait aujourd'hui (2026-04-04)
### Amélioration Visual Feedback (IP-066)
- [x] **Effet Pop Dynamique** : Ajout d'une animation d'échelle (rebond) et d'un trajet en arc pour les textes flottants. ✅
- [x] **Rotation Aléatoire** : Implémentation d'une inclinaison organique (tilt) aléatoire par instance. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-03)
### Intégration Tiled (IP-067)
- [x] **Recherche Importateur** : Identification de **YATI** (Yet Another Tiled Importer). ✅
- [x] **Installation & Fix** : Plugin déplacé à la racine et activé par l'utilisateur. ✅
- [ ] **Importation de Map** : Définir les calques et importer les textures animées.

### Zones de Vitesse & Indicateurs (IP-064 & IP-065)
- [x] **Zones de Vitesse (Ressources)** : Migration vers un système basé sur des ressources `SB_SpeedZone`. Suppression des paramètres Bloom/UI redondants. ✅
- [x] **Indicateurs 360°** : Création du composant `SB_TargetIndicator_VShmup` pour le suivi des cibles hors-champ. ✅
- [x] **Texte Flottant de Combo (IP-066)** : Remplacement du compteur de combo HUD par des textes "X KILL" flottants à la mort des ennemis. ✅
- [x] **Indicateurs 360°** : Création du composant `SB_TargetIndicator_VShmup` pour le suivi des cibles hors-champ. ✅
- [x] **Parentage Loot/Projectiles** : Correction du rattachement au Mainground Viewport pour un défilement mondial indépendant. ✅
- [x] **Assets Pixel-Art** : Génération de la flèche et du crâne d'alerte pour l'interface. ✅
- [x] **Fix Threading** : Utilisation de `call_deferred` pour éviter les erreurs "Parent node is busy" lors de l'instanciation au démarrage. ✅
- [x] **Shader Transparence** : Ajout d'un shader de Chroma Key pour traiter le fond des images JPEG générées. ✅
- [x] **Configuration Inspecteur** : Exposition de `warning_max_distance` (105m par défaut) dans le script ennemi. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-04-01 / 2026-04-02)
### Migration HUD & SpriteProgressBar (IP068 à IP072)
- [x] **Moteur de Rendu Custom** : Migration de `TextureProgressBar` vers `SB_SpriteProgressBar` pour un rendu pixel-perfect supportant les modes segmentés. ✅
- [x] **HUD Adaptatif (Portrait/Landscape)** : Création de scènes distinctes pour PC (`hud_landscape.tscn`) et Mobile (`hud_portrait.tscn`). ✅
- [x] **Détection Orientation** : Mise à jour du `SB_GameMode_VShmup` pour charger le HUD dynamiquement selon l'orientation bootstrapée dans `SB_Core`. ✅
- [x] **Noms Uniques (%)** : Stabilisation de la détection des barres HUD via l'option "Unique Name in Owner", permettant une hiérarchie libre dans l'éditeur. ✅
- [x] **Nettoyage GDScript** : Suppression des warnings de shadowing (`size`, `name`), des variables inutilisées et correction des divisions d'entiers. ✅
- [x] **Démo 1** : Alignement complet de la démo sur la nouvelle architecture HUD. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-03-31)
### Ghosting Manuel des Projectiles (IP-049)
- [x] **Suppression des GPUParticles3D** : Retrait complet du nœud `BulletTrail` dans les scènes de base joueur et ennemi. ✅
- [x] **Ghosting par Duplication** : Création de 3 copies du visuel principal (`AnimatedSprite3D`) dans `_ready()`. ✅
- [x] **Interpolation de Position Réelle** : Placement des fantômes via `_prev_pos` + `trail_vec * factor` (facteur 0.5/1.0/1.5). ✅
- [x] **Transparence (60%/30%/10%)** : Application via `node.modulate` natif. ✅
- [x] **Fix Matériau** : Suppression du `material_override` sur `BulletVisual` qui bloquait `modulate`. ✅
- [x] **Fix Billboard** : Ajout de `billboard = 1` directement sur le nœud `AnimatedSprite3D`. ✅
- [x] **Fix Parse Error** : Résolution du doublon `var movement` dans `_update_movement`. ✅
- [x] **Fix Doublon `_process`** : Nettoyage du script ennemi (`SB_Projectile_Enemy_VShmup.gd`). ✅

## ✅ Ce qui a été fait aujourd'hui (2026-03-31)
### Chargement Sélectif (Polish)
- [x] **Cases à cocher Background/Mainground** : Ajout de `load_background` et `load_mainground` dans `SB_GameMode_VShmup.gd`. ✅
- [x] **Optimisation Chargement** : Mise à jour de `_load_level_content()` pour éviter l'instanciation des scènes désactivées (gain de performance en dev). ✅
### Optimisation Android (IP-054)
- [x] **Stoppage Rendu Viewports** : `render_target_update_mode = UPDATE_DISABLED` pour les SubViewports de bloom sur mobile. ✅
- [ ] **IP-071** : Refactorisation de la barre de vie en composant indépendant. (Cible : Session de ce soir 19h+)
- [ ] **IP-067** : Intégration des cartes Tiled via le plugin YATI (Mainground).
- [x] **Réintégration des Layers** : `mainground_camera.cull_mask` inclut désormais les layers 11, 12, 13 sur mobile pour garantir la visibilité des projectiles sans l'overhead du bloom. ✅
- [x] **Masquage Debug** : Auto-désactivation des miniatures `SB_BloomMiniView` sur mobile. ✅
### Level Design Stage 1 (IP-053)
- [x] **Structure de Niveau** : Création de 6 vagues progressives (Intro, Escarmouche, Barrage) dans `mainground.tscn`. ✅
- [x] **Standardisation** : Utilisation systématique du template `SB_Enemy_1.tscn` et nettoyage des nœuds anonymes. ✅
### Interface & Debug (Polish)
- [x] **Console de Debug** : Ajout d'une option `show_debug_console` dans le Core. Désactivée par défaut pour la démo. ✅
### Performance Mobile Avancée (IP-055)
- [x] **Multiplicateurs de Qualité** : Ajout de `mobile_min_scale_multiplier` (0.5) et `mobile_min_fps_multiplier` (0.75) dans `SB_GameMode_VShmup.gd`. ✅
- [x] **Application Contextuelle** : Les limites de résolution dynamique sont désormais 50% plus basses spécifiquement sur Android. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-03-30)
### Polish Bloom & Layering (IP-051)
- [x] **Correction Layering Bloom** : Inversion de l'ordre des Viewports dans `40_game_scene.tscn`. Le Bloom est désormais rendu **SOUS** le Mainground, garantissant des objets nets. ✅
- [x] **Précision BloomConfig** : Passage du `step` de 0.1 à 0.01 pour l'intensité et le rayon. ✅
- [x] **Valeurs par Défaut** : Intensité 1.0, Rayon 5.0 (selon demande utilisateur). ✅
### Optimisation Android (IP-051)
- [x] **Détection Mobile** : Ajout de `is_mobile` et `auto_optimize_mobile` dans `SB_Core.gd`. ✅
- [x] **Désactivation Bloom Mobile** : Le `SB_ViewportManager_VShmup.gd` masque automatiquement le container de Bloom sur mobile. ✅
- [x] **Désactivation Anti-Aliasing** : Forçage à `false` sur mobile via le Core. ✅
### Bloom Sélectif sur les Projectiles (IP-050)
- [x] **Activation du BloomViewport** : `visible=true`, `render_target_update_mode=4`, ajout d'un `WorldEnvironment` avec glow dans `40_game_scene.tscn`. ✅
- [x] **Bloom Sélectif** : `Bloom_Camera.cull_mask = 1024` (layer 11 uniquement). ✅
- [x] **Layer 11 sur Projectiles** : Méthode `_apply_bloom_layers()` dans `SB_Projectile_VShmup.gd` — applique le render layer 11 au visuel principal + 3 fantômes. ✅
- [x] **Fix World3D** : `bloom_viewport.world_3d = mainground_viewport.find_world_3d()` dans `_initialize_game()` — le BloomViewport partage désormais le même monde 3D que le Mainground. ✅
- [x] **SB_BloomMiniView** : Composant debug affichant la miniature du BloomViewport en bas à gauche (`stoneblock/ui/debug/SB_BloomMiniView.gd`). ✅
- [x] **SB_BloomConfig** : Composant `@tool` exposant tous les paramètres du bloom (levels 1-7, intensity, strength, bloom_spread, hdr_threshold, blend_mode) dans l'inspecteur avec mise à jour temps réel (`stoneblock/ui/SB_BloomConfig.gd`). ✅
### Fix Bloom Invisible (Debug)
- [x] **Fix `own_world_3d = false`** : Le `BloomViewport` avait `own_world_3d = true` dans le `.tscn` → Godot ignorait l'assignation du `world_3d` partagé. Corrigé dans `40_game_scene.tscn` + sécurité ajoutée dans `_initialize_game()`. ✅
- [x] **Fix blend ADDITIVE** : Le `BloomViewportContainer` n'avait pas de `CanvasItemMaterial` en mode ADD. Sans ça, le bloom s'affichait en mode alpha normal (invisible sur fond transparent). Ajout d'un `CanvasItemMaterial { blend_mode = 1 }` sur le container. ✅
- [x] **Fix Shader Syntax** : Suppression du `return` dans le fragment processor (interdit en Godot 4) pour compatibilité totale. ✅
- [x] **Extension Bloom Globale** : Application automatique du Layer 11 aux **réacteurs** du joueur, aux **tirs ennemis** (et leurs ghosts) ainsi qu'à tous les **loots/pickups** (via classes de base). ✅
- [x] **Optimisation Particules** : Réduction du nombre de particules des réacteurs (48 -> 24) pour gain de performance immédiat. ✅
### Bloom Sélectif Multi-Passes (IP-052)
- [x] **Architecture Viewports** : Passage à 3 containers (`Long`, `Med`, `Short`). ✅
- [x] **Layers Dédiés** : Utilisation des Render Layers 11, 12, 13 pour séparer les types de flou. ✅
- [x] **Contrôles Config** : Ajout de l'activation individuelle, du rayon, de l'intensité et du toggle Debug. ✅
- [x] **Uniformisation Loots** : Migration de tous les objets de butin vers `SB_Loot_Base` (Layer 13). ✅
- [x] **Correction Réacteurs** : Réparation du fichier `SB_EngineParticles.tscn` (Layers & Structure). ✅
- [x] **Correction Sélecteur** : Mise à jour de `SB_BloomSelector3D` vers le nouveau système d'énumération. ✅
- [x] **Git Push** : Sauvegarde distante de l'ensemble du système. ✅

## ✅ Ce qui a été fait aujourd'hui (2024-03-28)
### Stabilité Core & Architecture No-Code
- [x] **Orientation & Fenêtre (IP-041)** : Redimensionnement intelligent et CENTRAGE automatique sur Desktop. ✅
- [x] **Dépendances Circulaires (IP-042)** : Résolution des erreurs "Busy" via découplage des types (`Object` vs `Resource`). ✅
- [x] **Scène de Chargement (IP-044)** : Migration 100% No-Code via les composants `SB_LoadingBar` et `SB_LoadingLabel`. ✅
- [x] **Nettoyage Technique** : Suppression systématique de tous les warnings GDScript et correction des typages de signaux. ✅
- [x] **Protocole IA** : Ajout de la commande `!ia.md` pour le rafraîchissement global des règles. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-03-26)
### Système de Loot & Quarium - IP-033
- [x] **Matériau Quarium** : Adoption du nom officiel pour le matériau éthéré du projet. ✅
- [x] **Fragments de Loot** : Création de la classe `SB_Loot_Base` gérant le magnétisme et l'éjection. ✅
- [x] **Visuels** : Implémentation des fragments en cubes colorés (Énergie: Jaune, Bouclier: Bleu, Coin: Blanc). ✅
- [x] **Drops Fixes** : Mise à jour de `SB_Enemy_VShmup.gd` avec les nouvelles valeurs (Shield: 1, Energy: 2, Coin: 3). ✅
- [x] **Éther Quantique -> Coin** : Renommage complet de la monnaie dans tout le projet. ✅
- [x] **Indicateur HUD** : Ajout d'un affichage "COINS: X" en bas à droite de l'écran. ✅
- [x] **Correction Bug Actualisation** : Ajout de `get_stat` dans `SB_Core.gd` qui manquait. ✅
- [x] **Correction Bug Persistence** : Suppression du reset de `magie` dans `SB_GameMode_VShmup.gd`. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-03-24)
### Infrastructure & Légal
- [x] **Licence Open Source** : Mise en place de la licence MIT. ✅
- [x] **Copyright** : Configuration pour "DolmenIT / DolmenAGX". ✅
- [x] **Validation** : Vérification de la conformité avec le standard OSI. ✅

### Polissage Démo 1 (SHMUP) - IP-027
- [x] **Système de Survie** : Implémentation d'un bouclier (25 pts) avec régénération auto (2s de délai) et d'une barre de vie (100 pts) protégée. ✅
- [x] **HUD Superposé** : Refonte de `hud.tscn` et `HUD_VShmup.gd` pour afficher le bouclier (Cyan) par dessus la vie (Rouge/Vert). ✅
- [x] **Alerte de Tir** : Ajout d'un clignotement rouge "glowing" (Émission) chez les ennemis avant qu'ils ne fassent feu. ✅
- [x] **Power-up Triple Shot** : Création du pickup `SB_Pickup_TripleShot` et de la logique de tir triple chez le joueur. ✅
- [x] **Fix Balistique** : Création du `World_Scroll_Pivot` pour dissocier le scrolling vertical des mouvements horizontaux (Tirs enfin droits !). ✅
- [x] **Équilibrage** : Ajustement de la vitesse des projectiles (18.0) et des chances de drop. ✅
### Extension Bullet Time (SHMUP) - IP-029
- [x] **Système de Bullet Time** : Création du `SB_TimeManager` pour gérer `Engine.time_scale` avec Tweens fluides. ✅
- [x] **Suivi Caméra (Deadzone)** : Implémentation d'une zone morte horizontale avec visualisation debug (Cyan) et vitesse de rattrapage proportionnelle (`IP-030`). ✅
- [x] **Réacteurs & Propulsion** : Système de particules paramétrable et mécanique d'accélération/freinage avec consommation d'énergie (`IP-031`). ✅
- [x] **Groupes d'Ennemis (LD)** : Transformation du `SB_EnemyGroup` en outil de template et générateur automatique pour faciliter le Level Design (`IP-032`). ✅
- [x] **Filtres Visuels** : Implémentation d'un shader d'overlay (Filtre bleu au hit, rouge à la mort, vignette blur). ✅
- [x] **Feedback Game Over** : Arrêt automatique des tirs ennemis dès la défaite du joueur. ✅
- [x] **Compensation Physique** : Adaptation du joueur et de la caméra (shake) pour rester nerveux en temps réel malgré le ralenti. ✅

## ✅ Ce qui a été fait aujourd'hui (2026-03-23)
### Pivot SHMUP (Demo 1)
- [x] Analyse de l'architecture Cosmic HyperSquad pour portage des composants SHMUP.
- [x] Initialisation du plan **IP-022** pour le pivot de la Démo 1.
- [x] **Système d'Entrées Gamepad** : Création de `SB_Input_Gamepad` (Mapper explicite) avec résolution de cible par **Nom** (No-Code).
- [x] **Mouvements Avancés** : Implémentation du **Tonneau Directionnel** (Barrel Roll) avec boost et rotation 360°.
- [x] **Système de HUD & Énergie** : Création d'un HUD modulaire chargé dynamiquement (`TextureProgressBar`) et gestion de l'énergie (Regen 2%/s, Tir 1%, Dash 20%).
- [x] **Portée des Projectiles** : Fix critique de la portée des tirs en scrolling via le parentage au `Camera_Pivot`.
- [x] **Unification Viewports** : Migration de toutes les couches (BG, MG, Bloom, UI) en exports `@export` pour une configuration 100% visuelle.
- [x] **Contraintes Caméra** : Finalisation du **Edge Clamping** en `SB_CameraManager_VShmup` (Limites respectant les bords de l'écran).
- [x] **Modularity** : Découplage complet entre GameMode, Player et Gamepad via une architecture "Push" et détection dynamique.
- [x] **Polissage UI** : Exécution du plan **IP-023** (Récapitulatif score en Game Over) ✅
- [x] **Génération Décors** : Exécution du plan **IP-024** (SB_BasicMeshGenerator procédural) ✅
- [x] **Modèles 3D** : Exécution du plan **IP-025** (Modèles Phantom Jet & Nexus Disk via PackedScene) ✅
- [x] **High Scores** : Exécution du plan **IP-026** (Architecture Découplée & UI) ✅

## 🏁 DÉMO 1 (SHMUP) : 🎉 100% TERMINÉ
✅ Boss, Scoring, Game Over, Décors Proceduraux, Modèles 3D, High Scores.

## ✅ Ce qui a été fait aujourd'hui (2026-03-22)
### Consolidation Demo 1 & Core
- [x] Raffinement de `SB_Core.gd` : Retrait des exports inutiles, simplification de l'interface (remplacement de `min_splash_time` par `use_stoneblock_splash`, suppression de `auto_setup_world`) et **nettoyage des chemins par défaut** (mis à vide).
- [x] Support du **Direct Boot** : Démarrage instantané si le splash est désactivé (fix de la machine à état pour assurer la transition).
- [x] Correction des menus de la Demo 1 : Fix des logs erronés sur les boutons Jouer et Quitter.
- [x] Pivot Demo 1 : Transformation en "Petit Platformer Basique" complet.
- [x] Mise à jour du sélecteur de niveaux pour pointer vers `40_game_scene.tscn`.
- [x] Amélioration de `40_game_scene.tscn` : Ajout de plateformes et de collectibles (Galettes) pour valider les stats du Core.

## ✅ Ce qui a été fait aujourd'hui (2026-03-21)
### Refonte Dolmenir & Menu
- [x] Pivot du Roadmap vers "Dolmenir : Le Petit Magicien Breton" (Plateforme 3D).
- [x] Refonte complète du menu de `sb_boot.tscn` (Jouer, Options, Quitter).
- [x] Intégration du composant `SB_Quit` pour la fermeture propre de l'app.
- [x] Correction des erreurs de ressources : Création des icônes manquantes (`SB_Follow3D.svg`, `SB_PlayerController3D.svg`).
- [x] Intégration des visuels 3-Slice pour `SB_Button` (Support textures normal/hover/pressed, marges et étirement).

## ✅ Ce qui a été fait aujourd'hui (2026-03-20)
### Initialisation du GDK & Analyse
- [x] Scan complet du dossier `ia/` et lecture des règles.
- [x] Inventaire des scripts (12 fichiers .gd).
- [x] Initialisation de l'infrastructure de planification dans `ia/brain/`.
- [x] Conception du `SB_Core` orienté **TPS Asynchrone**.
- [x] Création du `SB_Core.gd` et intégration dans `project.godot` (Autoload).
- [x] Implémentation de la **Console de Debug 100% Autonome** (Overlay intégré).
- [x] Correctif Critique : Positionnement UI (Ancres & Offsets) de la console.
- [x] Stylisation dynamique (Fond noir arrondi, 300x300, CanvasLayer).
- [x] Mise en place de l'architecture **Bootstrapper** (`demo1`) / **Niveau** (`scene1`).
- [x] Écran de **Splash Screen** avec logo 3D, Console autonome et transition.
- [x] Chargement et instanciation asynchrone fonctionnels via `SBCore`.

## ✅ Ce qui a été fait aujourd'hui (2026-03-19)
### Unification Grille & Auto-Props (Pipeline de Placement)
1. **Unification Pas de Grille :** Centralisation du paramètre `props_grid_step` dans le Manager. Les outils manuels et automatiques partagent désormais la même densité.
2. **Simplification Auto-Props :** Suppression du mode Aléatoire/Samples au profit d'une grille robuste avec jitter (décalage aléatoire) par passe pour un rendu naturel.
3. **Optimisation UI Auto-Props :** Refonte de l'interface des règles sur une seule ligne ultra-compacte.
4. **Correction Stabilité Manager :** Modification du `TerrainManagerHandler` pour prioriser le vrai Manager (évite les crashs d'identification avec les tuiles de terrain).
5. **Restauration UI Manuel :** Réactivation de la case "Pas Grille :" globale dans l'onglet manuel avec synchronisation temps réel.

## ✅ Ce qui a été fait aujourd'hui (2026-03-18)
... (Suite identique)

## 💡 Idées / Backlog
- [ ] Créer des nœuds spécialisés `SB_ImageEmission` et `SB_ImageSaturation` (suggestion utilisateur).
