# [IP-081] Restauration du Bullet Time (Correction Conflit TimeScale)

Lors du rollback sur le Glow Natif, un bloc de "Turbo Debug" a été conservé ou modifié dans le GameMode. Ce bloc force la vitesse du temps à 100% à chaque frame si le bouton de turbo n'est pas pressé, empêchant tout autre système (comme le `SB_TimeManager`) de ralentir le jeu.

## User Review Required

> [!IMPORTANT]
> Le mode Turbo (Clic Droit) sera conservé mais sa logique sera modifiée pour ne plus écraser les autres effets temporels (Bullet Time).

## Proposed Changes

### [Component] GameMode

#### [MODIFY] [SB_GameMode_VShmup.gd](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/stoneblock/gamemodes/SB_GameMode_VShmup.gd)

- Modifier la logique du "MODE TURBO DEBUG" (lignes 285-290).
- Utiliser un `elif` pour ne réinitialiser le temps que si nous étions en mode Turbo (> 1.0).

```gdscript
	# --- MODE TURBO DEBUG (Clic Droit) ---
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Engine.time_scale = 5.0
		if player: player.is_debug_invulnerable = true
	elif Engine.time_scale > 1.0: # Fix : Ne reset que si on était en Turbo
		Engine.time_scale = 1.0
		if player: player.is_debug_invulnerable = false
```

## Verification Plan

### Manual Verification
- Lancer la scène de jeu.
- Vérifier le Turbo (Clic droit).
- Vérifier le Bullet Time (Prendre un dégat).
- Vérifier le retour visuel (Overlay Bleu).
