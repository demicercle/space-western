class_name Ship
extends RefCounted

var nom := ""
var modele := ""
var description := ""
var classe := ""
var equipage_postes := 4
var longueur_m := 0
var tonnage := 0
var maneuvrabilite := "-"
var vitesse_tactique_K := 0
var vitesse_croisiere_us_j := 0.0
var vitesse_hyper_pc_j := 0
var autonomie_pc := 0
var blindage := 0
var coque_pv := 0
var etats := ["I", "L", "G", "D"]
var etat := "I"
var structure_pv := 0
var detruit := false
var senseurs := ""
var armement: Array = []
var equipage_standard := {}
var passagers_cabines := 0
var passagers_dortoirs := 0
var passagers_max := 0
var soute := 0
var prix := 0
var origine := ""
var systemes_secondaires: Array = []
var cargaison := {}
var rations := 0
var radix_pc := 0

static func etat_txt(e: String) -> String:
	match e:
		"I": return "Indemne"
		"L": return "Léger"
		"G": return "Grave"
		"D": return "Détruit"
	return e

static func galactic_basic(nom: String) -> Ship:
	var s := Ship.new()
	s.nom = nom
	s.modele = "Galactic Basic"
	s.description = "Le Basic est une grosse brique volante d'une trentaine de mètres de long. Sa coque, d'un gris triste, est bombée comme celle d'un bateau. Son pont supérieur est complètement plat et équipé d'une grande trappe d'accès à la soute. Son poste de pilotage ressemble à une coque d'œuf transparente et nervurée de métal. Exigu et fonctionnel, il offre un champ de vision presque circulaire au pilote et à la vigie. C'est dans son dos que se trouve la tourelle, dont l'habitacle est situé juste derrière le cockpit. À l'intérieur, une unique coursive relie les différentes parties du vaisseau, toutes plus exiguës les unes que les autres. Le Basic est un vaisseau de transport léger de catégorie C, le modèle le plus vendu, le plus volé et le plus utilisé de la Galaxie : son générateur, sa propulsion et son hyperpropulsion sont recyclés d'anciens appareils détruits. Il ne devrait coûter que 10 000 €, la barre psychologique du vaisseau le moins cher de la Galaxie."
	s.classe = "Transport léger (100 t / 30 m)"
	s.longueur_m = 30
	s.tonnage = 100
	s.maneuvrabilite = "-"
	s.vitesse_tactique_K = 75
	s.vitesse_croisiere_us_j = 12.0
	s.vitesse_hyper_pc_j = 500
	s.autonomie_pc = 10000
	s.blindage = 0
	s.coque_pv = 10
	s.etat = "I"
	s.structure_pv = s.coque_pv
	s.senseurs = "350 K (3,5 US)"
	s.armement = [
		{"pos": "P (tourelle)", "nom": "Canon laser léger", "stats": "2L / SA / 250 K / 1C"},
	]
	s.equipage_standard = {"P": 1, "V": 1, "C": 1, "Me": 1, "Ma": 0, "total": 4}
	s.equipage_postes = 4
	s.passagers_cabines = 0
	s.passagers_dortoirs = 5
	s.passagers_max = 25
	s.soute = 25
	s.prix = 10000
	s.origine = "OCG"
	s.systemes_secondaires = []
	s.radix_pc = s.autonomie_pc
	s.rations = 200
	s.cargaison = {
		"Ration": 200,
		"Medikit": 1,
		"Munitions laser (x10)": 4,
		"Scaphandre": 2,
		"Pièces détachées (1 kg)": 5,
		"Carte de système": 1,
	}
	return s

static func galactic_scout(nom: String) -> Ship:
	var s := Ship.new()
	s.nom = nom
	s.modele = "Galactic Scout"
	s.classe = "Corvette (100 t / 30 m)"
	s.longueur_m = 30
	s.tonnage = 100
	s.maneuvrabilite = "-"
	s.vitesse_tactique_K = 125
	s.vitesse_croisiere_us_j = 18.0
	s.vitesse_hyper_pc_j = 1000
	s.autonomie_pc = 10000
	s.blindage = 1
	s.coque_pv = 10
	s.etat = "I"
	s.structure_pv = s.coque_pv
	s.senseurs = "500 K (5 US)"
	s.armement = [
		{"pos": "P (tourelle)", "nom": "Canon laser léger", "stats": "2L / SA / 250 K / 1C"},
		{"pos": "V (tourelle)", "nom": "Canon laser léger", "stats": "2L / SA / 250 K / 1C"},
	]
	s.equipage_standard = {"P": 1, "V": 2, "C": 2, "Me": 3, "Ma": 0, "total": 8}
	s.equipage_postes = 8
	s.passagers_cabines = 0
	s.passagers_dortoirs = 5
	s.passagers_max = 25
	s.soute = 5
	s.prix = 21000
	s.origine = "OCG"
	s.systemes_secondaires = ["Sas d'abordage", "Infirmerie"]
	s.radix_pc = s.autonomie_pc
	s.rations = 200
	s.cargaison = {
		"Ration": 200,
		"Medikit": 1,
		"Munitions laser (x10)": 4,
		"Scaphandre": 2,
		"Pièces détachées (1 kg)": 5,
		"Carte de système": 1,
	}
	return s

func subir_degats(deg: String) -> String:
	var re := RegEx.new()
	re.compile("(\\d+)\\s*([LGMS])")
	var m := re.search(deg)
	if m == null:
		return deg
	var n := int(m.get_string(1))
	var sev := m.get_string(2)
	var mult: int = {"L": 1, "G": 2, "M": 3, "S": 5}[sev]
	var degats := n * mult
	if detruit:
		return "%s : vaisseau déjà détruit." % deg
	structure_pv -= degats
	var idx := etats.find(etat)
	while structure_pv <= 0 and idx < etats.size() - 1:
		idx += 1
		structure_pv += coque_pv
	etat = etats[idx]
	if idx == etats.size() - 1 and structure_pv <= 0:
		structure_pv = 0
		detruit = true
	return "%s : −%d points de structure (état %s, %d/%d PV%s)." % [deg, degats, etat_txt(etat), structure_pv, coque_pv, ", DESTRUCTION" if detruit else ""]

func fiche_txt() -> String:
	var lines: Array = []
	lines.append("%s — %s" % [nom, modele])
	lines.append("Classe : %s" % classe)
	lines.append("Manœuvrabilité : %s · Vitesse tactique : %d K/t" % [maneuvrabilite, vitesse_tactique_K])
	lines.append("Vitesse de croisière : %s US/h (%s US/j)" % [MAUtils.fmt_num(vitesse_croisiere_us_j / 24.0), MAUtils.fmt_num(vitesse_croisiere_us_j)])
	lines.append("Vitesse hyperspatiale : %d PC/j" % vitesse_hyper_pc_j)
	lines.append("Autonomie : %s PC · Réserve de Radix : %s / %s PC" % [MAUtils.fmt_int(autonomie_pc), MAUtils.fmt_int(radix_pc), MAUtils.fmt_int(autonomie_pc)])
	lines.append("Blindage : %d · Coque : %d PV par état · État : %s (%d/%d PV)%s" % [blindage, coque_pv, etat_txt(etat), structure_pv, coque_pv, " — DÉTRUIT" if detruit else ""])
	lines.append("Senseurs : %s" % senseurs)
	var eq: Dictionary = equipage_standard
	lines.append("Équipage standard : %d P + %d V + %d C + %d Me + %d Ma (%d)" % [eq.get("P", 0), eq.get("V", 0), eq.get("C", 0), eq.get("Me", 0), eq.get("Ma", 0), eq.get("total", 0)])
	lines.append("Passagers : %d cabine(s) + %d dortoir(s) (max %d)" % [passagers_cabines, passagers_dortoirs, passagers_max])
	lines.append("Soute : %d unités cargo" % soute)
	lines.append("Prix : %s € · Origine : %s" % [MAUtils.fmt_int(prix), origine])
	lines.append("Armement :")
	for a in armement:
		lines.append("  %s — %s (%s)" % [a["pos"], a["nom"], a["stats"]])
	lines.append("Systèmes secondaires : " + (", ".join(systemes_secondaires) if systemes_secondaires.size() > 0 else "aucun"))
	lines.append("Rations en soute : %d (1 par personne et par jour de voyage)" % rations)
	return "\n".join(lines)
