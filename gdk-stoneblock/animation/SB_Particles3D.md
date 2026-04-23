# SB_Particles3D

Système de particules flexible pour **StoneBlock**. Il permet de créer des jets de particules (cercles, images ou animations) avec un contrôle précis des trajectoires locales.

## ⚙️ Propriétés

### 📍 Spawn & Trajectoire
| Propriété | Description |
| :--- | :--- |
| `origin_offset` | Décalage XYZ par rapport à l'émetteur. |
| `spawn_radius` | Rayon de dispersion (r1) au point de départ. |
| `direction_angles` | Orientation de base du jet (AX, AY, AZ) en degrés. |
| `direction_spread` | Rayon de dispersion (r2) de la direction (crée un cône). |
| `min_power` / `max_power` | Puissance de projection (vitesse). |
| `local_space` | Si `false`, les particules sont indépendantes du parent après le spawn. |
| `emission_rate` | Nombre d'intervalles d'émission par seconde. |
| `amount_min` | Quantité minimale de particules par intervalle. |
| `amount_max` | Quantité maximale (pour créer des trainées/rafales). |
| `burst_spacing` | Espacement interne d'un burst. Plus c'est petit, plus la trainée est dense. |

### 🎨 Visuels
| Propriété | Description |
| :--- | :--- |
| `visual_mode` | `COLOR_CIRCLE` (cercle uni), `IMAGE` ou `ANIMATED`. |
| `particle_color` | Modulation de couleur. |
| `particle_image` | Texture pour le mode image. |
| `sprite_frames` | Animation pour le mode animé. |
| `billboard` | Si actif, les particules font face à la caméra. |
| `random_initial_rotation` | Donne un angle de départ aléatoire (0-360°). |
| `rotation_speed_min/max`| Vitesse de rotation continue du sprite (degrés/sec). |

### ⏳ Vie & Taille
| Propriété | Description |
| :--- | :--- |
| `lifetime` | Temps avant disparition (en sec). |
| `start_scale` | Taille initiale de la particule. |
| `end_scale` | Taille finale (permet l'évanouissement). |

### 🌍 Physique & Courbure
| Propriété | Description |
| :--- | :--- |
| `gravity` | Force constante (ex: Vector3(0, -9.8, 0)). |
| `attraction_to_origin` | Force attirant la particule vers son spawn. Utilisé pour créer des boucles ou des retours. |

## 🚀 Utilisation

1. Ajoutez `SB_Particles3D` à votre scène.
2. Configurez le `visual_mode` souhaité.
3. Ajustez `direction_angles` pour orienter le jet.
4. Utilisez `emission_rate` pour gérer le flux de particules.

---
*Fait partie du StoneBlock Animation System.*
