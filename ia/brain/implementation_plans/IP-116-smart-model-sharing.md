# IP-116 : Optimisation SB_StandardModel (Partage Intelligent)

## Description
Réduction de la consommation mémoire en évitant la duplication systématique des matériaux dans `SB_StandardModel`.

## Proposed Changes

### [StoneBlock Visual]

#### [MODIFY] [SB_StandardModel.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/visual/SB_StandardModel.gd)
- Analyse du matériau d'origine.
- Si les propriétés demandées (Metallic, Roughness, Albedo) sont identiques à celles du matériau d'origine, ne pas faire de `duplicate()`.
- Utilisation de `material_override` uniquement si nécessaire.

---

## Verification Plan
### Automated Tests
- Vérifier dans l'inspecteur distant que plusieurs ennemis partagent la même ressource Material si leurs réglages sont identiques.
