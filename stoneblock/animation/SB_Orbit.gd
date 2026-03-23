@tool
class_name SB_Orbit
extends Node

## 🛰️ SB_Orbit : Fait graviter un objet autour d'un centre ou d'une cible.
## Idéal pour des planètes, des satellites ou des effets de particules.

@export_group("Orbit Settings")
## Le rayon de l'orbite.
@export var radius: float = 5.0
## Vitesse de rotation (degrés par seconde).
@export var speed: float = 45.0
## Axe de rotation.
@export var axis: Vector3 = Vector3.UP
## Phase initiale (en degrés).
@export var initial_phase: float = 0.0

@export_group("Target")
## Le nœud à faire orbiter. Si vide, utilise le parent.
@export var target_node: Node3D
## Le centre de l'orbite (si vide, utilise la position (0,0,0) locale).
@export var orbit_center: Node3D

var _angle: float = 0.0

func _ready() -> void:
    if not target_node and get_parent() is Node3D:
        target_node = get_parent()
    _angle = deg_to_rad(initial_phase)

func _process(delta: float) -> void:
    if not target_node:
        return
        
    if not Engine.is_editor_hint() or (Engine.is_editor_hint() and get_viewport().get_camera_3d()):
        _angle += deg_to_rad(speed) * delta
    
    var offset = Vector3.ZERO
    
    # Calcul de la position orbitale basée sur l'axe
    var q = Quaternion(axis.normalized(), _angle)
    # On définit un vecteur de base perpendiculaire à l'axe pour le rayon
    var base_vec = Vector3.RIGHT
    if abs(axis.normalized().dot(Vector3.RIGHT)) > 0.9:
        base_vec = Vector3.UP
        
    var radial_vec = (axis.normalized().cross(base_vec)).normalized()
    offset = q * (radial_vec * radius)

    if orbit_center:
        target_node.global_position = orbit_center.global_position + offset
    else:
        target_node.position = offset
