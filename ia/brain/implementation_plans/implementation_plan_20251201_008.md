# Implementation Plan - Refactoring SkipButton : Composants Génériques Réutilisables (20251201_008)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2025-12-01 ~11:50
- **Fin** : 2025-12-01 ~11:53
- **Statut** : ✅ **COMPLETED**

## Objectif

Refactoriser `SkipButton` pour extraire les fonctionnalités en composants génériques réutilisables, organisés par fonctionnalité. Cela permettra de réutiliser facilement ces composants pour d'autres boutons ou éléments UI.

## État des lieux

### Problème identifié
Le script `SkipButton` contient plusieurs fonctionnalités qui pourraient être réutilisables :
- **Scaling des textures** : Fonction `_scale_texture()` et `_setup_textures()` (~115 lignes)
- **Positionnement adaptatif** : Fonction `_update_position()` (~50 lignes)
- **Configuration EventMaster** : Logique spécifique au bouton

### Fonctionnalités à extraire

1. **TextureScaler** : Composant pour redimensionner des textures avec opacité
   - Fonction `scale_texture()` statique ou utilitaire
   - Gestion des différents types de textures
   - Application d'opacité avant redimensionnement

2. **NinePatchTextureScaler** : Composant pour scaler des NinePatchRect
   - Applique le scaling à un NinePatchRect
   - Configure les patch_margins automatiquement
   - Gère l'opacité

3. **AdaptivePositioner** : Composant pour positionnement adaptatif
   - Positionnement basé sur résolution de base
   - Support de différents ancres (bas-droite, haut-gauche, etc.)
   - Gestion du scaling automatique

## Changements proposés

### 1. Créer un utilitaire de scaling de textures
#### [NEW] `scripts/components/texture_scaler.gd`
- **Type** : Classe utilitaire statique ou autoload
- **Fonctionnalités** :
  - `scale_texture(source_texture: Texture2D, scale_factor: float, image_opacity: float = 1.0) -> ImageTexture`
  - Gestion des différents types de textures (ImageTexture, CompressedTexture2D)
  - Application d'opacité avant redimensionnement
  - Conversion en RGBA8

### 2. Créer un composant pour scaler des NinePatchRect
#### [NEW] `scripts/components/nine_patch_texture_scaler.gd`
- **Type** : Script attachable à un Node (ou utilitaire)
- **Fonctionnalités** :
  - `scale_nine_patch(nine_patch: NinePatchRect, scale_factor: float, opacity: float = 1.0, patch_margin: int = 10)`
  - Applique le scaling via TextureScaler
  - Configure automatiquement les patch_margins
  - Gère le self_modulate

### 3. Créer un composant de positionnement adaptatif
#### [NEW] `scripts/components/adaptive_positioner.gd`
- **Type** : Script attachable à un Control
- **Fonctionnalités** :
  - Positionnement basé sur résolution de base
  - Support de différents ancres (export enum)
  - Gestion du scaling automatique
  - Écoute des changements de viewport

**Configuration** :
```gdscript
@export_group("Adaptive Positioning")
@export var base_width: float = 175.0
@export var base_height: float = 60.0
@export var margin_x: float = 30.0
@export var margin_y: float = 30.0
@export var base_resolution: Vector2 = Vector2(1920, 1080)
@export_enum("Bottom Right", "Bottom Left", "Top Right", "Top Left", "Center") var anchor_position: int = 0
```

### 4. Refactoriser SkipButton pour utiliser les composants
#### [MODIFY] `scripts/ui/skip_button.gd`
- Utiliser `TextureScaler.scale_texture()` au lieu de `_scale_texture()`
- Utiliser `NinePatchTextureScaler.scale_nine_patch()` pour chaque NinePatchRect
- Utiliser `AdaptivePositioner` comme composant enfant ou intégré
- Simplifier le code en déléguant aux composants

### 5. Optionnel : Créer un script de base réutilisable
#### [NEW] `scripts/ui/adaptive_button.gd` (optionnel)
- **Type** : Classe de base pour boutons avec fonctionnalités adaptatives
- **Fonctionnalités** :
  - Étend `TweenButton`
  - Intègre `AdaptivePositioner`
  - Support du scaling de textures
  - Peut être utilisé comme base pour d'autres boutons

## Étapes d'implémentation

### Étape 1 : Créer TextureScaler
**Timecode** : 2025-12-01 ~11:50-11:51  
**Statut** : ✅ **COMPLETED**

1. ✅ Créer `scripts/components/texture_scaler.gd`
2. ✅ Extraire la fonction `_scale_texture()` de SkipButton
3. ✅ Rendre la fonction statique (classe utilitaire)
4. ✅ Gérer différents types de textures (ImageTexture, CompressedTexture2D)

**Résultats** : Classe utilitaire statique créée avec fonction `scale_texture()` réutilisable.

### Étape 2 : Créer NinePatchTextureScaler
**Timecode** : 2025-12-01 ~11:51  
**Statut** : ✅ **COMPLETED**

1. ✅ Créer `scripts/components/nine_patch_texture_scaler.gd`
2. ✅ Créer fonction `scale_nine_patch()` qui utilise TextureScaler
3. ✅ Gérer la configuration des patch_margins
4. ✅ Gérer le self_modulate

**Résultats** : Classe utilitaire statique créée pour scaler facilement des NinePatchRect.

### Étape 3 : Créer AdaptivePositioner
**Timecode** : 2025-12-01 ~11:51-11:52  
**Statut** : ✅ **COMPLETED**

1. ✅ Créer `scripts/components/adaptive_positioner.gd`
2. ✅ Extraire la logique de `_update_position()` de SkipButton
3. ✅ Ajouter support de différents ancres (export enum: BOTTOM_RIGHT, BOTTOM_LEFT, TOP_RIGHT, TOP_LEFT, CENTER)
4. ✅ Gérer l'écoute des changements de viewport
5. ✅ Configurer le pivot automatiquement

**Résultats** : Composant réutilisable créé, peut être attaché à n'importe quel Control.

### Étape 4 : Refactoriser SkipButton
**Timecode** : 2025-12-01 ~11:52-11:53  
**Statut** : ✅ **COMPLETED**

1. ✅ Supprimer `_scale_texture()` (remplacé par TextureScaler)
2. ✅ Utiliser `NinePatchTextureScaler.scale_nine_patch()` pour chaque NinePatchRect
3. ✅ Simplifier `_setup_textures()` (de ~60 lignes à ~25 lignes)
4. ✅ Simplifier `_update_position()` (commentaire ajouté pour utilisation future d'AdaptivePositioner)
5. ✅ Code beaucoup plus simple et lisible

**Résultats** : SkipButton simplifié de ~230 lignes à ~142 lignes. Utilise maintenant les composants génériques.

### Étape 5 : Tests et vérification
**Timecode** : 2025-12-01 ~11:53  
**Statut** : ⏳ **PENDING** (À tester par l'utilisateur)

1. Vérifier que le bouton Skip fonctionne toujours
2. Tester les composants individuellement
3. Vérifier la réutilisabilité (créer un autre bouton test)

## Décisions techniques

### TextureScaler : Statique vs Autoload
- **Choix** : Fonction statique dans une classe utilitaire
- **Raison** : Pas besoin d'état, simple fonction utilitaire
- **Alternative** : Autoload si besoin de cache ou configuration globale

### AdaptivePositioner : Composant vs Intégré
- **Choix** : Composant attachable (script sur un Node enfant ou sur le Control lui-même)
- **Raison** : Flexibilité, peut être activé/désactivé
- **Alternative** : Intégré directement dans les boutons si toujours nécessaire

### Structure des composants
- **TextureScaler** : Classe utilitaire statique
- **NinePatchTextureScaler** : Fonction utilitaire ou classe statique
- **AdaptivePositioner** : Script attachable à un Control

## Notes

- Les composants doivent être indépendants et réutilisables
- Pas de dépendances circulaires
- Documentation claire pour chaque composant
- Exemples d'utilisation dans les commentaires

## Résumé de l'implémentation

### Fichiers créés
- `scripts/components/texture_scaler.gd` : Utilitaire statique pour scaling de textures
- `scripts/components/nine_patch_texture_scaler.gd` : Utilitaire pour scaler des NinePatchRect
- `scripts/components/adaptive_positioner.gd` : Composant réutilisable pour positionnement adaptatif

### Fichiers modifiés
- `scripts/ui/skip_button.gd` : Refactorisé pour utiliser les composants génériques (~90 lignes supprimées)

### Réduction de code
- **Avant** : ~230 lignes dans SkipButton
- **Après** : ~142 lignes dans SkipButton
- **Réduction** : ~38% de code en moins dans SkipButton
- **Composants réutilisables** : 3 nouveaux composants créés

### Avantages
- ✅ **Réutilisabilité** : Les composants peuvent être utilisés pour d'autres boutons ou éléments UI
- ✅ **Maintenabilité** : Code plus simple et organisé par fonctionnalité
- ✅ **Testabilité** : Chaque composant peut être testé indépendamment
- ✅ **Flexibilité** : AdaptivePositioner peut être utilisé comme composant enfant ou intégré
- ✅ **Documentation** : Chaque composant est bien documenté

### Utilisation future
Les composants peuvent maintenant être réutilisés pour :
- D'autres boutons (ex: bouton "Press to continue" dans Welcome Screen)
- D'autres éléments UI nécessitant un scaling de textures
- D'autres éléments UI nécessitant un positionnement adaptatif

