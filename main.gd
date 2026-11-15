class_name Main
extends Control

const POSTS := ["Pilote", "Vigie", "Ingénieur", "Canonnier", "Fusilier", "Cartographe / Historien"]
const TAB_COMMERCE := 4
const TAB_RECRUTER := 5

const SHIP_NAMES := ["La Guigne", "Black Pearl", "Vengeance", "L'Étoile Filante", "La Sirène", "Jolly Roger", "Faucon Noir", "La Glorieuse", "Mauvaise Fortune", "L'Épervier", "La Comète Noire", "Santa Maria"]

@onready var left_vbox: VBoxContainer = %LeftVBox
@onready var tabs: TabContainer = %Tabs

var ship: Ship
var characters: Array = []
var char_tokens := {}
var captain: Character = null
var credits := 0
var current_pos := GalaxyData.EXXALIA
var destination := Vector2i(-1, -1)
var distance := 0
var current_system: StarSystem
var systems_cache := {}

var galaxy_map: GalaxyMap
var system_map: SystemMap
var crew_panel: CrewPanel
var ship_panel: ShipPanel
var shop_panel: ShopPanel
var recruit_panel: RecruitPanel
var marchandage_mod := 1.0
var posts_container: VBoxContainer
var ship_name_label: Label
var credits_label: Label
var captain_label: Label
var info_label: Label
var travel_info_label: Label
var msg_label: Label
var plein_button: Button
var calc_button: Button
var journal: RichTextLabel
var context_menu: PopupMenu
var confirm_dialog: AcceptDialog
var pending_virer: Character = null
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
	_build_context_menu()
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
	if p is PostSlot:
		p.set_normal_style(panel_style)
	else:
		p.add_theme_stylebox_override("panel", panel_style)

func _build_left_panel() -> void:
	ship_name_label = Label.new()
	ship_name_label.add_theme_font_size_override("font_size", 16)
	ship_name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	left_vbox.add_child(ship_name_label)
	credits_label = Label.new()
	credits_label.add_theme_font_size_override("font_size", 14)
	credits_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.4))
	left_vbox.add_child(credits_label)
	captain_label = Label.new()
	captain_label.add_theme_font_size_override("font_size", 12)
	captain_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	left_vbox.add_child(captain_label)
	var pl := Label.new()
	pl.text = "Postes à bord (glisser-déposer un personnage ; clic = fiche ; clic droit = menu) :"
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
	tabs.set_tab_title(4, "Commerce")
	tabs.set_tab_title(5, "Recruter")

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
	travel_info_label = Label.new()
	travel_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	travel_info_label.add_theme_font_size_override("font_size", 13)
	travel_info_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	side.add_child(travel_info_label)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 8)
	side.add_child(btns)
	plein_button = Button.new()
	plein_button.text = "Faire le plein"
	plein_button.pressed.connect(_on_faire_le_plein)
	btns.add_child(plein_button)
	calc_button = Button.new()
	calc_button.text = "Calculer le voyage"
	calc_button.disabled = true
	calc_button.pressed.connect(_on_calc_voyage)
	btns.add_child(calc_button)
	msg_label = Label.new()
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_label.add_theme_font_size_override("font_size", 11)
	msg_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	side.add_child(msg_label)
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
	ship_panel.sell_requested.connect(_on_sell)

	shop_panel = ShopPanel.new()
	shop_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	tabs.get_child(4).add_child(shop_panel)
	shop_panel.buy_requested.connect(_on_buy)

	recruit_panel = RecruitPanel.new()
	recruit_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	tabs.get_child(5).add_child(recruit_panel)
	recruit_panel.recruit_found.connect(_on_recruit_found)
	recruit_panel.recruit_hired.connect(_on_recruit_hired)

func _build_context_menu() -> void:
	context_menu = PopupMenu.new()
	add_child(context_menu)
	context_menu.id_pressed.connect(_on_context_id)
	confirm_dialog = AcceptDialog.new()
	add_child(confirm_dialog)
	confirm_dialog.get_ok_button().text = "Oui"
	if "cancel_button_text" in confirm_dialog:
		confirm_dialog.cancel_button_text = "Non"
	confirm_dialog.confirmed.connect(_on_virer_confirmed)

func _start_game() -> void:
	ship = Ship.galactic_basic(MAUtils.pick(SHIP_NAMES))
	credits = 8000
	characters = []
	captain = null
	current_system = get_system(current_pos)
	refresh_all()

func get_system(cell: Vector2i) -> StarSystem:
	var key := "%d,%d" % [cell.x, cell.y]
	if systems_cache.has(key):
		return systems_cache[key]
	var s: StarSystem
	var named: Variant = GalaxyData.named_at(cell.x, cell.y)
	if cell == GalaxyData.EXXALIA:
		s = StarSystem.generate("Ε", 21, {"nom": "Exxalia", "nation": "l'OCG (Omni-cartel Galactique)", "route": "Route galactique", "gouvernement": "Corporatiste"})
		StarSystem.assurer_planete(s, "Exxalia")
	elif named != null and named["type"] == "relais":
		s = StarSystem.generate(GalaxyData.letter_symbol(cell.x), cell.y, {"nom": named["nom"]})
		StarSystem.assurer_station(s, named["nom"])
		s.est_relais = true
	else:
		var opts := {}
		if named != null:
			opts["nom"] = named["nom"]
		s = StarSystem.generate(GalaxyData.letter_symbol(cell.x), cell.y, opts)
	systems_cache[key] = s
	return s

func docked() -> bool:
	return current_system != null and current_system.peut_amarrer()

func soute_used() -> float:
	var u := 0.0
	for k in ship.cargaison.keys():
		u += ShopTables.place_de(k) * float(ship.cargaison[k])
	return u

func cours_actuel() -> Dictionary:
	if current_system != null:
		return current_system.cours_dict()
	return {"A": 1.0, "B": 1.0, "C": 1.0}

func cours_txt() -> String:
	var c := cours_actuel()
	return "A ×%s · B ×%s · C ×%s" % [MAUtils.fmt_num(c["A"]), MAUtils.fmt_num(c["B"]), MAUtils.fmt_num(c["C"])]

func radix_unit_price() -> float:
	return ship.tonnage * (1.5 if current_system != null and current_system.est_relais else 0.75)

func _on_buy(it: Dictionary) -> void:
	var prix := int(it["prix"])
	var place: float = float(it["place"])
	if not docked():
		shop_panel.set_message("Commerce indisponible hors planète/station-relais.")
		return
	if credits < prix:
		shop_panel.set_message("Crédits insuffisants pour %s (%s ¤)." % [it["nom"], MAUtils.fmt_int(prix)])
		return
	if soute_used() + place > ship.soute + 0.0001:
		shop_panel.set_message("Plus de place en soute pour %s." % it["nom"])
		return
	credits -= prix
	ship.cargaison[it["nom"]] = int(ship.cargaison.get(it["nom"], 0)) + 1
	if it["nom"] == "Ration":
		ship.rations = int(ship.cargaison["Ration"])
	shop_panel.set_message("Acheté : %s pour %s ¤ (en soute)." % [it["nom"], MAUtils.fmt_int(prix)])
	refresh_all()

func _on_sell(nom: String) -> void:
	if not docked():
		ship_panel.set_message("Vente indisponible hors planète/station-relais.")
		return
	if not ship.cargaison.has(nom) or int(ship.cargaison[nom]) <= 0:
		return
	var prix := ship_panel.prix_vente_unit(nom)
	credits += prix
	ship.cargaison[nom] = int(ship.cargaison[nom]) - 1
	if int(ship.cargaison[nom]) <= 0:
		ship.cargaison.erase(nom)
	if nom == "Ration":
		ship.rations = int(ship.cargaison.get("Ration", 0))
	ship_panel.set_message("Vendu : 1 × %s pour %s ¤." % [nom, MAUtils.fmt_int(prix)])
	refresh_all()

func _test_marchandage() -> String:
	if captain == null:
		marchandage_mod = 1.0
		return "Pas de capitaine : marchandage non testé (×1,00)."
	var r := Dice.test(captain.get_comp("Commerce"), 1)
	var m := Dice.test(3, 1)
	var mod := 1.0
	var txt := ""
	if r["succ"] >= m["succ"]:
		mod = 1.0 + 0.05 * maxi(0, r["succ"] - m["succ"])
		txt = "le capitaine remporte l'opposition (vendeur)"
	else:
		mod = 1.0 - 0.05 * maxi(0, m["succ"] - r["succ"])
		txt = "le marchand remporte l'opposition (acheteur)"
	mod = clampf(mod, 0.5, 1.5)
	marchandage_mod = mod
	return "Marchandage à l'arrivée — Commerce du capitaine %s : %s contre marchand %s : %s → prix de vente ×%s (plafonds 50 %%–150 %% du prix de base)." % [captain.nom, Dice.fmt_jet(r), Dice.fmt_jet(m), txt, MAUtils.fmt_num(mod)]

func nb_posts() -> int:
	return mini(POSTS.size(), ship.equipage_postes)

func make_token(c: Character) -> CharacterToken:
	var t := CharacterToken.new()
	t.setup(c)
	t.left_clicked.connect(_on_token_left_clicked)
	t.right_clicked.connect(_on_token_right_clicked)
	char_tokens[c] = t
	return t

func rebuild_posts() -> void:
	for ch in posts_container.get_children():
		posts_container.remove_child(ch)
		ch.queue_free()
	for i in range(nb_posts()):
		var slot := PostSlot.new()
		slot.post_name = post_name_static(i)
		slot.post_index = i
		slot.token_dropped.connect(_on_token_dropped)
		posts_container.add_child(slot)
		apply_panel_style(slot)
		var lst: Array = []
		for c in characters:
			if c.post_index == i:
				lst.append(char_tokens[c])
		slot.set_tokens(lst)
	var hamac := PostSlot.new()
	hamac.is_hamac = true
	hamac.post_name = "Hamac (sans poste)"
	hamac.post_index = -1
	hamac.hamac_max = ship.passagers_max
	hamac.token_dropped.connect(_on_token_dropped)
	posts_container.add_child(hamac)
	apply_panel_style(hamac)
	var hlist: Array = []
	for c in characters:
		if c.post_index == -1:
			hlist.append(char_tokens[c])
	hamac.set_tokens(hlist)

func _on_token_dropped(slot: PostSlot, token: CharacterToken) -> void:
	var ch: Character = token.character
	var new_idx := slot.post_index
	if ch.post_index == new_idx:
		return
	var old_idx := ch.post_index
	if new_idx >= 0:
		for c in characters:
			if c != ch and c.post_index == new_idx:
				c.post_index = old_idx
	ch.post_index = new_idx
	rebuild_posts()
	crew_panel.set_characters(characters, captain)

func _on_token_left_clicked(token: CharacterToken) -> void:
	tabs.current_tab = 2
	crew_panel.select_character(token.character)

func _on_token_right_clicked(token: CharacterToken, global_pos: Vector2) -> void:
	pending_virer = token.character
	context_menu.clear()
	context_menu.add_check_item("Élire capitaine", 0)
	context_menu.set_item_checked(0, captain == token.character)
	context_menu.add_item("Virer de l'équipage", 1)
	context_menu.popup(Rect2i(Vector2i(global_pos), Vector2i(220, 0)))

func _on_context_id(id: int) -> void:
	if pending_virer == null:
		return
	if id == 0:
		captain = pending_virer
		refresh_all()
	elif id == 1:
		confirm_dialog.dialog_text = "Virer %s de l'équipage ?" % pending_virer.nom
		confirm_dialog.popup_centered()

func _on_virer_confirmed() -> void:
	if pending_virer == null:
		return
	var ch: Character = pending_virer
	pending_virer = null
	characters.erase(ch)
	if char_tokens.has(ch):
		char_tokens[ch].queue_free()
		char_tokens.erase(ch)
	if captain == ch:
		captain = characters[0] if characters.size() > 0 else null
	if crew_panel.selected == ch:
		crew_panel.selected = characters[0] if characters.size() > 0 else null
	refresh_all()

func _on_cell_clicked(col: int, row: int) -> void:
	destination = Vector2i(col, row)
	distance = GalaxyData.distance_pc(current_pos, destination)
	galaxy_map.destination = destination
	galaxy_map.queue_redraw()
	msg_label.text = ""
	_update_info_label()
	_update_buttons()

func can_travel() -> bool:
	var has_pilot := false
	var has_vigie := false
	for c in characters:
		if c.post_index < 0:
			continue
		match post_name_static(c.post_index):
			"Pilote":
				has_pilot = true
			"Vigie":
				has_vigie = true
	return has_pilot and has_vigie

func salaire_jour() -> int:
	var s := 0
	for c in characters:
		s += c.prix_journalier
	return s

func _update_info_label() -> void:
	var pos_txt := "Position : %s (%s)" % [GalaxyData.coord_label(current_pos.x, current_pos.y), GalaxyData.coord_text(current_pos.x, current_pos.y)]
	if destination.x < 0:
		info_label.text = pos_txt + "\nCliquez sur une case de la carte galactique pour choisir une destination."
		return
	var dest_sys := get_system(destination)
	var named: Variant = GalaxyData.named_at(destination.x, destination.y)
	var dest_name: String = named["nom"] if named != null else "case inconnue"
	var extra := ""
	if not can_travel():
		extra = "\n/!\\ Calculer un voyage exige un Pilote ET une Vigie à leur poste."
	info_label.text = "%s\nDestination : %s — %s (%s)\nDistance : %s PC (1 case = 1 000 PC) · Vitesse : %d PC/j · Route : %s%s" % [
		pos_txt,
		dest_name, GalaxyData.coord_label(destination.x, destination.y), GalaxyData.coord_text(destination.x, destination.y),
		MAUtils.fmt_int(distance), ship.vitesse_hyper_pc_j, dest_sys.route, extra,
	]

func _update_buttons() -> void:
	var dk := docked()
	tabs.set_tab_disabled(TAB_COMMERCE, not dk)
	tabs.set_tab_disabled(TAB_RECRUTER, not dk)
	plein_button.disabled = not dk or ship.radix_pc >= ship.autonomie_pc
	calc_button.disabled = destination.x < 0 or not can_travel()
	recruit_panel.set_enabled_state(dk, credits, characters.size(), ship.passagers_max)

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

func _on_faire_le_plein() -> void:
	if not docked():
		msg_label.text = "Faire le plein impossible : le vaisseau n'est pas sur une planète ou une station-relais."
		return
	var missing := ship.autonomie_pc - ship.radix_pc
	if missing <= 0:
		msg_label.text = "La réserve de Radix est déjà pleine."
		return
	var unit_price: float = radix_unit_price()
	var blocks := int(ceil(missing / 1000.0))
	var cost := int(round(blocks * unit_price))
	if credits >= cost:
		ship.radix_pc = ship.autonomie_pc
		credits -= cost
		msg_label.text = "Plein effectué : +%s PC pour %s ¤." % [MAUtils.fmt_int(missing), MAUtils.fmt_int(cost)]
	else:
		var afford := int(credits / unit_price)
		if afford <= 0:
			msg_label.text = "Crédits insuffisants pour acheter du Radix (%s ¤/1 000 PC)." % MAUtils.fmt_num(unit_price)
			return
		var add := afford * 1000
		ship.radix_pc += add
		credits -= int(round(afford * unit_price))
		msg_label.text = "Plein partiel : +%s PC pour %s ¤." % [MAUtils.fmt_int(add), MAUtils.fmt_int(afford * unit_price)]
	refresh_all()

func _on_calc_voyage() -> void:
	if destination.x < 0 or not can_travel():
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
		"pieces": int(ship.cargaison.get("Pièces détachées (1 kg)", 0)),
	}
	var res := TravelSim.simulate(cfg)
	if res["suivi_reserve"]:
		ship.radix_pc = int(round(res["reserve"]))
	ship.rations = maxi(0, ship.rations - res["resume"]["rations"])
	ship.cargaison["Ration"] = ship.rations
	var pieces_used: int = res["resume"].get("pieces_used", 0)
	if pieces_used > 0:
		var dispo: int = int(ship.cargaison.get("Pièces détachées (1 kg)", 0))
		ship.cargaison["Pièces détachées (1 kg)"] = maxi(0, dispo - pieces_used)
		if int(ship.cargaison["Pièces détachées (1 kg)"]) == 0:
			ship.cargaison.erase("Pièces détachées (1 kg)")
	var sal: int = salaire_jour() * int(res["jours_count"])
	credits = maxi(0, credits - sal)
	for deg in res["resume"]["degats"]:
		if str(deg).contains("PC"):
			continue
		ship.subir_degats(str(deg))
	var ligne_march := ""
	if res["arrivee"] and dest_sys.peut_amarrer():
		ligne_march = _test_marchandage()
	_render_journal(res, dest_sys, sal, ligne_march)
	if res["arrivee"]:
		current_pos = destination
		current_system = dest_sys
		if not galaxy_map.explored.has(destination):
			galaxy_map.explored.append(destination)
		msg_label.text = "Arrivé à %s (%s)." % [dest_sys.nom, GalaxyData.coord_label(destination.x, destination.y)]
		if ligne_march != "":
			msg_label.text += " " + ligne_march
	elif res["a_sec"] and res["case_finale"] != null:
		current_pos = res["case_finale"]
		current_system = get_system(current_pos)
		msg_label.text = "Panne sèche — position relevée : %s." % GalaxyData.coord_label(current_pos.x, current_pos.y)
	for c in res["resume"]["cases_relees"]:
		if not galaxy_map.explored.has(c):
			galaxy_map.explored.append(c)
	destination = Vector2i(-1, -1)
	galaxy_map.destination = destination
	refresh_all()

func _render_journal(res: Dictionary, dest_sys: StarSystem, sal_total: int, ligne_march := "") -> void:
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
	bb += "Radix consommé : %s PC (réserve restante : %s / %s PC) · Rations consommées : %d (reste %d)\n" % [MAUtils.fmt_num(T["radix_pc"]), MAUtils.fmt_int(ship.radix_pc), MAUtils.fmt_int(ship.autonomie_pc), T["rations"], ship.rations]
	if T["rations"] > 0 and ship.rations == 0:
		bb += "[color=ff5544]Famine à bord : les rations sont épuisées ![/color]\n"
	bb += "Salaires de l'équipage : %d ¤/jour × %d jour(s) = %s ¤ — crédits restants : %s ¤\n" % [salaire_jour(), res["jours_count"], MAUtils.fmt_int(sal_total), MAUtils.fmt_int(credits)]
	if int(T.get("pieces_used", 0)) > 0:
		bb += "Pièces détachées consommées (réparations) : %d — reste en soute : %s\n" % [int(T["pieces_used"]), MAUtils.fmt_int(int(ship.cargaison.get("Pièces détachées (1 kg)", 0)))]
	if ligne_march != "":
		bb += "[color=gold]" + ligne_march + "[/color]\n"
	bb += "Bonus de pilotage gagnés : +%s PC\n" % MAUtils.fmt_num(T["bonus"])
	journal.text = bb

func _on_recruit_found(c: Character) -> void:
	recruit_panel.show_recrue(c)
	_update_buttons()

func _on_recruit_hired(c: Character) -> void:
	if not docked():
		recruit_panel.set_message("Recrutement impossible hors planète/station-relais.")
		return
	if characters.size() >= ship.passagers_max:
		recruit_panel.set_message("Le vaisseau est plein (%d/%d)." % [characters.size(), ship.passagers_max])
		return
	if credits < c.prix_recrutement:
		recruit_panel.set_message("Crédits insuffisants (%s ¤ requis)." % MAUtils.fmt_int(c.prix_recrutement))
		return
	credits -= c.prix_recrutement
	c.post_index = -1
	characters.append(c)
	make_token(c)
	if captain == null:
		captain = c
	recruit_panel.clear_recrue()
	recruit_panel.set_message("%s rejoint l'équipage pour %s ¤ (salaire %d ¤/jour). Premier personnage = capitaine." % [c.nom, MAUtils.fmt_int(c.prix_recrutement), c.prix_journalier])
	refresh_all()

func refresh_all() -> void:
	ship_name_label.text = "Vaisseau : %s (%s) — %s" % [ship.nom, ship.modele, GalaxyData.coord_label(current_pos.x, current_pos.y)]
	credits_label.text = "Crédits : %s ¤" % MAUtils.fmt_int(credits)
	captain_label.text = "Capitaine : %s" % (captain.nom if captain != null else "—")
	for c in characters:
		if char_tokens.has(c):
			char_tokens[c].is_captain = c == captain
			char_tokens[c].refresh_name()
			char_tokens[c].refresh_health()
	rebuild_posts()
	crew_panel.set_characters(characters, captain)
	ship_panel.set_ship(ship)
	system_map.set_system(current_system)
	galaxy_map.current_pos = current_pos
	galaxy_map.queue_redraw()
	travel_info_label.text = "Radix : %s / %s PC · Vitesse : %d PC/j" % [MAUtils.fmt_int(ship.radix_pc), MAUtils.fmt_int(ship.autonomie_pc), ship.vitesse_hyper_pc_j]
	var dk := docked()
	var items: Array
	var titre: String
	if current_system != null and current_system.est_relais:
		items = ShopTables.STATION_RELAIS
		titre = "Commerce — station-relais %s (tarifs du comptoir OCG, GdM p125)" % current_system.nom
	else:
		items = ShopTables.CATALOGUE
		titre = "Commerce — planète %s (catalogue MdJ p234-243)" % (current_system.nom if current_system != null else "?")
	shop_panel.set_catalog(items, titre, credits, soute_used(), ship.soute, dk, cours_txt())
	ship_panel.set_context(cours_actuel(), marchandage_mod, dk, radix_unit_price())
	_update_info_label()
	_update_buttons()
