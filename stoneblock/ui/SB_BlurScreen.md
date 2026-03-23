# SB_BlurScreen

Composant StoneBlock pour appliquer un flou progressif sur l'écran en utilisant un `CanvasLayer` et un shader de type `screen_texture`.

## Propriétés
- **Start Time** : Temps en secondes avant le début du flou.
- **End Time** : Temps en secondes pour atteindre le flou maximum.
- **Max Blur** : Intensité maximale du flou (LOD).
- **Layer** : Index du `CanvasLayer`. Permet de choisir quels éléments sont floutés (ceux ayant un index inférieur).

## Fonctionnement
Le script crée dynamiquement un `CanvasLayer` et un `ColorRect` couvrant tout l'écran au démarrage. Il anime ensuite l'uniform `blur_amount` du shader en fonction du temps écoulé.
