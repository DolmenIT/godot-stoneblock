# Répertoire des Calques (CanvasLayers) - StoneBlock

Ce document répertorie la hiérarchie d'affichage (pile des calques) utilisée dans le projet **Cosmic HyperSquad**. 
Plus le numéro est **élevé**, plus l'élément est affiché **par-dessus** les autres.

| Calque (Layer) | Nom / Usage | Description |
| :--- | :--- | :--- |
| **-128 à -1** | Arrière-plan profond | Utilisé pour des éléments de décor très lointains ou des sous-couches. |
| **0** | **Monde 3D & 2D Standard** | Le calque par défaut. C'est ici que tout le jeu est dessiné. |
| **99** | Darken Bloom Overlay | Applique un ombrage spécifique pour le rendu Selective Bloom. |
| **100** | Bloom Composite / Fades | Couche où le rendu du Bloom est fusionné. Utilisé aussi par les Fades Noir/Blanc système. |
| **110** | UI 3D Composite | Affiche le rendu final des éléments d'UI en 3D (SubViewports). |
| **111** | `SB_BlurScreen` (Flou) | Floute tout ce qui est en dessous (3D + Bloom + UI 3D). Les dialogues (120) restent nets. |
| **120** | **UI de Dialogue (Story)** | Calque principal des dialogues. Reste net au-dessus du flou par défaut. |
| **121** | `SB_FadeToColor` (Fondu) | Par défaut à 121 pour recouvrir absolument tout (monde + dialogues) à la fin. |
| **128** | `SB_SceneTimer` (Timer) | Affiche le temps écoulé de la scène (au-dessus de tout). |
| **130** | Sur-couche critique | Réservé pour des messages système, alertes ou menus de pause. |

## Guide de réglage
- **Pour flouter tout sauf le texte** : Mets le flou à `layer = 111`.
- **Pour faire un rideau noir total (UI comprise)** : Mets le fondu à `layer = 121`.
- **Pour qu'un élément passe sous tout le monde** : Utilise une valeur négative (ex: `-10`).

> [!NOTE]
> Ne pas confondre avec les **Render Layers (1-20)** de la 3D qui servent à la visibilité par la caméra. Ici, nous parlons du tri Z final sur ton écran.
