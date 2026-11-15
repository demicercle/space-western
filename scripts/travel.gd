class_name TravelSim

static func distance_pc(dep: Vector2i, arr: Vector2i) -> int:
	return int(round(Vector2(dep).distance_to(Vector2(arr)) * 1000.0))

static func cat_index(c: int) -> int:
	if c <= 4:
		return 0
	if c == 5:
		return 1
	if c <= 7:
		return 2
	if c == 8:
		return 3
	if c <= 10:
		return 4
	if c == 11:
		return 5
	return 6

static func _in_range(roll: int, range: String) -> bool:
	if range.contains("-"):
		var parts := range.split("-")
		return roll >= int(parts[0]) and roll <= int(parts[1])
	return roll == int(range)

static func tirer_peril(mode: String, mod_c: int) -> Dictionary:
	var c := Dice.d66() - mod_c
	var s := Dice.d66()
	if c < 0:
		return {"ignore": true, "idx": -1, "key": "", "roll_c": c, "roll_s": s}
	var table: Array = TravelTables.INTER if mode == "inter" else TravelTables.HYPER
	var idx := cat_index(c)
	var key := ""
	for pa in table[idx]["sous"]:
		if _in_range(s, pa[0]):
			key = pa[1]
			break
	return {"ignore": false, "idx": idx, "key": key, "roll_c": c, "roll_s": s}

static func route_proba(route_key: String) -> float:
	match route_key:
		"g":
			return 1.0 / 8.0
		"c":
			return 1.0 / 4.0
	return 1.0 / 2.0

static func simulate(cfg: Dictionary) -> Dictionary:
	var hyper: bool = cfg.get("mode", "hyper") == "hyper"
	var unite := "PC" if hyper else "US"
	var res := {
		"cfg": cfg, "jours": [], "arrivee": false, "a_sec": false, "fini": true,
		"suivi_reserve": cfg.get("radix_reserve", 0) > 0,
		"reserve": cfg.get("radix_reserve", 0) if cfg.get("radix_reserve", 0) > 0 else INF,
		"reserve_init": cfg.get("radix_reserve", 0),
		"jour_sec": 0, "heures_fin": 0.0, "case_finale": null,
		"saut": null,
		"resume": {"bonus": 0.0, "perils": [], "evites": 0, "subis": 0, "degats": [], "radix_pc": 0.0, "rations": 0, "releves": 0, "retards": 0, "majeurs": [], "pannes": 0, "reparees": 0, "eau_pct": 0.0, "cases_relees": [], "pieces_used": 0},
	}
	var T: Dictionary = res["resume"]
	var proba := route_proba(cfg.get("route_key", "x"))
	var vitesse: float = cfg.get("vitesse", 1000)
	var restant: float = cfg.get("distance", 0)
	var delay := 0
	var num := 0
	var pannes: Array = []
	var pieces := int(cfg.get("pieces", 0))
	var geo = cfg.get("dep", null) != null and cfg.get("arr", null) != null
	var saut_use := false

	if hyper:
		var na1: int = cfg.get("p1na", 0)
		var na2: int = cfg.get("p2na", 0)
		if na1 > 0 or na2 > 0:
			var pilote_saut := 2 if na2 > na1 else 1
			var na_saut := maxi(na1, na2)
			var mode_saut := "TD" if cfg.get("myst", false) else "normal"
			var essais := 0
			var exc := 0
			var ok := false
			while essais < 200:
				var r := Dice.test(na_saut, 1, mode_saut)
				essais += 1
				if r["ok"]:
					ok = true
					exc = r["extra"]
					break
			res["saut"] = {"pilote": pilote_saut, "na": na_saut, "mode": mode_saut, "essais": essais, "heures": essais, "exc": exc, "ok": ok}

	while (restant > 0.0 or delay > 0) and num < 366 and not res["a_sec"]:
		num += 1
		var actif := 1 if num % 2 == 1 else 2
		var pi: int = cfg.get("p1pi", 0) if actif == 1 else cfg.get("p2pi", 0)
		var vi_se: int = cfg.get("v1se", 0) if actif == 1 else cfg.get("v2se", 0)
		var vi_ss: int = cfg.get("v1ss", 0) if actif == 1 else cfg.get("v2ss", 0)
		var ae: int = cfg.get("cae", 0)
		var ig: int = cfg.get("ing", 0)
		var ca: int = cfg.get("carto", 0)
		var j := {"num": num, "actif": actif, "lignes": [], "evenement": false}
		var mod := {"td": 0, "tf": 0, "dead": false, "surf_interdit": false, "dist_frac": 1.0, "progresse": true, "surf_danger": false, "sens_muets": false}
		var pil_mode := func() -> String:
			if mod["dead"]:
				return "dead"
			if mod["td"] > mod["tf"]:
				return "TD"
			if mod["tf"] > 0:
				return "TF"
			return "normal"

		for i in range(pannes.size() - 1, -1, -1):
			var p: Dictionary = pannes[i]
			var spec := "Ingénierie (%d%s)" % [p["d"], ", TD" if p.get("td", false) else ""]
			var r: Dictionary
			if pieces > 0:
				pieces -= 1
				T["pieces_used"] += 1
				r = Dice.test(ig, p["d"], "TD" if p.get("td", false) else "normal")
			else:
				r = {"ok": false, "succ": 0, "extra": 0, "dice": [], "mode": "normal"}
				j["lignes"].append("Réparation de la « %s » impossible : plus de pièces détachées en soute." % p["nom"])
			if r["ok"]:
				j["lignes"].append("Réparation de la « %s » (Ingénieur, %s) : %s : réussie, la panne est terminée." % [p["nom"], spec, Dice.fmt_jet(r)])
				T["reparees"] += 1
				pannes.remove_at(i)
			else:
				j["lignes"].append("Panne en cours (« %s ») : réparation (Ingénieur, %s) : %s : échec, la panne continue." % [p["nom"], spec, Dice.fmt_jet(r)])
				if p["key"] == "pNavI" and r["succ"] == 0:
					j["lignes"].append("De plus, le navordinateur efface la carte du système.")
			j["evenement"] = true
		for p in pannes:
			match p.get("eff", ""):
				"piloteTD":
					mod["td"] += 1
				"prop":
					mod["dist_frac"] = 0.1
					mod["dead"] = true
				"derive":
					mod["dist_frac"] = 0.1
					mod["surf_interdit"] = true
				"noProgress":
					if not hyper:
						mod["progresse"] = false
				"sensMuets":
					mod["sens_muets"] = true

		if randf() < proba:
			j["evenement"] = true
			var mod_saut: int = res["saut"]["exc"] if (res["saut"] != null and not saut_use and hyper) else 0
			saut_use = true
			var t := tirer_peril(cfg.get("mode", "hyper"), mod_saut)
			if t["ignore"]:
				j["lignes"].append("Jet de catégorie du péril : %d − %d (succès excédentaires du calcul de saut) = %d : négatif, le péril est ignoré." % [t["roll_c"] + mod_saut, mod_saut, t["roll_c"]])
			else:
				var P: Dictionary = TravelTables.PERILS[cfg.get("mode", "hyper")][t["key"]]
				var cat: String = TravelTables.CATS[cfg.get("mode", "hyper")][t["idx"]]
				var pl := {"cat": cat, "cls": TravelTables.CLASSES[t["idx"]], "nom": P["n"], "tirage": t, "repere": false, "ident": false, "detail": [], "issue": ""}
				if mod_saut > 0:
					pl["detail"].append("Jet de catégorie retranché des %d succès excédentaires du calcul de saut : %d − %d = %d." % [mod_saut, t["roll_c"] + mod_saut, mod_saut, t["roll_c"]])
				var s_need: Variant = P["s"]
				if s_need is String and s_need == "-":
					pl["detail"].append("Panne : jamais détectable, le péril se révèle.")
				elif mod["sens_muets"]:
					pl["detail"].append("Senseurs hors service : le péril ne peut pas être repéré.")
				else:
					var r := Dice.test(vi_se, int(s_need))
					pl["repere"] = r["ok"]
					pl["detail"].append("Détection (Vigie %d, Senseurs, %d succès) : %s : %s" % [actif, int(s_need), Dice.fmt_jet(r), "repéré" if r["ok"] else "non repéré"])
				if pl["repere"]:
					var ss_need: Variant = P["ss"]
					if ss_need is String and ss_need == "-":
						pl["ident"] = true
						pl["detail"].append("Identification : protocole évident.")
					elif ss_need is String and ss_need == "X":
						pl["detail"].append("Identification : impossible (aucune science ne l'explique).")
					else:
						var rv := Dice.test(vi_ss, int(ss_need))
						pl["ident"] = rv["ok"]
						pl["detail"].append("Identification (Sciences stellaires %d succès, Vigie %d) : %s : %s" % [ss_need, actif, Dice.fmt_jet(rv), "identifié" if rv["ok"] else "non identifié"])
				match P.get("eff", ""):
					"piloteTD":
						mod["td"] += 1
					"prop":
						mod["dist_frac"] = 0.1
						mod["dead"] = true
					"derive":
						mod["dist_frac"] = 0.1
						mod["surf_interdit"] = true
					"noProgress":
						if not hyper:
							mod["progresse"] = false
				if t["key"] == "amas":
					mod["surf_interdit"] = true
				if t["key"] == "deferlante":
					mod["tf"] += 1
				if t["key"] == "nebuleuse":
					if pl["ident"]:
						mod["td"] += 1
					else:
						mod["surf_interdit"] = true
				if t["key"] == "decharges":
					mod["surf_danger"] = true
					if pl["repere"] and pl["ident"]:
						mod["tf"] += 1
				if t["key"] == "courantT":
					delay += 1
					T["retards"] += 1
					pl["issue"] = "Le voyage s'allonge d'une journée (J-1 sur l'horloge)."
				if t["key"] == "rayonnements":
					T["radix_pc"] -= 100.0
					if res["suivi_reserve"]:
						res["reserve"] += 100.0
					pl["issue"] = "Générateur rechargé de 100 PC."
				if P.get("combat", false):
					var evite := false
					if pl["repere"] and pl["ident"]:
						var r1 := Dice.test(pi, 2, pil_mode.call())
						if r1["ok"]:
							evite = true
							pl["issue"] = "Esquivé : Pilotage (2), %s." % Dice.fmt_jet(r1)
						else:
							var r2 := Dice.test(ae, 3)
							if r2["ok"]:
								evite = true
								pl["issue"] = "Repoussé : Pilotage (2) raté (%s), Armes embarquées (3), %s." % [Dice.fmt_jet(r1), Dice.fmt_jet(r2)]
							else:
								pl["issue"] = "Dégâts subis : %s (Pilotage raté : %s · Armes embarquées ratées : %s)." % [P["deg"], Dice.fmt_jet(r1), Dice.fmt_jet(r2)]
					elif pl["repere"]:
						var r1 := Dice.test(pi, 2, pil_mode.call())
						if r1["ok"]:
							evite = true
							pl["issue"] = "Esquivé de justesse (repéré mais non identifié) : Pilotage (2), %s." % Dice.fmt_jet(r1)
						else:
							pl["issue"] = "Non identifié, l'esquive échoue (%s) : dégâts subis : %s." % [Dice.fmt_jet(r1), P["deg"]]
					else:
						pl["issue"] = "Ni repéré ni identifié : dégâts subis : %s." % P["deg"]
					if evite:
						T["evites"] += 1
					else:
						T["subis"] += 1
						T["degats"].append("%s : %s" % [P["n"], P["deg"]])
						if t["key"] == "parasites":
							T["radix_pc"] += 500.0
							if res["suivi_reserve"]:
								res["reserve"] -= 500.0
				if P.get("panne", false):
					T["pannes"] += 1
					var rd: int = P["repar"]["d"]
					var rtd: bool = P["repar"].get("td", false)
					var spec := "Ingénierie (%d%s)" % [rd, ", TD" if rtd else ""]
					var r: Dictionary
					var sans_pieces := pieces <= 0
					if not sans_pieces:
						pieces -= 1
						T["pieces_used"] += 1
						r = Dice.test(ig, rd, "TD" if rtd else "normal")
					else:
						r = {"ok": false, "succ": 0, "extra": 0, "dice": [], "mode": "normal"}
					if r["ok"]:
						pl["issue"] = "Réparée le soir même par l'Ingénieur (%s, %s)." % [spec, Dice.fmt_jet(r)]
						T["reparees"] += 1
					else:
						pannes.append({"key": t["key"], "nom": P["n"], "eff": P.get("eff", ""), "d": rd, "td": rtd, "eau": P.get("eau", false), "jours": 0})
						pl["issue"] = ("Réparation impossible, plus de pièces détachées en soute (%s) : la panne persiste." if sans_pieces else "Non réparée (%s, %s) : la panne persiste.") % ([spec] if sans_pieces else [spec, Dice.fmt_jet(r)])
						if t["key"] == "pNavI" and r["succ"] == 0:
							pl["issue"] += " De plus, le navordinateur efface la carte du système."
				if P.get("majeur", false):
					T["majeurs"].append("J%d : %s" % [num, P["n"]])
					pl["issue"] += " Événement majeur."
				for dline in pl["detail"]:
					j["lignes"].append(dline)
				j["lignes"].append("Péril du jour (2d6 catégorie %d, 2d6 péril %d) — catégorie « %s » : %s. %s" % [t["roll_c"], t["roll_s"], cat, P["n"], P["d"]])
				if pl["issue"] != "":
					j["lignes"].append(pl["issue"])
				j["peril"] = pl
				T["perils"].append("J%d : %s (%s%s)%s" % [num, P["n"], "repéré" if pl["repere"] else ("révélé" if (P["s"] is String and P["s"] == "-") else "non repéré"), " et identifié" if pl["ident"] else "", " · " + pl["issue"] if pl["issue"] != "" else ""])

		var retard := restant <= 0.0
		if retard:
			var cons_jour_retard: float = vitesse if hyper else 0.0
			if res["suivi_reserve"] and res["reserve"] < cons_jour_retard - 0.000001:
				var f_vol: float = maxf(0.0, res["reserve"] / cons_jour_retard) if cons_jour_retard > 0.0 else 0.0
				res["a_sec"] = true
				res["jour_sec"] = num
				res["fini"] = false
				j["evenement"] = true
				j["lignes"].append("Panne sèche : plus assez de Radix pour reprendre une journée de voyage, le vaisseau s'arrête.")
				T["radix_pc"] += cons_jour_retard * f_vol
				res["reserve"] -= cons_jour_retard * f_vol
			else:
				delay -= 1
				j["evenement"] = true
				j["lignes"].append("Jour de retard (courant temporel) : le vaisseau reprend une journée de voyage.")
				T["radix_pc"] += cons_jour_retard
				if res["suivi_reserve"]:
					res["reserve"] -= cons_jour_retard
		else:
			var restant_avant := restant
			var base := minf(vitesse * mod["dist_frac"], restant)
			var bonus := 0.0
			if restant - base > 0.0:
				var nom_action := "Surfer sur la vague" if hyper else "Tirer des bords"
				if mod["surf_interdit"]:
					j["lignes"].append(nom_action + " : impossible aujourd'hui.")
				elif pil_mode.call() == "dead":
					j["lignes"].append(nom_action + " : impossible (Pilotage hors service).")
				else:
					var r := Dice.test(pi, 1, pil_mode.call())
					if r["ok"] and r["extra"] > 0:
						bonus = r["extra"] * (100.0 if hyper else 1.0)
						j["lignes"].append("%s (Pilote %d, (1)) : %s : +%s %s gratuits." % [nom_action, actif, Dice.fmt_jet(r), MAUtils.fmt_num(bonus), unite])
					else:
						j["lignes"].append("%s (Pilote %d, (1)) : %s : rien." % [nom_action, actif, Dice.fmt_jet(r)])
						if mod["surf_danger"] and not r["ok"]:
							T["degats"].append("Décharges énergétiques : 1S (ignorant le Blindage)")
							j["lignes"].append("La décharge frappe : 1S, ignorant le Blindage.")
							T["subis"] += 1
					j["evenement"] = true
			var frac_radix := 1.0
			var h_plan := 24.0
			if restant - (base + bonus) <= 0.0 and delay == 0:
				var cap_jour: float = vitesse * float(mod["dist_frac"]) + bonus
				h_plan = minf(24.0, restant_avant / cap_jour * 24.0) if cap_jour > 0.0 else 24.0
				frac_radix = h_plan / 24.0
			var cons_jour: float = vitesse * frac_radix if hyper else base * 10.0
			var f_vol := 1.0
			if res["suivi_reserve"] and res["reserve"] < cons_jour - 0.000001:
				f_vol = maxf(0.0, res["reserve"] / cons_jour) if cons_jour > 0.0 else 0.0
				res["a_sec"] = true
				res["jour_sec"] = num
				res["fini"] = false
				j["evenement"] = true
				var dist_sec := minf(base + bonus, restant_avant) * f_vol
				j["lignes"].append("Panne sèche : la réserve de Radix ne couvre pas la journée ; le vaisseau ne vole que %s puis s'arrête, à %s %s de la destination." % [heure_txt(h_plan * f_vol), MAUtils.fmt_num(maxf(0.0, restant_avant - dist_sec)), unite])
			var prevu := minf(base + bonus, restant_avant)
			var part_vol := f_vol if prevu > 0.0 else 0.0
			base *= part_vol
			bonus *= part_vol
			j["base"] = base
			j["bonus"] = bonus
			if f_vol < 1.0:
				T["bonus"] += bonus
			else:
				T["bonus"] += minf(bonus, maxf(0.0, restant_avant - base))
			if mod["progresse"]:
				restant -= (base + bonus)
			if f_vol >= 1.0 and restant <= 0.0 and delay == 0:
				res["heures_fin"] = h_plan
				j["heures_fin"] = h_plan
			var cons_reel: float = vitesse * frac_radix * f_vol if hyper else base * 10.0
			T["radix_pc"] += cons_reel
			if res["suivi_reserve"]:
				res["reserve"] -= cons_reel

		if geo:
			var d_tot := maxf(0.0, minf(float(cfg["distance"]), float(cfg["distance"]) - restant))
			var frac := d_tot / float(cfg["distance"]) if cfg["distance"] > 0 else 1.0
			var dep: Vector2i = cfg["dep"]
			var arr: Vector2i = cfg["arr"]
			var px := dep.x + frac * (arr.x - dep.x)
			var py := dep.y + frac * (arr.y - dep.y)
			j["case"] = Vector2i(int(round(px)), int(round(py)))
			res["case_finale"] = j["case"]
		j["restant"] = restant
		j["arrivee"] = restant <= 0.0 and delay == 0

		T["rations"] += cfg.get("equip", 0) + cfg.get("passagers", 0)
		for p in pannes:
			p["jours"] += 1
			if p.get("eau", false):
				T["eau_pct"] += 10.0
		if ca > 0 and not retard:
			var r := Dice.test(ca, 3)
			if r["ok"]:
				T["releves"] += 1
				if hyper and j.has("case"):
					var deja := false
					for c in T["cases_relees"]:
						if c == j["case"]:
							deja = true
						if not deja:
							T["cases_relees"].append(j["case"])
					j["lignes"].append("Relevé (Cartographie (3)) : %s : réussi, case %s notée sur la carte de la Galaxie." % [Dice.fmt_jet(r), GalaxyData.coord_text(j["case"].x, j["case"].y)])
				else:
					j["lignes"].append("Relevé (Cartographie (3)) : %s : raté, rien ne se passe." % Dice.fmt_jet(r))
		j["lignes"].append("Fin de journée %d : %s %s parcourus%s, reste %s %s." % [num, MAUtils.fmt_num(j.get("base", 0.0)), unite, " (+%s bonus)" % MAUtils.fmt_num(j.get("bonus", 0.0)) if j.get("bonus", 0.0) > 0 else "", MAUtils.fmt_num(maxf(0.0, restant)), unite])
		res["jours"].append(j)

	res["arrivee"] = restant <= 0.0 and delay == 0 and not res["a_sec"]
	res["jours_count"] = num
	res["restant"] = maxf(0.0, restant)
	return res

static func heure_txt(h: float) -> String:
	var tot := int(round(h * 60.0))
	var hh := tot / 60
	var mm := tot % 60
	return "%d h%s" % [hh, (" %02d min" % mm) if mm > 0 else ""]
