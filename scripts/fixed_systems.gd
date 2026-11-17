class_name FixedSystems

static func exxalia() -> StarSystem:
	var s := StarSystem.new()
	s.nom = "Exxalia"
	s.quad_x = "Ε"
	s.quad_y = 21
	s.etoile = "naine jaune"
	s.diam_etoile = "1 200 K"
	s.limite = 48
	s.nation = "OCG (frontières)"
	s.route = "Route galactique"
	s.gouvernement = "Corporatiste"
	s.patrouille = "20d MF : Galactic Scout ; 30d MF : Galactic Scout + 2 Galactic Escort"
	s.cout_pat = ""
	s.trafic = "important"
	s.trafic_desc = ""
	for t in SystemTables.TRAFICS:
		if t[0] == s.trafic:
			s.trafic_desc = t[1]
	s.act_solaire = "8d MF"
	s.act_solaire_proche = "8d MF (à 2,5 US ou moins : 8d MF au début de chaque heure)"
	s.est_relais = false
	s.corps = [
		{
			"type": "planète", "classe": "M", "nom": "Temesys", "orbite": 0.5, "distance_saut": 47.5,
			"diametre": "5 K", "atmosphere": "non-respirable", "environnement": "Montagne, Roche (Fournaise)",
			"gravite": "normale", "eau": false, "habitee": true, "population": "1 500 000",
			"niveau_techno": "B", "gouvernement": "corporatiste", "commerce": "planète pauvre (D+1)",
			"cours": "A : 0/1,5 · B : 1,5 · C : 1", "illegal": "armes lourdes, armes embarquées, drogues, esclaves",
			"astroport": "rudimentaire", "securite": "2 (13d MF : 5 mercenaires ; 23d MF : 10 mercenaires d'élite)",
			"systeme_orbital": "aucun",
			"description": "Boule de roche grise veinée de magma, presque calcinée par Losserim. Exploitations minières et missions scientifiques.",
		},
		{
			"type": "planète", "classe": "M", "nom": "Exxalia", "orbite": 1.0, "distance_saut": 47.0,
			"diametre": "10 K", "atmosphere": "respirable", "environnement": "Mer",
			"gravite": "normale", "eau": true, "habitee": true, "population": "5 milliards",
			"niveau_techno": "B", "gouvernement": "corporatiste", "commerce": "carrefour galactique (TF)",
			"cours": "A : 1 · B : 1 · C : 1", "illegal": "armes lourdes, armes embarquées, drogues, esclaves",
			"astroport": "Exxa-00 : standard ; Exxa-02 : première classe (+1d)", "securite": "4 (11d MF : 5 mercenaires ; 21d MF : 10 mercenaires d'élite)",
			"systeme_orbital": "Exxa-00 (25 K) ; Telya (50 K)",
			"description": "Capitale du système et symbole de l'OCG : gigantesque marché où tout est à vendre. Peu de terres émergent des océans ; des millions de vaisseaux partent et arrivent chaque jour.",
		},
		{
			"type": "planète", "classe": "M", "nom": "Aldéna", "orbite": 23.0, "distance_saut": 25.0,
			"diametre": "25 K", "atmosphere": "respirable", "environnement": "Arctique (Chambre froide)",
			"gravite": "normale", "eau": true, "habitee": true, "population": "1 milliard",
			"niveau_techno": "B", "gouvernement": "corporatiste", "commerce": "planète pauvre (D+1)",
			"cours": "A : 0 · B : 1,5 · C : 1", "illegal": "armes lourdes, armes embarquées, drogues, esclaves",
			"astroport": "rudimentaire (D+1)", "securite": "2 (13d MF : 5 mercenaires ; 23d MF : 10 mercenaires d'élite)",
			"systeme_orbital": "Danya (25 K) ; Ceinture de débris (75 K) ; Aldérion (100 K) ; Dela (250 K)",
			"description": "Immense désert glacé, blanc comme la neige, riche en minerais. nombreuses exploitations minières et amas de déchets industriels en orbite.",
		},
		{
			"type": "géante gazeuse", "classe": "G", "nom": "Meldory", "orbite": 42.0, "distance_saut": 6.0,
			"diametre": "30 K", "atmosphere": "non-respirable", "environnement": "Espace",
			"gravite": "faible (+1d)", "eau": false, "habitee": true, "population": "1 000 000 (en orbite)",
			"niveau_techno": "B", "gouvernement": "corporatiste", "commerce": "planète primitive (TD)",
			"cours": "A : 1,5 · B : 1,5 · C : 0/1,5", "illegal": "armes lourdes, armes embarquées, drogues, esclaves",
			"astroport": "aucun (stations orbitales possibles sur les satellites naturels)", "securite": "2 (13d MF : 5 mercenaires ; 23d MF : 10 mercenaires d'élite)",
			"systeme_orbital": "Delory (25 K) ; Mylore (75 K) ; Molorée (125 K) ; Delanar (300 K) ; Terminus (station orbitale habitée)",
			"couleur": "rouge écarlate",
			"description": "Grosse boule de gaz rouge écarlate aux confins du système. Mineurs de gaz sur les satellites ; rumeurs d'une flotte cachée du syndicat dans sa couche gazeuse.",
		},
	]
	return s
