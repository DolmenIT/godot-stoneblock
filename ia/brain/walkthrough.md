# Walkthrough - IP-123 : Système de Preview 3D Avancé (Masquage & Fusion)

## Changements Réalisés

### 🎨 SB_NineSlice3D (Moteur Visuel)
- **Double UV System** : Le shader calcule maintenant deux projections 9-slice indépendantes. Cela permet de garder l'image de preview en plein cadre tout en appliquant un masque (le fond du bouton) qui possède ses propres marges et son propre crop.
- **Moteur de Blending** : Ajout de 8 modes de fusion mathématiques (Multiply, Screen, Overlay, etc.) permettant d'intégrer visuellement la photo dans la texture du bouton.
- **Correction d'Alignement** : Calcul dynamique de `mask_real_size` pour éviter les décalages dans les angles dus aux différences de résolution.

### 🔘 SB_Button_3d (Interface)
- **Contrôle Inspecteur** : Ajout des curseurs `Preview Mix` et `Preview Blend Mode` directement dans le groupe "Multi-Layers Content".
- **Stabilité** : Correction d'un bug d'éditeur qui générait des erreurs "Node not found" pour les boutons n'affichant pas de prix (nœuds dynamiques).

## Sécurité du Projet
- **Nettoyage Git** : L'historique du dépôt a été réécrit pour supprimer toute trace de l'image de test `preview_l1s1.jpg` afin d'éviter tout problème de copyright.
- **Versioning IA** : Le dossier `/ia/` est désormais correctement suivi par Git après correction du `.gitignore`.

## Utilisation Suggérée
Pour un rendu "gravé" et premium, utilisez le mode **Overlay** avec un **Mix** à **0.7**.
