class_name SalvageTables

const SITES := ["Ceinture de débris", "Champ de bataille", "Champ d'astéroïdes", "Cimetière de vaisseaux", "Décharge", "Épave", "Ruines"]
const SITES_ESPACE := ["Ceinture de débris", "Champ d'astéroïdes", "Cimetière de vaisseaux", "Épave"]
const SITES_RECUP_CARTE := ["Ruines", "Décharge", "Champ de bataille", "Épave"]

const TROUVAILLES := ["Composants électroniques", "Composants industriels", "Composants spatiaux", "Recharge", "Épave (vaisseau)", "Épave (véhicule)", "Marchandise", "Minerai"]

const RECHARGES := ["blaster", "laser", "plasma", "armes lourdes", "carburant", "Radix"]
const RECHARGES_LBL := ["blaster (2 munitions/succès)", "laser (10 munitions/succès)", "plasma (3 munitions/succès)", "armes lourdes (1 munition/succès)", "carburant (100 km/succès)", "Radix (réserves de secours : 1 succès/10 t)"]

const MODS := {
	"Ceinture de débris": {"Composants électroniques": "D+1", "Composants industriels": "D+1", "Composants spatiaux": "-", "Recharge": "TD", "Épave (vaisseau)": "TD", "Épave (véhicule)": "x", "Marchandise": "x", "Minerai": "x"},
	"Champ de bataille": {"Composants électroniques": "+1d", "Composants industriels": "-", "Composants spatiaux": "x", "Recharge": "TD", "Épave (vaisseau)": "x", "Épave (véhicule)": "-", "Marchandise": "x", "Minerai": "x"},
	"Champ d'astéroïdes": {"Composants électroniques": "D+1", "Composants industriels": "D+1", "Composants spatiaux": "D+1", "Recharge": "D+1", "Épave (vaisseau)": "TD", "Épave (véhicule)": "x", "Marchandise": "TD", "Minerai": "+1d"},
	"Cimetière de vaisseaux": {"Composants électroniques": "D+1", "Composants industriels": "D+1", "Composants spatiaux": "-", "Recharge": "D+1", "Épave (vaisseau)": "D+1", "Épave (véhicule)": "x", "Marchandise": "TD", "Minerai": "x"},
	"Décharge": {"Composants électroniques": "-", "Composants industriels": "+1d", "Composants spatiaux": "x", "Recharge": "x", "Épave (vaisseau)": "x", "Épave (véhicule)": "-", "Marchandise": "TD", "Minerai": "x"},
	"Épave": {"Composants électroniques": "D+1", "Composants industriels": "D+1", "Composants spatiaux": "D+1", "Recharge": "D+1", "Épave (vaisseau)": "D+1", "Épave (véhicule)": "-", "Marchandise": "TD", "Minerai": "x"},
	"Ruines": {"Composants électroniques": "D+1", "Composants industriels": "D+1", "Composants spatiaux": "x", "Recharge": "-", "Épave (vaisseau)": "TD", "Épave (véhicule)": "-", "Marchandise": "TD", "Minerai": "x"},
}

const PRODUITS := {
	"Arme de fortune": {"comp": "Technologie", "diff": 3, "besoin": {"comp_elec": 10, "comp_indus": 10}, "donne": "Arme de fortune"},
	"Équipement de fortune": {"comp": "Technologie", "diff": 1, "besoin": {"comp_elec": 10, "comp_indus": 10}, "donne": "Équipement de fortune"},
	"Équipement de fortune (HT)": {"comp": "Technologie", "diff": 3, "besoin": {"comp_elec": 10, "comp_spatial": 10}, "donne": "Équipement de fortune (HT)"},
	"Véhicule de fortune": {"comp": "Ingénierie", "diff": 2, "besoin": {"comp_elec": 100, "comp_indus": 100, "epave_vehicule": 1}, "donne": "Véhicule de fortune"},
	"Vaisseau spatial (de fortune)": {"comp": "Ingénierie", "diff": 0, "besoin": {"comp_spatial": 0, "epave_vaisseau": 1}, "donne": "", "vaisseau": true},
}

static func modif(site: String, trouvaille: String) -> String:
	var d: Dictionary = MODS.get(site, {})
	return str(d.get(trouvaille, "x"))

static func est_site_espace(site: String) -> bool:
	return SITES_ESPACE.has(site)

static func sites_du_corps(body: Dictionary) -> Array:
	var sites: Array = []
	var pm: Variant = body.get("planet_map", null)
	if pm != null and pm.has("sites"):
		var m: Dictionary = pm["sites"]
		for v in m.values():
			var sv := str(v)
			if SITES_RECUP_CARTE.has(sv) and not sites.has(sv):
				sites.append(sv)
	var cours := StarSystem.parse_cours(str(body.get("cours", "")))
	if float(cours.get("B", 0.0)) > 0.0 and not sites.has("Décharge"):
		sites.append("Décharge")
	var so: String = str(body.get("systeme_orbital", "")).to_lower()
	if so.contains("ceinture de débris") and not sites.has("Ceinture de débris"):
		sites.append("Ceinture de débris")
	if so.contains("cimetière") and not sites.has("Cimetière de vaisseaux"):
		sites.append("Cimetière de vaisseaux")
	if (so.contains("ceinture d'astéroïdes") or so.contains("champ d'astéroïdes")) and not sites.has("Champ d'astéroïdes"):
		sites.append("Champ d'astéroïdes")
	if so.contains("épave") and not sites.has("Épave"):
		sites.append("Épave")
	return sites

static func comp_remise(produit: String) -> String:
	var p: Dictionary = PRODUITS.get(produit, {})
	return str(p.get("comp", "Technologie"))

static func diff_remise(produit: String, prix_vaisseau: int) -> int:
	if produit == "Vaisseau spatial (de fortune)":
		return maxi(1, int(round(prix_vaisseau / 2500.0)))
	var p: Dictionary = PRODUITS.get(produit, {})
	return int(p.get("diff", 1))

static func besoin_remise(produit: String, nb_systemes: int) -> Dictionary:
	var p: Dictionary = PRODUITS.get(produit, {})
	var b: Dictionary = (p.get("besoin", {}) as Dictionary).duplicate()
	if produit == "Vaisseau spatial (de fortune)":
		b["comp_spatial"] = 100 * nb_systemes
	return b

static func recharge_quantite(recharge: String, extra: int) -> int:
	match recharge:
		"blaster":
			return 2 * extra
		"laser":
			return 10 * extra
		"plasma":
			return 3 * extra
		"armes lourdes":
			return extra
		"carburant":
			return 100 * extra
	return 0
