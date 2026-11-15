class_name Character
extends RefCounted

var nom := ""
var prenom := ""
var surnom := ""
var nom_famille := ""
var profession := ""
var puissance := "Héros"
var role := "Premier rôle"
var pirate := false
var motivation := ""
var domaines: Array = []
var caracs := {}
var comp: Array = []
var niveaux_sante: Array = []
var pv_par_niveau := 0
var pv_max := 0
var pv := 0
var panache := 0
var gloire := 0
var defauts: Array = []
var qualites: Array = []
var post_index := -1

static func generate(puissance := "Héros", role := "Premier rôle") -> Character:
	var c := Character.new()
	c.puissance = puissance
	c.role = role
	var profession: String = MAUtils.pick(NPCTables.PROFESSIONS.keys())
	var p: Dictionary = NPCTables.PROFESSIONS[profession]
	c.profession = profession
	c.pirate = profession == "Pirate de l'espace"
	c.prenom = MAUtils.pick(NPCTables.PRENOMS)
	c.surnom = MAUtils.pick(NPCTables.SURNOMS)
	c.nom_famille = MAUtils.pick(NPCTables.NOMS)
	c.nom = "%s « %s » %s" % [c.prenom, c.surnom, c.nom_famille]
	if c.pirate:
		c.motivation = MAUtils.pick(NPCTables.MOTIVATIONS)
	var vals: Array = NPCTables.CARACS_TABLE[puissance].duplicate()
	vals.shuffle()
	var ordre: Array = []
	for d in p["dom"]:
		var car: String = NPCTables.DOMAINES_CARAC[d]
		if not ordre.has(car):
			ordre.append(car)
	var autres: Array = []
	for car in NPCTables.CARACS:
		if not ordre.has(car):
			autres.append(car)
	autres.shuffle()
	for car in autres:
		ordre.append(car)
	for i in range(ordre.size()):
		c.caracs[ordre[i]] = vals[i]
	var cvals: Array = NPCTables.COMP_TABLE[puissance].duplicate()
	var pool: Array = p["comp"].duplicate()
	pool.shuffle()
	for d in p["dom"]:
		var extra: Array = []
		for cn in NPCTables.COMPETENCES[d]:
			if not pool.has(cn):
				extra.append(cn)
		extra.shuffle()
		for k in range(mini(2, extra.size())):
			pool.append(extra[k])
	var seen := {}
	var pool2: Array = []
	for cn in pool:
		if not seen.has(cn):
			seen[cn] = true
			pool2.append(cn)
	for i in range(cvals.size()):
		if i < pool2.size():
			c.comp.append([pool2[i], cvals[i]])
	c.domaines = p["dom"].duplicate()
	var pg: Array = NPCTables.ROLES_PG[role]
	c.panache = pg[0]
	c.gloire = pg[1]
	c.niveaux_sante = NPCTables.ROLES_SANTE[role]
	c.pv_par_niveau = c.caracs["Carrure"] + c.caracs["Sang-froid"]
	c.pv_max = c.pv_par_niveau * maxi(1, c.niveaux_sante.size() - 1)
	c.pv = c.pv_max
	var defs: Array = NPCTables.TRAITS_DEFAUTS.duplicate()
	defs.shuffle()
	c.defauts = defs.slice(0, randi() % 3)
	var points: int = NPCTables.GRATUITS.get(puissance, 0)
	for t in c.defauts:
		points += absi(t[1])
	var qpool: Array = NPCTables.TRAITS_QUALITES.duplicate()
	qpool.shuffle()
	var achete := true
	while points > 0 and achete:
		achete = false
		for q in qpool:
			if points >= q[1] and not c.qualites.has(q):
				c.qualites.append(q)
				points -= q[1]
				achete = true
	return c

func get_comp(base: String) -> int:
	var best := 0
	for entry in comp:
		var name: String = entry[0]
		if name == base or name.begins_with(base + " (") or name.begins_with(base + " "):
			best = maxi(best, int(entry[1]))
	return best

func domaine_de(comp_name: String) -> String:
	for d in NPCTables.COMPETENCES.keys():
		if NPCTables.COMPETENCES[d].has(comp_name):
			return d
	return ""

func sante_txt() -> String:
	if pv <= 0:
		return niveaux_sante[niveaux_sante.size() - 1]
	var ratio := float(pv) / maxf(1.0, float(pv_max))
	if ratio > 2.0 / 3.0:
		return niveaux_sante[0]
	if ratio > 1.0 / 3.0:
		return niveaux_sante[1]
	return niveaux_sante[2]

func fiche_txt() -> String:
	var lines: Array = []
	lines.append("%s — %s (%s, %s)" % [nom, profession, puissance, role])
	for d in domaines:
		lines.append("Domaine privilégié : %s (caractéristique : %s)" % [d, NPCTables.DOMAINES_CARAC[d]])
	var car := ""
	for c in NPCTables.CARACS:
		car += "%s %d · " % [c, caracs[c]]
	lines.append("Caractéristiques : " + car.trim_suffix(" · "))
	for entry in comp:
		lines.append("  %s +%d (%s)" % [entry[0], entry[1], domaine_de(entry[0])])
	lines.append("Santé : %d PV/niveau (%s) — %d/%d PV, %s" % [pv_par_niveau, " · ".join(niveaux_sante), pv, pv_max, sante_txt()])
	lines.append("Panache %d · Gloire %d" % [panache, gloire])
	for t in defauts:
		lines.append("Défaut — %s (%d) : %s" % [t[0], t[1], t[2]])
	for q in qualites:
		lines.append("Qualité — %s (+%d) : %s" % [q[0], q[1], q[2]])
	if motivation != "":
		lines.append("Motivation : " + motivation)
	return "\n".join(lines)
