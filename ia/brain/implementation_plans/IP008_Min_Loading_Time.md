# [IP-008] Durée Minimale de l'Écran de Splash

L'objectif est d'empêcher une transition trop brutale vers le jeu si le chargement est instantané, en garantissant que le logo StoneBlock reste visible au moins 2 secondes.

## Logique de Temporisation
1. **Chronométrage** : `SBCore` enregistre le temps au lancement (`_ready`).
2. **Attente Combinée** : La transition ne déclenche que si :
   - La ressource est chargée (`THREAD_LOAD_LOADED`).
   - ET le temps écoulé est supérieur à `min_splash_time`.

## Changements Proposés

### [Component] Core
#### [MODIFY] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
- Ajouter `@export var min_splash_time: float = 2.0`.
- Ajouter une variable interne `_start_time`.
- Modifier la logique de transition pour inclure la vérification du temps.

## Plan de Vérification

### Tests Automatisés
- Lancer le projet et vérifier avec un chronomètre que la transition prend au moins 2 secondes.

### Vérification Manuelle
- S'assurer que le logo continue de tourner pendant l'attente.

---
**🟥🟨 VALIDATION REQUISE :** _Confirmez-vous ce délai de 2 secondes par défaut ?_
