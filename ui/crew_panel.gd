class_name CrewPanel
extends ScrollContainer

var cards: HBoxContainer

func _ready() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	cards = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 10)
	cards.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(cards)

func _make_card(c: Character) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(300, 0)
	var vb := VBoxContainer.new()
	card.add_child(vb)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)
	vb.add_child(hb)
	var port := Portrait.new()
	port.custom_minimum_size = Vector2(64, 64)
	port.seed = c.nom.hash()
	hb.add_child(port)
	var vb2 := VBoxContainer.new()
	vb2.size_flags_horizontal = SIZE_EXPAND_FILL
	hb.add_child(vb2)
	var nl := Label.new()
	nl.text = c.nom
	nl.add_theme_font_size_override("font_size", 14)
	nl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	vb2.add_child(nl)
	var pl := Label.new()
	pl.text = "%s · %s · %s" % [c.profession, c.puissance, c.role]
	pl.add_theme_font_size_override("font_size", 11)
	pl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	vb2.add_child(pl)
	var post := Label.new()
	post.text = "Poste : %s" % ("au hamac (sans poste)" if c.post_index < 0 else Main.post_name_static(c.post_index))
	post.add_theme_font_size_override("font_size", 11)
	post.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	vb2.add_child(post)
	var sep := HSeparator.new()
	vb.add_child(sep)
	var cl := Label.new()
	cl.text = "Caractéristiques"
	cl.add_theme_font_size_override("font_size", 12)
	vb.add_child(cl)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	vb.add_child(grid)
	for car in NPCTables.CARACS:
		var l := Label.new()
		l.text = "%s : %d" % [car, c.caracs[car]]
		l.add_theme_font_size_override("font_size", 11)
		grid.add_child(l)
	var sep2 := HSeparator.new()
	vb.add_child(sep2)
	var cml := Label.new()
	cml.text = "Compétences"
	cml.add_theme_font_size_override("font_size", 12)
	vb.add_child(cml)
	for entry in c.comp:
		var l := Label.new()
		l.text = "  %s +%d (%s)" % [entry[0], entry[1], c.domaine_de(entry[0])]
		l.add_theme_font_size_override("font_size", 11)
		vb.add_child(l)
	var sep3 := HSeparator.new()
	vb.add_child(sep3)
	var sl := Label.new()
	sl.text = "Santé : %d PV/niveau · %d/%d PV · %s\nNiveaux : %s\nPanache %d · Gloire %d" % [c.pv_par_niveau, c.pv, c.pv_max, c.sante_txt(), " · ".join(c.niveaux_sante), c.panache, c.gloire]
	sl.add_theme_font_size_override("font_size", 11)
	vb.add_child(sl)
	if c.defauts.size() > 0 or c.qualites.size() > 0:
		var tl := Label.new()
		var tlines: Array = []
		for t in c.defauts:
			tlines.append("Défaut — %s (%d) : %s" % [t[0], t[1], t[2]])
		for q in c.qualites:
			tlines.append("Qualité — %s (+%d) : %s" % [q[0], q[1], q[2]])
		tl.text = "\n".join(tlines)
		tl.add_theme_font_size_override("font_size", 10)
		vb.add_child(tl)
	if c.motivation != "":
		var ml := Label.new()
		ml.text = "Motivation : " + c.motivation
		ml.add_theme_font_size_override("font_size", 10)
		ml.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 0.8))
		vb.add_child(ml)
	return card

func set_characters(characters: Array) -> void:
	for ch in cards.get_children():
		cards.remove_child(ch)
		ch.queue_free()
	for c in characters:
		cards.add_child(_make_card(c))
