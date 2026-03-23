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
- **Refactorisation** : Fichier > 1000 lignes -> descendre sous **750 lignes**.
- **Images** : Vérifier l'existence avant de générer.
- **Conventions** : Consulter `ia/memory_ia.md` (OS/Shell).
- **Documentation** : Chaque `.gd` doit avoir son `.md` homonyme explicatif.
- **Taille** : Maintenir tous les fichiers `ia/*.md` sous **200 lignes**.
- **Priorité** : `ia/ia.md` et `ia/rules_ia.md` > `ia/memory_ia.md`.
- **INTERDICTION** : Ne JAMAIS modifier de fichiers projet via des commandes console (`PowerShell`, `CMD`) ou des scripts éphémères (`.gd`). Utiliser EXCLUSIVEMENT les outils d'édition (`replace_file_content`).
- **Langue** : La documentation est exclusivement en **français**. Il est INTERDIT de doubler un terme français par son équivalent anglais avec des parenthèses. L'anglais est réservé aux identifiants de code stricts et aux **noms de dossiers/fichiers** (ex: conserver `GeneratedProps` ou `Level_Terrains_Bundle.res`) pour la cohérence technique.
- **GIT COMMIT** : Pour chaque correctif ou tâche terminée (avant de passer à un nouveau sujet), l'IA doit suggérer un message de commit court et explicite en **français** (format `type(scope): message`).
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
- `!backup` : Forcer une sauvegarde immédiate du `todo.md` dans `ia/memories/`.
- `!ref` : Consulter et résumer les documents de référence (ex: `REFERENCE_UI_2D.md`).
- `!commit` : Suggérer un message de commit court et explicite (format `type(scope): message`).
- `!vocal` / `tts?` : Déclencher le script TTS `ia/ia_runtime/vocal_ia.ps1`.
- `!clean` : Identifier et suggérer la suppression de fichiers temporaires ou orphelins.
- `!refactor` : Analyser un fichier et proposer une subdivision ou une optimisation (si > 750 lignes).
- `!save` : Enregistrer un résumé de la conversation courante dans `ia/chat/`.
- `!load` : Reprendre le travail exactement là où il s'était arrêté lors de la dernière session.

## 🛠️ Protocole de Refactorisation
1. **Seuil d'Alerte** : Tout fichier dépassant **1000 lignes** DOIT être refactorisé pour descendre sous les **750 lignes**.
2. **Modularité** : Extraire les logiques métier lourdes dans des composants SB spécifiques ou des scripts utilitaires.
3. **Documentation** : Chaque refactorisation majeure doit s'accompagner d'une mise à jour du fichier `.md` homonyme.
4. **Validation** : Toujours passer par un `!plan` avant de lancer une refactorisation structurelle.

---
*Lien ressources : [implementation_plan.md](./brain/implementation_plan.md)*
