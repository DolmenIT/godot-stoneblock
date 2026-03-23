# [IP-006] SB_Core en tant que Singleton (Service Global)

L'objectif est d'aligner `SB_Core` sur le fonctionnement natif de Godot en l'utilisant comme un **Autoload** (Singleton). Cela permettra à n'importe quel script ou composant du jeu d'accéder aux services StoneBlock (chargement asynchrone, config, etc.) sans avoir besoin de références locales.

## Alignement Godot vs Unreal
- **Godot (Autoload)** : Persistance globale au-dessus de l'arbre des scènes.
- **Unreal (GameInstance)** : Persistant entre les niveaux.
- **SB_Core** : Sera notre "GameInstance" à la sauce Godot.

## Changements Proposés

### [Component] Core / Singleton
#### [MODIFY] [SB_Core.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/core/SB_Core.gd)
- Rendre le script plus robuste pour fonctionner de manière autonome.
- Ajouter des méthodes d'accès simplifié (p.ex. `SB.load_scene(path)`).

### [Integration] Configuration Projet
#### [MANUAL] [Godot Project Settings]
- Demander à l'utilisateur d'ajouter `res://stoneblock/core/SB_Core.gd` dans les Autoloads sous le nom `SBCore`.

### [Integration] Démo
#### [MODIFY] [demo1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/demo1.tscn)
- (Optionnel) Supprimer le nœud local `SB_Core` si on passe en Autoload pur, ou le conserver comme "Configurateur de niveau".

## Plan de Vérification

### Tests Automatisés
- Vérifier l'accès à `SBCore` depuis n'importe quel script.

### Vérification Manuelle
- Lancer le jeu et confirmer que le chargement asynchrone fonctionne toujours via le Singleton.

---
**🟥🟨 VALIDATION REQUISE :** _Êtes-vous d'accord pour faire de `SB_Core` un **Autoload** (Singleton) global ?_
