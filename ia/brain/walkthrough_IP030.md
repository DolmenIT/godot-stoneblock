# Walkthrough - [IP-030] Zone Morte Caméra (Horizontal Deadzone)

Cette modification améliore le confort visuel en empêchant la caméra de suivre chaque micro-mouvement horizontal du joueur, créant une zone centrale stable.

## Changements

### 🎥 SB_CameraManager_VShmup.gd
- **Zone Morte** : Ajout de `follow_deadzone_x` (défaut: 10.0).
- **Logique** : La caméra ne se déplace horizontalement que si la cible (le pivot) sort de la zone morte.
- **Visualisation Debug** : Ajout d'un rectangle Cyan semi-transparent (25% opacité) visible dans l'éditeur et en mode Debug pour matérialiser la zone.

## Tests Effectués
- Vérification du calcul de l'écart (abs diff > deadzone).
- Validation du positionnement dynamique du visuel debug au sol (Y=0.1).
- Test de la fluidité (lerp) lors de la sortie de zone.

## Résultat Visuel
Un rectangle Cyan apparaît au centre de la caméra Mainground. Le vaisseau peut se déplacer librement à l'intérieur sans que le décor ne défile horizontalement. Dès qu'il "pousse" un bord du rectangle, la caméra suit avec la fluidité habituelle.

```gdscript
# Extrait de la logique appliquée :
var diff_x = target_x - mainground_camera.position.x
if abs(diff_x) > follow_deadzone_x:
    var shift_x = diff_x - sign(diff_x) * follow_deadzone_x
    var final_target_x = mainground_camera.position.x + shift_x
    mainground_camera.position.x = lerp(mainground_camera.position.x, final_target_x, follow_smoothness * effective_delta)
```
