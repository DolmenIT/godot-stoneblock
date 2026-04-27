# [IP-009] Indicateur de Progression Visuel (UI)

L'objectif est d'afficher textuellement l'état du chargement asynchrone (nom de la scène et pourcentage) pour informer l'utilisateur pendant l'écran de splash.

## Nouveau Composant : SB_LoadingLabel
- **Type** : `Label` ou `Label3D`.
- **Fonction** : Se connecte au signal `SBCore.progress_updated` pour mettre à jour son texte.
- **Format** : "[Nom de la Scène] : Chargement [X]%"

## Changements Proposés

### [Component] UI
#### [NEW] [SB_LoadingLabel.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_LoadingLabel.gd)
- Gère la réception des signaux de progression.
- Formatage dynamique du texte.

### [Integration] Scènes
#### [MODIFY] [demo1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- Ajouter un `CanvasLayer` pour l'interface utilisateur.
- Ajouter un `Label` avec le script `SB_LoadingLabel`.

## Plan de Vérification

### Tests Automatisés
- Lancer le projet et vérifier que le texte évolue de 0% à 100%.

### Vérification Manuelle
- Confirmer que le nom de la scène affiché correspond à celui dans `SBCore`.

---
**🟥🟨 VALIDATION REQUISE :** _Souhaitez-vous un label 2D (Overlay) ou un label 3D flottant dans l'espace avec le logo ?_
