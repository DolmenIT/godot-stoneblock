# 🛰️ SB_Orbit

Composant d'animation permettant de faire graviter un objet autour d'un point central ou d'un autre nœud.

## ⚙️ Paramètres

### Orbit Settings
- **Radius** : La distance entre l'objet et le centre de l'orbite.
- **Speed** : La vitesse angulaire en degrés par seconde.
- **Axis** : L'axe autour duquel l'objet tourne (par défaut `UP` pour une orbite horizontale).
- **Initial Phase** : Angle de départ de l'objet sur son orbite.

### Target
- **Target Node** : Le nœud `Node3D` à déplacer. Si non défini, utilise le parent.
- **Orbit Center** : Le nœud servant de centre à l'orbite. S'il est vide, l'orbite se fait autour de l'origine locale `(0,0,0)`.

## 🛠️ Utilisation
Ajoutez ce nœud en tant qu'enfant d'un `MeshInstance3D` ou de n'importe quel `Node3D` pour le mettre en mouvement automatiquement.
