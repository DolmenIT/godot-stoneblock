# Walkthrough : Démo du Cube RGB (Phase 2)

Nous avons mis en place la première démonstration visuelle du GDK **DAGX StoneBlock** en créant des composants modulaires et réutilisables.

## 🚀 Réalisations

### 1. Nouveaux Composants "No-Code"
- **SB_Rotate3D** : Rotation continue paramétrable.
- **SB_ColorCycle** : Défilement RGB automatique.

### 2. Architecture Asynchrone (Bootstrapper & Singleton)
- **SBCore (Global)** : Singleton accessible via `SBCore`. Gère la transition et le nettoyage.
- **demo1.tscn (Splash Screen)** : Affiche le logo StoneBlock 3D animé (`SB_Rotate3D`) pendant le chargement.
- **scene1.tscn** : Le niveau chargé en arrière-plan.
- **Transition Fluide** : `SBCore` attend au moins 2 secondes avant de basculer.
- **Console 100% Autonome** : Le composant `SB_DebugConsole` intègre son propre `CanvasLayer`. Il est totalement indépendant de la structure UI de la scène.

## 🧪 Résultats
Le démarrage du projet est désormais visuel et fluide : le logo tourne instantanément, et `scene1` apparaît sans interruption dès qu'elle est chargée. 

---
*Léo "Antigrav" Valery - 2026-03-20*
