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
  - `system_map.gd` : carte du système courant (étoile, orbites, corps célestes cliquables, position du vaisseau) + fiche descriptive du corps sélectionné + bouton « Voyager vers ce corps » (voyage interplanétaire).
  - `crew_panel.gd` : onglet Équipage (fiches de personnage de gauche à droite).
  - `ship_panel.gd` : onglet Vaisseau (fiche du vaisseau + soute).
  - `post_slot.gd` : case « poste » du panneau gauche (vide ou assignée, zone de dépôt).
  - `character_token.gd` + `portrait.gd` : jeton personnage draggable (portrait, nom, moniteur de santé).
- `assets/carte_galactique.jpg` : carte de la galaxie du Manuel des joueurs (p. 14).

## Interface

- **Haut** : onglets Carte galactique / Carte de système / Équipage / Vaisseau / Commerce / Recruter.
- **Crédits** : affichés en **€** (euro) partout dans l'interface.
- **Gauche** : nom du vaisseau (sans coordonnées), **position actuelle + coordonnées** juste en dessous, **moniteur de santé du vaisseau** (coque PV/état + barre), **Radix actuel / capacité du réservoir**, **crédits**, capitaine, puis les cases « poste » (leur nombre dépend de l'équipage standard du vaisseau : Pilote, Vigie, Ingénieur, Canonnier, Fusilier, Cartographe / Historien), chacune vide ou assignée, plus la zone « hamac (sans poste) » qui accueille autant de personnages que le vaisseau le permet (passagers max).
- **Jetons personnage** : portrait, nom, moniteur de santé (PV + état) — glissables d'un poste à l'autre (échange si le poste est occupé ; le poste survolé est surligné pendant le déplacement).
  - **clic gauche** sur un jeton → bascule sur l'onglet Équipage et sélectionne ce personnage ;
  - **clic droit** sur un portrait → menu déroulant : « Élire capitaine » (coché si déjà capitaine ; un seul capitaine, le premier personnage recruté l'est par défaut) et « Virer de l'équipage » (popup de confirmation oui/non).
- **Onglet Équipage** : une seule fiche à la fois — on sélectionne un personnage **en cliquant sur son jeton dans la liste de gauche** (plus de boutons de sélection).
- **Onglet Vaisseau** : deux colonnes qui s'étendent jusqu'en bas de la fenêtre, chacune avec sa propre scrollbar — à gauche la **fiche du vaisseau** actuel remplie tel que décrit dans le MdJ (description du modèle p.255, caractéristiques, armement, systèmes secondaires, **réserve de Radix actuel / maximum**) ; à droite la **soute** : liste des objets avec **prix de vente** (base × cours de la planète × marchandage) et bouton **« vendre »**.
- **Onglet Commerce** : **5 sous-onglets** (Marchandises / Technologie courante / Technologie militaire / Technologie médicale / La belle vie), chaque sous-onglet en **3 colonnes (Objet / Description / Prix + bouton « acheter »)** ; sur une **station-relais**, tarifs du comptoir OCG (GdM p125) ; sur une **planète**, catalogue MdJ (p234-243) + **marchandises en vrac MdJ p233** (prix à la tonne = 1 UC ; achat = revente ×3). La description ne mentionne pas « US ». Le **prix d'achat = prix de base × cours de la catégorie (A/B/C)** sur la planète (valeurs 0 / 0,5 / 1 / 1,5 / 2 ; **cours ×0 → achat impossible**, bouton désactivé) ; idem pour la vente (cours ×0 → invendable). Bouton « acheter » aussi désactivé si crédits insuffisants ou soute pleine ; les prix sont **alignés à gauche** ; l'objet part automatiquement en soute et le message affiche le **total en soute** (« Acheté : Ration pour 2 € (31 en soute) »). les **Repas** servent de rations et sont **consommés en priorité** sur les Rations. (Vaisseaux et véhicules ignorés pour l'instant.)
- **Marchandage** (MdJ p271) : à la fin d'un voyage, si le vaisseau arrive sur une planète ou une station-relais, le **capitaine** fait le test d'opposition de Commerce ; chaque succès excédentaire du vendeur augmente le prix de vente de 5 % (acheteur : −5 %), plafonné à 50 %–150 % du prix de base × cours.
- **Soute en unités cargo (1 UC = 1 t / 10 m³)** : chaque objet occupe une place, total ≤ capacité du vaisseau ; les **rations** sont débitées à chaque jour de voyage ; les **pièces détachées** sont consommées à chaque réparation de l'ingénieur (réparation impossible sans pièces).
- Onglets **Commerce** et **Recruter toujours accessibles** (jamais grisés) : hors amarrage, ils affichent « Commerce impossible, trouvez une station-relais ou une planète commerciale » / « Recrutement impossible, trouvez une station-relais ou une planète habitée » (boutons désactivés). « Faire le plein » et « vendre » restent désactivés si le vaisseau n'est pas **amarré à une planète ou une station** du système courant. Le commerce/le recrutement dépendent toujours des **coordonnées actuelles** du vaisseau.
- **Carte galactique** : un clic sélectionne la case (surlignée en or) ; si elle diffère de la position du vaisseau, l'itinéraire est calculé et « Voyager » s'active. L'onglet **carte de système affiche toujours le système de la case sélectionnée** (lecture seule si ce n'est pas le système actuel : infos des corps affichées, mais « Voyager vers… » inactif).
- **Données fixes** : Exxalia (Epsilon, 21) reprend les données du document système Exxalia (étoile Losserim naine jaune 1 200 K, limite de saut 48 US, Temesys orbite 0,5 US, Exxalia 1 US, Aldéna 23 US, Meldory 42 US, cours/patrouilles/trafic conformes), quelle que soit la seed.
- **Voyage galactique depuis un corps** : si le vaisseau est sur un corps céleste, il doit d'abord rallier la **limite de saut** (voyage interplanétaire avec périls « inter », rations et Radix 10 PC/US), récapitulé en prélude du journal du saut hyper. Prix du Radix : tonnage × 0,75 €/1 000 PC sur une planète, × 1,5 € sur une station-relais.
- **Carte galactique** : au-dessus du bouton « Calculer le voyage », rappel **Radix actuel / max** et **vitesse en PC/jour**, plus un bouton **« Faire le plein »** (prix : tonnage × 0,75 € par 1 000 PC). Lorsqu'un itinéraire est tracé (clic sur une case), affichage de la **durée estimée en jours/heures** (distance ÷ vitesse PC/j) et des **rations nécessaires** avec le stock actuel (« rations nécessaires : 32 (en soute : 54) »).
- **Menu pause** : bouton **« Pause (F1) » en haut à droite** (après les onglets) ou touche **F1** : quitter le jeu, relancer depuis le début, plein écran on/off, cheats **+1 000 €**, **+1 000 Radix** cheats **+100 rations**, **soin de groupe** (équipage indemne) et **quick recruit** (si l'équipage est vide : recrute et poste automatiquement 1 Pilote, 1 Vigie (Senseurs ≥ +2), 1 Ingénieur, 1 Canonnier — **paye le prix de recrutement** de chacun).
- **Raccourcis clavier** : **Tab** = onglet suivant (en ignorant les onglets désactivés) ; **1..6** = onglet correspondant (1 = carte galactique, 2 = carte de système, …).
- **Onglet Recruter** : niveau (Normal, Élite, Héros, Boss, Big Boss) + profession, bouton « Trouver une recrue », puis « Recruter » en payant le prix (5 × salaire journalier en €/jour).
- **Onglet Carte de système** (grille 2×2 : **haut gauche** = description du système en tableau, **bas gauche** = visuel du système (étoile, orbites, corps, vaisseau en croix rouge), **haut droite** = bouton « Voyager vers… » + description du **corps sélectionné** en tableau, **bas droite** = **journal de bord des voyages interplanétaires**) : **cliquer sur un corps céleste** pour le sélectionner et afficher sa description (seul le corps sélectionné est décrit, avec la **distance depuis le vaisseau** calculée selon le **tableau des distances** (GdM p39 : partie fixe + 1d6 × multiplicateur ; dé > 5 = l'autre côté du soleil, trajectoire via le soleil)) ; la **position du vaisseau** (orbite + angle) est indiquée sur la carte — à l'arrivée d'un saut hyper, à la **limite de saut** dans la direction du trajet ; après un voyage interplanétaire, **sur le corps d'arrivée**. le vaisseau est dessiné en **croix rouge** (le corps courant est entouré) ; le **journal de bord des voyages interplanétaires s'affiche dans cet onglet**. Bouton **« Voyager vers ce corps »** : règles du **voyage interplanétaire** (distance en US, vitesse en US/j, Radix 10 PC/US, périls « inter », rations/jour, « Tirer des bords » +1 US/succès, panne sèche à l'orbite atteinte).
- **Carte galactique** : chaque coordonnée génère un système **de façon déterministe** (seed = f(seed de partie, col, rang)) — revisiter une case redonne le même système.
- **Contrôle** : cliquer sur une case de la carte galactique pour tracer l'itinéraire, puis « Voyager » (calcul du saut + périls + consommations + salaires, journal de bord jour par jour). Le voyage exige un **Pilote** et une **Vigie** à leur poste. À l'arrivée, le vaisseau est à la **limite de saut**, à l'angle correspondant à la **direction du trajet** sur la carte galactique.
- **Santé en voyage** : un personnage **blessé léger** subit **D+1 à tous ses jets**, **blessé grave** → **TD**, **Mort?** → ses jets sont impossibles ; si le **Pilote ou la Vigie est Mort?**, le voyage est impossible tant qu'il n'est pas remplacé. Un personnage au **hamac** (sans poste) régénère via la guérison naturelle. (journal hyper et interplanétaire) : **famine** — chaque jour sans rations, chaque personnage subit **3L** (ignore la protection) ; **guérison naturelle** (MdJ p111-112) — un personnage **sans poste** fait un test d'Athlétisme par jour de voyage (difficulté 2, 3 si équipage insuffisant) et récupère **1 PV + succès excédentaires**.

## Règles de démarrage

- Le vaisseau démarre à **Exxalia (Epsilon, 21)** : un **Galactic Basic** (500 PC/j, autonomie 10 000 PC), **8 000 €**, et **zéro personnage** — il faut recruter (onglet Recruter, possible uniquement sur une planète ou une station-relais, idem pour « Faire le plein") avant de pouvoir voyager.
