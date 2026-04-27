# [IP-119] SB_BloomTagger : Support Multi-Instances et Cumul de Calques

## Problématique
Lorsqu'on utilise plusieurs instances de `SB_BloomTagger` sur un même nœud (ex: un pour le rouge, un pour le bleu), le dernier tagger écrase systématiquement les calques (layers) et les matériaux d'émission des précédents.

## Objectifs
- Permettre le cumul des masques de calques (OR bitwise).
- Rendre l'application du shader d'émission sélective par surface.
- Éviter les conflits de matériaux entre plusieurs taggers.

## Changements proposés

### [NEW] [SB_BloomTagger_Color.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/gdk-stoneblock/visual/SB_BloomTagger_Color.gd)
- Nœud enfant pour définir une couleur de bloom spécifique.

### [MODIFY] [SB_BloomTagger.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/gdk-stoneblock/visual/SB_BloomTagger.gd)
- Gestion du multi-couleurs via un shader spatial à 16 slots.
- Collecte dynamique des nœuds enfants `SB_BloomTagger_Color`.
- Support des matériaux avec textures via un bypass de détection intelligent.

## Plan de Vérification
- [ ] Test avec 2 taggers sur un mesh possédant 2 matériaux distincts (Rouge et Bleu).
- [ ] Vérifier que les layers 11, 12 ou 13 se cumulent correctement dans l'inspecteur.
- [ ] Valider que le shader d'émission n'est appliqué qu'aux zones filtrées.

---
📅 **Demandé** : 2026-04-25
🚀 **Lancé** : 2026-04-25
✅ **Terminé** : 2026-04-25
