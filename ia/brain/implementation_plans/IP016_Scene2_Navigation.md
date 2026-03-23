# [IP-016] Scène 2 et Navigation Inter-Scènes
**Statut : 🟢 Actif**
**Date : 2026-03-20**

## 🕒 Timecodes
- **Discussion & Analyse** : 2026-03-20 ~17:28
- **Exécution** : 2026-03-20 ~17:35
- **Validation** : ✅ Terminée le 2026-03-20


L'objectif est d'étendre la démo avec une nouvelle scène interactive et un système de navigation par bouton.

## 🎯 Objectifs
L'objectif est d'étendre la démo avec une nouvelle scène interactive et un système de navigation par bouton utilisant le chargement asynchrone de `SB_Core`.

## 🛠️ Modifications Proposées

### [Component] UI
#### [NEW] [SB_Button.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_Button.gd)
- Bouton intelligent avec actions prédéfinies (Chargement de scène, Quitter, etc.).
- **Paramètres** : Texte, Action (Enum), Chemin Scène Cible.

#### [NEW] [SB_UI_Layer.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/ui/SB_UI_Layer.gd)
- Conteneur `CanvasLayer` spécialisé pour regrouper les composants UI StoneBlock.
- Gère l'ordonnancement (Layer) et la visibilité globale.

### [Scènes]
#### [MODIFY] [scene2.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/scene2.tscn)
- Utilisation de `SB_UI_Layer` à la place du `CanvasLayer` brut.
- Remplacement du bouton standard par `SB_Button` configuré pour charger `scene1`.

#### [MODIFY] [scene1.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/scene1.tscn)
- Utilisation de `SB_UI_Layer`.
- Remplacement du bouton par `SB_Button` configuré pour charger `scene2`.

## 🧪 Plan de Vérification
- [ ] Lancer `demo1.tscn`.
- [ ] Cliquer sur "Scène Suivante" dans `scene1`.
- [ ] Vérifier que le Splash Screen apparaît (grâce à `SB_Core`).
- [ ] Vérifier que `scene2` se charge et que les 10 sphères orbitent.
- [ ] Cliquer sur "Précédent" dans `scene2` et revenir à `scene1`.

**Dernière mise à jour : 2026-03-20**
