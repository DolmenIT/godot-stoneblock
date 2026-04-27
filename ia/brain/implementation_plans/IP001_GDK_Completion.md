# [IP-001] Analyse et Complétion du GDK StoneBlock

Ce plan vise à stabiliser le nouveau projet **DAGX StoneBlock** en identifiant et restaurant les composants essentiels du GDK (Godot Development Kit) qui manquent encore après l'import initial.

## État des Lieux
- **Composants présents** : BlurScreen, FadeToColor, BloomSelector3D, Move3D, etc. (12 fichiers .gd).
- **Composants manquants (identifiés via doc)** : `SB_Heightmap`, `SB_HeightmapGrid`, et le système de `TerrainLevelBundle`.
- **Infrastructure IA** : OK (Dossier `ia/` complet et configuré).

## Changements Proposés

### [Component] Système de Terrain (GDK Core)
Restauration de la logique de terrain "Zéro-Fichier" mentionnée dans `ia/memory_ia.md`.

#### [NEW] [SB_Heightmap.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/terrain/SB_Heightmap.gd)
Wrapper StoneBlock autour du générateur de heightmap.
#### [NEW] [SB_HeightmapGrid.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/terrain/SB_HeightmapGrid.gd)
Gestion de la grille de terrain et extraction des ressources vers le bundle.

### [Component] Documentation & Cohérence
- [ ] Créer les fichiers `.md` homonymes pour chaque script `.gd` (règle 54).
- [ ] Vérifier l'existence des icônes correspondantes dans `stoneblock/icons/`.

## Plan de Vérification

### Tests Automatisés
- Vérification de la compilation des nouveaux scripts dans l'éditeur Godot.

### Vérification Manuelle
- Demander à l'utilisateur de valider l'import des scripts de terrain d'origine s'ils sont disponibles localement, ou proposer une ré-implémentation basée sur les spécifications.

---
**🟥🟨 VALIDATION REQUISE :** _Confirmez-vous que je dois procéder à la création/restauration des fichiers de terrain `SB_Heightmap.gd` et `SB_HeightmapGrid.gd` ?_
