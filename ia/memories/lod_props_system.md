# 🌲 Système LOD Props & Baking

## 📝 Contexte et Problématique
Pour optimiser le rendu massif d’objets (Auto-Props), il était nécessaire de passer d'une instanciation simple à un système de **Niveaux de Détail (LOD)** performant, capable de gérer des billboards lointains tout en conservant une fluidité de placement.

## 🏗️ Architecture Technique
Le système repose sur 4 piliers :
1. **PropResource** : La définition (5 paliers : L0 haute-déf -> L4 billboard lointain).
2. **PropManager** : Le contrôleur runtime (Godot 4 `VisibilityRange`) attaché aux assets bakés.
3. **Baking Workflow** : Exportation de la configuration vers un `.tscn` optimisé.
4. **Auto-Props Pipeline** : Placement par duplication de prototype (ultra-rapide).

## 💡 Décisions Architecturales Clés
- **Isolation du Bake** : Utilisation d'une propriété dédiée `baked_tscn` pour ne jamais écraser les fichiers sources `.glb`.
- **Reverse Sync** : Le bake stocke les chemins d'origine (`source_lod0_path`, etc.) pour permettre à l'UI de restaurer les slots sources automatiquement au chargement.
- **Auto-Persistence** : Sauvegarde JSON automatique après chaque bake réussi pour garantir l'intégrité du lien.
- **Optimisation au Placement** : Pré-calcul de l'alignement AABB une seule fois par règle.

## 🔄 Flux de Travail (Bake)
1. Configurer les LODs (0-4) dans l'onglet "Objets Manuels".
2. Cliquer sur **Bake** -> Choisir le nom du fichier `.tscn`.
3. Le plugin génère la scène, l'assigne au champ "Asset Baké" et sauvegarde le preset JSON.
4. L'Auto-Props utilise alors ce fichier `.tscn` unique pour tout le placement.

## 📅 Historique
- **2026-03-19** : Mise en place complète, isolation des sources, reverse sync et automatisation de persistance.
