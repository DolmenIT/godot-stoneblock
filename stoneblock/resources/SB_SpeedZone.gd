@tool
extends Resource
class_name SB_SpeedZone

## 🎢 SB_SpeedZone : Définition d'une zone de changement de vitesse dynamique.

@export_group("Range")
## Position Z au-delà de laquelle la zone s'active (Début).
@export var start_z: float = 0.0
## Position Z en-dessous de laquelle la zone s'arrête (Fin).
@export var end_z: float = -1000.0

@export_group("Speeds")
## Vitesse de défilement de la caméra principale (Mainground).
@export var mainground_speed: float = -1.0
## Vitesse de défilement du décor de fond (Background). Laisse à 0 pour copier Mainground.
@export var background_speed: float = 0.0

@export_group("Transition")
## Fluidité du changement (plus c'est élevé, plus c'est rapide). 0 = Instantané.
@export var smoothness: float = 2.0
