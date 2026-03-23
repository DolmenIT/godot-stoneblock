# SB_FadeToColor

Composant StoneBlock pour effectuer un fondu progressif vers une couleur unie sur l'écran.

## Propriétés
- **Start Time** : Temps en secondes avant le début du fondu.
- **End Time** : Temps en secondes pour que la couleur soit opaque.
- **Fade Color** : La couleur cible du fondu.
- **Layer** : Index du `CanvasLayer`. Permet de recouvrir sélectivement des éléments (ex: dialogues à 120).

## Fonctionnement
Le script crée dynamiquement un `CanvasLayer` et un `ColorRect` au démarrage. Il anime ensuite l'alpha de la couleur du rectangle en fonction du temps écoulé.
