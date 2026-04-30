# 🧠 Index des Plans d'Implémentation

Ce fichier liste les plans d'implémentation actifs et passés pour le projet.

## Plans Actifs

- **[IP-139] [Détection Matérielle Intelligente (Auto-Bloom Logic)](./implementation_plans/IP-139_Hardware_Detection_AutoBloom.md)** : Désactivation auto du Bloom sur GPUs faibles. (STATUT: Terminée) ✅
- **[IP-138] [Persistance des Profils de Qualité (Apprentissage Mobile)](./implementation_plans/IP-138_Persistent_Quality_Profiles.md)** : Mémorisation du facteur de rendu optimal par scène. (STATUT: Terminée - **Correctif Boost 1% appliqué**) ✅
- **[IP-137] [Orchestration Avancée de la Performance Mobile](./implementation_plans/IP-137_Mobile_Advanced_Orchestration.md)** : Groupe d'optimisation dédié et cible FPS mobile. (STATUT: Terminée) ✅
- **[IP-136] [Réintroduction du Mobile Scale Factor (Multiplicateur Global)](./implementation_plans/IP-136_Reintroduce_Mobile_Scale_Factor.md)** : Contrôle global simplifié de la résolution mobile. (STATUT: Terminée) ✅
- **[IP-135] [Centralisation des Optimisations Mobiles (MSAA & Shadows)](./implementation_plans/IP-135_Mobile_MSAA_Shadow_Opt.md)** : Contrôle fin du MSAA et des ombres sur mobile. (STATUT: Terminée) ✅
- **[IP-134] [Optimisation Drastique des Viewports Bloom (Fix 5 FPS)](./implementation_plans/IP-134_Bloom_Visibility_Opt.md)** : Désactivation physique des viewports inutilisés. (STATUT: Terminée) ✅
- **[IP-133] [Stabilisation Performance Mobile (Fix Console Spam & Conflicts)](./implementation_plans/IP-133_Mobile_Perf_Cleanup.md)** : Correction des fichiers corrompus et conflits de masques. (STATUT: Terminée) ✅
- **[IP-132] [Fix de l'Initialisation de Résolution (Scale Snap)](./implementation_plans/IP-132_Fix_Scale_Initial_Snap.md)** : Élimination du flash de qualité au démarrage. (STATUT: Terminée) ✅
- **[IP-131] [Correction des Gizmos Fantômes SB_FlexContainer3D](./implementation_plans/IP-131_Fix_Ghost_Gizmos.md)** : Nettoyage des orphelins et visualisation du flux. (STATUT: En cours) 🚀

- **[IP-130] [Composant SB_Icon3D](./implementation_plans/IP-130_Icon3D_Component.md)** : Création d'un afficheur d'icônes 3D simplifié avec respect du ratio. (STATUT: Terminée) ✅
- **[IP-129] [Correction et Restauration SB_Image3D](./implementation_plans/IP-129_Fix_Image3D_Fit.md)** : Ajout des paramètres manquants et fix du bug de resize. (STATUT: Terminée) ✅
- **[IP-128] [Composant SB_Image3D](./implementation_plans/IP-128_Image3D_Component.md)** : Transformation de BackgroundFit en Image3D générique avec View Modes. (STATUT: Terminée) ✅
- **[IP-127] [Mode de Remplissage (Fill/Cover) pour les Previews](./implementation_plans/IP-127_Fill_Mode_Preview.md)** : Support de l'aspect ratio (Cover) dans SB_NineSlice3D. (STATUT: Terminée) ✅
- **[IP-126] [Suppression du Verrouillage Éditeur](./implementation_plans/IP-126_Remove_Button_Lock.md)** : Retrait du système de lock récursif sur SB_Button_3d. (STATUT: Terminée) ✅
- **[IP-125] [Rotation de Teinte (Hue Shift) pour Boutons 3D](./implementation_plans/IP-125_Hue_Shift_Button_3D.md)** : Slider global de teinte pour les états. (STATUT: Terminée) ✅
- **[IP-124] [Paramètres par défaut Bouton 3D](./implementation_plans/IP-124_Default_3D_Button_Params.md)** : Preview Mix = 0.1 et Mode Screen par défaut. (STATUT: Terminée) ✅
- **[IP-123] [Support du Masquage Alpha pour les Boutons 3D](./implementation_plans/IP-123_Masking_Preview_Button.md)** : Masquage des previews par l'alpha du cadre. (STATUT: Terminée) ✅
- **[IP-120] [Système d'Overrides et Presets de Qualité](./implementation_plans/IP-120_ForceSmoothFPS.md)** : Ajout de presets (Ultra, Low, etc.) et de forçages manuels. (STATUT: Terminée) ✅
- **[IP-115] [Rendu MultiMesh Hybride pour Ennemis](./implementation_plans/IP-115-multimesh-enemies.md)** : Optimisation Draw Calls (GPU). (STATUT: En attente) 🟦
- **[IP-116] [Optimisation SB_StandardModel](./implementation_plans/IP-116-smart-model-sharing.md)** : Partage intelligent de matériaux. (STATUT: En attente) 🟦
- **[IP-117] [Registre Global de Matériaux](./implementation_plans/IP-117-material-registry.md)** : Cache centralisé des ressources. (STATUT: En attente) 🟦
- **[IP-119] [SB_BloomTagger : Support Multi-Instances](./implementation_plans/IP-119-multi-tagger-support.md)** : Cumul des calques et sélection par surface. (STATUT: Terminée) ✅
- **[IP-122] [Séquenceur temporel et Rotation Animée](./implementation_plans/IP-122-timer-loop-rotate-anim.md)** : Support du loop sur Timer et rotations par Tween. (STATUT: Terminée) ✅
- **[IP-114] [Correction Hitbox Bouton 3D](./implementation_plans/2026-04-21_fix_button_3d_hitbox.md)** : Alignement de la rotation de la CollisionShape3D sur le mesh. (STATUT: Terminée) ✅
- **[IP-105] [Adaptation Carte Upgrade 3D](./implementation_plans/IP-105-upgrade-card.md)** : Transformation du clone de la ShipCard en carte d'amélioration carrée avec stats dynamiques. (STATUT: Terminée)

## Plans Terminés

- **[IP-107] [Finalisation Thèmes Armurerie 3D](./implementation_plans/IP-107-armory-theme-finalization.md)** : Migration vers le ThemeManager et harmonisation des échelles. (Terminé le 18/04/2026)
- **[IP-108] [Correction Visualisation Bloom](./implementation_plans/IP-108-bloom-debug-fix.md)** : Partage de matériau avec les MiniViews et optimisation Gaussienne. (Terminé le 18/04/2026)
- **[IP-109] [Correction Oscillation Bloom](./implementation_plans/IP-109-bloom-oscillation-fix.md)** : Désaccouplement Manager/Config pour libérer les pulsations. (Terminé le 18/04/2026)

- **[IP-FIN] Stabilisation du Système de Qualité Dynamique** : Mise à jour de la cadence et de la granularité de la résolution. ✅

---
*Dernière mise à jour : 2026-04-17*
