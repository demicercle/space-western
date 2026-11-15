class_name SystemMap
extends HBoxContainer

class MapCanvas extends Control:
	var sys: StarSystem
	func _ready() -> void:
		mouse_filter = MOUSE_FILTER_IGNORE
	func _draw() -> void:
		if sys == null or size.x <= 0.0 or size.y <= 0.0:
			return
		var c := size * 0.5
		var max_r: float = min(size.x, size.y) * 0.5 - 30.0
		var scale: float = max_r / (50.0 + 235.0 * sqrt(float(sys.limite) / float(sys.limite)))
		var r_of := func(o: float) -> float: return (50.0 + 235.0 * sqrt(o / float(sys.limite))) * scale
		var etoile_col := Color(1.0, 0.85, 0.4)
		match sys.etoile:
			"naine rouge": etoile_col = Color(1.0, 0.45, 0.3)
			"géante rouge": etoile_col = Color(1.0, 0.35, 0.25)
			"étoile binaire": etoile_col = Color(0.9, 0.95, 1.0)
			"étoile variable": etoile_col = Color(1.0, 0.7, 0.9)
		draw_circle(c, r_of.call(0.0) * 0.35 + 8.0, Color(etoile_col, 0.25))
		draw_circle(c, r_of.call(0.0) * 0.35 + 4.0, etoile_col)
		draw_string(ThemeDB.fallback_font, c + Vector2(14, 4), "%s (%s)" % [sys.nom, sys.etoile], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 0.95, 0.8))
		for body in sys.corps:
			var ro: float = r_of.call(float(body["orbite"]))
			draw_arc(c, ro, 0.0, TAU, 64, Color(1, 1, 1, 0.12), 1.0)
		if sys.ceinture != null:
			draw_arc(c, r_of.call(float(sys.ceinture["orbite"])), 0.0, TAU, 64, Color(0.8, 0.75, 0.6, 0.5), 2.0)
		var i := 0
		for body in sys.corps:
			var ang := float(i) * 2.399 + float(body["orbite"]) * 0.7
			var p: Vector2 = c + Vector2(cos(ang), sin(ang)) * r_of.call(float(body["orbite"]))
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
			draw_string(ThemeDB.fallback_font, p + Vector2(br + 3, -br - 2), "%s (orbite %d US)" % [body.get("nom", "?"), body["orbite"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.9, 0.92, 0.98, 0.95))
			i += 1

var canvas: MapCanvas
var details: RichTextLabel
var sys: StarSystem

func _ready() -> void:
	add_theme_constant_override("separation", 10)
	canvas = MapCanvas.new()
	canvas.size_flags_horizontal = SIZE_EXPAND_FILL
	canvas.custom_minimum_size = Vector2(420, 420)
	add_child(canvas)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(360, 0)
	add_child(scroll)
	details = RichTextLabel.new()
	details.bbcode_enabled = true
	details.size_flags_horizontal = SIZE_EXPAND_FILL
	details.size_flags_vertical = SIZE_EXPAND_FILL
	details.scroll_active = true
	scroll.add_child(details)

func set_system(s: StarSystem) -> void:
	sys = s
	canvas.sys = s
	canvas.queue_redraw()
	if s == null:
		details.text = ""
		return
	var bb := "[b][color=gold]%s[/color][/b] (%s-%d)\n" % [s.nom, s.quad_x, s.quad_y]
	bb += "Étoile : %s, diamètre %s · Limite : %d US\n" % [s.etoile, s.diam_etoile, s.limite]
	bb += "Nation : %s\nRoute : %s\nGouvernement : %s\n" % [s.nation, s.route, s.gouvernement]
	bb += "Patrouille : %s (coût %s) · Trafic : %s — %s\n" % [s.patrouille, s.cout_pat, s.trafic, s.trafic_desc]
	bb += "Activité solaire : %s (%s près de l'étoile)\n" % [s.act_solaire, s.act_solaire_proche]
	for body in s.corps:
		bb += "\n[color=cyan]▸ %s[/color] — %s, orbite %d US (saut : %d US)\n" % [body.get("nom", "?"), body.get("classe", body["type"]), body["orbite"], body["distance_saut"]]
		for k in ["diametre", "atmosphere", "environnement", "temperature", "gravite", "eau", "habitee", "population", "densite", "categorie", "niveau_techno", "gouvernement", "commerce", "cours", "illegal", "astroport", "securite", "systeme_orbital"]:
			if body.has(k) and str(body[k]) != "" and str(body[k]) != "false":
				bb += "    %s : %s\n" % [k, body[k]]
		if body.get("description", "") != "":
			bb += "    [i]%s[/i]\n" % body["description"]
	if s.ceinture != null:
		bb += "\n[color=cyan]▸ %s[/color], orbite %d US\n" % [s.ceinture["nom"], s.ceinture["orbite"]]
	details.text = bb
