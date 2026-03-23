# 🗺️ Index et Orientation IA

Ce fichier est le point d'entrée unique pour naviguer dans la documentation IA du projet.

## 🧭 Liens Directs
- **📜 [Règles et Protocoles](rules_ia.md)** : Règles de codage, Structure, Workflows et Timecodes. (Prioritaire)
- **🎭 [Persona IA](persona_ia.md)** : Qui je suis et comment j'interagis.
- **🧠 [Plans d'Implémentation](brain/implementation_plan.md)** : Suivi des tâches en cours et futures.
- **📋 [Topo Bundle Terrain](brain/TOPO_bundle_terrain_grille.md)** : Fonctionnement du système bundle (grille SB_HeightmapGrid) + ce qu’il reste à réparer pour une IA qui reprend.
- **💾 [Mémoire Contextuelle](memory_ia.md)** : Environnement technique (OS, Shell), conventions locales et état courant.
- **🧠 [Registre de Mémoire](memory_index.md)** : Mémoire par sujet et décisions architecturales.
- **🛠️ [IA Runtime](./ia_runtime/)** : Outils et scripts utilitaires. Trigger "**tts?**" pour synthèse vocale via `ia/ia_runtime/vocal_ia.ps1`.
- **📓 [Notes de Session](../chat-ia.md)** : Historique des décisions prises lors des sessions.
- **📋 [TODO & Bilan](todo.md)** : Prochaines étapes de travail, tests à effectuer et état d'avancement.

## 📁 Vue d'ensemble
L'organisation du dossier `ia/` permet de séparer la logique de travail de la connaissance projet :
`ia.md` (Index) -> `rules_ia.md` (Méthodologie) + `memory_ia.md` (Contexte & État).

## 📐 Plans d'implémentation & Validation Utilisateur
- Pour **toute modification non triviale** (nouvelle feature, refactor, migration, changement de workflow), l'IA doit :
  - rédiger un **plan d'implémentation** dans `ia/brain/implementation_plans/`,
  - référencer/mettre à jour le plan actif dans `brain/implementation_plan.md`,
  - présenter ce plan à l'utilisateur avant de modifier le code.
- Si un plan prévoit des modifications qui nécessitent une **validation explicite** de l'utilisateur, la **dernière phrase** de la réponse de l'IA doit être rendue très visible en **Markdown**, sous la forme :
  - `**🟥🟨 VALIDATION REQUISE :** _texte de la phrase à valider_`
  - Cette ligne doit toujours être le **dernier paragraphe** de la réponse, pour signaler clairement qu'une *validation est requise avant exécution*.

## 🔄 Flux de travail (demandes de modification)
L'IA suit **toujours** ce flux ; pas de proposition seule sans suite claire.
1. **Analyse** : Comprendre le besoin, le périmètre et les fichiers/ressources concernés.
2. **Proposition** : Décrire la solution (quoi faire, où, impact).
3. **Plan d'implémentation** : Rédiger un plan versionné dans `ia/brain/implementation_plans/` (réf. dans `brain/implementation_plan.md`).
4. **Exécution** :
   - **Modif petite** (1–2 fichiers, changement local, pas de refactor majeur) → **mise en place directe** après le plan.
   - **Modif grosse** (multi-fichiers, refactor, migration, risque de régression) → **demander validation** avant de coder ; utiliser `**🟥🟨 VALIDATION REQUISE :**` en fin de message si besoin.

## ⚠️ Maintenance
Tous les fichiers de ce répertoire doivent rester sous **200 lignes**. Condenser intelligemment sans perte d'information cruciale.
L'index `ia.md` et les règles `rules_ia.md` prévalent sur la mémoire contextuelle.
