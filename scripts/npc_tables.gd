class_name NPCTables

const CARACS := ["Agilité", "Carrure", "Perception", "Intelligence", "Présence", "Sang-froid"]

const CARACS_TABLE := {
	"Normal": [3, 2, 2, 2, 2, 1],
	"Élite": [3, 3, 3, 2, 2, 2],
	"Héros": [4, 3, 3, 3, 3, 2],
	"Boss": [5, 4, 4, 3, 3, 2],
	"Big Boss": [5, 5, 4, 4, 3, 3],
}

const COMP_TABLE := {
	"Normal": [2, 2, 2, 1, 1, 1, 1],
	"Élite": [3, 3, 2, 2, 2, 1, 1, 1, 1, 1],
	"Héros": [4, 4, 3, 3, 3, 2, 2, 1, 1, 1, 1, 1, 1],
	"Boss": [5, 4, 4, 4, 3, 3, 2, 2, 1, 1, 1, 1, 1, 1, 1],
	"Big Boss": [5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 1, 1, 1, 1, 1, 1, 1],
}

const GRATUITS := {"Boss": 5, "Big Boss": 10}

const DOMAINES := ["Techniques", "Survie", "Espionnage", "Sciences", "Négociation", "Trempe"]

const DOMAINES_CARAC := {
	"Techniques": "Agilité",
	"Survie": "Carrure",
	"Espionnage": "Perception",
	"Sciences": "Intelligence",
	"Négociation": "Présence",
	"Trempe": "Sang-froid",
}

const COMPETENCES := {
	"Techniques": ["Acrobaties", "Armes d'épaule", "Armes de poing", "Armes embarquées", "Artisanat", "Pilotage"],
	"Survie": ["Armes de jet", "Armes lourdes", "Athlétisme", "Mêlée"],
	"Espionnage": ["Déguisement", "Discrétion", "Falsification", "Recherche", "Senseurs", "Systèmes de sécurité"],
	"Sciences": ["Analyse", "Arts", "Connaissance", "Histoire", "Ingénierie", "Médecine", "Navigation", "Sciences solaires", "Sciences stellaires", "Stratégie"],
	"Négociation": ["Baratin", "Bureaucratie", "Comédie", "Commerce", "Danse", "Étiquette", "Jeux", "Séduction"],
	"Trempe": ["Commandement", "Démolition", "Détermination", "Illégalités", "Intimidation", "Premiers soins", "Tactiques"],
}

const PROFESSIONS_MILITAIRES := ["Soldat du rang", "Soldat d'élite / vétéran", "Officier militaire", "Force de l'ordre", "Mercenaire"]

static func type_profession(p: String) -> String:
	if PROFESSIONS_MILITAIRES.has(p):
		return "militaire"
	return "civil"

const PROFESSIONS := {
	"Soldat du rang": {"dom": ["Techniques", "Survie", "Trempe"], "comp": ["Armes d'épaule", "Mêlée", "Athlétisme", "Tactiques", "Armes de poing", "Intimidation"]},
	"Soldat d'élite / vétéran": {"dom": ["Techniques", "Survie", "Trempe"], "comp": ["Armes d'épaule", "Armes lourdes", "Mêlée", "Tactiques", "Athlétisme", "Détermination", "Armes de poing"]},
	"Officier militaire": {"dom": ["Trempe", "Techniques", "Sciences"], "comp": ["Commandement", "Tactiques", "Stratégie", "Armes d'épaule", "Étiquette"]},
	"Pilote": {"dom": ["Techniques", "Espionnage", "Sciences"], "comp": ["Pilotage (Vaisseau spatial)", "Senseurs", "Navigation", "Armes embarquées", "Analyse"]},
	"Canonnier": {"dom": ["Techniques", "Survie", "Espionnage"], "comp": ["Armes embarquées", "Armes lourdes", "Senseurs", "Mêlée"]},
	"Marchand": {"dom": ["Négociation", "Sciences", "Espionnage"], "comp": ["Commerce", "Baratin", "Étiquette", "Analyse", "Bureaucratie"]},
	"Contrebandier": {"dom": ["Espionnage", "Négociation", "Techniques"], "comp": ["Discrétion", "Commerce", "Systèmes de sécurité", "Baratin", "Falsification", "Pilotage"]},
	"Fonctionnaire": {"dom": ["Négociation", "Sciences", "Espionnage"], "comp": ["Bureaucratie", "Étiquette", "Histoire", "Analyse", "Baratin"]},
	"Noble solaire": {"dom": ["Négociation", "Sciences", "Trempe"], "comp": ["Étiquette", "Danse", "Histoire", "Commandement", "Baratin", "Connaissance"]},
	"Médecin": {"dom": ["Sciences", "Trempe", "Techniques"], "comp": ["Médecine", "Premiers soins", "Sciences stellaires", "Analyse", "Détermination"]},
	"Scientifique": {"dom": ["Sciences", "Techniques", "Espionnage"], "comp": ["Sciences stellaires", "Analyse", "Ingénierie", "Connaissance", "Navigation", "Histoire"]},
	"Ingénieur / machiniste": {"dom": ["Sciences", "Techniques", "Trempe"], "comp": ["Ingénierie", "Artisanat", "Analyse", "Armes embarquées", "Premiers soins"]},
	"Force de l'ordre": {"dom": ["Espionnage", "Techniques", "Trempe"], "comp": ["Recherche", "Armes de poing", "Intimidation", "Systèmes de sécurité", "Discrétion", "Tactiques"]},
	"Mercenaire": {"dom": ["Techniques", "Survie", "Trempe"], "comp": ["Armes d'épaule", "Armes de poing", "Mêlée", "Athlétisme", "Illégalités", "Intimidation"]},
	"Barman / tenancier": {"dom": ["Négociation", "Espionnage", "Trempe"], "comp": ["Baratin", "Jeux", "Illégalités", "Recherche", "Séduction"]},
	"Mineur / ouvrier": {"dom": ["Survie", "Techniques", "Trempe"], "comp": ["Athlétisme", "Ingénierie", "Artisanat", "Mêlée", "Détermination"]},
	"Agriculteur": {"dom": ["Survie", "Sciences", "Négociation"], "comp": ["Connaissance", "Commerce", "Athlétisme", "Premiers soins"]},
	"Journaliste": {"dom": ["Espionnage", "Négociation", "Sciences"], "comp": ["Recherche", "Analyse", "Baratin", "Bureaucratie", "Discrétion"]},
	"Artiste": {"dom": ["Sciences", "Négociation", "Trempe"], "comp": ["Arts", "Comédie", "Danse", "Séduction", "Baratin"]},
	"Religieux / gourou": {"dom": ["Sciences", "Trempe", "Négociation"], "comp": ["Connaissance", "Commandement", "Détermination", "Comédie", "Étiquette"]},
	"Pirate de l'espace": {"dom": ["Trempe", "Survie", "Techniques"], "comp": ["Armes d'épaule", "Mêlée", "Navigation", "Illégalités", "Baratin", "Pilotage", "Détermination"]},
}

const TRAITS_DEFAUTS := [
	["Amarres", -1, "responsabilité de pure forme"],
	["Amarres", -3, "doit demander l'autorisation avant de s'absenter"],
	["Désespoir", -1, "(D+2) aux tests de moral, Commandement et Intimidation"],
	["Désespoir", -3, "perd définitivement 2 PP"],
	["Subordonné", -1, "employé à temps partiel"],
	["Subordonné", -3, "employé à temps plein"],
	["Subordonné", -5, "esclave à vie"],
]

const TRAITS_QUALITES := [
	["Célébrité galactique", 1, "+1 Gloire (Gloire ≥ 5 requis)"],
	["Customisation", 1, "1 000 PX de customisations"],
	["Discret", 3, "−1 Gloire"],
	["Équipement spécial", 1, "commerce d'une autre nation"],
	["Équipement spécial", 3, "objets « alerte rouge » de sa nation"],
	["Grade", 1, "officier"],
	["Grade", 3, "officier supérieur"],
	["Grade", 5, "officier d'état-major"],
	["Mutation", 3, "mutation basique (si Gènes évolutifs)"],
	["Mutation", 5, "mutation avancée (si Gènes évolutifs)"],
	["Spécialité", 1, "spécialité (compétence ≤ 3)"],
	["Spécialité", 3, "spécialité (compétence 4)"],
	["Spécialité", 5, "spécialité (compétence ≥ 5)"],
	["Statut social", 1, "noble mineur, cadre, officier (Aisé)"],
	["Statut social", 3, "noble, officier supérieur, directeur (Riche)"],
	["Statut social", 5, "famille solaire, officier d'état-major, directoire galactique (Très riche)"],
]

const ROLES_SANTE := {
	"Figurant": ["Blessé léger", "Mort ?"],
	"Second rôle": ["Indemne", "Blessé léger", "Mort ?"],
	"Premier rôle": ["Indemne", "Blessé léger", "Blessé grave", "Mort ?"],
}

const ROLES_PG := {
	"Figurant": [0, 0],
	"Second rôle": [3, 1],
	"Premier rôle": [5, 3],
}

const PRENOMS := ["Alonzo", "Bruno", "Catalina", "Diego", "Esperanza", "Fidel", "Gonzalo", "Ines", "Joaquin", "Kiko", "Luna", "Manolo", "Nadia", "Orlando", "Paloma", "Quentin", "Ramona", "Santiago", "Teresa", "Ulysse", "Vito", "Ximena", "Yannick", "Zoé", "Marek", "Stella", "Django", "Rosita", "Esteban", "Mirta", "Cosmo", "Selma", "Pancho", "Ilan"]

const NOMS := ["Aguirre", "Barragan", "Cruz", "Dominguez", "Escobar", "Fuentes", "Gallardo", "Herrera", "Ibanez", "Jimenez", "Kowalski", "Lopez", "Marchetti", "Navarro", "Ortega", "Pizarro", "Quintero", "Ramirez", "Salazar", "Trujillo", "Umberto", "Vargas", "Wexler", "Yagami", "Zapata", "Bell", "Kruger", "Moreau", "Voss", "Falkenrath"]

const SURNOMS := ["le Taciturne", "la Manchote", "Trois-Doigts", "la Balafre", "le Rouquin", "la Veuve", "Beau-Parleur", "la Pipe", "Chien-Noir", "Muet", "Demi-Lune", "la lame de Libertad"]

const MOTIVATIONS := ["trouver le trésor de [PNJ célèbre]", "venger son frère disparu", "racheter le vaisseau familial", "devenir une légende de la confrérie", "fuir un passé de fonctionnaire", "faire fortune et prendre sa retraite à Libertad", "retrouver l'équipage qui l'a marooné", "prouver qu'il est le meilleur pilote de la Galaxie", "renverser un noble solaire"]
