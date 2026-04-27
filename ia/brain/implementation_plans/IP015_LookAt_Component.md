# [IP-015] Composant SB_LookAt

L'objectif est d'offrir une solution visuelle dans l'inspecteur pour orienter un objet (souvent une caméra) vers une cible.

## Fonctionnalités
- **Cible** : Sélection d'un `Node3D` cible via l'inspecteur.
- **Lissage (Smooth)** : Option pour un suivi fluide via `lerp` de la rotation (ou `quaternion`).
- **Mode Éditeur (@tool)** : Visualisation du `look_at` directement dans l'éditeur de scène.

## Changements Proposés

### [Component] Animations / Visuel
#### [NEW] [SB_LookAt.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/visual/SB_LookAt.gd)
- Création du script gérant l'orientation vers une cible.
- Support du lissage temporel.

## Plan de Vérification

### Tests Automatisés
- Attacher le script à la caméra de `scene1.tscn`.
- Assigner le cube comme cible.
- Vérifier que la caméra reste braquée sur le cube même si on déplace l'un ou l'autre.
