# 📓 Session 2026-03-30 — Bloom Fix & Shader Migration

**Heure** : ~08:35–09:40
**Sujet** : Fix du Bloom invisible, Migration vers Rendu Shader Gaussian et Extension globale.

## Travaux effectués

### 1. Fix Bloom Invisible (V1 - Glow Interne)
- Diagnostic : `own_world_3d` était à `true` et le mode de mélange n'était pas `ADD`.
- Correction : Passage en `own_world_3d = false` et ajout d'un `CanvasItemMaterial` en mode `ADD`.

### 2. Migration Shader (V2 - Gaussian Blur)
- Problématique : Le flou du Glow natif Godot 4 est instable sur fond transparent et manque de contrôle précis.
- Solution : Création de `SB_BloomBlur.gdshader` (Calcul de flou gaussien 9x9 optimisé).
- Implémentation : Remplacement du `CanvasItemMaterial` par un `ShaderMaterial` sur le `BloomViewportContainer`.
- Contrôle : Mise à jour de `SB_BloomConfig.gd` pour piloter `blur_radius` et `bloom_intensity`.

### 3. Extension Globale (V3)
- **Réacteurs** : Réduction des particules (48 -> 24) et passage sur le Layer 11.
- **Projectiles Ennemis** : Activation du Layer 11 sur le visuel et les 3 ghosts.
- **Loots & Pickups** : Mise à jour des classes de base (`SB_Loot_Base`, `SB_Pickable`) pour propager automatiquement le Layer 11 à tous les visuels enfants.

## Fichiers modifiés
- `demo/demo1/40_game_scene.tscn` (Shader + Config)
- `stoneblock/shaders/SB_BloomBlur.gdshader` (Nouveau)
- `stoneblock/ui/SB_BloomConfig.gd` (Refactor)
- `stoneblock/effects/SB_EngineParticles.tscn` (Layer 11 + Amount)
- `stoneblock/projectiles/SB_Projectile_Enemy_VShmup.gd` (Layer 11)
- `stoneblock/pickups/SB_Loot_Base.gd` (Layer 11 Auto)
- `stoneblock/core/SB_Pickable.gd` (Layer 11 Auto)

## Bilan Roadmap
- **[x] Bloom Sélectif (IP-050)** : ✅ Terminé et étendu.
- **[ ] Optimisation Android (IP-051)** : 🟦 Ajouté au TODO (Backlog).

## Commit suggéré
```
feat(bloom): migration shader gaussian blur + extension aux loots et tirs ennemis
```
