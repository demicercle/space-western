class_name StarSystem
extends RefCounted

var nom := ""
var etoile := ""
var diam_etoile := ""
var limite := 50
var quad_x := ""
var quad_y := 0
var nation := ""
var route := ""
var gouvernement := ""
var patrouille := ""
var cout_pat := ""
var trafic := ""
var trafic_desc := ""
var corps: Array = []
var ceinture = null
var act_solaire := ""
var act_solaire_proche := ""
var est_relais := false

static func _nom_systeme() -> String:
	var n: String = MAUtils.pick(SystemTables.NOM_SYL) + MAUtils.pick(SystemTables.NOM_SYL) + MAUtils.pick(SystemTables.NOM_FIN)
	return n.capitalize()

static func _nom_corps(orbite: int, sys: StarSystem) -> String:
	if randf() < 0.15:
		return MAUtils.pick(["Port ", "Relais ", "Station ", "Avant-poste "]) + MAUtils.pick(["Stellare", "Oreste", "Varda", "Kallon", "Esperanza", "Faro", "Cielo", "Ancla"])
	if randf() < 0.5:
		var romains := ["I", "II", "III", "IV", "V", "VI"]
		return "%s %s" % [sys.nom, romains[mini(5, orbite / 10)]]
	return MAUtils.pick(["Nueva ", "Puerto ", "San ", "Villa ", "Cabo ", "Costa "]) + sys.nom.substr(0, 1).to_upper() + MAUtils.pick(["lata", "mbral", "dor", "vena", "ciaga", "ruena", "milla", "stela"])

static func _nom_station() -> String:
	return MAUtils.pick(["Terminus", "Port Stellare", "Relais Oreste", "Station Varda", "Kallon", "Esperanza", "Faro", "Ancla"])

static func _mod_distance(o: int) -> String:
	if o <= 1:
		return "0,5×1d"
	if o <= 15:
		return "1d"
	if o <= 30:
		return "5×1d"
	if o <= 60:
		return "10×1d"
	return "10×2d"

static func _gen_orbites(nb: int, limite: int) -> Array:
	var orbites: Array = []
	var o := 1 + randi() % 6
	while orbites.size() < nb and o < limite - 3:
		orbites.append(o)
		o += (1 + randi() % 6) + 2
	return orbites

static func gen_temperature(orbite: int, etoile: String) -> String:
	var idx := 3
	if orbite <= 10:
		idx += 2
	elif orbite <= 20:
		idx += 1
	elif orbite <= 35:
		idx += 0
	elif orbite <= 45:
		idx -= 1
	else:
		idx -= 2
	if etoile == "naine rouge":
		idx -= 1
	if etoile == "géante rouge":
		idx += 1
	if etoile == "étoile binaire":
		idx += 1
	if etoile == "étoile variable":
		idx += MAUtils.pick([-1, 0, 1])
	return SystemTables.TEMPERATURES[clampi(idx - 1, 0, 4)]

static func _anomalie(temp: String):
	if temp == "glaciale" or temp == "froide":
		return "froid glacial (la nuit)"
	if temp == "chaude" or temp == "torride":
		return "température excessive (le jour)"
	return "radioactive (l'eau n'y est pas potable, la faune et la flore ne sont pas comestibles)" if randf() < 0.3 else ""

static func _gen_cours(commerce: String) -> String:
	if commerce == "Planète primitive":
		return "aucun comptoir OCG : pas de cours établi"
	var pick_c := func() -> float:
		if commerce == "Carrefour galactique" or commerce == "Carrefour commercial":
			return MAUtils.pick([1.0, 1.5, 2.0])
		if commerce == "Planète pauvre":
			return MAUtils.pick([0.0, 0.5, 1.0, 1.5])
		return MAUtils.wpick([[0.0, 1], [0.5, 2], [1.0, 4], [1.5, 2], [2.0, 1]])
	return "A : %s · B : %s · C : %s (0 : introuvable/invendable)" % [MAUtils.fmt_num(pick_c.call()), MAUtils.fmt_num(pick_c.call()), MAUtils.fmt_num(pick_c.call())]

static func _gen_illegal() -> String:
	var options := ["drogues", "esclaves", "vaisseaux militaires", "vaisseaux courants", "vaisseaux de plaisance", "technologie militaire", "technologie courante", "technologie spatiale"]
	var nb := randi() % 4
	var sel: Array = []
	while sel.size() < nb:
		var o: String = MAUtils.pick(options)
		if not sel.has(o):
			sel.append(o)
	return ", ".join(sel) if sel.size() > 0 else "aucune marchandise illégale en particulier"

static func _gen_corps(orbite: int, sys: StarSystem) -> Dictionary:
	var type: String = MAUtils.wpick([["planète", 60], ["géante gazeuse", 15], ["planétoïde", 15], ["station", 10]])
	if sys.etoile == "naine rouge" and type == "planète":
		type = "planète" if randf() < 0.7 else "planétoïde"
	if sys.etoile == "géante rouge":
		type = "géante gazeuse" if randf() < 0.5 else type
	if sys.etoile == "étoile binaire" and type == "planète":
		type = "géante gazeuse" if randf() < 0.5 else "planète"
	var c := {"type": type, "orbite": orbite, "distance_saut": sys.limite - orbite, "nom": ""}
	if type == "station":
		c["classe"] = MAUtils.pick(["station spatiale", "station orbitale"])
		c["diametre"] = MAUtils.pick(["1 K", "2 K", "3 K", "5 K", "« aussi grosse qu'une petite lune »"])
		c["atmosphere"] = "aucune (intérieur pressurisé)"
		c["environnement"] = "Espace"
		c["gravite"] = MAUtils.pick(["Faible", "Très faible", "Aucune"])
		c["astroport"] = MAUtils.pick(["Standard OCG", "Première classe", "Rudimentaire"])
		c["eau"] = randf() < 0.2
		c["habitee"] = true
		c["population"] = MAUtils.pick(["200 habitants", "2 000 habitants", "20 000 habitants", "100 000 habitants", "1 million d'habitants"])
		c["niveau_techno"] = MAUtils.pick(["A", "A", "B"])
		c["gouvernement"] = MAUtils.pick(["Corporatiste", "Démocratie", "Anarchie", "Aucun"])
		c["commerce"] = MAUtils.wpick([["Carrefour commercial", 3], ["Planète normale", 3], ["Planète pauvre", 2]])
		c["cours"] = _gen_cours(c["commerce"])
		c["illegal"] = _gen_illegal()
		c["securite"] = "%dd" % (1 + randi() % 5)
		c["description"] = "Un %s : coursives étroites, tuyauteries bruyantes et odeur de graisse de Radix." % ("habitat artificiel en orbite d'un corps céleste" if c["classe"] == "station orbitale" else "relais perdu au milieu du vide")
		return c
	if type == "planétoïde":
		c["classe"] = "planétoïde"
		c["diametre"] = MAUtils.pick(["0,5 K", "1 K", "2 K", "3 K"])
		c["atmosphere"] = "aucune" if randf() < 0.9 else "irrespirable (ténue)"
		c["environnement"] = "Espace" + (" ; " + MAUtils.pick(SystemTables.TEMP_ANORMALES) if randf() < 0.3 else "")
		c["gravite"] = MAUtils.pick(["Faible", "Très faible", "Aucune"])
		c["astroport"] = MAUtils.pick(["Rudimentaire", "Standard (mine OCG)"]) if randf() < 0.3 else "aucun"
		c["eau"] = false
		c["habitee"] = randf() < 0.4
		c["population"] = MAUtils.pick(["une vingtaine d'habitants", "200 habitants", "quelques centaines d'habitants", "2 000 habitants"]) if c["habitee"] else "aucune population"
		c["niveau_techno"] = MAUtils.pick(["B", "C", "C"])
		c["gouvernement"] = MAUtils.pick(["Anarchie", "Aucun", "Corporatiste"]) if c["habitee"] else "aucun"
		c["commerce"] = "Planète pauvre" if c["habitee"] else "aucun commerce"
		c["securite"] = "1d"
		c["description"] = MAUtils.pick([
			"Un squelette gigantesque de monstre de l'espace, dérivant dans le vide.",
			"Un astéroïde creusé de galeries et de hangars sommaires.",
			"Une structure cristalline aux reflets étranges, trop régulière pour être naturelle.",
			"Un iceberg géant, vestige d'une comète capturée par l'étoile.",
			"Une microplanète striée de galeries minières, à moitié abandonnée.",
		])
		return c
	if type == "géante gazeuse":
		c["classe"] = "G"
		c["diametre"] = "%d K" % (30 + randi() % 70)
		c["atmosphere"] = "dense (impossible d'atterrir : l'atmosphère devient liquide puis solide vers le noyau en fusion)"
		c["environnement"] = "Espace ; tempêtes permanentes dans la haute atmosphère"
		c["gravite"] = "Écrasante"
		c["astroport"] = "aucun (stations orbitales possibles sur les satellites naturels)"
		c["eau"] = false
		c["habitee"] = false
		var n_sat := 1 + randi() % 3
		c["systeme_orbital"] = "%d satellite%s naturel%s%s" % [n_sat, "s" if n_sat > 1 else "", "s" if n_sat > 1 else "", " ; usine d'exploitation de gaz en orbite" if randf() < 0.5 else ""]
		if randf() < 0.4:
			c["systeme_orbital"] += " ; %s (station orbitale habitée)" % _nom_station()
		c["population"] = "aucune population humaine"
		c["niveau_techno"] = "-"
		c["gouvernement"] = "aucun"
		c["commerce"] = "aucun"
		c["securite"] = "aucune patrouille"
		var temp := gen_temperature(orbite, sys.etoile)
		c["temperature"] = temp
		c["couleur"] = MAUtils.pick(SystemTables.COULEUR_GAZ[temp])
		c["description"] = "Une sphère %s striée de tempêtes immenses. Impossible d'y poser le pied." % c["couleur"]
		return c
	c["classe"] = "M"
	var diam := 5 + randi() % 21
	c["diametre"] = "%d K" % diam
	var habitabilite := 0.6 if (sys.etoile == "naine jaune" and orbite <= 40) else 0.2
	var temp := gen_temperature(orbite, sys.etoile)
	c["temperature"] = temp
	if randf() < habitabilite:
		c["atmosphere"] = "respirable"
		c["environnement"] = MAUtils.pick(SystemTables.ENV_VIVABLE[temp])
		if randf() < 0.3:
			var an: String = _anomalie(temp)
			if an != "":
				c["environnement"] += " ; " + an
		c["gravite"] = "Faible" if diam <= 8 else ("Forte" if diam >= 18 else "Normale")
		var phab := 0.9 if temp == "tempérée" else (0.55 if temp == "chaude" or temp == "froide" else 0.25)
		var env0: String = c["environnement"].split(" ; ")[0]
		phab -= SystemTables.HOSTILITE_ENV.get(env0, 1) * 0.1
		c["habitee"] = randf() < phab
	else:
		c["environnement"] = MAUtils.pick(SystemTables.ENV_SAUVAGE[temp])
		if randf() < 0.5:
			var an: String = _anomalie(temp)
			if an != "":
				c["environnement"] += " ; " + an
		var env0: String = c["environnement"].split(" ; ")[0]
		c["atmosphere"] = MAUtils.wpick(SystemTables.ATMOS_ENV.get(env0, [["Toxique", 2], ["Irrespirable", 2], ["aucune", 2]]))
		if c["atmosphere"].begins_with("Toxique"):
			c["atmosphere"] += " (toxique)"
		elif c["atmosphere"].begins_with("Irrespirable"):
			c["atmosphere"] += " (asphyxie)"
		elif c["atmosphere"].begins_with("Dangereux"):
			c["atmosphere"] += " (acide)"
		else:
			c["atmosphere"] += " (les véhicules à propulsion énergétique : vitesse ×1,5)"
		c["gravite"] = "Faible" if diam <= 8 else "Normale"
		c["habitee"] = randf() < (0.3 if temp == "tempérée" else 0.1)
	c["eau"] = c["atmosphere"] == "respirable" and randf() < 0.7
	c["astroport"] = MAUtils.wpick([["Rudimentaire ((D+1) pour atterrir et décoller)", 3], ["Standard OCG", 5], ["Première classe ((+1d) pour atterrir et décoller)", 2]]) if c["habitee"] else (MAUtils.pick(["Rudimentaire ((D+1) pour atterrir et décoller)"]) if randf() < 0.3 else "aucun")
	if not c["habitee"] and c["astroport"] != "aucun":
		c["astroport"] += " (avant-poste de recherche ou exploitation)"
	if c["habitee"]:
		var cat: String = MAUtils.pick(SystemTables.CATEGORIES)
		c["categorie"] = cat
		if c["atmosphere"] == "respirable":
			var env0: String = c["environnement"].split(" ; ")[0]
			var score: int = SystemTables.HOSTILITE_ENV.get(env0, 0) + (0 if temp == "tempérée" else 1)
			var pool_d: Array
			if score >= 3:
				pool_d = [["Déserte", 3], ["Peu peuplée", 3]]
			elif score >= 1:
				pool_d = [["Déserte", 2], ["Peu peuplée", 3], ["Moyennement peuplée", 2]]
			else:
				pool_d = [["Déserte", 1], ["Peu peuplée", 2], ["Moyennement peuplée", 3], ["Très peuplée", 2], ["Totalement urbanisée", 1]]
			var densite: String = MAUtils.wpick(pool_d)
			c["densite"] = densite
			var diams := 0 if diam <= 5 else (1 if diam <= 9 else (2 if diam <= 15 else (3 if diam <= 20 else (4 if diam <= 25 else 5))))
			var pops := [
				["100 millions", "500 millions", "1 milliard", "5 milliards", "10 milliards", "500 milliards"],
				["1 milliard", "2 milliards", "3 milliards", "8 milliards", "15 milliards", "2 000 milliards"],
				["3 milliards", "5 milliards", "8 milliards", "25 milliards", "50 milliards", "5 000 milliards"],
				["5 milliards", "10 milliards", "15 milliards", "50 milliards", "100 milliards", "10 000 milliards"],
				["10 milliards", "15 milliards", "25 milliards", "100 milliards", "250 milliards", "25 000 milliards"],
				["20 milliards", "30 milliards", "50 milliards", "250 milliards", "500 milliards", "50 000 milliards"],
			]
			var densites := ["Déserte", "Peu peuplée", "Moyennement peuplée", "Très peuplée", "Totalement urbanisée", "Planète ville"]
			c["population"] = pops[diams][densites.find(densite)] + " d'habitants"
		else:
			c["densite"] = "Déserte"
			c["population"] = MAUtils.pick(["une colonie sous dôme de 200 habitants", "une colonie sous dôme de 2 000 habitants", "une colonie sous dôme de 20 000 habitants", "une colonie sous dôme de 100 000 habitants"])
		c["niveau_techno"] = MAUtils.wpick([["A", 2], ["B", 4], ["C", 2]])
		c["gouvernement"] = sys.gouvernement if randf() < 0.7 else MAUtils.pick(SystemTables.GOUV)
		c["commerce"] = MAUtils.wpick([["Carrefour galactique", 1], ["Carrefour commercial", 2], ["Planète normale", 4], ["Planète pauvre", 2], ["Planète primitive", 1]])
		c["cours"] = _gen_cours(c["commerce"])
		c["illegal"] = _gen_illegal()
		c["securite"] = "%dd" % (1 + randi() % 6)
	else:
		c["categorie"] = "-"
		c["population"] = "aucune population"
		c["niveau_techno"] = "-"
		c["gouvernement"] = "aucun"
		c["commerce"] = "aucun"
		c["securite"] = "aucune patrouille"
	var n_sat := randi() % 4
	c["systeme_orbital"] = "aucun" if n_sat == 0 else "%d satellite%s naturel%s (gravité faible (+1d), sans atmosphère ni plans d'eau)" % [n_sat, "s" if n_sat > 1 else "", "s" if n_sat > 1 else ""]
	if c.get("habitee", false) and randf() < 0.35:
		var st := "%s (station orbitale habitée)" % _nom_station()
		c["systeme_orbital"] = st if c["systeme_orbital"] == "aucun" else c["systeme_orbital"] + " ; " + st
	var env0: String = c["environnement"].split(" ; ")[0]
	c["couleur"] = MAUtils.pick(SystemTables.COULEUR_ENV.get(env0, SystemTables.COULEURS.keys()))
	c["description"] = "Une sphère %s de %s de diamètre. %s" % [c["couleur"], c["diametre"], "Habité." if c["habitee"] else ("Monde sauvage, atmosphère respirable." if c["atmosphere"] == "respirable" else "Atmosphère hostile : scaphandre obligatoire.")]
	return c

static func generate(quad_x: String, quad_y: int, opts := {}) -> StarSystem:
	var s := StarSystem.new()
	s.quad_x = quad_x
	s.quad_y = quad_y
	s.nom = opts.get("nom", _nom_systeme())
	s.etoile = opts.get("etoile", MAUtils.wpick(SystemTables.ETOILES))
	match s.etoile:
		"naine rouge":
			s.diam_etoile = "%d K" % (1 + randi() % 10)
		"géante rouge":
			s.diam_etoile = "10 000 K (0,1 US)"
		"étoile variable":
			s.diam_etoile = MAUtils.pick(["40 K", "300 K", "1000 K"])
		"étoile binaire":
			s.diam_etoile = "primaire 1000 K + secondaire %d0 K" % (1 + randi() % 10)
		_:
			s.diam_etoile = "1000 K"
	s.limite = 100 if randf() < 0.05 else 50
	s.nation = opts.get("nation", MAUtils.pick(SystemTables.NATIONS))
	s.route = opts.get("route", MAUtils.wpick(SystemTables.ROUTES))
	s.gouvernement = opts.get("gouvernement", MAUtils.pick(SystemTables.GOUV))
	s.patrouille = MAUtils.wpick(SystemTables.PATROUILLES)
	s.cout_pat = "%dd MF" % [4, 6, 10, 15, 20, 25][randi() % 6]
	s.trafic = MAUtils.wpick([["négligeable", 3], ["faible", 4], ["moyen", 3], ["important", 2]])
	s.trafic_desc = ""
	for t in SystemTables.TRAFICS:
		if t[0] == s.trafic:
			s.trafic_desc = t[1]
	var nb := mini(2 + randi() % 4, 7)
	var orbites := _gen_orbites(nb, s.limite)
	for o in orbites:
		var c: Dictionary = _gen_corps(o, s)
		c["nom"] = _nom_corps(o, s)
		s.corps.append(c)
	if randf() < 0.35 and orbites.size() >= 2:
		var i := 1 + randi() % (orbites.size() - 1)
		s.ceinture = {"orbite": orbites[i - 1] + int((orbites[i] - orbites[i - 1]) / 2), "nom": "Ceinture d'astéroïdes"}
	s.act_solaire = MAUtils.pick(["10d MF", "15d MF", "20d MF"])
	s.act_solaire_proche = MAUtils.pick(["10d MF", "20d MF"])
	return s

func coord_txt() -> String:
	return "%s-%d" % [quad_x, quad_y]

func angle_corps(c: Dictionary) -> float:
	return float(corps.find(c)) * 2.399 + float(c["orbite"]) * 0.7

static func distance_inter(r1: float, r2: float) -> Dictionary:
	var de := Dice.d6()
	var autre := de > 5
	var dist: float
	if autre:
		dist = r1 + r2 + (de - 5) * 0.5
	else:
		dist = absf(r2 - r1) + de * 0.5
	return {"dist": dist, "de": de, "autre_cote": autre}

func peut_amarrer() -> bool:
	for c in corps:
		if c["type"] == "planète" or c["type"] == "station":
			return true
	return false

static func parse_cours(cours: String) -> Dictionary:
	var def := {"A": 0.0, "B": 0.0, "C": 0.0}
	if cours.contains("A :"):
		var re := RegEx.create_from_string("([ABC]) : ([0-9]+(?:[.,][0-9]+)?)")
		for m in re.search_all(cours):
			def[m.get_string(1)] = float(m.get_string(2).replace(",", "."))
	return def

func cours_dict() -> Dictionary:
	var def := {"A": 0.0, "B": 0.0, "C": 0.0}
	if est_relais:
		return {"A": 1.0, "B": 1.0, "C": 1.0}
	for c in corps:
		var cours: String = str(c.get("cours", ""))
		if c.get("habitee", false) and cours.contains("A :"):
			return parse_cours(cours)
	return def

static func assurer_planete(s: StarSystem, nom: String) -> void:
	for c in s.corps:
		if c["type"] == "planète":
			c["nom"] = nom
			c["habitee"] = true
			c["atmosphere"] = "respirable"
			return
	if s.corps.size() == 0:
		return
	var o: int = s.corps[0]["orbite"]
	var c: Dictionary = _gen_corps(o, s)
	c["type"] = "planète"
	c["classe"] = "M"
	c["nom"] = nom
	c["habitee"] = true
	c["atmosphere"] = "respirable"
	c["environnement"] = MAUtils.pick(SystemTables.ENV_VIVABLE[c.get("temperature", "tempérée")])
	c["eau"] = true
	c["astroport"] = MAUtils.pick(["Standard OCG", "Première classe", "Rudimentaire"])
	c["population"] = "5 milliards d'habitants"
	c["commerce"] = "Carrefour galactique"
	c["cours"] = _gen_cours(c["commerce"])
	c["illegal"] = _gen_illegal()
	c["securite"] = "%dd" % (1 + randi() % 6)
	c["niveau_techno"] = "A"
	c["gouvernement"] = s.gouvernement
	s.corps[0] = c

static func assurer_station(s: StarSystem, nom: String) -> void:
	for c in s.corps:
		if c["type"] == "station":
			c["nom"] = nom
			return
	if s.corps.size() == 0:
		s.corps.append({"orbite": 3, "distance_saut": s.limite - 3})
	var c: Dictionary = _gen_corps(s.corps[0]["orbite"], s)
	c["type"] = "station"
	c["classe"] = "station orbitale"
	c["nom"] = nom
	s.corps[0] = c

func infos_txt() -> String:
	var lines: Array = []
	lines.append("Système %s (%s)" % [nom, coord_txt()])
	lines.append("Étoile : %s, diamètre %s · Limite du système : %d US" % [etoile, diam_etoile, limite])
	lines.append("Nation : %s · Route : %s · Gouvernement : %s" % [nation, route, gouvernement])
	lines.append("Patrouille : %s (coût %s) · Trafic : %s — %s" % [patrouille, cout_pat, trafic, trafic_desc])
	lines.append("Activité solaire : %s (%s près de l'étoile)" % [act_solaire, act_solaire_proche])
	for c in corps:
		lines.append("")
		lines.append("▸ %s — %s, orbite %d US (distance de saut : %d US)" % [c.get("nom", "?"), c.get("classe", c["type"]), c["orbite"], c["distance_saut"]])
		for k in ["diametre", "atmosphere", "environnement", "temperature", "gravite", "eau", "habitee", "population", "densite", "categorie", "niveau_techno", "gouvernement", "commerce", "cours", "illegal", "astroport", "securite", "systeme_orbital", "description"]:
			if c.has(k) and str(c[k]) != "" and str(c[k]) != "false":
				lines.append("    %s : %s" % [k, c[k]])
	if ceinture != null:
		lines.append("")
		lines.append("▸ %s, orbite %d US" % [ceinture["nom"], ceinture["orbite"]])
	return "\n".join(lines)
