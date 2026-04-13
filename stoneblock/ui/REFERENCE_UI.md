# 📖 Référence UI — Composants StoneBlock

Documentation technique des éléments d'interface du framework StoneBlock (Standard 2026).  
Tous les composants sont marqués `@tool` : ils se configurent entièrement via l'Inspecteur Godot.

---

## 🏗️ Philosophie Générale

L'UI StoneBlock s'inspire du modèle CSS : chaque élément gère ses **marges** (espace extérieur),
son **padding** (espace intérieur) et son **sizing** (taille minimale) directement dans l'Inspecteur,
sans code supplémentaire.

### Structure Standard (Hiérarchie obligatoire)

```
Root (Control / PanelContainer)
 └── _SBMargin  [instance de SB_Margin.tscn]    ← gère les marges
      └── Contenu interne (Label / Button / etc.)
```

> **Règle d'Or** : Ne jamais recréer la hiérarchie manuellement.
> Toujours instancier la scène `.tscn` du composant.

---

## 📦 SB_Box — Conteneur

**Fichier** : `stoneblock/ui/SB_Box.tscn`  
**Classe** : `SB_Box extends PanelContainer`  
**Rôle** : Bloc de mise en page avec fond stylisé, marges et padding.  
Équivalent d'un `<div>` CSS.

### Propriétés (Inspecteur)

| Groupe | Propriété | Type | Défaut | Description |
|---|---|---|---|---|
| Background | `draw_background` | bool | `true` | Affiche ou masque le fond du panneau |
| Background | `background_style` | String | `"StudioPanel"` | Nom de la variation de thème (`SB_ThemeStyle`) à appliquer |
| Margins | `margin_left/top/right/bottom` | int | `20` | Espace extérieur autour du composant |
| Padding | `padding_left/top/right/bottom` | int | `0` | Espace intérieur (entre le bord et le contenu) |
| Sizing | `min_width` | int | `0` | Largeur minimale (px) |
| Sizing | `min_height` | int | `0` | Hauteur minimale (px) |

### Usage typique

Instancier `SB_Box.tscn`, placer son contenu à l'intérieur du nœud `_SBContent`.  
Changer `background_style` pour pointer vers un `SB_ThemeStyle` de type `PanelContainer`.

---

## 🔘 SB_Button — Bouton

**Fichier** : `stoneblock/ui/SB_Button.tscn`  
**Classe** : `SB_Button extends Control`  
**Rôle** : Bouton interactif avec texte, icône, texture nineslice et animations de survol.

### Signal

```gdscript
signal pressed  # Émis au clic sur le bouton
```

### Connexion (code)

```gdscript
$MonBouton.pressed.connect(_on_bouton_appuye)
```

### Propriétés (Inspecteur)

#### Groupe Thème

| Propriété | Type | Description |
|---|---|---|
| `style_class_name` | String | Nom du nœud `SB_ThemeStyle` à appliquer (ex: `"BoutonPrincipal"`). Vide = pas de style dédié. |

#### Groupe Texte

| Propriété | Type | Défaut | Description |
|---|---|---|---|
| `text` | String | `"Button"` | Texte affiché sur le bouton |
| `font_size` | int | `16` | Taille de police (px) |
| `alignment` | HorizontalAlignment | `CENTER` | Alignement horizontal du texte |
| `text_vertical_alignment` | VerticalAlignment | `CENTER` | Alignement vertical du texte |
| `autowrap_mode` | AutowrapMode | `OFF` | Retour à la ligne automatique |

#### Groupe Icône

| Propriété | Type | Description |
|---|---|---|
| `icon` | Texture2D | Icône affichée sur/dans le bouton |
| `icon_alignment` | HorizontalAlignment | Position horizontale de l'icône |
| `icon_vertical_alignment` | VerticalAlignment | Position verticale de l'icône |
| `icon_max_width` | int | Taille max de l'icône (px), défaut `75` |

#### Groupe Layout (StoneBlock CSS)

| Sous-groupe | Propriété | Défaut | Description |
|---|---|---|---|
| Margins | `margin_left/top/right/bottom` | `20` | Espace extérieur autour du bouton |
| Padding | `padding_left/top/right/bottom` | `20` | Espace intérieur entre le bord et le texte |
| Sizing | `min_width` | `200` | Largeur minimale (px) |
| Sizing | `min_height` | `200` | Hauteur minimale (px) |

#### Groupe Textures (Style Nineslice)

| Propriété | Description |
|---|---|
| `normal_texture` | Texture à l'état normal |
| `hover_texture` | Texture au survol |
| `pressed_texture` | Texture au clic |
| `slice_margin_left/top/right/bottom` | Marges du nineslice (px), défaut `32` |
| `crop_left/top/right/bottom` | Rogne les bords vides de la texture, défaut `10` |

> Si `normal_texture` est vide, le bouton utilise le thème Godot standard (StyleBoxFlat).

#### Groupe Transitions & Animations

| Propriété | Défaut | Description |
|---|---|---|
| `transition_duration` | `0.15` | Durée du fondu entre états (s) |
| `hover_scale_px` | `4.0` | Agrandissement au survol (px) |
| `pressed_scale_px` | `-4.0` | Rétrécissement au clic (px) |
| `match_texture_height` | `false` | Force la hauteur du composant à celle de la texture |

#### Groupe Debug

| Propriété | Description |
|---|---|
| `debug_font_measure` | Active les traces dans la Console Godot pour diagnostiquer le sizing du texte |

### Méthode publique

```gdscript
func get_btn() -> Button  # Retourne le Button Godot interne pour accès avancé
```

### Événement sous-composant

Au clic, `SB_Button` appelle automatiquement `start()` sur tous ses enfants directs
qui possèdent cette méthode (ex: `SB_FadeToColor`).

---

## 📝 SB_Label — Texte

**Fichier** : `stoneblock/ui/SB_Label.tscn`  
**Classe** : `SB_Label extends PanelContainer`  
**Rôle** : Label Godot enrichi avec gestion CSS des marges, padding et sizing.

### Propriétés (Inspecteur)

| Groupe | Propriété | Type | Défaut | Description |
|---|---|---|---|---|
| Texte | `text` | String | `"Label"` | Contenu textuel |
| Texte | `horizontal_alignment` | HorizontalAlignment | `LEFT` | Alignement horizontal |
| Texte | `vertical_alignment` | VerticalAlignment | `CENTER` | Alignement vertical |
| Margins | `margin_left/top/right/bottom` | int | `0` | Espace extérieur |
| Padding | `padding_left/top/right/bottom` | int | `0` | Espace intérieur |
| Sizing | `min_width` | int | `0` | Largeur minimale (px) |
| Sizing | `min_height` | int | `0` | Hauteur minimale (px) |

### Thème

La propriété `theme_type_variation` du nœud racine est automatiquement propagée
au `Label` interne (`%_internal_label`).

---

## 📏 SB_Margin — Gestion des Marges

**Fichier** : `stoneblock/ui/SB_Margin.tscn`  
**Classe** : `SB_Margin extends MarginContainer`  
**Rôle** : Composant interne utilisé par tous les autres composants SB pour gérer
les marges extérieures via `theme_constant_override`. Ne pas placer manuellement.

### Propriétés (Inspecteur)

| Propriété | Type | Défaut | Description |
|---|---|---|---|
| `margin_left` | int | `20` | Marge gauche |
| `margin_top` | int | `20` | Marge haute |
| `margin_right` | int | `20` | Marge droite |
| `margin_bottom` | int | `20` | Marge basse |

### Méthode publique

```gdscript
func set_margins(l: int, t: int, r: int, b: int) -> void
```

---

## 📦 SB_Div — Conteneur Léger (Legacy)

**Fichier** : `stoneblock/ui/SB_Div.gd`  
**Classe** : `SB_Div extends PanelContainer`  
**Rôle** : Ancien conteneur de layout basique. Remplacé par `SB_Box` pour les nouveaux projets.  
Conservé pour la compatibilité. Préférer `SB_Box` dans toute nouvelle scène.

| Propriété | Description |
|---|---|
| `padding_left/top/right/bottom` | Padding interne |
| `margin_top / margin_bottom` | Marges verticales uniquement |

---

## 📊 SB_SpriteProgressBar — Barre de Progression

**Fichier** : `stoneblock/ui/SB_SpriteProgressBar.gd`  
**Classe** : `SB_SpriteProgressBar extends Control`  
**Rôle** : Barre de progression pixel-art multi-mode. Remplace `TextureProgressBar`.
Supporte le mode segmenté (tuiles) et continu (texture clippée).

### Propriétés (Inspecteur)

#### Groupe Data

| Propriété | Type | Description |
|---|---|---|
| `sprite_frames` | SpriteFrames | Ressource contenant les animations `full` et `empty` |
| `anim_full` | StringName | Nom de l'animation pour l'état plein (défaut `"full"`) |
| `anim_empty` | StringName | Nom de l'animation pour l'état vide (défaut `"empty"`) |

#### Groupe Progress

| Propriété | Type | Défaut | Description |
|---|---|---|---|
| `value` | float | `100.0` | Valeur actuelle |
| `max_value` | float | `100.0` | Valeur maximale |
| `fill_mode` | FillMode | `LEFT_TO_RIGHT` | Direction de remplissage |

**Modes** : `LEFT_TO_RIGHT`, `RIGHT_TO_LEFT`, `TOP_TO_BOTTOM`, `BOTTOM_TO_TOP`

#### Groupe Visual Style

| Propriété | Type | Défaut | Description |
|---|---|---|---|
| `is_segmented` | bool | `true` | Chaque frame = une tuile indépendante |
| `is_continuous` | bool | `true` | Remplissage fluide (clippé) ou par paliers discrets |
| `ignore_hud_scaling` | bool | `false` | Neutralise le scale parent (HUD zoom) pour garder la taille pixel de design |

#### Groupe Safe Area (Pixels)

| Propriété | Description |
|---|---|
| `margin_left/right/top/bottom` | Bords à exclure du calcul de remplissage (ex: encadrement pixel) |
| `spacing` | Espacement entre les tuiles (mode segmenté) |

### Usage — Mise à jour de la valeur (code)

```gdscript
$BarreVie.value = 75.0     # Met la barre à 75%
$BarreVie.max_value = 100.0
```

---

## 🎨 Système de Thème

### SB_ThemeManager

**Fichier** : `stoneblock/core/SB_ThemeManager.gd`  
**Rôle** : Construit un objet `Theme` Godot à partir de la hiérarchie de ses nœuds enfants `SB_ThemeStyle`.
Injecte automatiquement ce thème dans toutes les scènes chargées par le `SB_Core`.

**Emplacement** : Dans `00_boot.tscn`, sous le `SB_Core`.

| Propriété | Description |
|---|---|
| `auto_refresh` | Reconstruit le thème automatiquement quand un enfant change (Mode Éditeur) |

**Méthode publique** :
```gdscript
func rebuild_theme() -> void  # Force la reconstruction du thème
```

---

### SB_ThemeStyle — Règle de Style

**Fichier** : `stoneblock/core/SB_ThemeStyle.gd`  
**Rôle** : Nœud enfant de `SB_ThemeManager`. Chaque instance définit un style (variation de thème).  
**Le nom du nœud = nom de la classe de style.** (ex: nœud nommé `"TitrePrincipal"` → `style_class_name = "TitrePrincipal"` sur le composant).

#### Groupe Cible

| Propriété | Type | Description |
|---|---|---|
| `target_class_name` | String | Classe Godot de base : `"Label"`, `"Button"`, `"PanelContainer"` |
| `is_global_default` | bool | Si coché, s'applique à toute instance de ce type (sans style_class_name) |

#### Groupe Police

| Propriété | Description |
|---|---|
| `font_size` | Taille de police (`-1` = ignorée) |
| `font_color` | Couleur du texte |

#### Groupe StyleBox (Fond/Coins)

| Propriété | Description |
|---|---|
| `use_stylebox` | Active la création d'un StyleBoxFlat (fond et coins) |
| `bg_color` | Couleur de fond |
| `is_pill_shape` | Coins arrondis au maximum |
| `corner_radius` | Rayon des coins (px) |

#### Groupe Ombres & Relief

| Propriété | Description |
|---|---|
| `shadow_size` | Taille de l'ombre portée |
| `shadow_color` | Couleur de l'ombre |
| `shadow_offset` | Décalage (Vector2) |

#### Groupe Borders & Shapes

| Propriété | Description |
|---|---|
| `is_circle` | Forme parfaitement circulaire |
| `border_width` | Épaisseur du contour |
| `border_color` | Couleur du contour |
| `skew` | Inclinaison de l'élément (ex: `0.05` à `0.1`) |
| `draw_center` | Si faux : fond transparent, seul le contour est dessiné |

#### Groupe Layout (CSS Style)

| Propriété | Description |
|---|---|
| `padding_left/top/right/bottom` | Padding interne du stylebox |
| `margin_left/top/right/bottom` | Marge externe (injectée dans les composants SB) |

---

## ⚡ Récapitulatif — Quel composant utiliser ?

| Besoin | Composant |
|---|---|
| Afficher du texte simple | `SB_Label.tscn` |
| Créer un bouton cliquable | `SB_Button.tscn` |
| Grouper des éléments dans un panneau | `SB_Box.tscn` |
| Ajouter une marge autour d'un groupe | `SB_Margin.tscn` (interne) ou wrapper `SB_Box` |
| Barre de vie / progression pixel-art | `SB_SpriteProgressBar` |
| Définir un style visuel global | `SB_ThemeStyle` (enfant de `SB_ThemeManager`) |

---

## ⚠️ Règles d'emploi

1. **Toujours instancier les `.tscn`** — Jamais créer un `PanelContainer + script` manuellement.
2. **Ne pas modifier les offsets/ancres** des nœuds internes (`%_SBMargin`, `%_internal_button`...).
3. **Pour le style** : utiliser `style_class_name` sur `SB_Button` / `theme_type_variation` sur `SB_Label` et `SB_Box`.
4. **Supprimer les `theme_override` locaux** dans l'Inspecteur : le `SB_ThemeManager` doit être la seule source de vérité visuelle.
5. **`SB_Div` est legacy** : le remplacer par `SB_Box` dans toute nouvelle scène.

---
*Mise à jour : 2026-04-13*
