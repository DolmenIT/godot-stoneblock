# SB_Alignement3D

Composant de gestion de mise en page (Layout) simplifié pour aligner des éléments 3D sur l'écran.

## 📄 Description
Ce composant permet de positionner automatiquement son parent par rapport aux bords de la caméra orthogonale. Il utilise un système de double ancrage : une ancre sur le parent et une ancre sur la cible (l'écran).

## ⚙️ Propriétés

| Propriété | Description |
| :--- | :--- |
| `parent_anchor` | Point de référence sur l'objet parent (ex: son coin). |
| `target_anchor` | Point de référence sur l'écran (ex: le coin de la caméra). |
| `offset_pixels` | Décalage manuel en pixels (X: droite, Y: haut). |
| `auto_detect_dimensions` | Tente de détecter `width` / `height` si le parent est un Sprite. |
| `parent_width_px` | Largeur du parent en pixels (si non détectée). |
| `parent_height_px`| Hauteur du parent en pixels (si non détectée). |
| `pixel_size` | Taille d'un pixel en unités 3D (défaut: 0.01). |

## 🛠️ Exemple d'utilisation
Pour aligner un logo en bas à droite avec une marge de 20 pixels :
1. Attachez `SB_Alignement3D` au Logo (Sprite3D).
2. Réglez `parent_anchor` sur `BOTTOM_RIGHT`.
3. Réglez `target_anchor` sur `BOTTOM_RIGHT`.
4. Réglez `offset_pixels` sur `(-20, 20)`. (Négatif en X pour aller vers la gauche, Positif en Y pour monter).
