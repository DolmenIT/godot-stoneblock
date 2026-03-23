# [IP-019] Demo 2 : Dolmenir - L'Éveil (Plateforme 3D)

L'objectif est de mettre en place les fondations d'un jeu de plateforme 3D minimaliste utilisant les concepts du GDK StoneBlock.

## Proposed Changes

### [Core]
#### [MODIFY] [SB_PlayerController3D.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_PlayerController3D.gd)
- Désactiver `lock_z_axis` par défaut (mouvement 3D complet).
- Optimiser la réactivité (accélération, friction).
- S'assurer que le modèle s'oriente vers la direction du mouvement.

### [Demos]
#### [MODIFY] [demo2_dolmenir.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo2/demo2_dolmenir.tscn)
- Ajouter des obstacles/menhirs (CubeMesh) pour créer un parcours de plateforme.
- Configurer `SB_Follow3D` sur la caméra pour un suivi fluide.

#### [MODIFY] [menu_principal.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/menu_principal.tscn)
- (Déjà fait) Le bouton "Jouer" redirige vers cette démo.

## Plan de vérification

### Manual Verification
1. **Lancement** : Lancer `sb_boot.tscn`, cliquer sur "Jouer".
2. **Mouvement** : Vérifier que le joueur se déplace librement en 3D.
3. **Saut** : Tester les transitions entre plateformes.
4. **Caméra** : Vérifier la fluidité du suivi.
5. **Succès** : Confirmation visuelle ou via log une fois l'objectif atteint.
