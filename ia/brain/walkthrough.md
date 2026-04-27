# Walkthrough - IP-123 : Support du Masquage Alpha pour les Boutons 3D

## Changements Réalisés

### 🎨 SB_NineSlice3D
- **Propriété Mask** : Ajout de `@export var mask_texture: Texture2D`.
- **Shader Spatial** :
    - Intégration d'un nouvel uniform `mask_texture` (par défaut blanc).
    - Calcul de l'alpha final en multipliant l'alpha de la texture principale par celui du masque.
    - Utilisation des coordonnées 9-slice (`target_x`, `target_y`) pour le masque afin de garantir une superposition parfaite avec la forme découpée.
- **Mise à jour** : Passage automatique du paramètre au ShaderMaterial lors de chaque rafraîchissement.

### 🔘 SB_Button_3d
- **Intégration Automatique** : Dans la boucle `_update_ui`, la couche nommée `Layer1_Preview` reçoit désormais la texture active du bouton (`target_tex`) comme masque d'alpha.
- **Réactivité** : Le masque se met à jour en temps réel lors du survol ou du clic si les textures de fond changent.

## Vérification Effectuée

### Rendu Visuel
- [x] L'image de preview (`image_preview_texture`) est désormais correctement "découpée" par la forme de la texture de fond du bouton (Normal BG).
- [x] Les coins arrondis et les zones transparentes du cadre bleu masquent parfaitement la photo du niveau.
- [x] Si aucune texture de masque n'est fournie, le shader utilise un masque blanc par défaut (pas de changement sur les autres couches).

## Message de Commit Suggéré
`feat(ui): add alpha masking support for 3D button previews`
