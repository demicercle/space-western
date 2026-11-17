class_name ShipPanel
extends HBoxContainer

var sheet_label: RichTextLabel
var hold_label: RichTextLabel
var soute_bar: ProgressBar
var hold_list: GridContainer
var hold_msg: Label
var cours: Dictionary = {"A": 1.0, "B": 1.0, "C": 1.0}
var docked := false
var radix_unit_price := 75.0
var ship: Ship

func _ready() -> void:
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	var p1 := PanelContainer.new()
	p1.size_flags_horizontal = SIZE_EXPAND_FILL
	p1.size_flags_vertical = SIZE_EXPAND_FILL
	p1.custom_minimum_size = Vector2(430, 0)
	add_child(p1)
	var sc1 := ScrollContainer.new()
	sc1.size_flags_horizontal = SIZE_EXPAND_FILL
	sc1.size_flags_vertical = SIZE_EXPAND_FILL
	p1.add_child(sc1)
	var vb1 := VBoxContainer.new()
	vb1.size_flags_horizontal = SIZE_EXPAND_FILL
	sc1.add_child(vb1)
	var t1 := Label.new()
	t1.text = "Fiche du vaisseau"
	t1.add_theme_font_size_override("font_size", 15)
	t1.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	vb1.add_child(t1)
	sheet_label = RichTextLabel.new()
	sheet_label.bbcode_enabled = true
	sheet_label.fit_content = true
	sheet_label.add_theme_font_size_override("font_size", 12)
	sheet_label.size_flags_horizontal = SIZE_EXPAND_FILL
	vb1.add_child(sheet_label)
	var p2 := PanelContainer.new()
	p2.size_flags_horizontal = SIZE_EXPAND_FILL
	p2.size_flags_vertical = SIZE_EXPAND_FILL
	p2.custom_minimum_size = Vector2(360, 0)
	add_child(p2)
	var sc2 := ScrollContainer.new()
	sc2.size_flags_horizontal = SIZE_EXPAND_FILL
	sc2.size_flags_vertical = SIZE_EXPAND_FILL
	p2.add_child(sc2)
	var vb2 := VBoxContainer.new()
	vb2.size_flags_horizontal = SIZE_EXPAND_FILL
	sc2.add_child(vb2)
	var t2 := Label.new()
	t2.text = "Soute et réserves"
	t2.add_theme_font_size_override("font_size", 15)
	t2.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	vb2.add_child(t2)
	hold_label = RichTextLabel.new()
	hold_label.bbcode_enabled = true
	hold_label.fit_content = true
	hold_label.size_flags_horizontal = SIZE_EXPAND_FILL
	vb2.add_child(hold_label)
	soute_bar = ProgressBar.new()
	soute_bar.custom_minimum_size = Vector2(0, 18)
	soute_bar.min_value = 0.0
	soute_bar.max_value = 100.0
	soute_bar.show_percentage = true
	vb2.add_child(soute_bar)
	hold_msg = Label.new()
	hold_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hold_msg.add_theme_font_size_override("font_size", 11)
	hold_msg.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	vb2.add_child(hold_msg)
	hold_list = GridContainer.new()
	hold_list.columns = 2
	hold_list.add_theme_constant_override("h_separation", 12)
	hold_list.add_theme_constant_override("v_separation", 3)
	hold_list.size_flags_horizontal = SIZE_EXPAND_FILL
	vb2.add_child(hold_list)

func prix_vente_unit(nom: String) -> int:
	return ShopTables.prix_vente(nom, cours)

func prix_base(nom: String) -> int:
	var it: Variant = ShopTables.find_catalogue(nom)
	if it == null:
		it = ShopTables.find_marchandise(nom)
	if it == null:
		it = ShopTables.find_in(ShopTables.STATION_RELAIS, nom)
	if it == null:
		return 1
	return ShopTables.prix_base(it)

func set_context(p_cours: Dictionary, p_docked: bool, p_radix_price: float) -> void:
	cours = p_cours
	docked = p_docked
	radix_unit_price = p_radix_price
	if ship != null:
		set_ship(ship)

func soute_used() -> float:
	if ship == null:
		return 0.0
	var u := 0.0
	for k in ship.cargaison.keys():
		u += ShopTables.place_de(k) * float(ship.cargaison[k])
	return u

func set_ship(s: Ship) -> void:
	ship = s
	if s == null:
		sheet_label.text = ""
		hold_label.text = ""
		if soute_bar != null:
			soute_bar.value = 0.0
		return
	var bb := "[b][color=gold]%s[/color][/b] — %s\n" % [s.nom, s.modele]
	if s.description != "":
		bb += "[i]%s[/i]\n\n" % s.description
	bb += "Classe : %s\n" % s.classe
	bb += "Manœuvrabilité : %s · Vitesse tactique : %d K/t\n" % [s.maneuvrabilite, s.vitesse_tactique_K]
	bb += "Vitesse de croisière : %s US/h (%s US/j)\n" % [MAUtils.fmt_num(s.vitesse_croisiere_us_j / 24.0), MAUtils.fmt_num(s.vitesse_croisiere_us_j)]
	bb += "Vitesse hyperspatiale : [b]%d PC/j[/b]\n" % s.vitesse_hyper_pc_j
	bb += "Autonomie : %s PC · Réserve de Radix : [b]%s / %s PC[/b]\n" % [MAUtils.fmt_int(s.autonomie_pc), MAUtils.fmt_int(s.radix_pc), MAUtils.fmt_int(s.autonomie_pc)]
	bb += "Blindage : %d · Coque : %d PV/état\n" % [s.blindage, s.coque_pv]
	bb += "État : [color=%s]%s[/color] (%d/%d PV)%s\n" % ["#ff5544" if s.detruit else "#7bed9f", Ship.etat_txt(s.etat), s.structure_pv, s.coque_pv, " — DÉTRUIT" if s.detruit else ""]
	bb += "Senseurs : %s\n" % s.senseurs
	var eq: Dictionary = s.equipage_standard
	bb += "Équipage standard : %d P + %d V + %d C + %d Me + %d Ma (%d)\n" % [eq.get("P", 0), eq.get("V", 0), eq.get("C", 0), eq.get("Me", 0), eq.get("Ma", 0), eq.get("total", 0)]
	bb += "Passagers : %d cabine(s) + %d dortoir(s) (max %d)\n" % [s.passagers_cabines, s.passagers_dortoirs, s.passagers_max]
	bb += "Soute : %s / %s UC\n" % [MAUtils.fmt_num(soute_used()), MAUtils.fmt_num(s.soute)]
	bb += "Prix : %s € · Origine : %s\n" % [MAUtils.fmt_int(s.prix), s.origine]
	bb += "\n[b]Armement[/b]\n"
	for a in s.armement:
		bb += "  %s — %s (%s)\n" % [a["pos"], a["nom"], a["stats"]]
	bb += "\n[b]Systèmes secondaires[/b] : " + (", ".join(s.systemes_secondaires) if s.systemes_secondaires.size() > 0 else "aucun") + "\n"
	sheet_label.text = bb
	var hb := "[b]Réserve de Radix[/b] : %s / %s PC — plein : %s €/1 000 PC (planète ×0,75, station-relais ×1,5 le tonnage ; ici %s €/1 000 PC)\n" % [MAUtils.fmt_int(s.radix_pc), MAUtils.fmt_int(s.autonomie_pc), MAUtils.fmt_num(s.tonnage * 0.75), MAUtils.fmt_num(radix_unit_price)]
	hb += "[b]Rations[/b] : %d (+%d repas, consommés en priorité) — 1 par personne et par jour de voyage\n" % [s.rations, int(s.cargaison.get("Repas", 0))]
	hb += "[b]Poids en soute[/b] : %s t / %s t · cours de vente : A ×%s · B ×%s · C ×%s · prix de vente = prix d'achat ÷ 1,5 (occasion)%s\n" % [MAUtils.fmt_num(soute_used()), MAUtils.fmt_num(s.soute), MAUtils.fmt_num(cours.get("A", 1.0)), MAUtils.fmt_num(cours.get("B", 1.0)), MAUtils.fmt_num(cours.get("C", 1.0)), "" if docked else " (vente indisponible ici)"]
	hold_label.text = hb
	if soute_bar != null:
		soute_bar.value = 100.0 * soute_used() / maxf(1.0, float(s.soute))
	for ch in hold_list.get_children():
		hold_list.remove_child(ch)
		ch.queue_free()
	hold_list.add_child(_hold_header("Nom de l'article"))
	hold_list.add_child(_hold_header("Quantité"))
	var keys := s.cargaison.keys()
	keys.sort()
	for k in keys:
		var q: float = float(s.cargaison[k])
		if q <= 0.0001:
			continue
		var nl := Label.new()
		nl.text = ShopTables.nom_affiche(str(k))
		nl.add_theme_font_size_override("font_size", 12)
		hold_list.add_child(nl)
		var ql := Label.new()
		ql.text = "%s · %s" % [ShopTables.quantite_soute_txt(str(k), q), ShopTables.tonnage_txt(q, ShopTables.place_de(str(k)))]
		ql.add_theme_font_size_override("font_size", 12)
		hold_list.add_child(ql)

func _hold_header(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	return l

func set_message(t: String) -> void:
	hold_msg.text = t
