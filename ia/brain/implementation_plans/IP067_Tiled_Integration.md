# IP-067 : Intégration des Cartes Tiled pour le Level Design (Mainground)

Ce plan définit la stratégie pour utiliser **Tiled** comme éditeur de niveau 2D au sein de l'architecture 3D du SHMUP StoneBlock.

## User Review Required

> [!IMPORTANT]
> **EMPLACEMENT DU PLUGIN :** Le plugin YATI a été détecté dans `GDScript/addons/`. Pour fonctionner, il **doit** être déplacé à la racine (`res://addons/`).
> **RENDU 2D DANS 3D :** Les cartes Tiled importées sont des `Node2D`. Nous devons décider si elles sont placées directement sur le plan Z=0 ou via un `SubViewport` pour plus de flexibilité (scrolling indépendant).

## Proposed Changes

### Core Integration

#### [x] [project.godot](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/project.godot)
- Plugin YATI activé. ✅

#### [x] [addons/YATI](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/addons/YATI)
- Dossier déplacé à la racine par l'utilisateur. ✅

### Level Workflow

#### [NEW] [res://assets/maps/level1/](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/assets/maps/level1/)
- Dossier cible pour les fichiers `.tmx`, `.tsx` et textures de tileset.

## Open Questions

> [!WARNING]
> **Animations :** Les textures animées dans Tiled doivent être configurées avec des durées fixes pour une compatibilité optimale avec le moteur de Tiles de Godot 4.

## Verification Plan

### Automated Tests
- Vérifier que les fichiers `.tmx` sont reconnus par l'importateur YATI.
- Vérifier que les cycles d'animation des tuiles sont visibles dans l'éditeur Godot.

### Manual Verification
- Instancier une carte de test dans `mainground.tscn`.
- Confirmer la visibilité via la `Mainground_Camera`.

**🟥🟨 VALIDATION REQUISE :** _Souhaites-tu que je déplace le dossier `addons/YATI` vers la racine pour toi ?_
