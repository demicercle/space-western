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

- **Haut** : onglets Carte galactique / Carte de système / Équipage / Vaisseau / Recruter.
- **Gauche** : nom du vaisseau, **crédits**, capitaine, puis les cases « poste » (leur nombre dépend de l'équipage standard du vaisseau : Pilote, Vigie, Ingénieur, Canonnier, Fusilier, Cartographe / Historien), chacune vide ou assignée, plus la zone « hamac (sans poste) » qui accueille autant de personnages que le vaisseau le permet (passagers max).
- **Jetons personnage** : portrait, nom, moniteur de santé (PV + état) — glissables d'un poste à l'autre (échange si le poste est occupé ; le poste survolé est surligné pendant le déplacement).
  - **clic gauche** sur un jeton → bascule sur l'onglet Équipage et sélectionne ce personnage ;
  - **clic droit** sur un portrait → menu déroulant : « Élire capitaine » (coché si déjà capitaine ; un seul capitaine, le premier personnage recruté l'est par défaut) et « Virer de l'équipage » (popup de confirmation oui/non).
- **Onglet Équipage** : une seule fiche de personnage à la fois, sélectionnable via les boutons de l'en-tête (ou en cliquant un jeton à gauche).
- **Onglet Vaisseau** : fiche du vaisseau actuel remplie tel que décrit dans le MdJ (description du modèle p.255, caractéristiques, armement, systèmes secondaires), **réserve de Radix actuel / maximum**, et à droite la **soute** : liste des objets avec **prix de vente** (base × cours de la planète × marchandage) et bouton **« vendre »**.
- **Onglet Commerce** : sur une **station-relais**, tarifs du comptoir OCG (GdM p125) ; sur une **planète**, tout le catalogue du MdJ (p234-243). Bouton « acheter » désactivé si crédits insuffisants ou soute pleine ; l'objet part automatiquement en soute et le prix est débité. (Vaisseaux et véhicules ignorés pour l'instant.)
- **Marchandage** (MdJ p271) : à la fin d'un voyage, si le vaisseau arrive sur une planète ou une station-relais, le **capitaine** fait le test d'opposition de Commerce ; chaque succès excédentaire du vendeur augmente le prix de vente de 5 % (acheteur : −5 %), plafonné à 50 %–150 % du prix de base × cours.
- **Soute en unités cargo (1 UC = 1 t / 10 m³)** : chaque objet occupe une place, total ≤ capacité du vaisseau ; les **rations** sont débitées à chaque jour de voyage ; les **pièces détachées** sont consommées à chaque réparation de l'ingénieur (réparation impossible sans pièces).
- « Faire le plein », « Recruter », l'onglet **Commerce** et « vendre » sont désactivés si le vaisseau n'est pas sur une station-relais ou une planète. Prix du Radix : tonnage × 0,75 ¤/1 000 PC sur une planète, × 1,5 ¤ sur une station-relais.
- **Carte galactique** : au-dessus du bouton « Calculer le voyage », rappel **Radix actuel / max** et **vitesse en PC/jour**, plus un bouton **« Faire le plein »** (prix : tonnage × 0,75 ¤ par 1 000 PC).
- **Onglet Recruter** : niveau (Normal, Élite, Héros, Boss, Big Boss) + profession, bouton « Trouver une recrue », puis « Recruter » en payant le prix (5 × salaire journalier en ¤/jour).
- **Contrôle** : cliquer sur une case de la carte galactique pour tracer l'itinéraire, puis « Calculer le voyage » (calcul du saut + périls + consommations + salaires, journal de bord jour par jour). Le voyage exige un **Pilote** et une **Vigie** à leur poste.

## Règles de démarrage

- Le vaisseau démarre à **Exxalia (Epsilon, 21)** : un **Galactic Basic** (500 PC/j, autonomie 10 000 PC), **8 000 ¤**, et **zéro personnage** — il faut recruter (onglet Recruter, possible uniquement sur une planète ou une station-relais, idem pour « Faire le plein") avant de pouvoir voyager.
