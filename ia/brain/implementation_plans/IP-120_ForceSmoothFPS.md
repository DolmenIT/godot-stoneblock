# IP-120 : Système d'Overrides et Presets de Qualité

Extension du système de qualité StoneBlock pour inclure des presets globaux et des contrôles granulaires par composant.

## User Review Required

> [!IMPORTANT]
> L'utilisation d'un preset (autre que `CUSTOM`) écrasera les valeurs manuelles des échelles et modes de Bloom. Le passage en mode `CUSTOM` permettra de reprendre le contrôle total sur chaque paramètre de forçage.

## Proposed Changes

### [Component] Quality Settings (Presets)

#### [MODIFY] [SB_QualityConfig.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/gdk-stoneblock/core/SB_QualityConfig.gd)
- Ajout de l'énumération `QualityPreset` :
  - `VERY_LOW` : (BG 0.5, MG 0.6, Bloom 0.2, Mode FAST)
  - `LOW` : (BG 0.7, MG 0.8, Bloom 0.4, Mode FAST)
  - `MEDIUM` : (BG 0.9, MG 0.9, Bloom 0.7, Mode BALANCED)
  - `ULTRA` : (BG 1.0, MG 1.0, Bloom 1.0, Mode ULTRA)
  - `CUSTOM` : (Laisse les réglages utilisateur)
- Ajout d'une propriété `@export var quality_preset` avec un setter `@tool` pour appliquer les valeurs immédiatement dans l'inspecteur.
- Ajout des flags de forçage (`force_bg_scale`, etc.) et de leurs valeurs respectives.

#### [MODIFY] [SB_QualityManager.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/gdk-stoneblock/core/SB_QualityManager.gd)
- Harmonisation avec `SB_QualityConfig` pour supporter les presets globaux au niveau du Manager.

---

### [Component] Rendering Logic

#### [MODIFY] [SB_ViewportManager.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/gdk-stoneblock/viewportmanagers/SB_ViewportManager.gd)
- Intégration des overrides dans `update_dynamic_resolution`.
- Priorité : **Preset / Overrides Manuels > Calcul Dynamique**.

## Verification Plan

### Manual Verification
- Sélectionner "Very Low Quality" dans le Manager et vérifier que les viewports s'ajustent instantanément à 0.5/0.6.
- Passer en "Custom" et forcer manuellement le Mainground à 1.0.
- Vérifier que le changement de preset dans l'éditeur (mode `@tool`) met bien à jour les sliders de l'inspecteur pour un feedback visuel clair.
