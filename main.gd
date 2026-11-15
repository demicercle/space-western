class_name Main
extends Control

const POSTS := ["Capitaine", "Pilote", "Vigie", "Ingénieur", "Canonnier", "Fusilier", "Cartographe / Historien"]

const SHIP_NAMES := ["La Guigne", "Black Pearl", "Vengeance", "L'Étoile Filante", "La Sirène", "Jolly Roger", "Faucon Noir", "La Glorieuse", "Mauvaise Fortune", "L'Épervier", "La Comète Noire", "Santa Maria"]

@onready var left_vbox: VBoxContainer = %LeftVBox
@onready var tabs: TabContainer = %Tabs

var ship: Ship
var characters: Array = []
var char_tokens := {}
var current_pos := GalaxyData.EXXALIA
var destination := Vector2i(-1, -1)
var distance := 0
var current_system: StarSystem
var systems_cache := {}

var galaxy_map: GalaxyMap
var system_map: SystemMap
var crew_panel: CrewPanel
var ship_panel: ShipPanel
var posts_container: VBoxContainer
var ship_name_label: Label
var info_label: Label
var calc_button: Button
var journal: RichTextLabel
var panel_style: StyleBoxFlat

static func post_name_static(i: int) -> String:
	if i < POSTS.size():
		return POSTS[i]
	return "Passager %d" % (i - POSTS.size() + 1)

func _ready() -> void:
	randomize()
	_setup_theme()
	_build_left_panel()
	_build_tabs()
	_start_game()

func _setup_theme() -> void:
	add_theme_color_override("font_color", Color(0.86, 0.89, 0.96))
	add_theme_font_size_override("font_size", 14)
	panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.09, 0.11, 0.18, 0.92)
	panel_style.border_color = Color(0.35, 0.45, 0.65)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(6)
	panel_style.set_content_margin_all(8)
	%LeftPanel.add_theme_stylebox_override("panel", panel_style)

func apply_panel_style(p: PanelContainer) -> void:
	p.add_theme_stylebox_override("panel", panel_style)

func _build_left_panel() -> void:
	ship_name_label = Label.new()
	ship_name_label.add_theme_font_size_override("font_size", 16)
	ship_name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	left_vbox.add_child(ship_name_label)
	var pl := Label.new()
	pl.text = "Postes à bord (glisser-déposer un personnage) :"
	pl.add_theme_font_size_override("font_size", 12)
	pl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	pl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_vbox.add_child(pl)
	posts_container = VBoxContainer.new()
	posts_container.add_theme_constant_override("separation", 6)
	left_vbox.add_child(posts_container)

func _build_tabs() -> void:
	tabs.set_tab_title(0, "Carte galactique")
	tabs.set_tab_title(1, "Carte de système")
	tabs.set_tab_title(2, "Équipage")
	tabs.set_tab_title(3, "Vaisseau")

	var tab_g: Control = tabs.get_child(0)
	var hb := HBoxContainer.new()
	hb.set_anchors_preset(Control.PRESET_FULL_RECT)
	hb.add_theme_constant_override("separation", 10)
	tab_g.add_child(hb)
	galaxy_map = GalaxyMap.new()
	galaxy_map.size_flags_horizontal = SIZE_EXPAND_FILL
	galaxy_map.size_flags_vertical = SIZE_EXPAND_FILL
	galaxy_map.cell_clicked.connect(_on_cell_clicked)
	hb.add_child(galaxy_map)
	var side := VBoxContainer.new()
	side.custom_minimum_size = Vector2(380, 0)
	side.add_theme_constant_override("separation", 6)
	hb.add_child(side)
	info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_size_override("font_size", 12)
	side.add_child(info_label)
	calc_button = Button.new()
	calc_button.text = "Calculer le voyage"
	calc_button.disabled = true
	calc_button.pressed.connect(_on_calc_voyage)
	side.add_child(calc_button)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	side.add_child(scroll)
	journal = RichTextLabel.new()
	journal.bbcode_enabled = true
	journal.size_flags_horizontal = SIZE_EXPAND_FILL
	journal.size_flags_vertical = SIZE_EXPAND_FILL
	journal.scroll_active = true
	scroll.add_child(journal)

	system_map = SystemMap.new()
	system_map.set_anchors_preset(Control.PRESET_FULL_RECT)
	tabs.get_child(1).add_child(system_map)

	crew_panel = CrewPanel.new()
	crew_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	tabs.get_child(2).add_child(crew_panel)

	ship_panel = ShipPanel.new()
	ship_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	tabs.get_child(3).add_child(ship_panel)

func _start_game() -> void:
	ship = Ship.galactic_scout(MAUtils.pick(SHIP_NAMES))
	current_system = get_system(current_pos)
	for i in range(4):
		var c := Character.generate("Héros", "Premier rôle")
		c.post_index = i
		characters.append(c)
		char_tokens[c] = CharacterToken.new()
		char_tokens[c].setup(c)
	refresh_all()

func get_system(cell: Vector2i) -> StarSystem:
	var key := "%d,%d" % [cell.x, cell.y]
	if systems_cache.has(key):
		return systems_cache[key]
	var s: StarSystem
	if cell == GalaxyData.EXXALIA:
		s = StarSystem.generate("Ε", 21, {"nom": "Exxalia", "nation": "l'OCG (Omni-cartel Galactique)", "route": "Route galactique", "gouvernement": "Corporatiste"})
	else:
		var named: Variant = GalaxyData.named_at(cell.x, cell.y)
		var opts := {}
		if named != null:
			opts["nom"] = named["nom"]
		s = StarSystem.generate(GalaxyData.letter_symbol(cell.x), cell.y, opts)
	systems_cache[key] = s
	return s

func rebuild_posts() -> void:
	for ch in posts_container.get_children():
		posts_container.remove_child(ch)
		ch.queue_free()
	for i in range(characters.size()):
		var slot := PostSlot.new()
		slot.post_name = post_name_static(i)
		slot.post_index = i
		slot.token_dropped.connect(_on_token_dropped)
		posts_container.add_child(slot)
		apply_panel_style(slot)
		for c in characters:
			if c.post_index == i:
				slot.token = char_tokens[c]
		slot.refresh()
	var hamac := PostSlot.new()
	hamac.is_hamac = true
	hamac.post_name = "Hamac (sans poste)"
	hamac.post_index = -1
	hamac.token_dropped.connect(_on_token_dropped)
	posts_container.add_child(hamac)
	apply_panel_style(hamac)
	for c in characters:
		if c.post_index == -1:
			hamac.token = char_tokens[c]
	hamac.refresh()

func _on_token_dropped(slot: PostSlot, token: CharacterToken) -> void:
	var ch: Character = token.character
	var new_idx := slot.post_index
	if ch.post_index == new_idx:
		return
	var old_idx := ch.post_index
	for c in characters:
		if c != ch and c.post_index == new_idx:
			c.post_index = old_idx
	ch.post_index = new_idx
	rebuild_posts()
	crew_panel.set_characters(characters)

func _on_cell_clicked(col: int, row: int) -> void:
	destination = Vector2i(col, row)
	distance = GalaxyData.distance_pc(current_pos, destination)
	galaxy_map.destination = destination
	galaxy_map.queue_redraw()
	calc_button.disabled = false
	_update_info_label()

func _update_info_label() -> void:
	if destination.x < 0:
		info_label.text = "Position : %s (%s)\nCliquez sur une case de la carte galactique pour choisir une destination." % [GalaxyData.coord_label(current_pos.x, current_pos.y), GalaxyData.coord_text(current_pos.x, current_pos.y)]
		return
	var dest_sys := get_system(destination)
	var named: Variant = GalaxyData.named_at(destination.x, destination.y)
	var dest_name: String = named["nom"] if named != null else "case inconnue"
	info_label.text = "Position : %s (%s)\nDestination : %s — %s (%s)\nDistance : %s PC (1 case = 1 000 PC) · Vitesse : %d PC/j · Route : %s" % [
		GalaxyData.coord_label(current_pos.x, current_pos.y), GalaxyData.coord_text(current_pos.x, current_pos.y),
		dest_name, GalaxyData.coord_label(destination.x, destination.y), GalaxyData.coord_text(destination.x, destination.y),
		MAUtils.fmt_int(distance), ship.vitesse_hyper_pc_j, dest_sys.route,
	]

func _post_skills() -> Dictionary:
	var sk := {"pi": 0, "na": 0, "se": 0, "ss": 0, "ing": 0, "cae": 0, "carto": 0}
	for c in characters:
		if c.post_index < 0:
			continue
		match post_name_static(c.post_index):
			"Pilote":
				sk["pi"] = c.get_comp("Pilotage")
				sk["na"] = c.get_comp("Navigation")
			"Vigie":
				sk["se"] = c.get_comp("Senseurs")
				sk["ss"] = c.get_comp("Sciences stellaires")
			"Ingénieur":
				sk["ing"] = c.get_comp("Ingénierie")
			"Canonnier":
				sk["cae"] = c.get_comp("Armes embarquées")
			"Cartographe / Historien":
				sk["carto"] = c.get_comp("Cartographie")
				if sk["carto"] == 0:
					sk["carto"] = maxi(c.get_comp("Navigation"), c.get_comp("Histoire"))
	return sk

func _on_calc_voyage() -> void:
	if destination.x < 0:
		return
	calc_button.disabled = true
	var sk := _post_skills()
	var dest_sys := get_system(destination)
	var route_key := "g" if dest_sys.route == "Route galactique" else ("c" if dest_sys.route == "Route commerciale" else "x")
	var cfg := {
		"mode": "hyper",
		"dep": current_pos,
		"arr": destination,
		"distance": distance,
		"vitesse": ship.vitesse_hyper_pc_j,
		"route_key": route_key,
		"p1pi": sk["pi"], "p1na": sk["na"], "p2pi": sk["pi"], "p2na": sk["na"],
		"v1se": sk["se"], "v1ss": sk["ss"], "v2se": sk["se"], "v2ss": sk["ss"],
		"cae": sk["cae"], "ing": sk["ing"], "carto": sk["carto"],
		"equip": characters.size(),
		"passagers": 0,
		"tonnage": ship.tonnage,
		"radix_reserve": ship.radix_pc,
		"myst": dest_sys.route == "Mystérieux",
	}
	var res := TravelSim.simulate(cfg)
	if res["suivi_reserve"]:
		ship.radix_pc = int(round(res["reserve"]))
	ship.rations = maxi(0, ship.rations - res["resume"]["rations"])
	ship.cargaison["Rations"] = ship.rations
	for deg in res["resume"]["degats"]:
		if str(deg).contains("PC"):
			continue
		ship.subir_degats(str(deg))
	_render_journal(res, dest_sys)
	if res["arrivee"]:
		current_pos = destination
		current_system = dest_sys
		if not galaxy_map.explored.has(destination):
			galaxy_map.explored.append(destination)
	elif res["a_sec"] and res["case_finale"] != null:
		current_pos = res["case_finale"]
		current_system = get_system(current_pos)
	for c in res["resume"]["cases_relees"]:
		if not galaxy_map.explored.has(c):
			galaxy_map.explored.append(c)
	destination = Vector2i(-1, -1)
	galaxy_map.destination = destination
	refresh_all()

func _render_journal(res: Dictionary, dest_sys: StarSystem) -> void:
	var dep: Vector2i = res["cfg"]["dep"]
	var arr: Vector2i = res["cfg"]["arr"]
	var bb := "[b][color=gold]Voyage : %s → %s[/color][/b]\n" % [GalaxyData.coord_label(dep.x, dep.y), GalaxyData.coord_label(arr.x, arr.y)]
	bb += "Distance : %s PC · Vitesse : %d PC/j · Route : %s (péril %s/jour)\n" % [MAUtils.fmt_int(res["cfg"]["distance"]), res["cfg"]["vitesse"], dest_sys.route, {"g": "1/8", "c": "1/4"}.get(res["cfg"]["route_key"], "1/2")]
	if res["saut"] != null:
		var s = res["saut"]
		bb += "Calcul du saut : Pilote %d, Navigation +%d (%s) : %d tentative(s) = %s, %d succès excédentaire(s) retranché(s) du premier jet de péril.\n" % [s["pilote"], s["na"], "TD" if s["mode"] == "TD" else "normal", s["essais"], TravelSim.heure_txt(s["heures"]), s["exc"]]
	else:
		bb += "Calcul du saut : aucun Pilote avec Navigation à bord — saut non simulé.\n"
	for j in res["jours"]:
		bb += "\n[b]Jour %d[/b] (quart %d) :\n" % [j["num"], j["actif"]]
		for l in j["lignes"]:
			bb += "  " + str(l) + "\n"
		if j.get("arrivee", false):
			bb += "  [color=7bed9f][b]ARRIVÉE à destination[/b][/color]\n"
	var T: Dictionary = res["resume"]
	bb += "\n[b]Résumé du voyage[/b]\n"
	if res["arrivee"]:
		bb += "[color=7bed9f]Arrivé en %d jour(s) (%s de vol le dernier jour).[/color]\n" % [res["jours_count"], TravelSim.heure_txt(res["heures_fin"])]
	elif res["a_sec"]:
		bb += "[color=ff5544]Panne sèche le jour %d[/color] — position relevée : %s.\n" % [res["jour_sec"], GalaxyData.coord_label(res["case_finale"].x, res["case_finale"].y) if res["case_finale"] != null else "?"]
	else:
		bb += "Voyage interrompu après %d jour(s), reste %s PC.\n" % [res["jours_count"], MAUtils.fmt_num(res["restant"])]
	bb += "Périls : %d (%d évités, %d subis) · Pannes : %d (%d réparées) · Retards : %d · Relevés : %d\n" % [T["perils"].size(), T["evites"], T["subis"], T["pannes"], T["reparees"], T["retards"], T["releves"]]
	if T["degats"].size() > 0:
		bb += "Dégâts subis : " + " ; ".join(T["degats"]) + "\n"
	if T["majeurs"].size() > 0:
		bb += "Événements majeurs : " + " ; ".join(T["majeurs"]) + "\n"
	bb += "Radix consommé : %s PC (réserve restante : %s PC) · Rations consommées : %d (reste %d)\n" % [MAUtils.fmt_num(T["radix_pc"]), MAUtils.fmt_int(ship.radix_pc), T["rations"], ship.rations]
	if T["rations"] > 0 and ship.rations == 0:
		bb += "[color=ff5544]Famine à bord : les rations sont épuisées ![/color]\n"
	if T["eau_pct"] > 0:
		bb += "Eau délestée (recycleur en panne) : %d %%\n" % int(T["eau_pct"])
	bb += "Bonus de pilotage gagnés : +%s PC\n" % MAUtils.fmt_num(T["bonus"])
	journal.text = bb

func refresh_all() -> void:
	ship_name_label.text = "Vaisseau : %s (%s) — %s" % [ship.nom, ship.modele, GalaxyData.coord_label(current_pos.x, current_pos.y)]
	rebuild_posts()
	crew_panel.set_characters(characters)
	ship_panel.set_ship(ship)
	system_map.set_system(current_system)
	galaxy_map.current_pos = current_pos
	galaxy_map.queue_redraw()
	_update_info_label()
