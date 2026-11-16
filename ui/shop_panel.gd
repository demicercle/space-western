class_name ShopPanel
extends VBoxContainer

signal buy_requested(item: Dictionary)

const TAB_TITLES := ["Marchandises", "Technologie courante", "Technologie militaire", "Technologie médicale", "La belle vie"]

var title_label: Label
var info_label: Label
var msg_label: Label
var tabs: TabContainer
var grids: Array = []
var items: Array = []
var credits := 0
var soute_used := 0.0
var soute_max := 25.0
var docked := false
var cours: Dictionary = {"A": 1.0, "B": 1.0, "C": 1.0}

static var _re_us := RegEx.create_from_string("\\bUS\\b")
static var _re_spaces := RegEx.create_from_string(" {2,}")
static var _re_empty_par := RegEx.create_from_string("\\(\\s*\\)")

static func _desc_txt(it: Dictionary) -> String:
	var d := str(it.get("note", ""))
	d = _re_us.sub(d, "", true)
	d = _re_spaces.sub(d, " ", true)
	d = _re_empty_par.sub(d, "", true)
	d = d.strip_edges()
	var meta := "Dispo %s · %s UC" % [str(it.get("dispo", "?")), MAUtils.fmt_num(float(it.get("place", 0.0)))]
	if d == "":
		return meta
	return d + " — " + meta

static func _tab_of(cat: String) -> int:
	if cat == "Technologie militaire":
		return 2
	if cat == "Technologie médicale":
		return 3
	if cat == "Technologie courante" or cat == "Station-relais":
		return 1
	if cat == "La belle vie":
		return 4
	return 0

func _ready() -> void:
	add_theme_constant_override("separation", 8)
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 15)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	add_child(title_label)
	info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_size_override("font_size", 12)
	info_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	add_child(info_label)
	msg_label = Label.new()
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_label.add_theme_font_size_override("font_size", 12)
	msg_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	add_child(msg_label)
	tabs = TabContainer.new()
	tabs.size_flags_horizontal = SIZE_EXPAND_FILL
	tabs.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(tabs)
	for t in TAB_TITLES:
		var tab := Control.new()
		tab.name = t
		tabs.add_child(tab)
		var sc := ScrollContainer.new()
		sc.set_anchors_preset(Control.PRESET_FULL_RECT)
		tab.add_child(sc)
		var grid := GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 14)
		grid.add_theme_constant_override("v_separation", 5)
		grid.size_flags_horizontal = SIZE_EXPAND_FILL
		sc.add_child(grid)
		grids.append(grid)

func _header_cell(txt: String) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	return l

func set_catalog(p_items: Array, titre: String, p_credits: int, p_soute_used: float, p_soute_max: float, p_docked: bool, cours_txt: String, p_cours: Dictionary) -> void:
	items = p_items
	credits = p_credits
	soute_used = p_soute_used
	soute_max = p_soute_max
	docked = p_docked
	cours = p_cours
	title_label.text = titre
	info_label.text = "Crédits : %s € · Soute : %s / %s UC · Cours : %s%s" % [MAUtils.fmt_int(credits), MAUtils.fmt_num(soute_used), MAUtils.fmt_num(soute_max), cours_txt, "" if docked else " · (commerce indisponible hors planète/station-relais)"]
	for grid in grids:
		for ch in grid.get_children():
			grid.remove_child(ch)
			ch.queue_free()
		grid.add_child(_header_cell("Objet"))
		grid.add_child(_header_cell("Description"))
		grid.add_child(_header_cell("Prix"))
	for it in items:
		var grid: GridContainer = grids[_tab_of(str(it.get("cat", "")))]
		var nom_l := Label.new()
		nom_l.text = str(it["nom"])
		nom_l.custom_minimum_size = Vector2(230, 0)
		nom_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nom_l.add_theme_font_size_override("font_size", 12)
		grid.add_child(nom_l)
		var desc_l := Label.new()
		desc_l.text = _desc_txt(it)
		desc_l.size_flags_horizontal = SIZE_EXPAND_FILL
		desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_l.add_theme_font_size_override("font_size", 11)
		desc_l.add_theme_color_override("font_color", Color(0.75, 0.78, 0.85))
		grid.add_child(desc_l)
		var cell := HBoxContainer.new()
		cell.add_theme_constant_override("separation", 8)
		cell.custom_minimum_size = Vector2(190, 0)
		var prix := ShopTables.prix_achat(it, cours)
		var prix_l := Label.new()
		prix_l.text = ("—" if prix < 0 else "%s €" % MAUtils.fmt_int(prix))
		prix_l.size_flags_horizontal = SIZE_EXPAND_FILL
		prix_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		prix_l.add_theme_font_size_override("font_size", 12)
		cell.add_child(prix_l)
		var btn := Button.new()
		btn.text = "Acheter"
		var trop_cher := prix >= 0 and credits < prix
		var plus_de_place := soute_used + float(it["place"]) > soute_max + 0.0001
		btn.disabled = not docked or prix < 0 or trop_cher or plus_de_place
		if prix < 0:
			btn.tooltip_text = "Achat impossible ici (cours ×0 pour la catégorie %s)" % str(it.get("dispo", "?"))
		elif trop_cher:
			btn.tooltip_text = "Crédits insuffisants"
		elif plus_de_place:
			btn.tooltip_text = "Plus de place en soute"
		btn.pressed.connect(_on_buy.bind(it))
		cell.add_child(btn)
		grid.add_child(cell)

func _on_buy(it: Dictionary) -> void:
	buy_requested.emit(it)

func set_message(t: String) -> void:
	msg_label.text = t
