# [IP-010] Console de Debug In-Game (StoneLogger)

L'objectif est de remplacer le simple label de chargement par une console de debug dynamique capable de lister plusieurs messages système (chargement, erreurs, initialisations) avec un style "Engine".

## Système de Log Global
- **SBCore** : Ajout d'une méthode `log_info(msg)` et d'un signal `message_logged`.
- **SB_DebugConsole** : Nouveau composant UI basé sur `RichTextLabel` qui s'abonne à ces messages.

## Changements Proposés

### [Component] Core
#### [MODIFY] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
- Ajouter le signal `message_logged(text, type)`.
- Ajouter la méthode `log_msg(text, type)`.
- Rediriger les prints importants vers ce système.

### [Component] UI
#### [NEW] [SB_DebugConsole.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_DebugConsole.gd)
- Gère l'empilement des messages.
- Auto-scroll et limitation du nombre de lignes.

### [Integration] Scènes
#### [MODIFY] [demo1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- Remplacer le `LoadingLabel` par un `PanelContainer` (300x300, StyleBoxFlat noir transparent, coins arrondis).
- Ajouter un `RichTextLabel` comme enfant du panel, avec le script `SB_DebugConsole`.
- Configurer les ancres (Bas gauche) et les marges.

## Plan de Vérification

### Tests Automatisés
- Lancer le projet et vérifier que plusieurs lignes s'affichent successivement (Init, Loading, Ready).

---
**🟥🟨 VALIDATION REQUISE :** _Souhaitez-vous que cette console reste visible tout le temps ou seulement pendant le chargement ?_
