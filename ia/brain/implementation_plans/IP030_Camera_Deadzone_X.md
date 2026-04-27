# [IP-030] Suivi Caméra : Zone Morte Horizontale (Deadzone)

Ce plan vise à améliorer le confort visuel du Shmup en ajoutant une zone morte horizontale pour la caméra. La caméra ne commencera à suivre le pivot que lorsque celui-ci dépassera une distance seuil par rapport au centre de l'écran.

## Proposed Changes

### [Camera System]

#### [MODIFY] [SB_CameraManager_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/cameramanagers/SB_CameraManager_VShmup.gd)
- **Exports** :
    - Ajouter `@export var follow_deadzone_x: float = 10.0` (Distance en mètres avant que la caméra ne bouge).
- **Visualisation Debug** :
    - Ajouter `@export var show_deadzone_visual: bool = true`.
    - Créer dynamiquement un plan (MeshInstance3D) semi-transparent (Bleu/Cyan, 25% opacité) pour matérialiser la zone en cours de jeu/éditeur.
    - Largeur = `follow_deadzone_x * 2`.

## Verification Plan

### Manual Verification
1. Lancer la scène `res://demo/demo1/demo1_shmup.tscn`.
2. Déplacer le vaisseau (le pivot suit le vaisseau).
3. Vérifier que la caméra reste immobile tant que le vaisseau/pivot reste proche du centre.
4. Vérifier que la caméra commence à défiler horizontalement de manière fluide dès que le pivot "pousse" les bords de la zone morte.
5. Ajuster `follow_deadzone_x` dans l'inspecteur pour valider la flexibilité.

**🟥🟨 VALIDATION REQUISE :** Souhaitez-vous que j'applique cette modification avec une valeur par défaut de 10.0 pour la zone morte ?
