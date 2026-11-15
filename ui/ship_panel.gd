class_name ShipPanel
extends ScrollContainer

var sheet_label: RichTextLabel
var hold_label: RichTextLabel

func _ready() -> void:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12)
	hb.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(hb)
	var p1 := PanelContainer.new()
	p1.size_flags_horizontal = SIZE_EXPAND_FILL
	p1.custom_minimum_size = Vector2(430, 0)
	hb.add_child(p1)
	var vb1 := VBoxContainer.new()
	p1.add_child(vb1)
	var t1 := Label.new()
	t1.text = "Fiche du vaisseau"
	t1.add_theme_font_size_override("font_size", 15)
	t1.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	vb1.add_child(t1)
	sheet_label = RichTextLabel.new()
	sheet_label.bbcode_enabled = true
	sheet_label.size_flags_horizontal = SIZE_EXPAND_FILL
	sheet_label.size_flags_vertical = SIZE_EXPAND_FILL
	vb1.add_child(sheet_label)
	var p2 := PanelContainer.new()
	p2.size_flags_horizontal = SIZE_EXPAND_FILL
	p2.custom_minimum_size = Vector2(330, 0)
	hb.add_child(p2)
	var vb2 := VBoxContainer.new()
	p2.add_child(vb2)
	var t2 := Label.new()
	t2.text = "Soute et réserves"
	t2.add_theme_font_size_override("font_size", 15)
	t2.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	vb2.add_child(t2)
	hold_label = RichTextLabel.new()
	hold_label.bbcode_enabled = true
	hold_label.size_flags_horizontal = SIZE_EXPAND_FILL
	hold_label.size_flags_vertical = SIZE_EXPAND_FILL
	vb2.add_child(hold_label)

func set_ship(s: Ship) -> void:
	if s == null:
		sheet_label.text = ""
		hold_label.text = ""
		return
	var bb := "[b][color=gold]%s[/color][/b] — %s\n" % [s.nom, s.modele]
	bb += "Classe : %s\n" % s.classe
	bb += "Manœuvrabilité : %s · Vitesse tactique : %d K/t\n" % [s.maneuvrabilite, s.vitesse_tactique_K]
	bb += "Vitesse de croisière : %s US/h (%s US/j)\n" % [MAUtils.fmt_num(s.vitesse_croisiere_us_j / 24.0), MAUtils.fmt_num(s.vitesse_croisiere_us_j)]
	bb += "Vitesse hyperspatiale : [b]%d PC/j[/b]\n" % s.vitesse_hyper_pc_j
	bb += "Autonomie : %s PC · Réserve de Radix : [b]%s PC[/b]\n" % [MAUtils.fmt_int(s.autonomie_pc), MAUtils.fmt_int(s.radix_pc)]
	bb += "Blindage : %d · Coque : %d PV/état\n" % [s.blindage, s.coque_pv]
	bb += "État : [color=%s]%s[/color] (%d/%d PV)%s\n" % ["#ff5544" if s.detruit else "#7bed9f", Ship.etat_txt(s.etat), s.structure_pv, s.coque_pv, " — DÉTRUIT" if s.detruit else ""]
	bb += "Senseurs : %s\n" % s.senseurs
	var eq: Dictionary = s.equipage_standard
	bb += "Équipage standard : %d P + %d V + %d C + %d Me + %d Ma (%d)\n" % [eq.get("P", 0), eq.get("V", 0), eq.get("C", 0), eq.get("Me", 0), eq.get("Ma", 0), eq.get("total", 0)]
	bb += "Passagers : %d cabine(s) + %d dortoir(s) (max %d)\n" % [s.passagers_cabines, s.passagers_dortoirs, s.passagers_max]
	bb += "Soute : %d unités cargo · Prix : %s ¤ · Origine : %s\n" % [s.soute, MAUtils.fmt_int(s.prix), s.origine]
	bb += "\n[b]Armement[/b]\n"
	for a in s.armement:
		bb += "  %s — %s (%s)\n" % [a["pos"], a["nom"], a["stats"]]
	bb += "\n[b]Systèmes secondaires[/b] : " + (", ".join(s.systemes_secondaires) if s.systemes_secondaires.size() > 0 else "aucun") + "\n"
	sheet_label.text = bb
	var hb := "[b]Réserve de Radix[/b] : %s PC (plein : %s PC à 1000 PC = tonnage × 1,5 R)\n" % [MAUtils.fmt_int(s.radix_pc), MAUtils.fmt_int(s.autonomie_pc)]
	hb += "[b]Rations[/b] : %d (1 par personne et par jour de voyage)\n\n" % s.rations
	hb += "[b]Contenu de la soute[/b] (%d unités) :\n" % s.soute
	var keys := s.cargaison.keys()
	keys.sort()
	for k in keys:
		hb += "  %s ×%d\n" % [k, s.cargaison[k]]
	hold_label.text = hb
