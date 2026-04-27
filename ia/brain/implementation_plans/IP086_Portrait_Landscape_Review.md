# 🧠 [IP-086] Revue de Cohérence Portrait/Paysage - Démo 1

Ce plan vise à vérifier et stabiliser l'affichage des 5 écrans principaux de la démo 1 suite à la migration vers le système responsive de StoneBlock. L'objectif est de garantir une navigation fluide et visuellement premium sur mobile (Portrait) et desktop (Paysage).

## User Review Required

> [!IMPORTANT]
> - **Comportement Global** : Souhaitez-vous que je corrige directement les anchors/marges si je détecte un défaut, ou préférez-vous un rapport détaillé avant modification ?
> - **Simulation** : Les tests seront basés sur les capacités de redimensionnement dynamique du `SB_Core` (F11 en mode debug).

## Proposed Changes

### 1. [00_boot.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/00_boot.tscn)
- **Vérification** : S'assurer que `SB_Core` est configuré avec `initial_orientation = SBOrientation.LANDSCAPE` par défaut.
- **Impact** : Détermine le point de départ de la session de test.

---

### 2. [01_splashscreen_scene.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/01_splashscreen_scene.tscn)
- **Vérification** : Centrage du logo et de l'indicateur de chargement.
- **Anchors** : Vérifier que les éléments ne sont pas "écrasés" lors du passage au format Portrait (9:16).

---

### 3. [10_menu_principal.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/10_menu_principal.tscn)
- **Vérification** : Les boutons `SB_Button` doivent rester accessibles et centrés.
- **Structure** : Vérifier si l'usage de `VBoxContainer` ou `CenterContainer` est optimal pour le responsive.

---

### 4. [11_menu_levels.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/11_menu_levels.tscn)
- **Vérification** : La grille de sélection des niveaux doit s'adapter.
- **Navigation** : S'assurer que les titres ne débordent pas.

---

### 5. [40_game_scene.tscn](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/demo/demo1/40_game_scene.tscn)
- **Vérification HUD** : Validation du swap automatique entre `hud_landscape.tscn` et `hud_portrait.tscn`.
- **Clamping Caméra** : Vérifier que les limites de mouvement du joueur s'adaptent dynamiquement à la largeur du viewport.

## Open Questions

- **🟥🟨 VALIDATION REQUISE :** Devons-nous forcer une orientation spécifique pour certains écrans ou rester 100% dynamique partout ?

## Verification Plan

### Manual Verification
1. Lancement de chaque scène via l'éditeur.
2. Utilisation de la commande `toggle_orientation()` (F11) via le `SB_Core`.
3. Analyse visuelle des débordements.

### Timecodes
- **Discussion** : 2026-04-14 ~11:20
- **Étapes** : À définir après validation.
- **Fin** : À définir.
