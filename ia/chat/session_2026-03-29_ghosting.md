# 📓 Session 2026-03-29 — Ghosting Manuel des Projectiles (IP-049)

## 🎯 Objectif
Remplacer le système de traînée par particules (`GPUParticles3D`) par un Ghosting "Pixel-Perfect" basé sur la duplication contrôlée de sprites, pour un effet de vitesse propre et précis à 60fps.

## 🔑 Décisions Techniques
- **Méthode retenue** : Duplication de `AnimatedSprite3D` (`_visual_node.duplicate()`) × 3 dans `_ready()`.
- **Positionnement** : Interpolation via `_prev_pos` stocké avant le déplacement → `trail_vec * factor`. Facteurs : 0.5 / 1.0 / 1.5 (espacement double pour lisibilité).
- **Transparence** : `node.modulate = Color(r, g, b, alpha)` → le plus simple et le plus fiable.
- **Billboard** : Propriété `billboard = 1` sur le nœud `AnimatedSprite3D` directement (pas dans le matériau).
- **Matériau** : Suppression du `material_override` qui bloquait `modulate` (source de tous les problèmes d'alpha).

## 🐛 Bugs résolus
| Erreur | Cause | Fix |
|--------|-------|-----|
| `Parse Error: already named "movement"` | Double `var movement` dans `_update_movement` | Renommage en `trail_vec` |
| `Parse Error: same name as previous function` | Double `func _process` dans script ennemi | Réécriture complète |
| Fantômes tous au même alpha | `material_override` bloquait `modulate` | Suppression du `material_override` |
| Sprite invisible / rectangle gris | `billboard_mode` dans l'ancien matériau perdu | `billboard = 1` sur le nœud |
| `is_inside_tree()` errors | Fantômes créés avant d'être dans l'arbre | `call_deferred("_apply_vfx_settings")` |

## 📁 Fichiers modifiés
- `stoneblock/projectiles/SB_Projectile_VShmup.gd`
- `stoneblock/projectiles/SB_Projectile_Enemy_VShmup.gd`
- `stoneblock/projectiles/SB_Projectile_VShmup.tscn`
- `stoneblock/projectiles/SB_Projectile_Enemy_VShmup.tscn`
- `demo/demo1/projectiles/bullet_player_1.tscn`
- `demo/demo1/projectiles/bullet_enemy_1.tscn`

## 💬 Message de commit suggéré
```
feat(projectiles): ghosting manuel sub-frame par duplication de sprite
```
