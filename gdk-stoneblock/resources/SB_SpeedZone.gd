@tool
@icon("res://gdk-stoneblock/assets/icons/SB_UI.svg")
extends Resource
class_name SB_SpeedZone

## 🎢 SB_SpeedZone : Définition d'une zone de changement de vitesse dynamique.

@export_group("Range")
## Position Z au-delÃ  de laquelle la zone s'active (DÃ©but).
@export var start_z: float = 0.0
## Position Z en-dessous de laquelle la zone s'arrÃªte (Fin).
@export var end_z: float = -1000.0

@export_group("Speeds")
## Vitesse de dÃ©filement de la camÃ©ra principale (Mainground).
@export var mainground_speed: float = -1.0
## Vitesse de dÃ©filement du dÃ©cor de fond (Background). Laisse Ã  0 pour copier Mainground.
@export var background_speed: float = 0.0

@export_group("Transition")
## FluiditÃ© du changement (plus c'est Ã©levÃ©, plus c'est rapide). 0 = InstantanÃ©.
@export var smoothness: float = 2.0
