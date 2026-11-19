class_name ShopTables

const CATALOGUE := [
	{"nom": "Caisse à outils", "prix": 100, "dispo": "B", "cat": "Courant", "note": "Permet certains tests d'Ingénierie.", "place": 2.0},
	{"nom": "Carte planétaire", "prix": 50, "dispo": "B", "cat": "Courant", "note": "Atlas de la planète ; test de Navigation pour un voyage planétaire.", "place": 0.01},
	{"nom": "Carte de système", "prix": 250, "dispo": "B", "cat": "Courant", "note": "Position des corps célestes du système ; (sc) en Navigation dans ce système.", "place": 0.01},
	{"nom": "Carte galactique standard", "prix": 2500, "dispo": "B", "cat": "Courant", "note": "Carte de la Galaxie.", "place": 0.01},
	{"nom": "Carte galactique à jour", "prix": 5000, "dispo": "A", "cat": "Courant", "note": "Carte de la Galaxie à jour ; (sc) en Navigation (saut).", "place": 0.01},
	{"nom": "Carte galactique de mauvaise qualité", "prix": 500, "dispo": "B", "cat": "Courant", "note": "Carte ancienne ; (E2F) en Navigation (saut).", "place": 0.01},
	{"nom": "Carte galactique précise", "prix": 10000, "dispo": "A", "cat": "Courant", "note": "Carte très précise ; (SC) en Navigation (saut).", "place": 0.01},
	{"nom": "Combinaison de vol", "prix": 50, "dispo": "B", "cat": "Courant", "note": "(sc) aux tests d'Environnement (espace) contre le vide.", "place": 0.2},
	{"nom": "Communicateur", "prix": 75, "dispo": "B", "cat": "Courant", "note": "Radio tactique, portée 10 km ; scan des fréquences (E2F).", "place": 0.05},
	{"nom": "Corde (15 m)", "prix": 5, "dispo": "C", "cat": "Courant", "note": "", "place": 0.05},
	{"nom": "Eau (1 L)", "prix": 1, "dispo": "C", "cat": "Courant", "note": "", "place": 0.001},
	{"nom": "Gourde", "prix": 1, "dispo": "C", "cat": "Courant", "note": "", "place": 0.01},
	{"nom": "Grappin", "prix": 2, "dispo": "C", "cat": "Courant", "note": "", "place": 0.02},
	{"nom": "Grappin magnétique", "prix": 50, "dispo": "B", "cat": "Courant", "note": "(sc) en Athlétisme pour atteindre un vaisseau ; portée 50 m.", "place": 0.05},
	{"nom": "Hamac", "prix": 1, "dispo": "C", "cat": "Courant", "note": "", "place": 0.05},
	{"nom": "Instruments d'électronique", "prix": 250, "dispo": "B", "cat": "Courant", "note": "Tests d'Ingénierie, Systèmes de sécurité et Technologie.", "place": 1.0},
	{"nom": "Lampe torche", "prix": 2, "dispo": "B", "cat": "Courant", "note": "Portée 10 m.", "place": 0.01},
	{"nom": "Matériel de plongée", "prix": 50, "dispo": "B", "cat": "Courant", "note": "Plongée jusqu'à 100 m pendant une heure.", "place": 0.5},
	{"nom": "Module-mémoire", "prix": 1000, "dispo": "A", "cat": "Courant", "note": "5 coordonnées de saut ; stockage de données.", "place": 0.01},
	{"nom": "Navordinateur de poche", "prix": 750, "dispo": "A", "cat": "Courant", "note": "(sc) en Navigation à la surface des planètes.", "place": 0.2},
	{"nom": "Pièces détachées (1 kg)", "prix": 2, "dispo": "B", "cat": "Courant", "marchandise": true, "note": "Réparer un vaisseau, véhicule ou objet (1 kg consommé par réparation) — marchandise comptée au kg.", "place": 0.001},
	{"nom": "Repas", "prix": 25, "dispo": "B", "cat": "Courant", "note": "Un bon repas (compte comme 300 g de nourriture).", "place": 0.01},
	{"nom": "Respirateur", "prix": 10, "dispo": "B", "cat": "Courant", "note": "(SC) contre gaz et atmosphères nocives ; ~50 h.", "place": 0.1},
	{"nom": "Sac à dos", "prix": 1, "dispo": "C", "cat": "Courant", "note": "Emporte 10 kg.", "place": 0.05},
	{"nom": "Scaphandre", "prix": 500, "dispo": "B", "cat": "Courant", "note": "Réserve d'air 1 h ; immunité au vide.", "place": 1.0},
	{"nom": "Antidote générique", "prix": 10, "dispo": "B", "cat": "Médical", "note": "Dose en seringue jetable.", "place": 0.01},
	{"nom": "Medikit", "prix": 100, "dispo": "B", "cat": "Médical", "note": "Bandages, antibiotiques, attelles, système expert rudimentaire.", "place": 0.5},
	{"nom": "Pilules antiradiations", "prix": 10, "dispo": "B", "cat": "Médical", "note": "Géules d'iode.", "place": 0.01},
	{"nom": "Spray coagulant", "prix": 10, "dispo": "B", "cat": "Médical", "note": "Stoppe une hémorragie.", "place": 0.01},
	{"nom": "Pistolet laser", "prix": 50, "dispo": "B", "cat": "Militaire", "note": "Dégâts 2L · SA · charg. 5 · portée 25 m · CAR 2.", "place": 0.05},
	{"nom": "Pistolet à plasma", "prix": 75, "dispo": "B", "cat": "Militaire", "note": "Dégâts 1G · CC · charg. 5 · portée 5 m · CAR 3.", "place": 0.05},
	{"nom": "Blaster", "prix": 125, "dispo": "B", "cat": "Militaire", "note": "Dégâts 1L · RC · charg. 10 · portée 15 m · CAR 2.", "place": 0.1},
	{"nom": "Fusil laser", "prix": 100, "dispo": "B", "cat": "Militaire", "note": "Dégâts 2G · SA · charg. 10 · portée 100 m · CAR 2.", "place": 0.2},
	{"nom": "Fusil à plasma", "prix": 150, "dispo": "B", "cat": "Militaire", "note": "Dégâts 1M · CC · charg. 10 · portée 15 m · CAR 4.", "place": 0.2},
	{"nom": "Hyperblaster", "prix": 250, "dispo": "B", "cat": "Militaire", "note": "Dégâts 1G · RC/RL · charg. 30 · portée 50 m · CAR 3.", "place": 0.3},
	{"nom": "Hyperblaster lourd", "prix": 500, "dispo": "B", "cat": "Militaire", "note": "Arme lourde · Dégâts 1G · RL · charg. 100 · portée 500 m · CAR 4.", "place": 1.0},
	{"nom": "Lance-roquettes à répétition", "prix": 1000, "dispo": "B", "cat": "Militaire", "note": "Arme lourde · Dégâts 2M · SA · charg. 5 · portée 250 m · CAR 5.", "place": 2.0},
	{"nom": "Grenade à fragmentation", "prix": 25, "dispo": "B", "cat": "Militaire", "note": "Dégâts 5G · aire d'effet CAR×5 m.", "place": 0.05},
	{"nom": "Grenade à plasma", "prix": 50, "dispo": "B", "cat": "Militaire", "note": "Dégâts 5M · aire d'effet CAR×5 m.", "place": 0.05},
	{"nom": "Poignard", "prix": 5, "dispo": "C", "cat": "Militaire", "note": "Dégâts L · CAR 2.", "place": 0.02},
	{"nom": "Poings de combat", "prix": 5, "dispo": "B", "cat": "Militaire", "note": "Dégâts S (non létaux) · CAR 2 ; vendus par paires.", "place": 0.05},
	{"nom": "Sabre de pirate", "prix": 15, "dispo": "B", "cat": "Militaire", "note": "Dégâts G · CAR 2.", "place": 0.1},
	{"nom": "Épée tronçonneuse", "prix": 250, "dispo": "B", "cat": "Militaire", "note": "Dégâts M · CAR 3 ; 10 frappes par batterie.", "place": 0.5},
	{"nom": "Bouclier", "prix": 10, "dispo": "C", "cat": "Militaire", "note": "(sc) en Mêlée pour éviter une attaque de corps à corps.", "place": 0.5},
	{"nom": "Pavois", "prix": 50, "dispo": "B", "cat": "Militaire", "note": "(SC) en Mêlée pour esquiver ; encombre comme une arme lourde.", "place": 1.0},
	{"nom": "Gilet protecteur", "prix": 25, "dispo": "B", "cat": "Militaire", "note": "Protection 1 · torse · encombrement nul.", "place": 0.2},
	{"nom": "Plastron blindé", "prix": 100, "dispo": "B", "cat": "Militaire", "note": "Protection 2 · torse, bras, tête · encombrement D+1.", "place": 1.0},
	{"nom": "Armure intégrale", "prix": 1000, "dispo": "A", "cat": "Militaire", "note": "Protection 3 · corps entier · 5 min pour s'équiper.", "place": 4.0},
	{"nom": "Baïonnette", "prix": 5, "dispo": "C", "cat": "Militaire", "note": "Arme de mêlée L sur une arme d'épaule.", "place": 0.05},
	{"nom": "Finition « pirate »", "prix": 25, "dispo": "B", "cat": "Militaire", "note": "Bois et métal doré : la classe !", "place": 0.05},
	{"nom": "Lunette de visée", "prix": 50, "dispo": "B", "cat": "Militaire", "note": "(sc) aux tirs au-delà de la portée, en CC ou SA.", "place": 0.05},
	{"nom": "Munitions laser (x10)", "prix": 1, "dispo": "B", "cat": "Militaire", "note": "", "place": 0.1},
	{"nom": "Munitions blaster (x10)", "prix": 5, "dispo": "B", "cat": "Militaire", "note": "", "place": 0.1},
	{"nom": "Munitions plasma (x10)", "prix": 3, "dispo": "B", "cat": "Militaire", "note": "", "place": 0.1},
	{"nom": "Roquette", "prix": 50, "dispo": "B", "cat": "Militaire", "note": "", "place": 0.1},
	{"nom": "Vêtements courants", "prix": 5, "dispo": "C", "cat": "Luxe", "note": "", "place": 0.1},
	{"nom": "Vêtements de pirate", "prix": 25, "dispo": "C", "cat": "Luxe", "note": "Bottes, chemise ouverte, tricorne : la tenue qui s'impose.", "place": 0.1},
	{"nom": "Tenue de gala", "prix": 250, "dispo": "B", "cat": "Luxe", "note": "Costume d'apparat ou tenue d'officier.", "place": 0.2},
	{"nom": "Babioles", "prix": 50, "dispo": "C", "cat": "Luxe", "note": "Faux bijoux, apparence de richesse.", "place": 0.1},
	{"nom": "Bijoux authentiques", "prix": 1000, "dispo": "C", "cat": "Luxe", "note": "Pierres précieuses, or : vraie richesse.", "place": 0.05},
	{"nom": "Rhum d'Havana", "prix": 10, "dispo": "B", "cat": "Luxe", "note": "La bouteille authentique, uniquement sur Havana.", "place": 0.01},
]

const MARCHANDISES := [
	{"nom": "Nourriture (1 UC)", "prix": 250, "dispo": "C", "cat": "Marchandises", "note": "Nourriture en vrac (rations fusionnées) — 1 UC = 1 t ; chaque personnage consomme 300 g/jour. Achat : prix de revente ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Alcools (1 UC)", "prix": 1000, "dispo": "C", "cat": "Marchandises", "note": "Boissons alcoolisées. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Alliages raffinés (1 UC)", "prix": 5000, "dispo": "B", "cat": "Marchandises", "note": "Alliages industriels. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Armes (1 UC)", "prix": 5000, "dispo": "B", "cat": "Marchandises", "note": "Armes personnelles et protections en vrac. Achat : ×3. Illégal.", "place": 1.0, "achat_x3": true, "illegal": true},
	{"nom": "Artefacts archéologiques (1 UC)", "prix": 10000, "dispo": "A", "cat": "Marchandises", "note": "Vestiges des époques passées. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Artefacts technologiques (1 UC)", "prix": 10000, "dispo": "A", "cat": "Marchandises", "note": "High-tech de l'Âge des Conquêtes. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Babioles (1 UC)", "prix": 250, "dispo": "C", "cat": "Marchandises", "note": "Faux bijoux et gadgets. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Carburant (1 UC)", "prix": 500, "dispo": "B", "cat": "Marchandises", "note": "Carburants divers. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Conteneur vide (1 t)", "prix": 20, "dispo": "B", "cat": "Marchandises", "note": "Conteneur de 1 t. Coûte 100 € à l'achat, revente 20 €.", "place": 1.0, "prix_achat_base": 100},
	{"nom": "Costumes de luxe (1 UC)", "prix": 1000, "dispo": "B", "cat": "Marchandises", "note": "Tenues de gala. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Drogues (1 UC)", "prix": 5000, "dispo": "A", "cat": "Marchandises", "note": "Illégal. Achat : ×3.", "place": 1.0, "achat_x3": true, "illegal": true},
	{"nom": "Esclaves (10) (1 UC)", "prix": 2500, "dispo": "B", "cat": "Marchandises", "note": "10 esclaves par conteneur. Illégal. Achat : ×3.", "place": 1.0, "achat_x3": true, "illegal": true},
	{"nom": "Matériel électronique (1 UC)", "prix": 2500, "dispo": "B", "cat": "Marchandises", "note": "Radios, modules-mémoire... Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Matériel industriel (1 UC)", "prix": 1000, "dispo": "B", "cat": "Marchandises", "note": "Matériel lourd pour usines et chantiers. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Médicaments (1 UC)", "prix": 2500, "dispo": "B", "cat": "Marchandises", "note": "Produits médicaux. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Métaux (1 UC)", "prix": 500, "dispo": "C", "cat": "Marchandises", "note": "Métaux communs. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Métaux précieux (1 UC)", "prix": 7500, "dispo": "A", "cat": "Marchandises", "note": "Or, argent, platine. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Mobilier de luxe (1 UC)", "prix": 750, "dispo": "A", "cat": "Marchandises", "note": "Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Œuvres d'art (1 UC)", "prix": 2500, "dispo": "B", "cat": "Marchandises", "note": "Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Peaux et bétail (1 UC)", "prix": 250, "dispo": "C", "cat": "Marchandises", "note": "Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Pierres précieuses (1 UC)", "prix": 10000, "dispo": "A", "cat": "Marchandises", "note": "Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Produits de luxe (1 UC)", "prix": 5000, "dispo": "B", "cat": "Marchandises", "note": "Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Radix (1 UC)", "prix": 1000, "dispo": "B", "cat": "Marchandises", "note": "Carburant hyperspatial en vrac. Achat : ×3.", "place": 1.0, "achat_x3": true},
	{"nom": "Textiles (1 UC)", "prix": 500, "dispo": "C", "cat": "Marchandises", "note": "Achat : ×3.", "place": 1.0, "achat_x3": true},
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
	{"nom": "Pièces détachées (1 kg)", "prix": 5, "dispo": "B", "cat": "Station-relais", "marchandise": true, "note": "Comptoir OCG, au kg — marchandise comptée au kg.", "place": 0.001},
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
	it = find_in(MARCHANDISES, nom)
	if it != null:
		return float(it["place"])
	var st: Variant = find_in(STATION_RELAIS, nom)
	if st != null:
		return float(st["place"])
	return 0.1

static func tonnage_txt(q: float, place: float) -> String:
	var t := q * place
	if t < 1.0:
		return "%s kg" % MAUtils.fmt_int(t * 1000.0)
	return "%s UC" % MAUtils.fmt_num(t)

static func est_marchandise(nom: String) -> bool:
	if find_marchandise(nom) != null:
		return true
	var it: Variant = find_item(nom)
	return it != null and bool(it.get("marchandise", false))

static func quantite_soute_txt(nom: String, q: float) -> String:
	if est_marchandise(nom):
		return "×%s kg" % MAUtils.fmt_int(q * place_de(nom) * 1000.0)
	return "×%s" % MAUtils.fmt_num(q)

static func find_marchandise(nom: String) -> Variant:
	return find_in(MARCHANDISES, nom)

static func prix_base(it: Dictionary) -> int:
	var base: float = float(it.get("prix_achat_base", 0.0))
	if base <= 0.0:
		base = float(it["prix"]) * (3.0 if bool(it.get("achat_x3", false)) else 1.0)
	return int(round(base))

static func prix_achat(it: Dictionary, cours: Dictionary) -> int:
	var c: float = float(cours.get(str(it.get("dispo", "C")), 1.0))
	if c <= 0.0:
		return -1
	return int(round(float(prix_base(it)) * c))

static func est_illegal(it: Dictionary) -> bool:
	return bool(it.get("illegal", false))

static func find_item(nom: String) -> Variant:
	var it: Variant = find_catalogue(nom)
	if it == null:
		it = find_marchandise(nom)
	if it == null:
		it = find_in(STATION_RELAIS, nom)
	return it

static func lot_de(it: Dictionary) -> int:
	return maxi(1, int(it.get("lot", 1)))

static func nom_affiche(nom: String) -> String:
	var it: Variant = find_item(nom)
	var lot := 1
	if it != null:
		lot = lot_de(it)
	if lot > 1:
		var base := "Rations" if nom == "Ration" else nom + "s"
		return "%s (%d)" % [base, lot]
	return nom

static func prix_vente(nom: String, cours: Dictionary) -> int:
	var it: Variant = find_catalogue(nom)
	if it == null:
		it = find_in(MARCHANDISES, nom)
	if it == null:
		it = find_in(STATION_RELAIS, nom)
	if it == null:
		return 1
	var c: float = float(cours.get(str(it.get("dispo", "C")), 1.0))
	if c <= 0.0:
		return 0
	return maxi(1, int(round(float(prix_base(it)) * c / 1.5)))
