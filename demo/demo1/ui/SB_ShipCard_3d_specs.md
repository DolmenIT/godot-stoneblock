# 🛸 Spécifications Techniques : SB_ShipCard_3D (Neon Diegetic UI)

Ce document définit les standards visuels et techniques pour l'interface 3D des cartes de vaisseaux dans le projet **StoneBlock / Cosmic HyperSquad**.

## 🏗️ Architecture Masonry (Axe Y)
Pour garantir la visibilité sur toutes les caméras et éviter le Z-Fighting ou les erreurs de tri de transparence, l'interface suit un étagement strict de **0.01 unité** :

| Altitude Y | Élément | Sous-Couches |
| :--- | :--- | :--- |
| **0.01** | Socle | Background principal (QuadMesh) |
| **0.02** | Vaisseau | Illustration (Layer 1) |
| **0.03** | Décoration | Cadres et motifs de rareté (Layer 2) |
| **0.04** | Labels (Titres) | "SANTÉ", Nom du vaisseau, Classe |
| **0.05** | Boxes (UI) | Fonds sombres translucides et Slot upgrades |
| **0.06** | Valeurs (UI) | Chiffres des stats et noms des équipements |

> [!TIP]
> Si vous ajoutez un nouvel élément interactif, placez-le à **0.07** pour qu'il surplombe tout le reste.

---

## 🎨 Palette de Rareté Néon (HDR)
Les couleurs de texte (`Label3D`) sont plus saturées que les cadres pour permettre une émission HDR sans blanchir prématurément.

*   **COMMUNE (Vert)** : `#1FAA00` (Vert électrique dense)
*   **RARE (Bleu)** : `#1565C0` (Bleu profond)
*   **LEGENDAIRE (Jaune)** : `#FBC02D` (Or équilibré)

### 🌟 Réglages du Bloom (Script)
Le script `SB_ShipCard_3d.gd` gère automatiquement la luminance :
- **Multiplicateur HDR** : `2.0` (Valeur d'équilibre par défaut)
- **Modulate** : Affecte à la fois le corps (`modulate`) et le contour (`outline_modulate`) pour un halo épais.
- **Layers** : Bit 0 (Render) + Bit 11 (Bloom), soit la valeur **2049**.

---

## 🛠️ Gestion des Matériaux
Pour afficher plusieurs cartes simultanément sans bugs visuels :
- **Material Uniqueness** : Les matériaux des fonds (`StandardMaterial3D`) doivent être rendus UNIQUES par instance au lancement (via script).
- **Propriétés standard** :
    - `Unshaded` : Actif (Ignore l'éclairage de scène).
    - `Transparency` : Alpha actif.
    - `Cull Mode` : Disabled.

---
*Dernière mise à jour : 15 Avril 2026 - StoneBlock Creative Specs*
