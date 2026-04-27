# [IP-053] Demo 1.1 : Structure du Niveau 1 (Placement Manuel)

Ce plan vise à transformer la scène de jeu actuelle en un véritable niveau structuré, en utilisant exclusivement le placement manuel des groupes d'ennemis (`SB_EnemyGroup_VShmup`) conformément aux règles du projet.

## 🧭 Contexte
Le projet utilise une architecture "No-Code" basée sur les noms de nœuds. Pour le Level Design, nous privilégions le placement manuel des groupes dans la scène du Mainground. Chaque groupe s'active automatiquement à une certaine distance du `Camera_Pivot`.

## 🛠️ Modifications Proposées

### [Niveau - Stage 1]

#### [MODIFY] [mainground.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/levels/level1/stage1/mainground.tscn)
1. **Nettoyage** : Standardiser tous les groupes pour utiliser `SB_Enemy_1.tscn` (ExtResource 2) au lieu de nœuds Area3D anonymes.
2. **Phase 1 : Introduction (Z= -50 à -120)**
   - Groupe 1 (Z-50) : 3 Disques (Formation V, pas de tir).
   - Groupe 2 (Z-90) : 4 Jets (Formation Ligne Horiz, pas de tir).
3. **Phase 2 : Escarmouche (Z= -150 à -280)**
   - Groupe 3 (Z-160) : 5 Disques (Formation Circle, tir faible). Mouvement sinusoïdal lent.
   - Groupe 4 (Z-220) : 4 Jets (Formation Square, tir moyen). Descente plus rapide.
4. **Phase 3 : Barrage (Z= -320 à -400)**
   - Groupe 5 (Z-330) : 6 Disques (Formation V, tir soutenu).
   - Groupe 6 (Z-380) : 3 Jets rapides croisant horizontalement.

## ❓ Questions Ouvertes
- Souhaitez-vous que je crée également une scène de "Boss" ou de "Transition" à la fin (Z -450), ou restons-nous sur une boucle de combat pour le moment ?

## ✅ Plan de Vérification
1. Lancer la scène `res://demo/demo1/demo1_shmup.tscn`.
2. Vérifier que les vagues s'enchaînent de manière fluide.
3. Valider l'activation par distance.
