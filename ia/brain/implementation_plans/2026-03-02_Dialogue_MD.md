# [2026-03-02 ~13:15] Plan d'implémentation : Système d'Import/Export de Dialogues (MD)

L'objectif est de simplifier la saisie de l'histoire en permettant d'éditer les dialogues dans des fichiers Markdown (`.md`) au lieu de passer par l'inspecteur Godot.

## Proposed Format (.md)
Chaque bloc est séparé par `---`. Un bloc commence par des métadonnées optionnelles, suivies du texte.

```markdown
# [Titre ou ID]

---
character: Brahmanda
side: left
avatar: res://path/to/avatar.png
audio: res://path/to/audio.wav
value: 0.8
---
Texte du dialogue.
Peut être multi-ligne.

---
character: Narrateur
side: right
---
Texte suivant.
```

## Proposed Changes

### [DialogProgression.gd](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/scripts/components/dialog_progression.gd)
- Ajout de propriétés exportées pour désigner le fichier MD.
- Ajout de boutons d'action (setters) : `Export to MD` et `Import from MD`.
- Implémentation de `_import_from_md()` :
    - Lit le fichier, split par `---`.
    - Analyse les métadonnées YAML-style.
    - Crée des instances de `DialogEntry`.
- Implémentation de `_export_to_md()` :
    - Parcourt `entries`.
    - Génère le texte Markdown correspondant.

### [res://dialogs/](file:///d:/Projets/Cosmic%20HyperSquad/current/cosmic-hyper-squad/dialogs/) [NEW]
- Création du répertoire pour stocker les fichiers de narration du projet.

## Verification Plan
1. **Export** : Prendre une scène existante avec des dialogues (ex: `500_story_screen_1.tscn`), cliquer sur "Export". Vérifier le fichier `.md`.
2. **Import** : Modifier le `.md`, cliquer sur "Import". Vérifier que l'array `entries` se met à jour.
3. **Robustesse** : Tester avec des fichiers mal formés ou des métadonnées manquantes.
