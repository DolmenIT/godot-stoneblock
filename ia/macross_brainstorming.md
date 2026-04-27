# 🧠 Brainstorming Visuel : Inspiration Macross Shooting Insight

Ce document analyse les codes visuels de **Macross Shooting Insight** pour enrichir l'identité graphique de notre **Cycle SHMUP (Démo 1)**.

## 📸 Références Capturées
Les images sont stockées dans : `ia/resources/macross_insight/`

### 1. [Composition de l'écran & UI Gameplay](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/ia/resources/macross_insight/shmup_ui_portraits.png)
- **Portraits Dynamiques** : Utilisation de portraits de personnages dans les coins (Bas-gauche / Milieu-droite) pour la narration "en vol".
- **HUD Technique** : Barres d'énergie et de bouclier très fines, hautement technologiques (motifs hexagonaux).
- **Lisibilité** : Fond sombre (espace) contrastant avec des tirs aux couleurs saturées (Cyan, Rose, Jaune).

### 2. [VFX & "Itano Circus"](file:///d:/Projets/DAGX%20StoneBlock/current/dagx-stone-block/ia/resources/macross_insight/shmup_gameplay_1.png)
- **Traînées de missiles** : Multiples traînées courbes qui remplissent l'écran sans le saturer complètement (gestion de l'opacité et du bloom).
- **Indicateurs de Verrouillage** : Cercles de lock-on animés autour des ennemis.

---

## 🎯 Pistes pour StoneBlock (Démo 1)

### 🎨 Palette de Couleurs "StoneBlock Edition"
- **Base** : Utiliser notre matériau **Quarium** (Éthéré/Bleu) pour les tirs de base.
- **Contrastes** : Opposer le jaune/orange des explosions au bleu/cyan du HUD.

### 🍱 Layout UI (No-Code)
- **Composant Portrait** : Créer un composant `SB_DialogOverlay` qui affiche des portraits 2D (ou 3D avec un SubViewport) lors des phases de boss ou d'alertes.
- **HUD Minimaliste** : S'inspirer de la finesse des lignes de Macross pour notre barre de bouclier/vie actuelle.

### ✨ Effets de Particules
- **Barrel Roll FX** : Accentuer l'effet de traînée lors du tonneau (Barrel Roll) du vaisseau.
- **Alerte de Tir** : Garder notre clignotement rouge (Émission) actuel, mais peut-être ajouter un petit effet de "focus" hexagonal sur l'ennemi qui va tirer.

---

## 🟥🟨 VALIDATION REQUISE :
**Est-ce que cette direction visuelle (portraits dynamiques et UI technique fine) te convient pour la suite de nos développements sur le SHMUP ?**
