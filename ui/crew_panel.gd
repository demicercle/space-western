class_name CrewPanel
extends VBoxContainer

var selector: HBoxContainer
var card_scroll: ScrollContainer
var card_holder: VBoxContainer
var characters: Array = []
var selected: Character = null
var captain: Character = null

func _ready() -> void:
	add_theme_constant_override("separation", 8)
	var head := Label.new()
	head.text = "Équipage — sélectionnez un membre pour afficher sa fiche :"
	head.add_theme_font_size_override("font_size", 13)
	head.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	add_child(head)
	selector = HBoxContainer.new()
	selector.add_theme_constant_override("separation", 6)
	add_child(selector)
	card_scroll = ScrollContainer.new()
	card_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(card_scroll)
	card_holder = VBoxContainer.new()
	card_holder.size_flags_horizontal = SIZE_EXPAND_FILL
	card_scroll.add_child(card_holder)

static func make_card(c: Character, is_captain := false) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(340, 0)
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
	nl.text = ("♛ " if is_captain else "") + c.nom
	nl.add_theme_font_size_override("font_size", 14)
	nl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if is_captain else Color(1.0, 0.9, 0.5))
	vb2.add_child(nl)
	var pl := Label.new()
	pl.text = "%s · %s · %s" % [c.profession, c.puissance, c.role]
	pl.add_theme_font_size_override("font_size", 11)
	pl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	vb2.add_child(pl)
	var post := Label.new()
	post.text = "Poste : %s%s" % ["au hamac (sans poste)" if c.post_index < 0 else Main.post_name_static(c.post_index), " · CAPITAINE" if is_captain else ""]
	post.add_theme_font_size_override("font_size", 11)
	post.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	vb2.add_child(post)
	var pr := Label.new()
	pr.text = "Salaire : %d €/jour · Recrutement : %d €" % [c.prix_journalier, c.prix_recrutement]
	pr.add_theme_font_size_override("font_size", 11)
	pr.add_theme_color_override("font_color", Color(0.95, 0.8, 0.4))
	vb2.add_child(pr)
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

func set_characters(chars: Array, cap: Character = null) -> void:
	characters = chars
	captain = cap
	for ch in selector.get_children():
		selector.remove_child(ch)
		ch.queue_free()
	for c in characters:
		var b := Button.new()
		b.text = ("♛ " if c == captain else "") + c.nom
		b.toggle_mode = true
		b.button_pressed = c == selected
		b.pressed.connect(_on_select.bind(c))
		selector.add_child(b)
	if selected != null and not characters.has(selected):
		selected = null
	if selected == null and characters.size() > 0:
		selected = characters[0]
	_refresh_card()

func select_character(c: Character) -> void:
	if not characters.has(c):
		return
	selected = c
	for ch in selector.get_children():
		if ch is Button:
			var b := ch as Button
			b.button_pressed = b.text.ends_with(c.nom)
	_refresh_card()

func _on_select(c: Character) -> void:
	selected = c
	for ch in selector.get_children():
		if ch is Button:
			(ch as Button).button_pressed = (ch as Button).text.ends_with(c.nom)
	_refresh_card()

func _refresh_card() -> void:
	for ch in card_holder.get_children():
		card_holder.remove_child(ch)
		ch.queue_free()
	if selected == null:
		var l := Label.new()
		l.text = "Aucun membre d'équipage. Recrutez depuis l'onglet « Recruter »."
		l.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
		card_holder.add_child(l)
		return
	card_holder.add_child(make_card(selected, selected == captain))

