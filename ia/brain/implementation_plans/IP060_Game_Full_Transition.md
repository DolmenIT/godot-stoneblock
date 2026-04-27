# Implementation Plan - Transition vers Jeu Complet (IP060)

> [!IMPORTANT]
> **PROTOCOLE**:
> 1. Ce plan vise à transformer la démo technique StoneBlock en une expérience de jeu complète.
> 2. **NE JAMAIS SUPPRIMER** les plans d'implémentation. Les conserver pour l'historique.

## 📅 Timeline
- **Début** : 2026-04-01 ~14:50
- **Statut** : 🔄 **IN PROGRESS**

## 🎯 Objectifs
Transformer la démo StoneBlock en un jeu complet en ajoutant un Boss de fin de niveau, un flux de victoire, et un nettoyage final des dossiers obsolètes.

## 🛠️ Changements Proposés

### 1. Système de Boss (Fin de Stage)
#### [NEW] `stoneblock/enemies/SB_Boss_VShmup.gd`
- Nouvelle classe héritant de `SB_Enemy_VShmup` (ou structure similaire).
- Gestion de PV élevés et barre de vie HUD dédiée.
- Phases de combat basées sur le \% de PV.
- Patterns de projectiles complexes (cercles, vagues).

#### [NEW] `demo/demo1/enemies/SB_Boss_1.tscn`
- Scène du premier Boss utilisant le modèle `emerald_nexus_disk.glb` (ou une variante plus imposante).

### 2. Flux de Victoire & Transition
#### [MODIFY] `stoneblock/gamemodes/SB_GameMode_VShmup.gd`
- Ajout d'un état `is_victory`.
- Déclenchement de la victoire à la mort du Boss.
- Stopper le scrolling et nettoyer les ennemis restants.

#### [NEW] `stoneblock/ui/SB_Victory_VShmup.tscn`
- Nouvel écran de succès affichant : "STAGE CLEAR", Score final, Coins récoltés.
- Bouton "Réessayer" et "Menu Principal".

### 3. Nettoyage de Structure (Conformité)
- Le dossier `cosmic-hypersquad/` est désormais ignoré par Git.
- Les fichiers déplacés par l'utilisateur ne doivent plus être référencés par les scènes de la démo.

## ❓ Questions Ouvertes
- **Type de Boss** : Dois-je créer un Boss qui apparaît à la fin d'un timer de niveau ou à la fin physiquement du scrolling vertical ?
- **Patterns** : Préfères-tu des tirs pré-calculés (curtain fire) ou des tirs qui visent le joueur ?

## 🧪 Plan de Vérification
1. **Test Boss** : Lancer le Boss seul pour tester ses phases et sa barre de vie.
2. **Flux Complet** : Faire une partie complète de la démo (Stage 1) et vérifier que la mort du Boss déclenche bien l'écran de victoire.
3. **Persistance** : Vérifier que les Coins gagnés pendant le combat contre le Boss sont bien enregistrés dans le Core (`game_stats.json`).
