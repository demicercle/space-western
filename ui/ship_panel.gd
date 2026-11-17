class_name ShipPanel
extends HBoxContainer

signal sell_requested(nom: String)

var sheet_label: RichTextLabel
var hold_label: RichTextLabel
var hold_list: VBoxContainer
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
	hold_msg = Label.new()
	hold_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hold_msg.add_theme_font_size_override("font_size", 11)
	hold_msg.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	vb2.add_child(hold_msg)
	hold_list = VBoxContainer.new()
	hold_list.add_theme_constant_override("separation", 3)
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
	hb += "[b]Soute[/b] : %s / %s UC · cours de vente : A ×%s · B ×%s · C ×%s · prix de vente = prix d'achat ÷ 1,5 (occasion)%s\n" % [MAUtils.fmt_num(soute_used()), MAUtils.fmt_num(s.soute), MAUtils.fmt_num(cours.get("A", 1.0)), MAUtils.fmt_num(cours.get("B", 1.0)), MAUtils.fmt_num(cours.get("C", 1.0)), "" if docked else " (vente indisponible : scannez le corps pour détecter un astroport)"]
	hold_label.text = hb
	for ch in hold_list.get_children():
		hold_list.remove_child(ch)
		ch.queue_free()
	var keys := s.cargaison.keys()
	keys.sort()
	for k in keys:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var pv := prix_vente_unit(k)
		var it0: Variant = ShopTables.find_item(str(k))
		var c0: float = float(cours.get(str(it0.get("dispo", "C")) if it0 != null else "C", 1.0))
		var lbl := Label.new()
		lbl.size_flags_horizontal = SIZE_EXPAND_FILL
		lbl.text = "%s ×%d — achat de base %s € · %s UC" % [k, s.cargaison[k], MAUtils.fmt_int(prix_base(k)), MAUtils.fmt_num(ShopTables.place_de(k))]
		lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(lbl)
		var pl := Label.new()
		pl.text = ("vente : invendable (cours ×0)" if pv <= 0 else "vente : %s €/u" % MAUtils.fmt_int(pv))
		pl.add_theme_font_size_override("font_size", 12)
		pl.add_theme_color_override("font_color", ShopPanel._couleur_prix(c0))
		row.add_child(pl)
		var btn := Button.new()
		btn.text = "Vendre"
		btn.disabled = not docked or pv <= 0
		btn.tooltip_text = "Vendre 1 unité (prix de vente = achat ÷ 1,5)" if (docked and pv > 0) else ("Invendable ici (cours ×0)" if docked else "Vente indisponible : scannez le corps pour détecter un astroport")
		btn.pressed.connect(_on_sell.bind(k))
		row.add_child(btn)
		hold_list.add_child(row)

func _on_sell(nom: String) -> void:
	sell_requested.emit(nom)

func set_message(t: String) -> void:
	hold_msg.text = t
