# space-western

Jeu vidéo inspiré des règles du jeu de rôle papier **Metal Adventures** (Urbain David & Arnaud Cuidet, French), développé avec **Godot 4** (rendu GL Compatibility).

## Lancement

Ouvrir le projet dans Godot 4 et lancer la scène `main.tscn` (scène principale).

## Architecture

- `main.tscn` : scène racine `Control` « Main » + nœuds d'interface (HSplitContainer : panneau gauche des postes / onglets de droite avec 4 `Control` d'onglets).
- `main.gd` : script principal attaché au nœud racine — état du jeu, démarrage (vaisseau à **Exxalia (Epsilon, 21)**, 4 personnages générés en **Héros / Premier rôle**), glisser-déposer des postes, calcul de voyage.
- Scripts secondaires :
  - `scripts/ma_utils.gd` : utilitaires (tirages aléatoires pondérés, formatage des nombres en français).
  - `scripts/dice.gd` : dés (d6, 2d6) et résolution des tests (chaque dé ≥ 4 = 1 succès ; TD : seuls les 6 ; TF : tout sauf 1).
  - `scripts/npc_tables.gd` + `scripts/character.gd` : générateur de PNJ (caractéristiques, compétences, professions, traits) et classe `Character`.
  - `scripts/ship.gd` : classe `Ship` (fiche vaisseau : caractéristiques, armement, systèmes secondaires, soute) — modèle de départ : *Galactic Scout*.
  - `scripts/system_tables.gd` + `scripts/star_system.gd` : générateur de systèmes planétaires et classe `StarSystem`.
  - `scripts/travel_tables.gd` + `scripts/travel.gd` : calculateur de voyage spatial (calcul du saut, périls journaliers 2d6+2d6, pannes, combats simplifiés, Radix, rations) produisant un journal de bord.
  - `scripts/galaxy_data.gd` : grille galactique 40×40 (lettres grecques Α-Ω puis 2ᵉ cycle, rangées 1-40, 1 case = 1 000 PC), systèmes nommés du Manuel des joueurs.
- `ui/` : composants d'interface
  - `galaxy_map.gd` : carte galactique 40×40 (image officielle du MdJ p.14), croix de position, clic pour choisir la destination, tracé de l'itinéraire.
  - `system_map.gd` : carte du système courant (étoile, orbites, corps célestes) + fiches descriptives.
  - `crew_panel.gd` : onglet Équipage (fiches de personnage de gauche à droite).
  - `ship_panel.gd` : onglet Vaisseau (fiche du vaisseau + soute).
  - `post_slot.gd` : case « poste » du panneau gauche (vide ou assignée, zone de dépôt).
  - `character_token.gd` + `portrait.gd` : jeton personnage draggable (portrait, nom, moniteur de santé).
- `assets/carte_galactique.jpg` : carte de la galaxie du Manuel des joueurs (p. 14).

## Interface

- **Haut** : onglets Carte galactique / Carte de système / Équipage / Vaisseau.
- **Gauche** : nom du vaisseau + X cases « poste » (X = nombre total de personnes à bord : Capitaine, Pilote, Vigie, Ingénieur, Canonnier, Fusilier, Cartographe / Historien, Passager 1, 2…), chacune vide ou assignée ; zone « hamac » pour reposer un personnage.
- **Jetons personnage** : portrait, nom, moniteur de santé — glissables d'un poste à l'autre (échange si le poste est occupé).
- **Contrôle** : cliquer sur une case de la carte galactique pour tracer l'itinéraire, puis « Calculer le voyage » (calcul du saut + périls + consommations, journal de bord jour par jour).
