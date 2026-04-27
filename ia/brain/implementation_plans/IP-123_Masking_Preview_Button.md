# Plan d'Implémentation IP-123 : Système de Preview 3D Avancé

## 📝 Description
Ajout du support du masquage alpha et des modes de fusion (blending) pour les textures de preview des boutons 3D, afin de permettre une intégration visuelle parfaite (coins arrondis, transparence, mixage de couleurs).

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-27
- 🚀 **Lancé** : 2026-04-27
- ✅ **Terminé** : 2026-04-27

## 🛠️ Résumé des Modifications

### 🎨 SB_NineSlice3D
- [x] Support du `mask_texture`.
- [x] Système **Double UV** (calcul de `mask_real_size`) pour un alignement au pixel près.
- [x] Moteur de **Fusion (Blending Modes)** : Normal, Multiply, Add, Screen, Overlay, Darken, Lighten, Difference.

### 🔘 SB_Button_3d
- [x] Injection automatique du masque et des paramètres de découpe (Crop/Margins).
- [x] Exposition de `preview_mix` et `preview_blend_mode` dans l'inspecteur.
- [x] Correction des erreurs `@onready` sur les nœuds de prix dynamiques.

### 🔒 Sécurité & Nettoyage
- [x] Suppression de l'image de test de l'historique Git (Force Push).
- [x] Correction du `.gitignore` pour autoriser le dossier `/ia/`.
