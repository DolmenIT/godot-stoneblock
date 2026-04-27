# IP-123 : Support du Masquage Alpha pour les Boutons 3D

## 📝 Description
Permettre aux couches secondaires d'un bouton (comme `Layer1_Preview`) d'être masquées par l'alpha de la couche principale (le cadre du bouton). Cela garantit que les images de preview respectent les bords arrondis et la transparence du design du bouton.

## 📅 Chronologie
- 📅 **Demandé** : 2026-04-27
- 🚀 **Lancé** : 2026-04-27
- ✅ **Terminé** : 2026-04-27

## 🛠️ Modifications

### 1. `gdk-stoneblock/visual/SB_NineSlice3D.gd`
- Ajouter `@export var mask_texture: Texture2D`.
- Mettre à jour le `SHADER_CODE` :
    - Ajouter `uniform sampler2D mask_texture : hint_default_white;`.
    - Dans `fragment()`, échantillonner le masque avec les mêmes coordonnées `target_x/y`.
    - Multiplier `ALPHA` par `mask.a`.
- Mettre à jour `_update_visual()` pour passer le paramètre au shader.

### 2. `demo/demo1/ui/SB_Button_3d.gd`
- Dans `_update_ui()`, identifier la couche `Layer1_Preview`.
- Lui assigner la texture courante du bouton (`target_tex`) comme `mask_texture`.

## 🧪 Tests à effectuer
1. Vérifier que les boutons standards sans preview ne sont pas impactés.
2. Vérifier que le bouton `BTN_L1S1` affiche maintenant la photo découpée par le cadre bleu.
3. Vérifier que le masquage suit les changements d'états (Hover/Pressed) si le cadre change de forme.

## 🏁 Walkthrough
(À remplir après exécution)
