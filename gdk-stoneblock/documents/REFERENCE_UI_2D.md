# 📖 Référence : Composants UI 2D Standards (Style Fortnite)

Ce document répertorie les composants d'interface 2D couramment utilisés dans les jeux modernes, avec un focus sur les éléments inspirés de **Fortnite**. Ils serviront de base pour le cycle de développement des **Démos 1 à 9**.

## 🔴 1. HUD (Heads-Up Display) - Jeu en temps réel
Composants affichés en permanence ou dynamiquement pendant l'action :
- **Barres de Statut (Mètres)** : 
    - Vie (Health), Bouclier (Shield), Énergie/Endurance.
    - Utilise des shaders pour les effets de remplissage (smooth lerp).
- **Navigation** :
    - **Minimap** : Vue du dessus avec position du joueur et icônes.
    - **Boussole (Compass)** : Bandeau horizontal (0-360°) avec marqueurs d'objectifs.
- **Combat & Interaction** :
    - **Réticule (Crosshair)** : Dynamique (s'écarte au tir) et contextuel.
    - **Indicateur de Dégâts** : Textes flottants (Floating Damage Numbers) ou flashs à l'écran.
    - **Feed d'Éliminations** : Journal textuel compact en haut à droite.
- **Informations Contextuelles** :
    - **Journal de Mission/Quête** : Liste d'objectifs simplifiée.
    - **Quickbar** : Slots d'inventaire rapide (chiffres 1-5).
    - **Indicateurs d'interaction** : "(E) Rechercher" au-dessus des objets 3D.

## 🔵 2. Menus & Interfaces de Gestion
Fenêtres interactives de plein écran ou overlays :
- **Inventaire (Grid-based)** : Grilles d'items avec drag-and-drop et tooltips.
- **Lobby / Choix de Mode** : Cartes cliquables avec animations au survol.
- **Boutique / Battle Pass** : Carrousel d'items avec prévisualisation.
- **Paramètres (Settings)** :
    - **Sliders** : Volume, Sensibilité, Échelle du HUD.
    - **Checkboxes / Toggles** : Inversion d'axe, Mode Daltonien.
    - **Dropdowns / Tabs** : Catégories de réglages (Vidéo, Audio, Contrôles).
- **Chat Log** : Zone de texte défilante avec canaux (Team, Party).

## 🟢 3. Feedback & Effets de Transition
- **Notifications de Zone** : Texte large au centre ("Bienvenue à StoneBlock").
- **Écrans de Fin (Victory/Game Over)** : Overlays avec statistiques de fin de partie.
- **Loading Progress** : Barres de progression détaillées (Phase 1, Phase 2...).

---
*Référence établie le : 21/03/2026*
