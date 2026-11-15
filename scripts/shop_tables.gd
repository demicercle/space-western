class_name ShopTables

const CATALOGUE := [
	{"nom": "Caisse à outils", "prix": 100, "dispo": "B", "cat": "Technologie courante", "note": "Permet certains tests d'Ingénierie.", "place": 2.0},
	{"nom": "Carte planétaire", "prix": 50, "dispo": "B", "cat": "Technologie courante", "note": "Atlas de la planète ; test de Navigation pour un voyage planétaire.", "place": 0.01},
	{"nom": "Carte de système", "prix": 250, "dispo": "B", "cat": "Technologie courante", "note": "Position des corps célestes du système ; (sc) en Navigation dans ce système.", "place": 0.01},
	{"nom": "Carte galactique standard", "prix": 2500, "dispo": "B", "cat": "Technologie courante", "note": "Carte de la Galaxie.", "place": 0.01},
	{"nom": "Carte galactique à jour", "prix": 5000, "dispo": "A", "cat": "Technologie courante", "note": "Carte de la Galaxie à jour ; (sc) en Navigation (saut).", "place": 0.01},
	{"nom": "Carte galactique de mauvaise qualité", "prix": 500, "dispo": "B", "cat": "Technologie courante", "note": "Carte ancienne ; (E2F) en Navigation (saut).", "place": 0.01},
	{"nom": "Carte galactique précise", "prix": 10000, "dispo": "A", "cat": "Technologie courante", "note": "Carte très précise ; (SC) en Navigation (saut).", "place": 0.01},
	{"nom": "Combinaison de vol", "prix": 50, "dispo": "B", "cat": "Technologie courante", "note": "(sc) aux tests d'Environnement (espace) contre le vide.", "place": 0.2},
	{"nom": "Communicateur", "prix": 75, "dispo": "B", "cat": "Technologie courante", "note": "Radio tactique, portée 10 km ; scan des fréquences (E2F).", "place": 0.05},
	{"nom": "Corde (15 m)", "prix": 5, "dispo": "C", "cat": "Technologie courante", "note": "", "place": 0.05},
	{"nom": "Eau (1 L)", "prix": 1, "dispo": "C", "cat": "Technologie courante", "note": "", "place": 0.001},
	{"nom": "Gourde", "prix": 1, "dispo": "C", "cat": "Technologie courante", "note": "", "place": 0.01},
	{"nom": "Grappin", "prix": 2, "dispo": "C", "cat": "Technologie courante", "note": "", "place": 0.02},
	{"nom": "Grappin magnétique", "prix": 50, "dispo": "B", "cat": "Technologie courante", "note": "(sc) en Athlétisme pour atteindre un vaisseau ; portée 50 m.", "place": 0.05},
	{"nom": "Hamac", "prix": 1, "dispo": "C", "cat": "Technologie courante", "note": "", "place": 0.05},
	{"nom": "Instruments d'électronique", "prix": 250, "dispo": "B", "cat": "Technologie courante", "note": "Tests d'Ingénierie, Systèmes de sécurité et Technologie.", "place": 1.0},
	{"nom": "Lampe torche", "prix": 2, "dispo": "B", "cat": "Technologie courante", "note": "Portée 10 m.", "place": 0.01},
	{"nom": "Matériel de plongée", "prix": 50, "dispo": "B", "cat": "Technologie courante", "note": "Plongée jusqu'à 100 m pendant une heure.", "place": 0.5},
	{"nom": "Module-mémoire", "prix": 1000, "dispo": "A", "cat": "Technologie courante", "note": "5 coordonnées de saut ; stockage de données.", "place": 0.01},
	{"nom": "Navordinateur de poche", "prix": 750, "dispo": "A", "cat": "Technologie courante", "note": "(sc) en Navigation à la surface des planètes.", "place": 0.2},
	{"nom": "Pièces détachées (1 kg)", "prix": 2, "dispo": "B", "cat": "Technologie courante", "note": "Réparer un vaisseau, véhicule ou objet (1 kg consommé par réparation).", "place": 0.01},
	{"nom": "Ration", "prix": 1, "dispo": "C", "cat": "Technologie courante", "note": "Nourriture pour une journée (1 ration/personne/jour de voyage).", "place": 0.01},
	{"nom": "Repas", "prix": 25, "dispo": "B", "cat": "Technologie courante", "note": "Un bon repas.", "place": 0.01},
	{"nom": "Respirateur", "prix": 10, "dispo": "B", "cat": "Technologie courante", "note": "(SC) contre gaz et atmosphères nocives ; ~50 h.", "place": 0.1},
	{"nom": "Sac à dos", "prix": 1, "dispo": "C", "cat": "Technologie courante", "note": "Emporte 10 kg.", "place": 0.05},
	{"nom": "Scaphandre", "prix": 500, "dispo": "B", "cat": "Technologie courante", "note": "Réserve d'air 1 h ; immunité au vide.", "place": 1.0},
	{"nom": "Antidote générique", "prix": 10, "dispo": "B", "cat": "Technologie médicale", "note": "Dose en seringue jetable.", "place": 0.01},
	{"nom": "Medikit", "prix": 100, "dispo": "B", "cat": "Technologie médicale", "note": "Bandages, antibiotiques, attelles, système expert rudimentaire.", "place": 0.5},
	{"nom": "Pilules antiradiations", "prix": 10, "dispo": "B", "cat": "Technologie médicale", "note": "Géules d'iode.", "place": 0.01},
	{"nom": "Spray coagulant", "prix": 10, "dispo": "B", "cat": "Technologie médicale", "note": "Stoppe une hémorragie.", "place": 0.01},
	{"nom": "Pistolet laser", "prix": 50, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts 2L · SA · charg. 5 · portée 25 m · CAR 2.", "place": 0.05},
	{"nom": "Pistolet à plasma", "prix": 75, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts 1G · CC · charg. 5 · portée 5 m · CAR 3.", "place": 0.05},
	{"nom": "Blaster", "prix": 125, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts 1L · RC · charg. 10 · portée 15 m · CAR 2.", "place": 0.1},
	{"nom": "Fusil laser", "prix": 100, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts 2G · SA · charg. 10 · portée 100 m · CAR 2.", "place": 0.2},
	{"nom": "Fusil à plasma", "prix": 150, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts 1M · CC · charg. 10 · portée 15 m · CAR 4.", "place": 0.2},
	{"nom": "Hyperblaster", "prix": 250, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts 1G · RC/RL · charg. 30 · portée 50 m · CAR 3.", "place": 0.3},
	{"nom": "Hyperblaster lourd", "prix": 500, "dispo": "B", "cat": "Technologie militaire", "note": "Arme lourde · Dégâts 1G · RL · charg. 100 · portée 500 m · CAR 4.", "place": 1.0},
	{"nom": "Lance-roquettes à répétition", "prix": 1000, "dispo": "B", "cat": "Technologie militaire", "note": "Arme lourde · Dégâts 2M · SA · charg. 5 · portée 250 m · CAR 5.", "place": 2.0},
	{"nom": "Grenade à fragmentation", "prix": 25, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts 5G · aire d'effet CAR×5 m.", "place": 0.05},
	{"nom": "Grenade à plasma", "prix": 50, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts 5M · aire d'effet CAR×5 m.", "place": 0.05},
	{"nom": "Poignard", "prix": 5, "dispo": "C", "cat": "Technologie militaire", "note": "Dégâts L · CAR 2.", "place": 0.02},
	{"nom": "Poings de combat", "prix": 5, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts S (non létaux) · CAR 2 ; vendus par paires.", "place": 0.05},
	{"nom": "Sabre de pirate", "prix": 15, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts G · CAR 2.", "place": 0.1},
	{"nom": "Épée tronçonneuse", "prix": 250, "dispo": "B", "cat": "Technologie militaire", "note": "Dégâts M · CAR 3 ; 10 frappes par batterie.", "place": 0.5},
	{"nom": "Bouclier", "prix": 10, "dispo": "C", "cat": "Technologie militaire", "note": "(sc) en Mêlée pour éviter une attaque de corps à corps.", "place": 0.5},
	{"nom": "Pavois", "prix": 50, "dispo": "B", "cat": "Technologie militaire", "note": "(SC) en Mêlée pour esquiver ; encombre comme une arme lourde.", "place": 1.0},
	{"nom": "Gilet protecteur", "prix": 25, "dispo": "B", "cat": "Technologie militaire", "note": "Protection 1 · torse · encombrement nul.", "place": 0.2},
	{"nom": "Plastron blindé", "prix": 100, "dispo": "B", "cat": "Technologie militaire", "note": "Protection 2 · torse, bras, tête · encombrement D+1.", "place": 1.0},
	{"nom": "Armure intégrale", "prix": 1000, "dispo": "A", "cat": "Technologie militaire", "note": "Protection 3 · corps entier · 5 min pour s'équiper.", "place": 4.0},
	{"nom": "Baïonnette", "prix": 5, "dispo": "C", "cat": "Technologie militaire", "note": "Arme de mêlée L sur une arme d'épaule.", "place": 0.05},
	{"nom": "Finition « pirate »", "prix": 25, "dispo": "B", "cat": "Technologie militaire", "note": "Bois et métal doré : la classe !", "place": 0.05},
	{"nom": "Lunette de visée", "prix": 50, "dispo": "B", "cat": "Technologie militaire", "note": "(sc) aux tirs au-delà de la portée, en CC ou SA.", "place": 0.05},
	{"nom": "Munitions laser (x10)", "prix": 1, "dispo": "B", "cat": "Technologie militaire", "note": "", "place": 0.1},
	{"nom": "Munitions blaster (x10)", "prix": 5, "dispo": "B", "cat": "Technologie militaire", "note": "", "place": 0.1},
	{"nom": "Munitions plasma (x10)", "prix": 3, "dispo": "B", "cat": "Technologie militaire", "note": "", "place": 0.1},
	{"nom": "Roquette", "prix": 50, "dispo": "B", "cat": "Technologie militaire", "note": "", "place": 0.1},
	{"nom": "Vêtements courants", "prix": 5, "dispo": "C", "cat": "La belle vie", "note": "", "place": 0.1},
	{"nom": "Vêtements de pirate", "prix": 25, "dispo": "C", "cat": "La belle vie", "note": "Bottes, chemise ouverte, tricorne : la tenue qui s'impose.", "place": 0.1},
	{"nom": "Tenue de gala", "prix": 250, "dispo": "B", "cat": "La belle vie", "note": "Costume d'apparat ou tenue d'officier.", "place": 0.2},
	{"nom": "Babioles", "prix": 50, "dispo": "C", "cat": "La belle vie", "note": "Faux bijoux, apparence de richesse.", "place": 0.1},
	{"nom": "Bijoux authentiques", "prix": 1000, "dispo": "C", "cat": "La belle vie", "note": "Pierres précieuses, or : vraie richesse.", "place": 0.05},
	{"nom": "Rhum d'Havana", "prix": 10, "dispo": "B", "cat": "La belle vie", "note": "La bouteille authentique, uniquement sur Havana.", "place": 0.01},
]

const STATION_RELAIS := [
	{"nom": "Caisse à outils", "prix": 250, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 2.0},
	{"nom": "Carte de système", "prix": 500, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 0.01},
	{"nom": "Carte galactique standard", "prix": 5000, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 0.01},
	{"nom": "Carte galactique à jour", "prix": 10000, "dispo": "A", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 0.01},
	{"nom": "Carte galactique de mauvaise qualité", "prix": 1000, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 0.01},
	{"nom": "Carte galactique précise", "prix": 20000, "dispo": "A", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 0.01},
	{"nom": "Carte planétaire", "prix": 100, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 0.01},
	{"nom": "Combinaison de vol", "prix": 100, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 0.2},
	{"nom": "Eau (1 L)", "prix": 2, "dispo": "C", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 0.001},
	{"nom": "Instruments d'électronique", "prix": 500, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 1.0},
	{"nom": "Pièces détachées (1 kg)", "prix": 5, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG, au kg.", "place": 0.01},
	{"nom": "Ration", "prix": 2, "dispo": "C", "cat": "Station-relais", "note": "Comptoir OCG (0,5 kg).", "place": 0.01},
	{"nom": "Repas", "prix": 2, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 0.01},
	{"nom": "Scaphandre", "prix": 1000, "dispo": "B", "cat": "Station-relais", "note": "Comptoir OCG.", "place": 1.0},
]

static func find_in(list: Array, nom: String) -> Variant:
	for it in list:
		if it["nom"] == nom:
			return it
	return null

static func find_catalogue(nom: String) -> Variant:
	return find_in(CATALOGUE, nom)

static func prix_catalogue(nom: String) -> int:
	var it: Variant = find_catalogue(nom)
	if it == null:
		return 1
	return int(it["prix"])

static func dispo_catalogue(nom: String) -> String:
	var it: Variant = find_catalogue(nom)
	if it == null:
		return "C"
	return str(it["dispo"])

static func place_de(nom: String) -> float:
	var it: Variant = find_catalogue(nom)
	if it != null:
		return float(it["place"])
	var st: Variant = find_in(STATION_RELAIS, nom)
	if st != null:
		return float(st["place"])
	return 0.1
