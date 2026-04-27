# [IP-122] Séquenceur temporel et Rotation Animée (Barrel Roll)

## Problématique
Le système actuel manque de flexibilité pour des animations ponctuelles répétées (ex: un tonneau toutes les 3 secondes).
- `SB_Timer` ne boucle pas.
- `SB_Rotate3D` est uniquement une rotation continue.

## Objectifs
- Permettre au `SB_Timer` de boucler.
- Permettre au `SB_Rotate3D` d'effectuer une rotation précise sur une durée définie via Tween.

## Changements proposés

### [MODIFY] [SB_Timer.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/gdk-stoneblock/core/SB_Timer.gd)
- Ajouter `@export var loop: bool = false`.
- Modifier `start()` pour boucler si `loop` est actif.

### [MODIFY] [SB_Rotate3D.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/gdk-stoneblock/animation/SB_Rotate3D.gd)
- Ajouter `@export var one_shot: bool = false`.
- Ajouter `@export var duration: float = 1.0`.
- Ajouter `@export var animation_degrees: Vector3 = Vector3(0, 0, 360)`.
- Ajouter une méthode `start()` utilisant un `create_tween()` pour animer la rotation.

## Plan de Vérification
- [ ] Créer un Timer à 3s avec Loop = true.
- [ ] Ajouter un Rotate3D en enfant avec One Shot = true et 360° sur Z.
- [ ] Vérifier que l'objet fait un tonneau toutes les 3 secondes.

---
📅 **Demandé** : 2026-04-25
🚀 **Lancé** : 2026-04-25
✅ **Terminé** : 2026-04-25
