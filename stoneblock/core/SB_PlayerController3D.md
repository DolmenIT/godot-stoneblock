# 🏃 SB_PlayerController3D

Ce composant est un contrôleur de personnage 3D (`CharacterBody3D`) conçu pour la simplicité et la modularité au sein du GDK StoneBlock.

## 🛠️ Configuration
1. Attachez ce script à un nœud `CharacterBody3D`.
2. Configurez les propriétés de mouvement, de saut et de gravité dans l'inspecteur.
3. (Optionnel) Assignez un nœud visuel (modèle 3D) dans le slot **Model** pour qu'il s'oriente automatiquement vers la direction du mouvement.

## 🎮 Contrôles par défaut
- **Déplacement** : Touches directionnelles (ou ZQSD selon mapping Godot).
- **Saut** : Espace (`ui_accept`).

## ⚙️ Paramètres
- **Speed** : Vitesse maximale du personnage.
- **Acceleration** : Rapidité avec laquelle le personnage atteint sa vitesse max.
- **Jump Velocity** : Force verticale impulsionnelle.
- **Rotation Speed** : Vitesse à laquelle le modèle s'aligne sur la trajectoire.

## 📝 Note Technique
Le script utilise `move_toward` pour un lissage naturel sans inertie excessive, idéal pour un gameplay de plateforme précise.
