class_name SystemTables

const NATIONS := ["la Ligue des Planètes Libres", "l'Empire Galactique", "l'Empire de Sol", "l'OCG (Omni-cartel Galactique)", "une enclave des Barrens", "aucune (système indépendant)"]

const GOUV := ["Anarchie", "Aucun", "Collectivisme", "Corporatiste", "Démocratie", "Dictature", "Monarchie"]

const ROUTES := [["Route galactique", 2], ["Route commerciale", 4], ["Hors des routes", 3], ["Mystérieux", 1]]

const TRAFICS := [
	["négligeable", "seuls les équipages en transit croisent ici"],
	["faible", "quelques vaisseaux par semaine"],
	["moyen", "un va-et-vient permanent autour des astroports"],
	["important", "un flot incessant de vaisseaux marchands"],
]

const ETOILES := [["naine jaune", 40], ["naine rouge", 25], ["géante rouge", 12], ["étoile variable", 10], ["étoile binaire", 13]]

const ENVIRONNEMENTS := ["Désert", "Jungle", "Forêt", "Montagnes", "Plaines", "Toundra", "Glaciers", "Marais", "Océans", "Volcans", "Côtes", "Canyons"]

const TEMP_ANORMALES := [
	"température excessive (le jour)",
	"froid glacial (la nuit)",
	"radioactive (l'eau n'y est pas potable, la faune et la flore ne sont pas comestibles)",
]

const TEMPERATURES := ["glaciale", "froide", "tempérée", "chaude", "torride"]

const ENV_VIVABLE := {
	"glaciale": ["Toundra", "Côtes"],
	"froide": ["Toundra", "Côtes", "Montagnes"],
	"tempérée": ["Forêt", "Plaines", "Montagnes", "Côtes", "Marais"],
	"chaude": ["Désert", "Jungle", "Marais", "Côtes"],
	"torride": ["Désert", "Jungle"],
}

const ENV_SAUVAGE := {
	"glaciale": ["Glaciers", "Toundra", "Océans"],
	"froide": ["Glaciers", "Toundra", "Montagnes", "Océans"],
	"tempérée": ["Forêt", "Plaines", "Montagnes", "Côtes", "Océans", "Marais"],
	"chaude": ["Désert", "Volcans", "Canyons", "Côtes"],
	"torride": ["Volcans", "Canyons", "Désert"],
}

const COULEUR_ENV := {
	"Désert": ["jaune pastel", "rouge ocre", "orange brûlé", "grise et poussiéreuse"],
	"Jungle": ["vert turquoise", "verte et brune"],
	"Forêt": ["verte et brune", "vert turquoise"],
	"Plaines": ["verte et brune", "jaune pastel"],
	"Montagnes": ["grise et poussiéreuse", "rouge ocre"],
	"Marais": ["verte et brune", "vert turquoise"],
	"Océans": ["bleu azur", "d'un bleu profond", "vert turquoise"],
	"Côtes": ["bleu azur", "vert turquoise", "d'un bleu profond"],
	"Toundra": ["blanche et glacée", "grise et poussiéreuse"],
	"Glaciers": ["blanche et glacée"],
	"Volcans": ["rouge ocre", "orange brûlé", "violette"],
	"Canyons": ["rouge ocre", "orange brûlé", "grise et poussiéreuse"],
}

const COULEUR_GAZ := {
	"glaciale": ["d'un bleu profond", "violette", "blanche et glacée"],
	"froide": ["bleu azur", "d'un bleu profond"],
	"tempérée": ["jaune pastel", "orange brûlé"],
	"chaude": ["rouge ocre", "orange brûlé"],
	"torride": ["rouge ocre", "orange brûlé", "violette"],
}

const ATMOS_ENV := {
	"Volcans": [["Toxique", 3], ["Dangereux (acide)", 3]],
	"Canyons": [["Toxique", 2], ["Dangereux (acide)", 2], ["Irrespirable", 2]],
	"Désert": [["aucune", 3], ["Irrespirable", 3], ["Toxique", 1]],
	"Glaciers": [["aucune", 3], ["Irrespirable", 3]],
	"Océans": [["Irrespirable", 3], ["Toxique", 2], ["Dangereux (acide)", 1]],
	"Toundra": [["aucune", 2], ["Irrespirable", 3]],
	"Forêt": [["Toxique", 3], ["Irrespirable", 2]],
	"Plaines": [["Toxique", 2], ["Irrespirable", 2], ["aucune", 2]],
	"Montagnes": [["Irrespirable", 3], ["aucune", 2], ["Toxique", 1]],
	"Marais": [["Toxique", 3], ["Dangereux (acide)", 2], ["Irrespirable", 1]],
	"Côtes": [["Irrespirable", 2], ["Toxique", 2], ["aucune", 1]],
}

const HOSTILITE_ENV := {"Forêt": 0, "Plaines": 0, "Côtes": 0, "Montagnes": 1, "Désert": 1, "Jungle": 1, "Marais": 1, "Océans": 1, "Toundra": 2, "Canyons": 2, "Glaciers": 3, "Volcans": 3}

const CATEGORIES := ["agricole", "aristocratique", "commerçante", "industrielle", "touristique", "sauvage", "minière (extraction)", "pétrolière (gaz et hydrocarbures)", "religieuse (pèlerinage)", "stratégique (militaire)"]

const PATROUILLES := [["Corvette pirate", 6], ["Patrouille des forces de l'ordre de la nation", 5], ["Corporation : mercenaires", 3], ["Flotte de la noblesse locale", 2]]

const NOM_SYL := ["al", "be", "cor", "del", "e", "fa", "gan", "hes", "il", "jus", "ka", "lo", "mar", "ne", "os", "pra", "qui", "ras", "sol", "ta", "ur", "vas", "xe", "yor", "zen"]

const NOM_FIN := ["a", "o", "e", "is", "or", "um", "ax", "ia", "on", "ar"]

const COULEURS := {
	"bleu azur": "#4fa3d1",
	"vert turquoise": "#2ec4a6",
	"jaune pastel": "#f4d35e",
	"rouge ocre": "#c1553f",
	"grise et poussiéreuse": "#8d93b8",
	"blanche et glacée": "#dde3f5",
	"verte et brune": "#7a9e4f",
	"violette": "#9b6dd6",
	"orange brûlé": "#d0602f",
	"d'un bleu profond": "#1e56b0",
}
