class_name SystemMap
extends GridContainer

signal travel_requested(body: Dictionary)

class MapCanvas extends Control:
	var sys: StarSystem
	var selected_body: Variant = null
	var ship_orbite := -1.0
	var ship_angle := 0.0
	var ship_body: Variant = null
	signal body_hit(body: Dictionary)
	signal body_deselected

	func _center() -> Vector2:
		return size * 0.5

	func _scale() -> float:
		return (min(size.x, size.y) * 0.5 - 30.0) / 285.0

	func _r_of(o: float) -> float:
		return (50.0 + 235.0 * sqrt(o / float(sys.limite))) * _scale()

	func body_pos(body: Dictionary) -> Vector2:
		var i := sys.corps.find(body)
		var ang := float(i) * 2.399 + float(body["orbite"]) * 0.7
		return _center() + Vector2(cos(ang), sin(ang)) * _r_of(float(body["orbite"]))

	func ship_pos() -> Vector2:
		return _center() + Vector2(cos(ship_angle), sin(ship_angle)) * _r_of(ship_orbite)

	func _gui_input(event: InputEvent) -> void:
		if sys == null:
			return
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			for body in sys.corps:
				if body_pos(body).distance_to(event.position) < 13.0:
					body_hit.emit(body)
					get_viewport().set_input_as_handled()
					return
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			body_deselected.emit()
			get_viewport().set_input_as_handled()

	func _draw() -> void:
		if sys == null or size.x <= 0.0 or size.y <= 0.0:
			return
		var c := _center()
		var etoile_col := Color(1.0, 0.85, 0.4)
		match sys.etoile:
			"naine rouge": etoile_col = Color(1.0, 0.45, 0.3)
			"géante rouge": etoile_col = Color(1.0, 0.35, 0.25)
			"étoile binaire": etoile_col = Color(0.9, 0.95, 1.0)
			"étoile variable": etoile_col = Color(1.0, 0.7, 0.9)
		draw_circle(c, _r_of(0.0) * 0.35 + 8.0, Color(etoile_col, 0.25))
		draw_circle(c, _r_of(0.0) * 0.35 + 4.0, etoile_col)
		draw_string(ThemeDB.fallback_font, c + Vector2(14, 4), "%s (%s)" % [sys.nom, sys.etoile], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 0.95, 0.8))
		for body in sys.corps:
			draw_arc(c, _r_of(float(body["orbite"])), 0.0, TAU, 64, Color(1, 1, 1, 0.12), 1.0)
		if sys.ceinture != null:
			draw_arc(c, _r_of(float(sys.ceinture["orbite"])), 0.0, TAU, 64, Color(0.8, 0.75, 0.6, 0.5), 2.0)
		var i := 0
		for body in sys.corps:
			var p := body_pos(body)
			var col := MAUtils.hex_color(SystemTables.COULEURS.get(body.get("couleur", ""), "#a8d8ea"))
			var br := 4.0
			match body["type"]:
				"géante gazeuse": br = 9.0
				"station": br = 5.0
				"planétoïde": br = 3.0
			if body["type"] == "station":
				draw_rect(Rect2(p - Vector2(br, br), Vector2(br * 2, br * 2)), col)
			else:
				draw_circle(p, br, col)
			draw_circle(p, br, Color(0, 0, 0, 0.4), false, 1.0)
			draw_string(ThemeDB.fallback_font, p + Vector2(br + 3, -br - 2), "%s (orbite %s US)" % [body.get("nom", "?"), MAUtils.fmt_num(float(body["orbite"]))], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.9, 0.92, 0.98, 0.95))
			if body == selected_body:
				draw_arc(p, 13.0, 0.0, TAU, 32, Color(1.0, 0.85, 0.3, 0.95), 2.0)
			i += 1
		if ship_orbite >= 0.0:
			if ship_body != null and sys.corps.has(ship_body):
				draw_arc(body_pos(ship_body), 15.0, 0.0, TAU, 32, Color(1, 1, 1, 0.8), 1.5)
			var sp := ship_pos()
			var col := Color(1.0, 0.25, 0.2)
			draw_line(sp + Vector2(-8, -8), sp + Vector2(8, 8), Color(0, 0, 0, 0.85), 3.5)
			draw_line(sp + Vector2(-8, 8), sp + Vector2(8, -8), Color(0, 0, 0, 0.85), 3.5)
			draw_line(sp + Vector2(-8, -8), sp + Vector2(8, 8), col, 1.6)
			draw_line(sp + Vector2(-8, 8), sp + Vector2(8, -8), col, 1.6)
			draw_string(ThemeDB.fallback_font, sp + Vector2(10, -10), "Vaisseau (%s US)" % MAUtils.fmt_num(ship_orbite), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.45, 0.4))

var canvas: MapCanvas
var sys_details: RichTextLabel
var body_details: RichTextLabel
var travel_button: Button
var sys_msg: Label
var journal_label: RichTextLabel
var sys: StarSystem
var selected_body: Variant = null
var selected_dist: Variant = null
var ship_orbite := -1.0
var ship_angle := 0.0
var ship_body: Variant = null
var is_current_system := true

func _ready() -> void:
	columns = 2
	add_theme_constant_override("h_separation", 10)
	add_theme_constant_override("v_separation", 10)
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	var sys_scroll := ScrollContainer.new()
	sys_scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	sys_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	sys_scroll.custom_minimum_size = Vector2(340, 200)
	add_child(sys_scroll)
	sys_details = RichTextLabel.new()
	sys_details.bbcode_enabled = true
	sys_details.size_flags_horizontal = SIZE_EXPAND_FILL
	sys_details.size_flags_vertical = SIZE_EXPAND_FILL
	sys_details.scroll_active = true
	sys_scroll.add_child(sys_details)
	var right_top := VBoxContainer.new()
	right_top.size_flags_horizontal = SIZE_EXPAND_FILL
	right_top.size_flags_vertical = SIZE_EXPAND_FILL
	right_top.add_theme_constant_override("separation", 6)
	right_top.custom_minimum_size = Vector2(340, 200)
	add_child(right_top)
	travel_button = Button.new()
	travel_button.text = "Voyager vers ce corps"
	travel_button.disabled = true
	travel_button.pressed.connect(_on_travel_pressed)
	right_top.add_child(travel_button)
	sys_msg = Label.new()
	sys_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sys_msg.add_theme_font_size_override("font_size", 11)
	sys_msg.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	right_top.add_child(sys_msg)
	var body_scroll := ScrollContainer.new()
	body_scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	body_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	right_top.add_child(body_scroll)
	body_details = RichTextLabel.new()
	body_details.bbcode_enabled = true
	body_details.size_flags_horizontal = SIZE_EXPAND_FILL
	body_details.size_flags_vertical = SIZE_EXPAND_FILL
	body_details.scroll_active = true
	body_scroll.add_child(body_details)
	canvas = MapCanvas.new()
	canvas.size_flags_horizontal = SIZE_EXPAND_FILL
	canvas.size_flags_vertical = SIZE_EXPAND_FILL
	canvas.custom_minimum_size = Vector2(380, 300)
	canvas.mouse_filter = MOUSE_FILTER_STOP
	canvas.body_hit.connect(_on_body_hit)
	canvas.body_deselected.connect(_on_body_deselected)
	add_child(canvas)
	var right_bot := VBoxContainer.new()
	right_bot.size_flags_horizontal = SIZE_EXPAND_FILL
	right_bot.size_flags_vertical = SIZE_EXPAND_FILL
	right_bot.add_theme_constant_override("separation", 4)
	right_bot.custom_minimum_size = Vector2(340, 160)
	add_child(right_bot)
	var jhead := Label.new()
	jhead.text = "Journal de bord (voyages dans le système) :"
	jhead.add_theme_font_size_override("font_size", 12)
	jhead.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	right_bot.add_child(jhead)
	var jscroll := ScrollContainer.new()
	jscroll.size_flags_horizontal = SIZE_EXPAND_FILL
	jscroll.size_flags_vertical = SIZE_EXPAND_FILL
	right_bot.add_child(jscroll)
	journal_label = RichTextLabel.new()
	journal_label.bbcode_enabled = true
	journal_label.size_flags_horizontal = SIZE_EXPAND_FILL
	journal_label.scroll_active = true
	jscroll.add_child(journal_label)

func _on_body_hit(body: Dictionary) -> void:
	select_body(body)

func _on_body_deselected() -> void:
	select_body(null)

func select_body(body: Variant) -> void:
	selected_body = body
	canvas.selected_body = body
	canvas.queue_redraw()
	selected_dist = null
	if body != null:
		travel_button.disabled = ship_body == body
		travel_button.text = "Voyager vers %s" % str(body.get("nom", "?"))
		if ship_body == body:
			travel_button.tooltip_text = "Le vaisseau est déjà sur ce corps"
		elif not is_current_system:
			travel_button.tooltip_text = "Le vaisseau n'est pas dans ce système : l'itinéraire galactique sera tracé"
		else:
			travel_button.tooltip_text = ""
		if sys != null and ship_orbite >= 0.0:
			selected_dist = StarSystem.distance_inter(ship_orbite, float(body["orbite"]))
	else:
		travel_button.disabled = true
		travel_button.text = "Voyager vers ce corps"
		travel_button.tooltip_text = ""
	_render_details()

func _on_travel_pressed() -> void:
	if selected_body != null:
		travel_requested.emit(selected_body)

func set_system(s: StarSystem) -> void:
	sys = s
	canvas.sys = s
	if s == null or (selected_body != null and not s.corps.has(selected_body)):
		select_body(null)
	canvas.queue_redraw()
	_render_details()

func set_ship_pos(o: float, angle: float, body: Variant) -> void:
	ship_orbite = o
	ship_angle = angle
	ship_body = body
	canvas.ship_orbite = o
	canvas.ship_angle = angle
	canvas.ship_body = body
	canvas.queue_redraw()
	_render_details()

static func _table_bb(rows: Array) -> String:
	var bb := "[table=2]"
	for r in rows:
		bb += "[cell][b]%s[/b][/cell][cell]%s[/cell]" % [str(r[0]), str(r[1])]
	bb += "[/table]\n"
	return bb

func _body_bb(body: Dictionary) -> String:
	var rows: Array = [
		["Système planétaire", "%s (%s-%d)" % [sys.nom, sys.quad_x, sys.quad_y]],
		["Orbite", "%s US" % MAUtils.fmt_num(float(body["orbite"]))],
		["Distance de saut", "%s US" % MAUtils.fmt_num(float(body["distance_saut"]))],
		["Classe", str(body.get("classe", body["type"]))],
	]
	var keys := [
		["systeme_orbital", "Système orbital"], ["diametre", "Diamètre"], ["atmosphere", "Atmosphère"],
		["environnement", "Environnement"], ["temperature", "Température"], ["gravite", "Gravité"],
		["eau", "Eau"], ["habitee", "Habitée"], ["population", "Population"], ["densite", "Densité"],
		["categorie", "Catégorie"], ["niveau_techno", "Niveau technologique"], ["gouvernement", "Gouvernement"],
		["commerce", "Commerce"], ["cours", "Cours des marchandises"], ["illegal", "Marchandises illégales"],
		["astroport", "Astroport"], ["securite", "Sécurité"],
	]
	for kv in keys:
		if body.has(kv[0]) and str(body[kv[0]]) != "" and str(body[kv[0]]) != "false":
			rows.append([kv[1], str(body[kv[0]])])
	var bb := "\n[b][color=cyan]▸ %s[/color][/b]\n" % str(body.get("nom", "?"))
	bb += _table_bb(rows)
	if body.get("description", "") != "":
		bb += "[i]%s[/i]\n" % str(body["description"])
	if ship_orbite >= 0.0:
		var di: Variant = selected_dist
		if di == null or body != selected_body:
			di = StarSystem.distance_inter(ship_orbite, float(body["orbite"]))
		bb += "Distance depuis le vaisseau : %s US (tableau des distances : 1d6 = %d%s)\n" % [MAUtils.fmt_num(di["dist"]), int(di["de"]), ", autre côté du soleil" if di["autre_cote"] else ""]
	return bb

func _render_details() -> void:
	if sys == null:
		sys_details.text = ""
		body_details.text = ""
		return
	var bb := "[b][color=gold]%s[/color][/b]\n" % sys.nom
	if not is_current_system:
		bb += "[i]Système affiché : case sélectionnée sur la carte galactique — le vaisseau n'est pas dans ce système (informations en lecture seule).[/i]\n"
	var corps_noms := []
	for body in sys.corps:
		corps_noms.append(str(body.get("nom", "?")))
	var rows: Array = [
		["Coordonnées", "%s-%d (%s)" % [sys.quad_x, sys.quad_y, GalaxyData.coord_label(GalaxyData.col_of(sys.quad_x), sys.quad_y) if GalaxyData.col_of(sys.quad_x) > 0 else "%s-%d" % [sys.quad_x, sys.quad_y]]],
		["Étoile", "%s, diamètre %s" % [sys.etoile, sys.diam_etoile]],
		["Limite de saut", "%d US" % sys.limite],
		["Nationalité", sys.nation],
		["Route", sys.route],
		["Gouvernement", sys.gouvernement],
		["Patrouilles", "%s%s" % [sys.patrouille, (" (coût %s)" % sys.cout_pat) if sys.cout_pat != "" else ""]],
		["Trafic", "%s — %s" % [sys.trafic, sys.trafic_desc]],
		["Activité solaire", "%s (%s près de l'étoile)" % [sys.act_solaire, sys.act_solaire_proche]],
		["Corps célestes", ", ".join(corps_noms)],
	]
	bb += _table_bb(rows)
	sys_details.text = bb
	var bb2 := ""
	if is_current_system:
		sys_details.text += "\n[b]Position du vaisseau[/b] : "
		if ship_body != null:
			sys_details.text += "%s (orbite %s US)\n" % [str(ship_body.get("nom", "?")), MAUtils.fmt_num(float(ship_body["orbite"]))]
		else:
			sys_details.text += "limite de saut du système (%d US)\n" % sys.limite
	if selected_body != null and sys.corps.has(selected_body):
		bb2 += _body_bb(selected_body)
	else:
		bb2 += "[i]Cliquez sur un corps céleste de la carte (en bas à gauche) pour afficher sa description.[/i]\n"
		for body in sys.corps:
			bb2 += "▸ %s — orbite %s US\n" % [str(body.get("nom", "?")), MAUtils.fmt_num(float(body["orbite"]))]
	if sys.ceinture != null:
		bb2 += "\n▸ %s, orbite %s US\n" % [str(sys.ceinture["nom"]), MAUtils.fmt_num(float(sys.ceinture["orbite"]))]
	body_details.text = bb2

func set_message(t: String) -> void:
	sys_msg.text = t

func set_journal(t: String) -> void:
	journal_label.text = t
