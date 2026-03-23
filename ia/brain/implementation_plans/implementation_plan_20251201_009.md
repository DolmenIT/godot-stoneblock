# Implementation Plan - ActionTrigger : Composant Générique pour Actions EventMaster (20251201_009)

> [!IMPORTANT]
> **PROTOCOL**:
> 1. Always follow the **latest** implementation plan in progress.
> 2. **NEVER DELETE** implementation plans. Keep them for history.

## 📅 Timeline
- **Début** : 2025-12-01 ~11:59
- **Statut** : ✅ **COMPLETED**

## Objectif

Créer un composant générique `ActionTrigger` qui peut être attaché comme enfant des nœuds d'événements EventMaster (Pressed, Released, HoverEnter, HoverExit) pour déclencher des actions comme le chargement de scène, l'émission de signaux, ou l'appel de méthodes.

## État des lieux

### Problème identifié
Actuellement, pour gérer les actions lors d'un clic sur un bouton, il faut :
1. Configurer l'EventMaster dans le script du bouton
2. Connecter le signal `event_pressed` à une méthode
3. Émettre un signal depuis le bouton
4. Écouter le signal dans le screen/scène parente

C'est beaucoup de code pour une action simple comme charger une scène.

### Solution proposée
Créer un composant `ActionTrigger` qui peut être attaché directement comme enfant du nœud "Pressed" (ou autres) dans l'EventMaster, permettant de déclencher des actions sans code supplémentaire.

## Changements proposés

### 1. Créer ActionTrigger
#### [NEW] `scripts/components/action_trigger.gd`
- **Type** : Script attachable à un Node
- **Fonctionnalités** :
  - Support de plusieurs types d'actions (enum ActionType)
  - Chargement de scène (LOAD_SCENE)
  - Émission de signal (EMIT_SIGNAL)
  - Appel de méthode (CALL_METHOD)
  - Changement de scène (CHANGE_SCENE)
  - Délai configurable avant exécution
  - Méthode `_trigger(event_master)` appelée par EventMaster

### 2. Créer SceneLoader (optionnel)
#### [NEW] `scripts/components/scene_loader.gd`
- **Type** : Script qui hérite de ActionTrigger
- **Fonctionnalités** :
  - Pré-configuré pour LOAD_SCENE
  - Plus simple à utiliser si on veut juste charger une scène

## Structure d'utilisation

### Exemple dans .tscn
```
BtnSkip (TextureButton)
└── EventMaster (Node2D)
    └── Pressed (Node)
        ├── ShowPressedOverlay (TweenAlpha)
        ├── ScaleDown (TweenScale)
        └── LoadNextScene (ActionTrigger ou SceneLoader)  ← NOUVEAU
            - action_type: LOAD_SCENE
            - scene_path: "res://scenes/200_welcome_scene/200_welcome_scene.tscn"
```

### Exemple d'utilisation
1. **Charger une scène** : Attacher `SceneLoader` au nœud "Pressed", configurer `scene_path`
2. **Émettre un signal** : Attacher `ActionTrigger`, configurer `action_type: EMIT_SIGNAL`, `signal_target`, `signal_name`
3. **Appeler une méthode** : Attacher `ActionTrigger`, configurer `action_type: CALL_METHOD`, `method_target`, `method_name`

## Étapes d'implémentation

### Étape 1 : Créer ActionTrigger
**Timecode** : 2025-12-01 ~11:59  
**Statut** : ✅ **COMPLETED**

1. ✅ Créer `scripts/components/action_trigger.gd`
2. ✅ Implémenter enum ActionType avec 4 types d'actions
3. ✅ Implémenter méthode `_trigger(event_master)`
4. ✅ Implémenter les méthodes privées pour chaque type d'action
5. ✅ Ajouter support du délai

**Résultats** : Composant générique créé, supporte 4 types d'actions.

### Étape 2 : Créer SceneLoader
**Timecode** : 2025-12-01 ~11:59  
**Statut** : ✅ **COMPLETED**

1. ✅ Créer `scripts/components/scene_loader.gd`
2. ✅ Hériter de ActionTrigger
3. ✅ Pré-configurer action_type à LOAD_SCENE

**Résultats** : Composant spécialisé créé pour simplifier le chargement de scènes.

## Décisions techniques

### ActionTrigger vs SceneLoader
- **ActionTrigger** : Composant générique pour toutes les actions
- **SceneLoader** : Composant spécialisé pour simplifier le chargement de scènes
- **Raison** : Flexibilité + Simplicité selon le besoin

### Intégration avec EventMaster
- **Méthode** : `_trigger(event_master)` appelée automatiquement par EventMaster
- **Compatibilité** : Fonctionne avec l'architecture EventMaster existante
- **Pas de modification** : EventMaster n'a pas besoin d'être modifié

### Types d'actions supportés
- **LOAD_SCENE** : Instancie et ajoute une scène à l'arbre
- **CHANGE_SCENE** : Change de scène avec `change_scene_to_file`
- **EMIT_SIGNAL** : Émet un signal sur un nœud cible
- **CALL_METHOD** : Appelle une méthode sur un nœud cible

## Notes

- Le composant peut être attaché à n'importe quel nœud d'événement (Pressed, Released, HoverEnter, HoverExit)
- Support du délai pour retarder l'exécution de l'action
- Validation et messages d'erreur clairs
- Documentation complète dans les commentaires

## Résumé de l'implémentation

### Fichiers créés
- `scripts/components/action_trigger.gd` : Composant générique pour actions
- `scripts/components/scene_loader.gd` : Composant spécialisé pour chargement de scènes

### Avantages
- ✅ **Simplicité** : Plus besoin de code pour charger une scène, juste configurer dans l'éditeur
- ✅ **Réutilisabilité** : Peut être utilisé pour n'importe quel bouton ou élément UI
- ✅ **Flexibilité** : Supporte plusieurs types d'actions
- ✅ **Intégration** : Fonctionne avec l'architecture EventMaster existante
- ✅ **Pas de breaking changes** : L'ancien système (signaux) continue de fonctionner

### Utilisation future
Le composant peut être utilisé pour :
- Charger des scènes lors d'un clic
- Émettre des signaux depuis n'importe quel événement
- Appeler des méthodes sur des nœuds cibles
- Combiner plusieurs actions (plusieurs ActionTrigger dans le même nœud)

