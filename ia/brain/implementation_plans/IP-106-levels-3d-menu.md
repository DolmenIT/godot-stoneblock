# IP-106 : Menu des Niveaux 3D avec Level Cards & Aperçu

Ce plan détaille la migration du menu des niveaux (`11_menu_levels.tscn`) vers une interface 3D diégétique complète. L'expérience repose sur des cartes de niveaux interactives et un panneau d'aperçu détaillé, le tout basé sur l'esthétique "Upgrade Card" de l'Armurerie.

## User Review Required

> [!IMPORTANT]
> - **Level Stage Card** : Nous créons un nouveau composant `SB_LevelCard_3d` qui servira d'élément de sélection. Il sera plus compact que l'aperçu de droite mais partagera le même design.
> - **Navigation Tactile/Manette** : Le focus/survol d'une carte à gauche mettra à jour le grand panneau d'aperçu à droite.

## Proposed Changes

### [Component] UI 3D
#### [NEW] [SB_LevelCard_3d.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/ui/SB_LevelCard_3d.tscn)
- Version compacte (format portrait ou carré) de l'Upgrade Card.
- Nœuds : Socle, Image (miniature du niveau), Cadre.
- Supporte le survol (émission lumineuse) et le clic.

#### [NEW] [SB_LevelPreview_3d.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/ui/SB_LevelPreview_3d.tscn)
- Version large (format paysage) servant d'affichage dynamique.
- Affiche le nom du Stage en grand, le record de score, et une description du secteur.

#### [MODIFY] [SB_LevelPreview_3d.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/ui/SB_LevelPreview_3d.gd)
- Logique pour mettre à jour les textures et textes en fonction du niveau sélectionné.

### [Scene] Menu Levels 3D
#### [NEW] [11_menu_levels_3d.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/11_menu_levels_3d.tscn)
- Orchestration technique (Viewports, Cameras, Bloom).

#### [NEW] [levels_3d_content.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/levels/level1/levels_3d_content.tscn)
- **Mainground** :
    - Titre 3D "CARTE STELLAIRE".
    - Grille de `SB_LevelCard_3d` (ex: 2x3 ou 3x2).
    - Panneau `SB_LevelPreview_3d` positionné à droite.

#### [NEW] [SB_Levels_Logic.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/levels/level1/SB_Levels_Logic.gd)
- Gère la synchronisation entre la sélection (cartes de gauche) et l'aperçu (droite).
- Encode les paramètres de chaque niveau (scène background, mainground, vitesse).

## Verification Plan

### Automated Tests
- Lancement de la scène de sélection.
- Vérification que cliquer sur une `SB_LevelCard_3d` lance bien le Shmup avec les bons paramètres.

### Manual Verification
- S'assurer que le "flow" entre le menu principal, la sélection de niveau et le hangar est fluide et cohérent graphiquement.
