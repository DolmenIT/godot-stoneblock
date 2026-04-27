# Architecture des Composants UI StoneBlock (Standard 2026)

## 💡 Philosophie
L'interface de StoneBlock repose sur des composants **instanciables** et **configurables via l'inspecteur** (Low-Code). L'objectif est de supprimer toute contrainte de layout forcée (comme les `custom_minimum_size` en dur) au profit d'un système élastique inspiré du CSS.

## 🏗️ Structure Standard
Tout composant UI d'élite (`SB_Button`, `SB_Box`, `SB_Label`) doit suivre cette hiérarchie stricte :

1. **Root (PanelContainer)** : 
   - Sert de conteneur de base.
   - Style : `StyleBoxEmpty` (par défaut).
   - Script : Gère les exports "StoneBlock CSS".
2. **_SBMargin (Instance de SB_Margin.tscn)** : 
   - Nom Unique : `%_SBMargin`.
   - Gère les marges extérieures (Margins).
3. **Contenu Interne (Label, Button, etc.)** :
   - Nom Unique : `%_internal_label` ou `%_internal_button`.
   - Reçoit les propriétés de texte et de thème.

## 🎨 StoneBlock CSS (Propriétés Exportées)
Chaque composant expose trois catégories dans l'inspecteur :
- **Margins** : Gérées via le nœud `SB_Margin` interne.
- **Padding** : Injecté dynamiquement dans les `StyleBox` du contenu interne.
- **Sizing** : Propriétés `min_width` et `min_height` qui pilotent le `custom_minimum_size` du nœud racine.

## 🎭 Système de Thème
- **Propagation** : Le script du composant injecte son propre `theme_type_variation` dans l'organe interne.
- **StandardManager** : `SB_ThemeManager` peut détecter ces composants et injecter automatiquement les marges/paddings s'ils sont définis dans un `SB_ThemeStyle`.

## ⚠️ Règles d'Or
- **Ne jamais modifier les offsets** ou les ancres manuellement sur une instance.
- **Utiliser les instances** : Ne jamais recréer la hiérarchie manuellement (ex: `PanelContainer` + script), car les nœuds internes nommés seront manquants.
