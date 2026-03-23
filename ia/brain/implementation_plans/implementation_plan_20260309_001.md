# Implementation Plan - Optimisation Sauvegarde Terrain (Dirty Flag SB_HeightmapGrid) (20260309_001)

> [!IMPORTANT]
> **PROTOCOL**  
> - Plan créé pour documenter le système de *dirty flag* sur `SB_HeightmapGrid` et l'interception de sauvegarde dans `terrain_brush_plugin.gd`.  
> - Les modifications de code ont déjà été appliquées pendant la session du 2026-03-09.  
> - Ce plan sert de **trace historique** + base pour ajustements ultérieurs si tu veux raffiner le comportement.

## 📅 Timeline
- **Début** : 2026-03-09 ~??:??  
- **Validation utilisateur** : 2026-03-09 ~??:??  
- **Statut** : ✅ **COMPLETED**

## 🎯 Objectif
Accélérer la sauvegarde des scènes contenant des terrains en évitant de ré‑extraire systématiquement toutes les ressources (`.res`) quand le terrain n’a pas été modifié depuis la dernière extraction.

## 1. Ajout d’un Dirty Flag sur `SB_HeightmapGrid`
- **Fichier** : `scripts/components/SB_HeightmapGrid.gd`
- **But** : Savoir si les ressources du terrain (heightmaps, textures, mesh, splatmaps) ont été modifiées depuis la dernière extraction.
- **Étapes** :
  1. Ajouter `var _resources_dirty: bool = false` + helpers :
     - `mark_resources_dirty(reason := "")`
     - `mark_resources_clean()`
     - `are_resources_dirty() -> bool`
  2. Passer à **dirty** dans les cas suivants :
     - `generate_grid()` (nouveau maillage complet).
     - `on_heightmap_edited()` (sculpt/paint sur un chunk).
     - (Option future : hooker d’autres opérations lourdes si besoin : blur global, auto‑paint complet, etc.)

## 2. Conditionner `extract_all_resources` au Dirty Flag
- **Fichier** : `scripts/components/SB_HeightmapGrid.gd`
- **But** : Ne lancer l’extraction que si nécessaire.
- **Étapes** :
  1. En début de `extract_all_resources(progress_dialog := null, force_sync := false)` :
     - Si `heightmap_generators` vide → early return (comme avant).
     - **Nouveau** : si `not are_resources_dirty()` → log optionnel (`debug_verbose_logs`) + **return** (pas d’extraction).
  2. Après la boucle d’extraction de tous les terrains :
     - Appeler `mark_resources_clean()` pour signaler que les `.res` sont à jour.

## 3. Intégration avec le Plugin (`_apply_changes`)
- **Fichier** : `addons/terrain_brush_plugin/terrain_brush_plugin.gd`
- **But** : Éviter de bloquer la sauvegarde si la grille n’est pas dirty.
- **Étapes** :
  1. Dans `_extract_all_managers_recursive(node)` :
     - Si `node is SB_HeightmapGrid` :
       - Vérifier `node.has_method("are_resources_dirty") and not node.are_resources_dirty()` :
         - Si **false** → lancer `node.extract_all_resources(null, true)` (comme avant).
         - Si **true** → **skipper** l’extraction pour ce manager.

## 4. Effets attendus & Points de vigilance
- **Effets positifs** :
  - Sauvegardes **quasi instantanées** quand tu n’as pas touché au terrain depuis la dernière extraction.
  - Comportement identique à avant (extraction complète) dès que tu sculptes/peins/génères une nouvelle grille.
- **Points de vigilance** :
  - Bien garder en tête que l’extraction ne se relance qu’après une vraie modif (dirty flag).  
  - Si tu veux forcer une extraction manuelle (ex: avant commit), on pourra ajouter plus tard :
    - un bouton “**Force Extract Now**” sur `SB_HeightmapGrid`,
    - ou une option dans la toolbar.

## ✅ État actuel
- Code du dirty flag + condition d’extraction déjà en place et validé par l’utilisateur.  
- Prochain ajustement éventuel : affiner **quelles opérations** marquent le terrain comme dirty selon ton ressenti en usage réel (brush seul, auto‑paint, blur global, etc.).

## 📝 Notes de validation
- ✅ Validation utilisateur obtenue le 2026-03-09.  
- Le système est opérationnel : sauvegardes rapides si terrain non modifié, extraction complète si dirty.

