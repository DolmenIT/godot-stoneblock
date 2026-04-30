# IP-138 : Persistance des Profils de Qualité (Apprentissage Mobile)

## 🎯 Objectif
Mémoriser le `Mobile Render Factor` optimal pour chaque scène afin d'éviter que le système ne recommence à 1.0 (ou au réglage par défaut) à chaque chargement de scène.

## 🛠️ Modifications effectuées

### 1. `SB_Core.gd`
- Ajout de la gestion d'un fichier JSON local : `user://sb_mobile_profiles.json`.
- Nouvelles méthodes :
    - `get_saved_mobile_factor(scene_id)` : Récupère la valeur apprise.
    - `save_mobile_factor(scene_id, factor)` : Enregistre une nouvelle valeur.
- La clé utilisée est le `scene_file_path` de la scène actuelle.

### 2. `SB_ViewportManager.gd`
- **Chargement** : Dans `apply_initial_scaling()`, le système vérifie s'il existe un profil pour la scène actuelle et l'applique immédiatement au `SB_Core.mobile_render_factor`.
- **Apprentissage** : Une logique de stabilité a été ajoutée dans la boucle dynamique.
    - Si le facteur reste stable (moins de 0.01 de variation) pendant **30 secondes**.
    - Le `SB_ViewportManager` demande au `SB_Core` de sauvegarder ce nouveau profil.
    - Un message de log informe de l'apprentissage réussi.

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-30
- 🚀 **Lancé** : 2026-04-30
- ✅ **Terminé** : 2026-04-30

## 📝 Étapes d'exécution
1. [x] Implémenter le stockage JSON dans `SB_Core`.
2. [x] Connecter le chargement au démarrage de la scène.
3. [x] Ajouter le timer de stabilité de 30s pour la sauvegarde automatique.
