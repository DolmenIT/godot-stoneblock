# [IP-004] Composants Visuels : Rotation et Cycle de Couleurs

L'objectif est de fournir des composants simples et hautement configurables pour l'animation et les effets visuels de base, afin de réaliser la démo du "Cube RGB".

## Philosophie "Component-Based"
Conformément au souhait de l'utilisateur de limiter les scripts manuels, nous créons des briques réutilisables :
- **SB_Rotate3D** : Pour toute rotation continue ou oscillante.
- **SB_ColorCycle** : Pour animer les couleurs d'un matériau.

## Changements Proposés

### [Component] Animation
#### [NEW] [SB_Rotate3D.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/animation/SB_Rotate3D.gd)
- `@export` de la vitesse par axe.
- Support du mode `@tool`.

### [Component] Visual (Nouveau Dossier)
#### [NEW] [SB_ColorCycle.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/visual/SB_ColorCycle.gd)
- Cycle les couleurs via une interpolation HSL ou une liste de couleurs.
- Cible un `MeshInstance3D` ou un `Sprite3D`.

### [Integration] Démo
#### [MODIFY] [demo1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- Ajout d'un `MeshInstance3D` (BoxMesh).
- Ajout des composants `SB_Rotate3D` et `SB_ColorCycle`.

## Plan de Vérification

### Tests Automatisés
- Vérification que le cube tourne et change de couleur dans l'éditeur (grâce au mode `@tool`).

### Vérification Manuelle
- Lancement de la scène pour confirmer la fluidité de l'animation.

---
**🟥🟨 VALIDATION REQUISE :** _Êtes-vous d'accord pour la création de ces deux composants et l'ajout du cube dans `demo1.tscn` ?_
