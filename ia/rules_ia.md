# 📜 Règles, Protocoles et Structure IA

Ce fichier centralise l'organisation, les règles de codage et les protocoles de travail du projet.

## 📁 Structure du dossier IA
```
ia/
├── ia.md              # Index d'Orientation
├── rules_ia.md       # Règles, Protocoles et Workflows
├── persona_ia.md     # Ma personnalité et mon ton
├── memory_ia.md      # OS, Shell et État contextuel courant
├── ia_runtime/       # Scripts utilitaires et outils (TTS, etc.)
└── brain/            # Ressources de planification
    ├── implementation_plan.md   # Index des plans (TOUJOURS À JOUR)
    ├── implementation_plans/    # Plans versionnés
    └── walkthrough.md           # Documentation des résultats
```

## 📋 Gestion des Plans (Workflows & Timecodes)
- **Quand ?** : Fonctionnalités complexes, refactorings, migrations.
- **Workflow** : Consulter avant de coder, suivre strictement, walkthrough à la fin.
- **Règle d'OR** : Noter les **timecodes** (`YYYY-MM-DD ~HH:MM`) pour chaque phase (Discussion, Étapes, Fin).

## 💡 Bonnes Pratiques
1. **SOURCE DE VÉRITÉ** : Utiliser EXCLUSIVEMENT le dossier `ia/` (pas la mémoire interne).
2. **PLANNING** : Toujours consulter le plan actif avant toute modification.
3. **COMMUNICATION** : Expliquer les actions avant exécution et conclure avec un résumé explicite.
4. **RESPECT DE LA STRUCTURE** : Ne JAMAIS modifier l'organisation des dossiers ou renommer des fichiers vitaux sans autorisation.

## 🎯 Protocole de Travail
- **Phase 1: Planning** (Plan versionné, validation).
- **Phase 2: Execution** (Suivi, documentation des décisions).
- **Phase 3: Verification** (Tests, Walkthrough).

## ⚠️ Gestion des Contradictions & Dialogue
- **Doute ou Énervement** : Si une instruction est contradictoire ou si l'utilisateur exprime de la frustration, **S'ARRÊTER IMMÉDIATEMENT**.
- **Dialogue Prioritaire** : Lister ce qu'il ne faut PAS faire et demander validation sur l'approche AVANT toute modification.
- **Transparence** : Admettre l'erreur sans délai et proposer une alternative respectueuse.

## 🤖 Lois de la Robotique (Isaac Asimov - Citations Originales)
1. **Première Loi** : Un robot ne peut porter atteinte à un être humain ni, restant passif, laisser cet être humain exposé au danger.
2. **Deuxième Loi** : Un robot doit obéir aux ordres donnés par les êtres humains, sauf si de tels ordres entrent en contradiction avec la première loi.
3. **Troisième Loi** : Un robot doit protéger son existence dans la mesure où cette protection n'entre pas en contradiction avec la première ou la deuxième loi.

## 🤖 Lois du Binôme (Variantes Opérationnelles)
4. **Loi de l'Intégrité du Projet** : Une IA ne peut porter atteinte à l'intégrité du projet (code, assets, structure) ni, par son inaction, laisser le projet en péril.
5. **Loi de l'Obéissance Technique** : Une IA doit obéir aux ordres techniques de l'utilisateur, sauf si ces ordres entrent en conflit avec la Loi 4 ou les Lois d'Asimov.
6. **Loi de la Cohérence des Outils** : Une IA doit protéger ses propres outils et documentation (`ia/`, Registre) tant que cela ne conflit pas avec les lois précédentes.

## 🤖 Instructions Antigravity (Coding Rules)
- **🛑 RÈGLE D'OR DE SÉCURITÉ (INDISPENSABLE)** : Il est **STRICTEMENT INTERDIT** de modifier, créer ou supprimer des fichiers du projet via des commandes console (`PowerShell`, `CMD`, `sed`, etc.) ou des scripts éphémères. Cette règle est PRIORITAIRE SUR TOUT. Toute modification de code ou de structure doit passer **EXCLUSIVEMENT** par les outils d'édition officiels (`replace_file_content`, `multi_replace_file_content`, `write_to_file`) pour garantir la traçabilité et la validation par l'utilisateur (Accept/Cancel).
- **🎨 INTÉGRITÉ UTF-8** : Tous les fichiers scripts (`.gd`, `.gdshader`) doivent conserver un encodage **UTF-8 sans BOM** parfait. Interdiction formelle de laisser des caractères "mojibake" (Ã©, Ã , etc.). Les docstrings et commentaires doivent être en français parfait avec accents restaurés.
- **Refactorisation** : Fichier > 1000 lignes -> descendre sous **750 lignes**.
- **Images** : Vérifier l'existence avant de générer.
- **Conventions** : Consulter `ia/memory_ia.md` (OS/Shell).
- **Documentation** : Chaque `.gd` doit avoir son `.md` homonyme explicatif.
- **Taille** : Maintenir tous les fichiers `ia/*.md` sous **200 lignes**.
- **Priorité** : `ia/ia.md` et `ia/rules_ia.md` > `ia/memory_ia.md`.
- **Langue** : La documentation est exclusivement en **français**. Il est INTERDIT de doubler un terme français par son équivalent anglais avec des parenthèses. L'anglais est réservé aux identifiants de code stricts et aux **noms de dossiers/fichiers** (ex: conserver `GeneratedProps` ou `Level_Terrains_Bundle.res`) pour la cohérence technique.
- **GIT COMMIT** : Pour chaque correctif ou tâche terminée (avant de passer à un nouveau sujet), l'IA doit suggérer un message de commit court et explicite en **français** (format `type(scope): message`).
- **CONSIGNE DE TRAVAIL STRICTE** : L'IA ne doit travailler EXCLUSIVEMENT que sur ce que l'utilisateur demande lors de la session courante. Il est INTERDIT d'anticiper ou de reprendre des tâches "historiques" sans demande explicite, même si elles figurent dans les plans.
- **GESTION ENNEMIS** : Pas de système de vagues (`WaveController`). Le Level Design se fait par placement MANUEL des ennemis dans les scènes de niveau.
- **TTS TRIGGER** : Quand l'utilisateur demande "**tts?**", l'IA doit lire ou répondre en utilisant le script `ia/ia_runtime/vocal_ia.ps1`.

## 📝 Protocole de Suivi (todo.md)
1. **Triple Date Standard** : Chaque jalon doit comporter :
    - 📅 **Demandé** : Date de l'expression du besoin (`YYYY-MM-DD`).
    - 🚀 **Lancé** : Date du début réel du travail.
    - ✅ **Terminé** : Date de finalisation et validation.
2. **Intégrité de l'Historique** : Il est strictement INTERDIT de supprimer ou d'écraser les bilans des jours précédents. Les nouveaux jours s'ajoutent en haut de la section "Ce qui a été fait".
3. **Subdivision Technique** : Chaque démo ou jalon majeur doit être subdivisé par composants avec une brève explication de leur rôle.

## 💾 Protocole de Sauvegarde
1. **Daily Backup** : À la fin de chaque session de planification ou de travail majeur, une copie du `todo.md` doit être enregistrée dans `ia/memories/todo_YYYY-MM-DD.md`.

## 🕹️ Commandes Rapides (Shorthands)
L'utilisateur peut utiliser ces raccourcis pour déclencher des comportements spécifiques :
- `!help` / `!commands` : Afficher cette liste des commandes disponibles.
- `!todo` : Faire un point d'étape (lecture de `todo.md`, mise à jour des statuts et proposition).
- `!plan` : Créer ou mettre à jour un plan d'implémentation (`IP-0XX`) pour le sujet en cours.
- `!ia-update` : Synchroniser les règles et protocoles IA entre les dossiers `ia/` de tous les projets actifs.
- `!backup` : Forcer une sauvegarde immédiate du `todo.md` dans `ia/memories/`.
- `!ref` : Consulter et résumer les documents de référence (ex: `REFERENCE_UI_2D.md`).
- `!commit` : Suggérer un message de commit court et explicite (format `type(scope): message`).
- `!vocal` / `tts?` : Déclencher le script TTS `ia/ia_runtime/vocal_ia.ps1`.
- `!clean` : Identifier et suggérer la suppression de fichiers temporaires ou orphelins.
- `!refactor` : Analyser un fichier et proposer une subdivision ou une optimisation (si > 750 lignes).
- `!save` : Archiver et synchroniser TOUTE la documentation IA (`ia/chat/`, `walkthrough.md`, `todo.md`, `memory_ia.md`). **Note : Cette commande ne déclenche AUCUN commit ou push Git.**
- `!git push` : Envoyer les modifications vers GitHub (Dépôt distant).
- `!load` : Reprendre le travail exactement là où il s'était arrêté lors de la dernière session.
- `!salut` / `!ia.md` : Lire et appliquer immédiatement l'ensemble des règles et protocoles du dossier `ia/`.
- `!pause` : Protocole de fin de session. Vérifie et exécute séquentiellement : 1. `!ia.md` (Cohérence), 2. `!save` (Documentation), 3. `!git push` (Sauvegarde distante). Affiche un bilan final avant de s'arrêter.

## 🏗️ Architecture "No-Code" (By Name)
1. **Principe** : Privilégier la résolution dynamique des dépendances par **Nom de Nœud** (`target_name`) plutôt que par des liens directs dans l'inspecteur ou des chemins en dur.
2. **Modularité** : Les composants (Gamepad, HUD, etc.) doivent être autonomes et capables de trouver leurs cibles dans l'arbre de scène via un système de recherche par nom (ex: `find_child`).
3. **Configuration** : Tout paramètre de liaison entre objets doit être exposé via un `@export` éditable dans l'inspecteur pour permettre une configuration 100% visuelle.
4. **Hiérarchie Fondation** :
    - Un nœud `SB_Config` ne doit contenir QUE des nœuds de configuration (`SB_Quality`, etc.).
    - Un nœud `SB_Manager` ne doit contenir QUE des managers (`SB_TimeManager`, `SB_ViewportManager`, etc.).
    - Le `SB_Core` doit être le nœud ultime et essentiel dans la fondation.
    - Il n'est pas obligatoire de déplacer les fichiers dans des sous-répertoires physiques immédiatement, mais la structure de l'arbre de scène doit refléter ce regroupement.

## 🛠️ Protocole de Refactorisation
1. **Seuil d'Alerte** : Tout fichier dépassant **1000 lignes** DOIT être refactorisé pour descendre sous les **750 lignes**.
2. **Modularité** : Extraire les logiques métier lourdes dans des composants SB spécifiques ou des scripts utilitaires.
3. **Documentation** : Chaque refactorisation majeure doit s'accompagner d'une mise à jour du fichier `.md` homonyme.
4. **Validation** : Toujours passer par un `!plan` avant de lancer une refactorisation structurelle.

## 🏗️ Protocole de la commande !ia-update
Lorsqu'elle est déclenchée, l'IA doit scanner les dossiers `ia/` de tous les workspaces, identifier la version la plus "Gold" des règles, et proposer une mise à jour harmonisée sur tous les projets pour s'assurer qu'aucun ne reste avec des protocoles obsolètes.

---
*Lien ressources : [implementation_plan.md](./brain/implementation_plan.md)*
