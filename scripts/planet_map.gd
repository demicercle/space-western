class_name PlanetMap

const ENV_COULEURS := {
	"Désert": "#e8c56b", "Jungle": "#2e7d4f", "Forêt": "#4f7a3a", "Montagnes": "#8d93b8",
	"Plaines": "#a7c957", "Toundra": "#c2ccc9", "Glaciers": "#dde3f5", "Marais": "#5f7a5a",
	"Océans": "#1e56b0", "Volcans": "#a83226", "Côtes": "#4fa3d1", "Canyons": "#d0602f",
}

static var _re_diam := RegEx.create_from_string("[0-9]+(?:[.,][0-9]+)?")

static func parse_diametre(v: Variant) -> float:
	var m := _re_diam.search(str(v))
	if m == null:
		return 10.0
	return float(m.get_string().replace(",", "."))

static func hex_distance(q: int, r: int) -> int:
	return (absi(q) + absi(r) + absi(q + r)) / 2

static func hex_anneau(rayon: int) -> Array:
	if rayon == 0:
		return [Vector2i(0, 0)]
	var dirs := [Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
	var anneau: Array = []
	var q := -rayon
	var r := rayon
	for cote in range(6):
		for i in range(rayon):
			anneau.append(Vector2i(q, r))
			q += dirs[cote].x
			r += dirs[cote].y
	return anneau

static func hex_spiral(n: int) -> Array:
	var cells: Array = []
	var rayon := 0
	while cells.size() < n:
		var anneau := hex_anneau(rayon)
		var reste := n - cells.size()
		if anneau.size() <= reste:
			for c in anneau:
				cells.append(c)
		else:
			for i in range(reste):
				var k := mini(int(round(i * anneau.size() / float(reste))), anneau.size() - 1)
				cells.append(anneau[k])
		rayon += 1
	return cells

static func centrer_grille(cells: Array) -> Array:
	var mq := 0
	var mr := 0
	for c in cells:
		mq += c.x
		mr += c.y
	mq = int(round(mq / float(cells.size())))
	mr = int(round(mr / float(cells.size())))
	var out: Array = []
	for c in cells:
		out.append(c - Vector2i(mq, mr))
	return out

static func grille_cubic(n: int) -> Array:
	var largeur := int(ceil(sqrt(float(n))))
	var hauteur := int(ceil(n / float(largeur)))
	var cells: Array = []
	for r in range(hauteur):
		for q in range(largeur):
			if cells.size() >= n:
				break
			cells.append(Vector2i(q, r))
	return centrer_grille(cells)

static func hex_grille(n: int, systeme: String) -> Array:
	if systeme == "cubic":
		return grille_cubic(n)
	return hex_spiral(n)

static func hex_centre(qr: Vector2i, s: float) -> Vector2:
	return Vector2(s * sqrt(3.0) * (qr.x + qr.y / 2.0), s * 1.5 * qr.y)

static func sont_voisins(a: Vector2i, b: Vector2i) -> bool:
	return hex_distance(a.x - b.x, a.y - b.y) == 1

static func coord_case(map: Dictionary, i: int) -> String:
	var c: Vector2i = map["cells"][i]
	if map["coord"] == "cubic":
		return "(%d, %d, %d)" % [c.x, c.y, -c.x - c.y]
	return "(%d, %d)" % [c.x, c.y]

static func couleur_case(env: String) -> Color:
	if ENV_COULEURS.has(env):
		return MAUtils.hex_color(ENV_COULEURS[env])
	if SystemTables.COULEURS.has(env):
		return MAUtils.hex_color(SystemTables.COULEURS[env])
	if env == "coque (station)":
		return Color.html("#3d4668")
	if env == "roche stérile":
		return Color.html("#a09482")
	return Color.html("#a8d8ea")

static func libelle_env(env: String) -> String:
	if env == "coque (station)":
		return "Coque (station)"
	if env == "roche stérile":
		return "Roche stérile"
	return env.capitalize()

static func _gen_envs(body: Dictionary, type: String, cells: Array) -> Array:
	var n: int = cells.size()
	if type == "géante gazeuse":
		var temp: String = str(body.get("temperature", "tempérée"))
		var pal: Array = SystemTables.COULEUR_GAZ.get(temp, SystemTables.COULEUR_GAZ["tempérée"])
		var rangs: Array = []
		for c in cells:
			if not rangs.has(c.y):
				rangs.append(c.y)
		rangs.sort()
		var teinte := {}
		for i in rangs.size():
			teinte[rangs[i]] = pal[i % pal.size()]
		var envs: Array = []
		for c in cells:
			envs.append(teinte[c.y])
		return envs
	if type == "station":
		var e: Array = []
		for i in n:
			e.append("coque (station)")
		return e
	if type == "planétoïde":
		var e2: Array = []
		for i in n:
			e2.append("roche stérile")
		return e2
	var temp: String = str(body.get("temperature", "tempérée"))
	var respirable: bool = str(body.get("atmosphere", "")) == "respirable"
	var pool: Array
	if respirable:
		pool = SystemTables.ENV_VIVABLE.get(temp, SystemTables.ENV_VIVABLE["tempérée"])
	else:
		pool = SystemTables.ENV_SAUVAGE.get(temp, SystemTables.ENV_SAUVAGE["tempérée"])
	var envs2: Array = []
	if randf() < 0.55:
		var dominant: String = MAUtils.pick(pool)
		var autres: Array = []
		for e in pool:
			if e != dominant:
				autres.append(e)
		var part := 0.7 + randf() * 0.25
		for i in n:
			if autres.is_empty() or randf() < part:
				envs2.append(dominant)
			else:
				envs2.append(MAUtils.pick(autres))
	else:
		for i in n:
			envs2.append("")
		var nb_graines := maxi(2, int(round(n / 5.0)))
		for i in range(mini(nb_graines, n)):
			envs2[randi() % n] = MAUtils.pick(pool)
		var restantes: Array = []
		for i in n:
			if envs2[i] == "":
				restantes.append(i)
		while not restantes.is_empty():
			var suite: Array = []
			var progres := false
			for i in restantes:
				var vois: Array = []
				for j in n:
					if envs2[j] != "" and sont_voisins(cells[i], cells[j]):
						vois.append(j)
				if not vois.is_empty() and randf() < 0.85:
					envs2[i] = envs2[vois[randi() % vois.size()]]
					progres = true
				else:
					suite.append(i)
			if not progres:
				for i in suite:
					envs2[i] = MAUtils.pick(pool)
				break
			restantes = suite
	return _valider_cotes(pool, envs2, cells)

static func _valider_cotes(pool: Array, envs: Array, cells: Array) -> Array:
	var pool2: Array = []
	for e in pool:
		if e != "Côtes":
			pool2.append(e)
	var modif := true
	var tours := 0
	while modif and tours < 12:
		modif = false
		tours += 1
		for i in envs.size():
			if envs[i] != "Côtes":
				continue
			var a_ocean := false
			var a_terre := false
			for j in cells.size():
				if j != i and sont_voisins(cells[i], cells[j]):
					if envs[j] == "Océans":
						a_ocean = true
					else:
						a_terre = true
			if not a_ocean or not a_terre:
				if pool2.is_empty():
					envs[i] = "Océans"
				else:
					envs[i] = MAUtils.pick(pool2)
				modif = true
	return envs
const SITES_HABITES := {"Colonie": 100, "Village": 1000, "Astroport": 10000, "Ville": 100000}
const SITE_NATUREL := "Crique"
const SITES_RECUP := ["Ruines", "Décharge", "Champ de bataille", "Épave"]

static var _re_pop := RegEx.create_from_string("([0-9][0-9 ]*)")

static func parse_population(txt: String) -> int:
	var t := txt.to_lower()
	if t.contains("aucune") or t == "":
		return 0
	if t.contains("vingtaine"):
		return 20
	if t.contains("centaines"):
		return 300
	var m := _re_pop.search(t)
	if m == null:
		return 0
	var n := int(m.get_string(1).replace(" ", ""))
	if t.contains("milliard"):
		return n * 1000000000
	if t.contains("million"):
		return n * 1000000
	return n

static func pop_txt(pop: int) -> String:
	if pop <= 0:
		return "aucune population"
	if pop >= 1000000000:
		return "%s milliards d'habitants" % MAUtils.fmt_int(pop / 1000000000.0)
	if pop >= 1000000:
		return "%s millions d'habitants" % MAUtils.fmt_int(pop / 1000000.0)
	return "%s habitants" % MAUtils.fmt_int(pop)

static func sites_habites(pop: int) -> Array:
	var out: Array = []
	if pop <= 0:
		return out
	if pop <= 100:
		out.append("Colonie")
	elif pop <= 1000:
		out.append("Village")
	elif pop <= 10000:
		out.append("Astroport")
	elif pop <= 100000:
		out.append("Ville")
	else:
		var n := int(ceil(pop / 100000.0))
		for i in n:
			out.append("Ville")
	return out

static func _prendre(libres: Array) -> int:
	var k := randi() % libres.size()
	return libres.pop_at(k)

static func _placer_site(sites: Dictionary, libres: Array, cells: Array, envs: Array, type: String, prefer_cotes: bool) -> void:
	if libres.is_empty():
		return
	var idx := -1
	if prefer_cotes:
		var cand: Array = []
		for i in libres:
			if envs[i] == "Côtes":
				cand.append(i)
		if not cand.is_empty():
			idx = cand[randi() % cand.size()]
	if idx < 0 and not sites.is_empty() and randf() < 0.6:
		var occupees: Array = sites.keys()
		for essai in range(6):
			if idx >= 0:
				break
			var base: int = occupees[randi() % occupees.size()]
			var vois: Array = []
			for i in libres:
				if sont_voisins(cells[i], cells[base]):
					vois.append(i)
			if not vois.is_empty():
				idx = vois[randi() % vois.size()]
	if idx < 0:
		idx = _prendre(libres)
	else:
		libres.erase(idx)
	sites[idx] = type

static func _gen_sites(body: Dictionary, type: String, cells: Array, envs: Array) -> Dictionary:
	var sites := {}
	if type == "géante gazeuse":
		return sites
	var libres: Array = []
	for i in envs.size():
		if envs[i] != "Océans":
			libres.append(i)
	var pop := parse_population(str(body.get("population", "")))
	var pop0 := pop
	var habitee: bool = bool(body.get("habitee", false))
	var ap: String = str(body.get("astroport", ""))
	var a_astro := ap != "" and not ap.begins_with("aucun")
	if habitee and pop > 0:
		var hab := sites_habites(pop)
		if a_astro and not hab.has("Astroport"):
			hab.append("Astroport")
		while hab.size() > libres.size() and pop > 100:
			pop = int(pop / 2)
			hab = sites_habites(pop)
			if a_astro and not hab.has("Astroport"):
				hab.append("Astroport")
		if hab.size() > libres.size():
			pop = 0
			hab = []
		if pop != pop0:
			body["population"] = pop_txt(pop)
			if pop == 0:
				body["habitee"] = false
		for t in hab:
			_placer_site(sites, libres, cells, envs, t, false)
	if bool(body.get("eau", false)):
		var nb_c := 1 + randi() % 3
		for i in nb_c:
			_placer_site(sites, libres, cells, envs, "Crique", true)
	var techno: String = str(body.get("niveau_techno", ""))
	var cours := StarSystem.parse_cours(str(body.get("cours", "")))
	var desc: String = str(body.get("description", "")).to_lower()
	var nb_ruines := 0
	if techno != "" and techno != "-" and techno != "aucun":
		nb_ruines = 1 + randi() % 2
	elif not habitee:
		nb_ruines = randi() % 2
	for i in nb_ruines:
		_placer_site(sites, libres, cells, envs, "Ruines", false)
	if float(cours.get("B", 0.0)) > 0.0:
		for i in 1 + randi() % 2:
			_placer_site(sites, libres, cells, envs, "Décharge", false)
	if (habitee and randf() < 0.3) or desc.contains("guerre") or desc.contains("bataille"):
		_placer_site(sites, libres, cells, envs, "Champ de bataille", false)
	if randf() < (0.4 if not habitee else 0.2):
		_placer_site(sites, libres, cells, envs, "Épave", false)
	return sites

static func rayon_equivalent(n: int) -> int:
	return maxi(1, int(ceil((3.0 + sqrt(maxf(0.0, 12.0 * n - 3.0))) / 6.0)))

static func generer(body: Dictionary, graine: int) -> Dictionary:
	seed(graine)
	var type: String = str(body.get("type", "planète"))
	var diam := parse_diametre(body.get("diametre", "10 K"))
	var coord := "axial"
	var taille := 76.0
	var n := 1
	var rayon := 0
	if type == "station" or type == "planétoïde":
		coord = "cubic"
		n = maxi(1, int(round(diam)))
	elif type == "géante gazeuse":
		rayon = clampi(int(round(diam / 4.8)), 1, 31)
		n = 3 * rayon * (rayon - 1) + 1
	else:
		rayon = clampi(int(round(diam / 1.8)), 1, 31)
		n = 3 * rayon * (rayon - 1) + 1
	if coord == "axial":
		var r_eq := rayon_equivalent(n)
		if r_eq >= 32:
			taille = 4.0
		elif r_eq >= 16:
			taille = 16.0
		elif r_eq >= 8:
			taille = 32.0
		else:
			taille = 64.0
	var cells := hex_grille(n, coord)
	var envs := _gen_envs(body, type, cells)
	var sites := _gen_sites(body, type, cells, envs)
	return {"nom": str(body.get("nom", "?")), "classe": type, "coord": coord, "taille": taille / 2.0, "rayon": rayon, "cases": n, "cells": cells, "envs": envs, "sites": sites}
