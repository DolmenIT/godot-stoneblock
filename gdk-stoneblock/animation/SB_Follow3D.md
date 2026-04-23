# SB_Follow3D

Composant de suivi 3D pour le système **StoneBlock**. Il permet à un objet (souvent son parent) de maintenir une distance spécifique avec une cible désignée.

## ⚙️ Propriétés

| Propriété | Type | Description |
| :--- | :--- | :--- |
| `target_node` | `Node3D` | Le nœud qui sera déplacé. Par défaut, le parent direct. |
| `follow_target` | `Node3D` | Le nœud à suivre. |
| `distance` | `float` | La distance à maintenir (en mètres). |
| `use_3d_distance` | `bool` | Si actif, la distance est calculée sur les 3 axes. Sinon, l'axe Y est ignoré. |
| `smooth_speed` | `float` | Vitesse de lissage via interpolation (lerp). `0` pour un mouvement instantané. |
| `look_at_target` | `bool` | Si actif, l'objet tournera pour toujours faire face à la cible. |

## 🚀 Utilisation

1. Ajoutez un nœud `SB_Follow3D` comme enfant de l'objet qui doit suivre.
2. Glissez-déposez la cible dans le slot `follow_target`.
3. Ajustez la `distance` souhaitée (ex: `10.0`).
4. Réglez la `smooth_speed` pour un effet de caméra ou de compagnon plus fluide.

---
*Fait partie du StoneBlock Animation System.*
