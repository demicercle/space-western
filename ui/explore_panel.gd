class_name ExplorePanel
extends VBoxContainer

signal recup_requested(site: String, trouvaille: String, recharge: String)
signal remettre_requested(produit: String)

class MapCanvas extends Control:
	var panel: ExplorePanel
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			panel._on_canvas_click(event.position)
			get_viewport().set_input_as_handled()
	func _draw() -> void:
		panel._draw_map(self)

var title_label: Label
var msg_label: Label
var canvas: MapCanvas
var legend_label: Label
var info_label: Label
var site_opt: OptionButton
var trouv_opt: OptionButton
var recharge_opt: OptionButton
var btn_recup: Button
var remise_opt: OptionButton
var btn_remettre: Button
var recup_label: Label
var map := {}
var selected := -1
var centres: Array = []
var s := 32.0
var zoom := 1.0
var offset := Vector2.ZERO

func _ready() -> void:
	add_theme_constant_override("separation", 6)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 15)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	add_child(title_label)
	msg_label = Label.new()
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_label.add_theme_font_size_override("font_size", 12)
	msg_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	add_child(msg_label)
	canvas = MapCanvas.new()
	canvas.panel = self
	canvas.size_flags_horizontal = SIZE_EXPAND_FILL
	canvas.size_flags_vertical = SIZE_EXPAND_FILL
	canvas.custom_minimum_size = Vector2(300, 300)
	canvas.mouse_filter = MOUSE_FILTER_STOP
	add_child(canvas)
	legend_label = Label.new()
	legend_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend_label.add_theme_font_size_override("font_size", 11)
	legend_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	add_child(legend_label)
	info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_size_override("font_size", 12)
	info_label.add_theme_color_override("font_color", Color(0.65, 0.9, 0.75))
	add_child(info_label)
	var sep := HSeparator.new()
	add_child(sep)
	var sh := Label.new()
	sh.text = "Récupération (La Guerre et la Désolation, p. 14-17) — sites de récupération du corps"
	sh.add_theme_font_size_override("font_size", 13)
	sh.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	add_child(sh)
	var hb1 := HBoxContainer.new()
	hb1.add_theme_constant_override("separation", 8)
	add_child(hb1)
	site_opt = OptionButton.new()
	site_opt.add_item("Aucun site de récupération sur ce corps")
	site_opt.size_flags_horizontal = SIZE_EXPAND_FILL
	hb1.add_child(site_opt)
	trouv_opt = OptionButton.new()
	for t in SalvageTables.TROUVAILLES:
		trouv_opt.add_item(t)
	trouv_opt.size_flags_horizontal = SIZE_EXPAND_FILL
	hb1.add_child(trouv_opt)
	recharge_opt = OptionButton.new()
	for r in SalvageTables.RECHARGES_LBL:
		recharge_opt.add_item(r)
	hb1.add_child(recharge_opt)
	btn_recup = Button.new()
	btn_recup.text = "Récoup ! (1 jour)"
	btn_recup.tooltip_text = "Action « Récoup ! » : test de Recherche, difficulté 1 + modificateur du site/trouvaille"
	btn_recup.pressed.connect(_on_recup_pressed)
	hb1.add_child(btn_recup)
	var hb2 := HBoxContainer.new()
	hb2.add_theme_constant_override("separation", 8)
	add_child(hb2)
	remise_opt = OptionButton.new()
	for p in SalvageTables.PRODUITS.keys():
		remise_opt.add_item(p)
	remise_opt.size_flags_horizontal = SIZE_EXPAND_FILL
	hb2.add_child(remise_opt)
	btn_remettre = Button.new()
	btn_remettre.text = "Remettre à neuf (1 jour)"
	btn_remettre.tooltip_text = "Action « Remettre à neuf » : test d'Ingénierie (vaisseau/véhicule) ou de Technologie — les composants ne sont consommés qu'en cas de succès"
	btn_remettre.pressed.connect(_on_remettre_pressed)
	hb2.add_child(btn_remettre)
	recup_label = Label.new()
	recup_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recup_label.add_theme_font_size_override("font_size", 11)
	recup_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	add_child(recup_label)

func _on_recup_pressed() -> void:
	var site: String = site_opt.get_item_text(site_opt.selected).replace(" (E)", "")
	var recharge: String = SalvageTables.RECHARGES[recharge_opt.selected] if recharge_opt.selected >= 0 else "blaster"
	recup_requested.emit(site, trouv_opt.get_item_text(trouv_opt.selected), recharge)

func _on_remettre_pressed() -> void:
	remettre_requested.emit(remise_opt.get_item_text(remise_opt.selected))

static func _recup_txt(recup: Dictionary) -> String:
	var rec: Dictionary = recup.get("recharges", {})
	var parts: Array = []
	parts.append("élec %d kg" % int(recup.get("comp_elec", 0)))
	parts.append("indus %d kg" % int(recup.get("comp_indus", 0)))
	parts.append("spatiaux %d kg" % int(recup.get("comp_spatial", 0)))
	parts.append("minerai %d kg" % int(recup.get("minerai", 0)))
	parts.append("épave vaisseau ×%d (%d syst. ok)" % [int(recup.get("epave_vaisseau", 0)), int(recup.get("epave_sys", 0))])
	parts.append("épave véhicule ×%d" % int(recup.get("epave_vehicule", 0)))
	var rparts: Array = []
	for k in rec.keys():
		rparts.append("%s ×%d" % [k, int(rec[k])])
	if not rparts.is_empty():
		parts.append("recharges : " + ", ".join(rparts))
	return "Stock de récupération — composants : " + " · ".join(parts)

func refresh_salvage(sites: Array, recup: Dictionary, has_scaphandre: bool) -> void:
	site_opt.clear()
	if sites.is_empty():
		site_opt.add_item("Aucun site de récupération sur ce corps")
	else:
		for s in sites:
			site_opt.add_item(s + (" (E)" if SalvageTables.est_site_espace(s) else ""))
	btn_recup.disabled = sites.is_empty()
	recup_label.text = _recup_txt(recup)

func set_body(body: Variant, graine: int, recup := {}, has_scaphandre := false) -> void:
	selected = -1
	if body == null:
		map = {}
		title_label.text = "Explorer"
		msg_label.text = "Explorer indisponible : le vaisseau doit être en orbite autour d'un corps stellaire scanné avec succès (bouton « Scanner ce corps (1 h) » dans la carte de système)."
		legend_label.text = ""
		info_label.text = "Cliquez sur une case hexagonale pour afficher ses caractéristiques."
		canvas.queue_redraw()
		return
	var b: Dictionary = body
	if not b.has("planet_map"):
		b["planet_map"] = PlanetMap.generer(b, graine)
	map = b["planet_map"]
	var coord_lbl := "cubic (q, r, s)" if str(map["coord"]) == "cubic" else "axial (q, r)"
	var taille_txt := "%d cases" % map["cells"].size()
	if int(map.get("rayon", 0)) > 0:
		taille_txt = "rayon %d · %d cases" % [int(map["rayon"]), map["cells"].size()]
	title_label.text = "Explorer — %s (%s, %s · coordonnées %s)" % [str(map["nom"]), str(map["classe"]), taille_txt, coord_lbl]
	msg_label.text = ""
	_legend()
	info_label.text = "Cliquez sur une case hexagonale pour afficher ses caractéristiques (coordonnées, environnement, site)."
	refresh_salvage(SalvageTables.sites_du_corps(b), recup, has_scaphandre)
	canvas.queue_redraw()

func _legend() -> void:
	var counts := {}
	for e in map["envs"]:
		var l: String = PlanetMap.libelle_env(str(e))
		counts[l] = int(counts.get(l, 0)) + 1
	var parts: Array = []
	for l in counts.keys():
		parts.append("%s (%d)" % [l, int(counts[l])])
	var ccounts := {}
	for v in map["sites"].values():
		ccounts[str(v)] = int(ccounts.get(str(v), 0)) + 1
	for k in ccounts.keys():
		parts.append("%s ×%d" % [k, int(ccounts[k])])
	if parts.is_empty():
		legend_label.text = "Légende : aucune case"
	else:
		legend_label.text = "Légende : " + ", ".join(parts)

func _layout() -> void:
	centres = []
	if map.is_empty() or canvas == null:
		return
	s = float(map["taille"])
	var pts: Array = []
	for c in map["cells"]:
		pts.append(PlanetMap.hex_centre(c, s))
	var p0: Vector2 = pts[0]
	var minx: float = p0.x
	var miny: float = p0.y
	var maxx: float = p0.x
	var maxy: float = p0.y
	for pv in pts:
		var p: Vector2 = pv
		minx = minf(minx, p.x)
		miny = minf(miny, p.y)
		maxx = maxf(maxx, p.x)
		maxy = maxf(maxy, p.y)
	var cw: float = maxx - minx + 2.0 * s
	var ch: float = maxy - miny + 2.0 * s
	zoom = 1.0
	if canvas.size.x > 0.0 and canvas.size.y > 0.0:
		zoom = minf(1.0, minf((canvas.size.x - 40.0) / cw, (canvas.size.y - 40.0) / ch))
	offset = Vector2.ZERO
	if canvas.size.x > 0.0:
		offset.x = (canvas.size.x - cw * zoom) / 2.0 - (minx - s) * zoom
		offset.y = (canvas.size.y - ch * zoom) / 2.0 - (miny - s) * zoom
	for pv in pts:
		var p: Vector2 = pv
		centres.append(offset + p * zoom)

func _draw_map(cv: Control) -> void:
	_layout()
	if map.is_empty():
		return
	var sq := sqrt(3.0) / 2.0
	var envs: Array = map["envs"]
	var sites: Dictionary = map["sites"]
	for i in centres.size():
		var p: Vector2 = centres[i]
		var col: Color = PlanetMap.couleur_case(str(envs[i]))
		var pts := PackedVector2Array([
			p + Vector2(0, -s * zoom),
			p + Vector2(sq * s * zoom, -s * zoom / 2.0),
			p + Vector2(sq * s * zoom, s * zoom / 2.0),
			p + Vector2(0, s * zoom),
			p + Vector2(-sq * s * zoom, s * zoom / 2.0),
			p + Vector2(-sq * s * zoom, -s * zoom / 2.0),
		])
		cv.draw_colored_polygon(pts, col)
		cv.draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[4], pts[5], pts[0]]), Color(0.04, 0.05, 0.1), 1.5)
		if i == selected:
			cv.draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[4], pts[5], pts[0]]), Color(1.0, 0.85, 0.3), 2.5)
		if sites.has(i):
			_draw_glyph(cv, str(sites[i]), p, s * zoom * 0.45)

func _draw_glyph(cv: Control, t: String, p: Vector2, g: float) -> void:
	var w := Color(1, 1, 1)
	match t:
		"Astroport":
			cv.draw_polyline(PackedVector2Array([p + Vector2(0, -g), p + Vector2(g, g * 0.75), p + Vector2(-g, g * 0.75), p + Vector2(0, -g)]), w, 1.5)
			cv.draw_circle(p, g * 0.2, w)
		"Ville":
			cv.draw_rect(Rect2(p - Vector2(g * 0.8, g * 0.8), Vector2(g * 1.6, g * 1.6)), w)
		"Village":
			cv.draw_rect(Rect2(p - Vector2(g * 0.55, g * 0.55), Vector2(g * 1.1, g * 1.1)), w)
		"Colonie":
			cv.draw_rect(Rect2(p - Vector2(g * 0.8, g * 0.8), Vector2(g * 1.6, g * 1.6)), w, false, 1.5)
		"Crique":
			cv.draw_circle(p, g * 0.5, Color(0.75, 0.9, 1.0))
		"Ruines":
			cv.draw_line(p + Vector2(-g * 0.85, -g * 0.85), p + Vector2(g * 0.85, g * 0.85), w, 1.5)
			cv.draw_line(p + Vector2(-g * 0.85, g * 0.85), p + Vector2(g * 0.85, -g * 0.85), w, 1.5)
		"Décharge":
			cv.draw_polyline(PackedVector2Array([p + Vector2(-g, -g * 0.6), p + Vector2(g, -g * 0.6), p + Vector2(0, g)]), w, 1.5)
		"Champ de bataille":
			cv.draw_line(p + Vector2(-g * 0.7, -g * 0.7), p + Vector2(g * 0.7, g * 0.7), w, 2.0)
			cv.draw_line(p + Vector2(-g * 0.7, g * 0.7), p + Vector2(g * 0.7, -g * 0.7), w, 2.0)
		"Épave":
			cv.draw_arc(p, g * 0.7, 0, TAU, 16, w, 1.5)
			cv.draw_line(p + Vector2(-g * 0.4, g * 0.1), p + Vector2(g * 0.4, g * 0.1), w, 1.5)

func _on_canvas_click(pos: Vector2) -> void:
	if map.is_empty():
		return
	_layout()
	var best := -1
	var bestd := 1.0e9
	for i in centres.size():
		var cp: Vector2 = centres[i]
		var d: float = cp.distance_to(pos)
		if d < s * zoom and d < bestd:
			best = i
			bestd = d
	if best >= 0:
		select_cell(best)

func select_cell(i: int) -> void:
	selected = i
	var coord := PlanetMap.coord_case(map, i)
	var env := PlanetMap.libelle_env(str(map["envs"][i]))
	var site: String = str(map["sites"].get(i, ""))
	var txt := "Case %d · coordonnées %s · environnement : %s" % [i + 1, coord, env]
	if site != "":
		txt += " · site : %s" % site
	else:
		txt += " · aucun site"
	info_label.text = txt
	canvas.queue_redraw()
