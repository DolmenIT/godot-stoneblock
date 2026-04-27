# [IP-020] Nettoyage & Démo 3 : Magie Celtique

Finalisation de la Démo 3 pour intégrer les collectibles, le HUD et le suivi de caméra.

## Proposed Changes

### [Demo 3]
Mise à jour de la scène de démonstration pour assurer la jouabilité et la qualité visuelle.

#### [MODIFY] [demo3_magie.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo3/demo3_magie.tscn)
- **Collisions** : Ajout d'une `CapsuleShape3D` au `Player` et d'une `SphereShape3D` à `Galette_1`.
- **Caméra** : Ajout d'un nœud `Camera3D` avec le script `SB_Follow3D` ciblant le `Player`.
- **UI (HUD)** : Refonte de `SB_HUD` avec un `MarginContainer` pour respecter les marges et améliorer le rendu "premium".
- **Collectibles** : Ajout de plusieurs instances de `SB_Pickable` (Galettes et Kouign-amanns) réparties sur le sol.

### [Core]
#### [MODIFY] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
- Vérification de la robustesse de `add_stat` (déjà implémenté mais à confirmer lors des tests).

## Verification Plan

### Automated Tests
_Aucun test automatisé n'est disponible pour ce composant._

### Manual Verification
1. Lancer la scène `res://demo/demo3/demo3_magie.tscn` dans Godot.
2. Déplacer le personnage à l'aide des touches directionnelles (ou WASD).
3. Vérifier que la caméra suit correctement le joueur avec un mouvement fluide (LERP).
4. Ramasser les "Galettes" et "Kouign-amanns" en passant dessus.
5. Vérifier que :
    - Les objets disparaissent au contact.
    - Le message de succès s'affiche dans la console de debug.
    - Le HUD met à jour les compteurs "Magie" et "Score" en temps réel.

**🟥🟨 VALIDATION REQUISE :** _Souhaitez-vous que j'ajoute des effets visuels supplémentaires (particules, sons) lors du ramassage ou ce plan vous convient-il ?_
