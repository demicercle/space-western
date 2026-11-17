class_name Main
extends Control

const POSTS := ["Pilote", "Vigie", "Ingénieur", "Canonnier", "Fusilier", "Cartographe / Historien"]
const TAB_COMMERCE := 4
const TAB_RECRUTER := 5

const SHIP_NAMES := ["La Guigne", "Black Pearl", "Vengeance", "L'Étoile Filante", "La Sirène", "Jolly Roger", "Faucon Noir", "La Glorieuse", "Mauvaise Fortune", "L'Épervier", "La Comète Noire", "Santa Maria"]

@onready var left_vbox: VBoxContainer = %LeftVBox
@onready var tabs: TabContainer = %Tabs
@onready var pause_button: Button = %PauseButton

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
var ship_body: Variant = null
var ship_orbite_us := 0.0
var ship_angle := 0.0
var game_seed := 0
var jours_ecoules := 0
var heure_jour := 0
var articles_trouves := {}
var corps_recherche: Variant = null

const SCAN_EXTRA := ["classe", "diametre", "atmosphere", "environnement", "eau", "gravite", "systeme_orbital", "commerce", "securite", "sources d'énergie", "satellites artificiels ou trafic aérien", "dégagements d'énergie typiques de combats spatiaux en orbite"]

static var _re_int := RegEx.create_from_string("[0-9]+")

const EFFACER_ARTICLES_QUAND_RECHERCHE := true

func _securite_planete() -> int:
	if ship_body == null:
		return 0
	var m := _re_int.search(str(ship_body.get("securite", "")))
	if m == null:
		return 0
	return int(m.get_string())

var galaxy_map: GalaxyMap
var system_map: SystemMap
var crew_panel: CrewPanel
var ship_panel: ShipPanel
var shop_panel: ShopPanel
var recruit_panel: RecruitPanel
var posts_container: VBoxContainer
var calendar_label: Label
var jours_label: Label
var ship_name_label: Label
var pos_label: Label
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
var voyage_dialog: AcceptDialog
var pending_voyage: Callable
var pending_virer: Character = null
var panel_style: StyleBoxFlat
var ship_health_label: Label
var ship_health_bar: ProgressBar
var radix_label: Label
var rations_label: Label
var itineraire_label: Label
var pause_menu: PopupMenu

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
	_build_pause_menu()
	pause_button.pressed.connect(_toggle_pause_menu)
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
	calendar_label = Label.new()
	calendar_label.add_theme_font_size_override("font_size", 13)
	calendar_label.add_theme_color_override("font_color", Color(0.75, 0.9, 1.0))
	left_vbox.add_child(calendar_label)
	jours_label = Label.new()
	jours_label.add_theme_font_size_override("font_size", 12)
	jours_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	left_vbox.add_child(jours_label)
	ship_name_label = Label.new()
	ship_name_label.add_theme_font_size_override("font_size", 16)
	ship_name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	left_vbox.add_child(ship_name_label)
	pos_label = Label.new()
	pos_label.add_theme_font_size_override("font_size", 12)
	pos_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	left_vbox.add_child(pos_label)
	var shb := VBoxContainer.new()
	shb.add_theme_constant_override("separation", 2)
	left_vbox.add_child(shb)
	ship_health_label = Label.new()
	ship_health_label.add_theme_font_size_override("font_size", 12)
	shb.add_child(ship_health_label)
	ship_health_bar = ProgressBar.new()
	ship_health_bar.min_value = 0
	ship_health_bar.max_value = 1
	ship_health_bar.value = 1
	ship_health_bar.show_percentage = false
	ship_health_bar.custom_minimum_size = Vector2(0, 10)
	shb.add_child(ship_health_bar)
	radix_label = Label.new()
	radix_label.add_theme_font_size_override("font_size", 12)
	radix_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	left_vbox.add_child(radix_label)
	rations_label = Label.new()
	rations_label.add_theme_font_size_override("font_size", 12)
	rations_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	left_vbox.add_child(rations_label)
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

func _on_tab_changed(t: int) -> void:
	if t == 1 and system_map.is_current_system and ship_body != null:
		system_map.select_body(ship_body)

func _build_tabs() -> void:
	tabs.tab_changed.connect(_on_tab_changed)
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
	galaxy_map.cell_right_clicked.connect(_on_cell_right_clicked)
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
	itineraire_label = Label.new()
	itineraire_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	itineraire_label.add_theme_font_size_override("font_size", 12)
	itineraire_label.add_theme_color_override("font_color", Color(0.65, 0.9, 0.75))
	side.add_child(itineraire_label)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 8)
	side.add_child(btns)
	plein_button = Button.new()
	plein_button.text = "Faire le plein"
	plein_button.pressed.connect(_on_faire_le_plein)
	btns.add_child(plein_button)
	calc_button = Button.new()
	calc_button.text = "Voyager"
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
	system_map.travel_requested.connect(_on_voyage_inter)
	system_map.scan_requested.connect(_on_scanner)

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
	shop_panel.search_requested.connect(_on_rechercher)
	shop_panel.sell_requested.connect(_on_sell)

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
	voyage_dialog = AcceptDialog.new()
	add_child(voyage_dialog)
	voyage_dialog.get_ok_button().text = "Oui"
	voyage_dialog.add_cancel_button("Non")
	voyage_dialog.confirmed.connect(_on_voyage_dialog_confirmed)

func _ask_voyage_confirm(text: String, action: Callable) -> void:
	pending_voyage = action
	voyage_dialog.dialog_text = text
	voyage_dialog.popup_centered()

func _info_popup(text: String) -> void:
	pending_voyage = Callable()
	voyage_dialog.dialog_text = text
	voyage_dialog.popup_centered()

func _on_voyage_dialog_confirmed() -> void:
	var a := pending_voyage
	pending_voyage = Callable()
	if a.is_valid():
		a.call()

func _build_pause_menu() -> void:
	pause_menu = PopupMenu.new()
	add_child(pause_menu)
	pause_menu.add_item("Quitter le jeu", 0)
	pause_menu.add_item("Relancer le jeu depuis le début", 1)
	pause_menu.add_check_item("Plein écran", 2)
	pause_menu.add_separator()
	pause_menu.add_item("Cheat : +1 000 €", 3)
	pause_menu.add_item("Cheat : +1 000 Radix", 4)
	pause_menu.add_item("Cheat : quick recruit (Pilote+Vigie+Ingénieur+Canonnier)", 5)
	pause_menu.add_item("Cheat : +100 rations", 6)
	pause_menu.add_item("Cheat : soin de groupe (tout l'équipage indemne)", 7)
	pause_menu.id_pressed.connect(_on_pause_id)

func _toggle_pause_menu() -> void:
	if pause_menu.visible:
		pause_menu.hide()
	else:
		pause_menu.set_item_checked(2, DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
		pause_menu.popup_centered()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k := event as InputEventKey
	if k.keycode == KEY_F1:
		_toggle_pause_menu()
		get_viewport().set_input_as_handled()
	elif k.keycode == KEY_TAB:
		var n := tabs.get_tab_count()
		for i in range(1, n + 1):
			var j := (tabs.current_tab + i) % n
			if not tabs.is_tab_disabled(j):
				tabs.current_tab = j
				break
		get_viewport().set_input_as_handled()
	elif k.keycode >= KEY_1 and k.keycode <= KEY_9:
		var t: int = k.keycode - KEY_1
		if t < tabs.get_tab_count() and not tabs.is_tab_disabled(t):
			tabs.current_tab = t
		get_viewport().set_input_as_handled()

func _on_pause_id(id: int) -> void:
	match id:
		0:
			get_tree().quit()
		1:
			if get_tree().current_scene != null:
				get_tree().reload_current_scene()
			else:
				get_tree().change_scene_to_file("res://main.tscn")
		2:
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		3:
			credits += 1000
			msg_label.text = "Cheat : +1 000 € (crédits : %s €)." % MAUtils.fmt_int(credits)
			refresh_all()
		4:
			ship.radix_pc = mini(ship.autonomie_pc, ship.radix_pc + 1000)
			msg_label.text = "Cheat : +1 000 Radix (réserve : %s / %s PC)." % [MAUtils.fmt_int(ship.radix_pc), MAUtils.fmt_int(ship.autonomie_pc)]
			refresh_all()
		5:
			_cheat_quick_recruit()
		6:
			ship.rations += 100
			ship.cargaison["Ration"] = ship.rations
			msg_label.text = "Cheat : +100 rations (total : %d)." % ship.rations
			refresh_all()
		7:
			for c in characters:
				c.pv = c.pv_max
			msg_label.text = "Cheat : soin de groupe — tout l'équipage est indemne."
			refresh_all()

func _cheat_quick_recruit() -> void:
	if characters.size() > 0:
		msg_label.text = "Quick recruit : l'équipage n'est pas vide."
		refresh_all()
		return
	var pi := Character.generate("Héros", "Premier rôle", "Pilote")
	pi.post_index = 0
	var vi: Character = null
	for i in range(200):
		var t := Character.generate("Héros", "Premier rôle")
		if t.get_comp("Senseurs") >= 2:
			vi = t
			break
	if vi == null:
		vi = Character.generate("Héros", "Premier rôle", "Pilote")
	vi.post_index = 1
	var ing := Character.generate("Héros", "Premier rôle", "Ingénieur / machiniste")
	ing.post_index = 2
	var ca := Character.generate("Héros", "Premier rôle", "Canonnier")
	ca.post_index = 3
	var total := 0
	for c in [pi, vi, ing, ca]:
		characters.append(c)
		make_token(c)
		total += c.prix_recrutement
	credits = maxi(0, credits - total)
	if captain == null:
		captain = characters[0]
	msg_label.text = "Quick recruit : %s (Pilote), %s (Vigie), %s (Ingénieur), %s (Canonnier) recrutés et postés — payé %s €." % [pi.nom, vi.nom, ing.nom, ca.nom, MAUtils.fmt_int(total)]
	refresh_all()

func _appliquer_sante_voyage(res: Dictionary) -> void:
	var T: Dictionary = res["resume"]
	var cons_r: int = int(T["rations"])
	var repas: int = int(ship.cargaison.get("Repas", 0))
	var total := ship.rations + repas
	var famine_j := maxi(0, cons_r - total)
	var use_repas := mini(repas, cons_r)
	var use_ration := mini(ship.rations, maxi(0, cons_r - repas))
	if use_repas > 0:
		T["repas_utilises"] = use_repas
		var reste_repas := repas - use_repas
		if reste_repas <= 0:
			ship.cargaison.erase("Repas")
		else:
			ship.cargaison["Repas"] = reste_repas
	ship.rations = maxi(0, ship.rations - use_ration)
	ship.cargaison["Ration"] = ship.rations
	T["famine_jours"] = famine_j
	var sante: Array = []
	if famine_j > 0:
		for c in characters:
			var av: int = c.pv
			c.pv = maxi(0, c.pv - 3 * famine_j)
			if c.pv != av:
				sante.append({"nom": c.nom, "avant": av, "apres": c.pv})
	T["sante_famine"] = sante
	var jours: int = int(res["jours_count"])
	var diff := 3 if characters.size() < nb_posts() else 2
	var soins: Array = []
	for c in characters:
		if c.post_index >= 0 or c.pv >= c.pv_max:
			continue
		var av: int = c.pv
		for j in range(jours):
			if c.pv >= c.pv_max:
				break
			var r := Dice.test(c.dice_test("Athlétisme"), diff)
			if r["ok"]:
				c.pv = mini(c.pv_max, c.pv + 1 + int(r["extra"]))
		if c.pv != av:
			soins.append({"nom": c.nom, "avant": av, "apres": c.pv})
	T["sante_soins"] = soins

func refresh_ship_health() -> void:
	if ship == null:
		return
	var col := Color(0.55, 0.9, 0.55)
	match ship.etat:
		"L":
			col = Color(0.9, 0.9, 0.4)
		"G":
			col = Color(1.0, 0.65, 0.3)
		"D":
			col = Color(1.0, 0.3, 0.3)
	ship_health_label.text = "Coque : %d/%d PV · %s%s" % [ship.structure_pv, ship.coque_pv, Ship.etat_txt(ship.etat), " — DÉTRUIT" if ship.detruit else ""]
	ship_health_label.add_theme_color_override("font_color", col)
	ship_health_bar.max_value = maxf(1.0, float(ship.coque_pv))
	ship_health_bar.value = clampf(float(ship.structure_pv), 0.0, ship_health_bar.max_value)

func rations_necessaires() -> int:
	if destination.x < 0 or ship == null:
		return characters.size()
	var jours := float(distance) / float(maxi(1, ship.vitesse_hyper_pc_j))
	var j_r := int(ceil(jours))
	if absf(jours - roundf(jours)) < 0.001:
		j_r = int(round(jours))
	return j_r * characters.size()

func rations_dispo() -> int:
	return ship.rations + int(ship.cargaison.get("Repas", 0))

func _itineraire_txt() -> String:
	if destination.x < 0 or ship == null:
		return "Aucun itinéraire tracé."
	var jours := float(distance) / float(maxi(1, ship.vitesse_hyper_pc_j))
	var j := int(jours)
	var h := int(round((jours - j) * 24.0))
	if h >= 24:
		j += 1
		h -= 24
	var duree := "%d j" % j
	if h > 0:
		duree += " %d h" % h
	if j == 0 and h == 0:
		duree = "moins d'une heure"
	var rations := rations_necessaires()
	var en_soute := rations_dispo()
	return "Itinéraire : %s PC · durée estimée : %s · rations nécessaires : %d (en soute : %d)" % [MAUtils.fmt_int(distance), duree, rations, en_soute]

func avancer_jours(n: int) -> void:
	jours_ecoules += maxi(0, n)

func avancer_heure(h: int) -> void:
	heure_jour += maxi(0, h)
	while heure_jour >= 25:
		heure_jour -= 25
		jours_ecoules += 1

func _start_game() -> void:
	game_seed = randi()
	ship = Ship.galactic_basic(MAUtils.pick(SHIP_NAMES))
	credits = 8000
	characters = []
	captain = null
	jours_ecoules = 0
	heure_jour = 0
	articles_trouves.clear()
	corps_recherche = null
	current_system = get_system(current_pos)
	ship_body = null
	ship_orbite_us = float(current_system.limite)
	ship_angle = 0.0
	for c in current_system.corps:
		if c["type"] == "planète" and str(c.get("nom", "")) == current_system.nom:
			ship_body = c
			break
	if ship_body == null:
		for c in current_system.corps:
			if c["type"] == "planète":
				ship_body = c
				break
	if ship_body != null:
		ship_orbite_us = float(ship_body["orbite"])
		ship_angle = current_system.angle_corps(ship_body)
	if ship_body != null and current_pos == GalaxyData.EXXALIA:
		ship_body["scan"] = {"ok": true, "astroport": true, "infos": ["astroport"]}
	refresh_all()
	if ship_body != null:
		system_map.select_body(ship_body)

func get_system(cell: Vector2i) -> StarSystem:
	var key := "%d,%d" % [cell.x, cell.y]
	if systems_cache.has(key):
		return systems_cache[key]
	seed(int(hash("%d|%d|%d" % [game_seed, cell.x, cell.y])))
	var s: StarSystem
	var named: Variant = GalaxyData.named_at(cell.x, cell.y)
	if cell == GalaxyData.EXXALIA:
		s = FixedSystems.exxalia()
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
	if current_system == null or ship_body == null:
		return false
	return ship_body["type"] == "planète" or ship_body["type"] == "station"

func soute_used() -> float:
	var u := 0.0
	for k in ship.cargaison.keys():
		u += ShopTables.place_de(k) * float(ship.cargaison[k])
	return u

func cours_actuel() -> Dictionary:
	if ship_body != null and ship_body.has("cours"):
		return StarSystem.parse_cours(str(ship_body["cours"]))
	if current_system != null:
		return current_system.cours_dict()
	return {"A": 1.0, "B": 1.0, "C": 1.0}

func cours_txt() -> String:
	var c := cours_actuel()
	return "A ×%s · B ×%s · C ×%s" % [MAUtils.fmt_num(c["A"]), MAUtils.fmt_num(c["B"]), MAUtils.fmt_num(c["C"])]

func radix_unit_price() -> float:
	return ship.tonnage * (1.5 if current_system != null and current_system.est_relais else 0.75)

func _on_buy(it: Dictionary) -> void:
	var prix := ShopTables.prix_achat(it, cours_actuel())
	var place: float = float(it["place"])
	if not peut_commercer():
		shop_panel.set_message("Commerce indisponible ici : corps non scanné, aucun astroport détecté ou cours ×0.")
		return
	if prix < 0:
		shop_panel.set_message("Achat impossible ici : cours ×0 pour la catégorie %s (%s)." % [str(it.get("dispo", "?")), str(it["nom"])])
		return
	if credits < prix:
		shop_panel.set_message("Crédits insuffisants pour %s (%s €)." % [it["nom"], MAUtils.fmt_int(prix)])
		return
	if soute_used() + place > ship.soute + 0.0001:
		shop_panel.set_message("Plus de place en soute pour %s." % it["nom"])
		return
	credits -= prix
	ship.cargaison[it["nom"]] = int(ship.cargaison.get(it["nom"], 0)) + 1
	if it["nom"] == "Ration":
		ship.rations = int(ship.cargaison["Ration"])
	shop_panel.set_message("Acheté : %s pour %s € (%d en soute)." % [it["nom"], MAUtils.fmt_int(prix), int(ship.cargaison[it["nom"]])])
	refresh_all()

func _on_sell(nom: String) -> void:
	if not peut_commercer():
		ship_panel.set_message("Vente indisponible ici : corps non scanné, aucun astroport détecté ou cours ×0.")
		return
	if not ship.cargaison.has(nom) or int(ship.cargaison[nom]) <= 0:
		return
	var prix := ship_panel.prix_vente_unit(nom)
	if prix <= 0:
		ship_panel.set_message("%s est invendable ici (cours ×0 pour sa catégorie)." % nom)
		return
	credits += prix
	ship.cargaison[nom] = int(ship.cargaison[nom]) - 1
	if int(ship.cargaison[nom]) <= 0:
		ship.cargaison.erase(nom)
	if nom == "Ration":
		ship.rations = int(ship.cargaison.get("Ration", 0))
	ship_panel.set_message("Vendu : 1 × %s pour %s €." % [nom, MAUtils.fmt_int(prix)])
	refresh_all()

func body_scan_ok() -> bool:
	if ship_body == null:
		return false
	var sc: Variant = ship_body.get("scan", null)
	if sc == null or not bool(sc.get("ok", false)):
		return false
	return bool(sc.get("astroport", false))

func peut_commercer() -> bool:
	if not docked() or not body_scan_ok():
		return false
	var c := cours_actuel()
	return float(c["A"]) > 0.0 or float(c["B"]) > 0.0 or float(c["C"]) > 0.0

func peut_recruter() -> bool:
	if not docked() or not body_scan_ok():
		return false
	return ship_body["type"] == "station" or bool(ship_body.get("habitee", false))

func _scan_roller() -> Character:
	for c in characters:
		if c.post_index == 1:
			return c
	var best: Character = null
	var best_v := -1
	for c in characters:
		var v: int = c.dice_test("Senseurs")
		if v > best_v:
			best_v = v
			best = c
	return best

func _on_scanner() -> void:
	if ship_body == null or current_system == null:
		return
	var sb: Dictionary = ship_body
	var sc0: Variant = sb.get("scan", null)
	var had_ok: bool = sc0 != null and bool(sc0.get("ok", false))
	var roller: Character = _scan_roller()
	if roller == null:
		system_map.set_message("Scan impossible : aucun personnage avec Senseurs à bord.")
		return
	avancer_heure(1)
	var m := _sante_mod(roller)
	var r := Dice.test(roller.dice_test("Senseurs") + int(m[0]), 2, str(m[1]))
	var bb := "[b][color=gold]Scan de %s[/color][/b] (%s, %d h) — Senseurs de %s : %s (diff 2) — total : %d succès\n" % [str(sb.get("nom", "?")), MAUtils.galdate(jours_ecoules), heure_jour, roller.nom, Dice.fmt_jet(r), int(r["succ"])]
	var infos: Array = []
	if had_ok:
		infos = sc0["infos"].duplicate()
	var astro := false
	if r["ok"]:
		astro = sb["type"] == "station"
		if not astro:
			var ap: String = str(sb.get("astroport", ""))
			astro = ap != "" and not ap.begins_with("aucun")
		if not infos.has("astroport"):
			infos.append("astroport")
		var extra: int = int(r["extra"])
		var nouvelles: Array = []
		var restantes: Array = []
		for k in SCAN_EXTRA:
			if not infos.has(k):
				restantes.append(k)
		restantes.shuffle()
		for i in range(mini(extra, restantes.size())):
			infos.append(restantes[i])
			nouvelles.append(restantes[i])
		sb["scan"] = {"ok": true, "astroport": astro, "infos": infos}
		bb += "[color=7bed9f]Scan réussi[/color] — astroport %s et sa fréquence radio (commerce/recrutement autorisés si cours > 0).\n" % ("détecté" if astro else "NON détecté sur ce corps")
		if nouvelles.size() > 0:
			bb += "+%d succès excédentaire(s) → nouvelles infos : %s\n" % [extra, ", ".join(nouvelles)]
		else:
			bb += "(aucune info supplémentaire : tout est déjà révélé)\n"
		bb += "Infos révélées au total (%d) : %s\n" % [infos.size(), ", ".join(infos)]
	else:
		if not had_ok:
			sb["scan"] = {"ok": false, "astroport": false, "infos": []}
			bb += "[color=ff5544]Scan échoué[/color] — 1 h écoulée, rescan possible.\n"
		else:
			bb += "[color=ff5544]Scan échoué[/color] — 1 h écoulée (infos précédentes conservées).\n"
	system_map.append_journal(bb)
	if r["ok"] and astro:
		system_map.set_message("Scan OK : astroport détecté sur %s — commerce et recrutement disponibles." % str(sb.get("nom", "?")))
	elif r["ok"]:
		system_map.set_message("Scan OK : aucun astroport sur %s — commerce/recrutement indisponibles ici." % str(sb.get("nom", "?")))
	else:
		system_map.set_message("Scan échoué sur %s (1 h écoulée) — rescan possible." % str(sb.get("nom", "?")))
	refresh_all()
func _on_rechercher() -> void:
	if not peut_commercer():
		shop_panel.set_message("Recherche impossible : scannez ce corps (bouton « Scanner ») et détectez un astroport, avec au moins un cours > 0.")
		return
	if current_system != null and current_system.est_relais:
		shop_panel.set_message("Comptoir OCG de la station-relais : tarifs fixes, pas besoin de chercher.")
		return
	if captain == null:
		shop_panel.set_message("Pas de capitaine désigné pour mener la recherche.")
		return
	if EFFACER_ARTICLES_QUAND_RECHERCHE:
		articles_trouves.clear()
	var sb: Dictionary = ship_body
	var cours := cours_actuel()
	var com: String = str(sb.get("commerce", "")).to_lower()
	var est_carrefour := com.contains("carrefour")
	var est_pauvre := com.contains("pauvre")
	var est_primitive := com.contains("primitive")
	var liste: Array = ShopTables.CATALOGUE + ShopTables.MARCHANDISES
	var tests := 0
	var nouveaux := 0
	var log := ""
	for it in liste:
		var nom: String = str(it["nom"])
		var dispo: String = str(it.get("dispo", "C"))
		var c: float = float(cours.get(dispo, 1.0))
		if c <= 0.0:
			continue
		if articles_trouves.has(nom):
			continue
		var base_prix: int = ShopTables.prix_achat(it, cours)
		var illegal := ShopTables.est_illegal(it)
		var comp_key := "Illégalités" if illegal else "Commerce"
		if dispo == "C" and base_prix <= 10:
			articles_trouves[nom] = true
			nouveaux += 1
			log += "  [color=7bed9f]Trouvé : %s[/color] — dispo C et prix ≤ 10 € : trouvé automatiquement : [b]%s €[/b]\n" % [nom, MAUtils.fmt_int(base_prix)]
			continue
		tests += 1
		var diff: int = int(round(c * 2.0))
		var nd: int = captain.dice_test(comp_key)
		var mods := ""
		var mode := "normal"
		if est_primitive:
			mode = "TD"
			mods += " (TD : planète primitive)"
		if est_carrefour:
			nd += 1
			mods += " +1d (carrefour)"
		if dispo == "C":
			mode = "TF"
			mods += " (TF, dispo C)"
		if dispo == "A":
			diff += 1
			mods += " D+1 (dispo A)"
		var cat: String = str(it.get("cat", ""))
		if (cat == "Technologie militaire" or cat == "Technologie spatiale") and base_prix > 100:
			diff += 1
			mods += " D+1 (%s, prix > 100 €)" % cat.to_lower()
		if est_pauvre:
			diff += 1
			mods += " D+1 (planète pauvre)"
		var r := Dice.test(nd, diff, mode)
		if illegal:
			var secu := _securite_planete()
			if secu > 0:
				var rs := Dice.test(secu, 1)
				if int(rs["succ"]) > int(r["succ"]):
					log += "  [color=ff5544]Recherche repérée par la sécurité[/color] — patrouille (%d dés : %s = %d succès) bat le test d'Illégalités de %s (%s = %d succès) : %s non trouvé\n" % [secu, Dice.fmt_jet(rs), int(rs["succ"]), nom, Dice.fmt_jet(r), int(r["succ"]), nom]
					continue
		if not r["ok"]:
			continue
		articles_trouves[nom] = true
		nouveaux += 1
		var tag := " [color=ff9966](illégal)[/color]" if illegal else ""
		log += "  [color=7bed9f]Trouvé : %s[/color]%s — %s %s (diff %d%s) : OK : [b]%s €[/b] (base × cours)\n" % [nom, tag, comp_key, Dice.fmt_jet(r), diff, mods, MAUtils.fmt_int(base_prix)]
	corps_recherche = ship_body
	avancer_jours(1)
	refresh_all()
	var msg_rech := "Recherche d'articles à %s (%s) : %d test(s), +1 jour (durée « Faire ses courses », MdJ p271) — calendrier %s (année %d, %d jour(s) écoulé(s)) — %d nouvel article(s), %d au total." % [str(sb.get("nom", "?")), str(sb.get("commerce", "?")), tests, MAUtils.galdate(jours_ecoules), MAUtils.annee_galactique(jours_ecoules), jours_ecoules, nouveaux, articles_trouves.size()]
	if EFFACER_ARTICLES_QUAND_RECHERCHE:
		msg_rech += " (recherche précédente effacée)"
	shop_panel.set_message(msg_rech)
	if log != "":
		journal.text += "\n[b][color=gold]Recherche d'articles — %s, %s (année %d)[/color][/b]\n" % [MAUtils.galdate(jours_ecoules), str(sb.get("nom", "?")), MAUtils.annee_galactique(jours_ecoules)] + log

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
	var cell := Vector2i(col, row)
	galaxy_map.selected_cell = cell
	if cell == current_pos:
		destination = Vector2i(-1, -1)
		distance = 0
	else:
		destination = cell
		distance = GalaxyData.distance_pc(current_pos, destination)
	galaxy_map.destination = destination
	galaxy_map.queue_redraw()
	msg_label.text = ""
	_update_info_label()
	_update_buttons()
	_update_system_tab()

func _on_cell_right_clicked(col: int, row: int) -> void:
	var cell := Vector2i(col, row)
	galaxy_map.selected_cell = cell
	destination = Vector2i(-1, -1)
	distance = 0
	galaxy_map.destination = destination
	galaxy_map.queue_redraw()
	msg_label.text = ""
	_update_info_label()
	_update_buttons()
	_update_system_tab()
	tabs.current_tab = 1

func _update_system_tab() -> void:
	var sel := galaxy_map.selected_cell
	if sel.x < 0:
		sel = current_pos
	var showing_current := sel == current_pos
	system_map.set_system(get_system(sel))
	system_map.is_current_system = showing_current
	if showing_current:
		system_map.set_ship_pos(ship_orbite_us, ship_angle, ship_body)
	else:
		system_map.set_ship_pos(-1.0, 0.0, null)

func _sante_mod(c: Character) -> Array:
	var idx := c.sante_index()
	if idx == 1:
		return [1, ""]
	if idx == 2:
		return [0, "TD"]
	if idx == 3:
		return [0, "dead"]
	return [0, ""]

func _blocage_sante() -> String:
	for c in characters:
		if c.post_index >= 0 and (post_name_static(c.post_index) == "Pilote" or post_name_static(c.post_index) == "Vigie") and c.sante_index() >= 3:
			return "\n/!\\ %s est « Mort? » : voyage impossible tant qu'il n'est pas remplacé." % c.nom
	return ""

func can_travel() -> bool:
	var has_pilot := false
	var has_vigie := false
	for c in characters:
		if c.post_index < 0:
			continue
		match post_name_static(c.post_index):
			"Pilote":
				if c.sante_index() >= 3:
					return false
				has_pilot = true
			"Vigie":
				if c.sante_index() >= 3:
					return false
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
		itineraire_label.text = _itineraire_txt()
		return
	var dest_sys := get_system(destination)
	var named: Variant = GalaxyData.named_at(destination.x, destination.y)
	var dest_name: String = named["nom"] if named != null else "case inconnue"
	var extra := ""
	if not can_travel():
		extra = "\n/!\\ Voyager exige un Pilote ET une Vigie à leur poste." + _blocage_sante()
	info_label.text = "%s\nDestination : %s — %s (%s)\nDistance : %s PC (1 case = 1 000 PC) · Vitesse : %d PC/j · Route : %s%s" % [
		pos_txt,
		dest_name, GalaxyData.coord_label(destination.x, destination.y), GalaxyData.coord_text(destination.x, destination.y),
		MAUtils.fmt_int(distance), ship.vitesse_hyper_pc_j, dest_sys.route, extra,
	]
	itineraire_label.text = _itineraire_txt()

func _update_buttons() -> void:
	var dk := docked()
	plein_button.disabled = not dk or ship.radix_pc >= ship.autonomie_pc
	calc_button.disabled = destination.x < 0 or not can_travel()
	recruit_panel.set_enabled_state(peut_recruter(), credits, characters.size(), ship.passagers_max)
	if not dk:
		shop_panel.set_message("Commerce impossible, trouvez une station-relais ou une planète commerciale.")
	elif not body_scan_ok():
		shop_panel.set_message("Commerce impossible : scannez ce corps (bouton « Scanner » dans la carte de système) pour détecter un astroport.")
	elif not peut_commercer():
		shop_panel.set_message("Commerce impossible ici : cours A/B/C tous à ×0 sur ce corps.")

func _post_skills() -> Dictionary:
	var sk := {"pi": 0, "na": 0, "se": 0, "ss": 0, "ing": 0, "cae": 0, "carto": 0, "dpi": 0, "mpi": "", "dna": 0, "mna": "", "dse": 0, "mse": "", "dss": 0, "mss": "", "ding": 0, "ming": "", "dae": 0, "mae": "", "dca": 0, "mca": ""}
	for c in characters:
		if c.post_index < 0:
			continue
		var m := _sante_mod(c)
		match post_name_static(c.post_index):
			"Pilote":
				sk["pi"] = c.dice_test("Pilotage")
				sk["na"] = c.dice_test("Navigation")
				sk["dpi"] = m[0]
				sk["mpi"] = m[1]
				sk["dna"] = m[0]
				sk["mna"] = m[1]
			"Vigie":
				sk["se"] = c.dice_test("Senseurs")
				sk["ss"] = c.dice_test("Sciences stellaires")
				sk["dse"] = m[0]
				sk["mse"] = m[1]
				sk["dss"] = m[0]
				sk["mss"] = m[1]
			"Ingénieur":
				sk["ing"] = c.dice_test("Ingénierie")
				sk["ding"] = m[0]
				sk["ming"] = m[1]
			"Canonnier":
				sk["cae"] = c.dice_test("Armes embarquées")
				sk["dae"] = m[0]
				sk["mae"] = m[1]
			"Cartographe / Historien":
				sk["carto"] = c.dice_test("Cartographie")
				if sk["carto"] == 0:
					sk["carto"] = maxi(c.dice_test("Navigation"), c.dice_test("Histoire"))
				sk["dca"] = m[0]
				sk["mca"] = m[1]
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
		msg_label.text = "Plein effectué : +%s PC pour %s €." % [MAUtils.fmt_int(missing), MAUtils.fmt_int(cost)]
	else:
		var afford := int(credits / unit_price)
		if afford <= 0:
			msg_label.text = "Crédits insuffisants pour acheter du Radix (%s €/1 000 PC)." % MAUtils.fmt_num(unit_price)
			return
		var add := afford * 1000
		ship.radix_pc += add
		credits -= int(round(afford * unit_price))
		msg_label.text = "Plein partiel : +%s PC pour %s €." % [MAUtils.fmt_int(add), MAUtils.fmt_int(afford * unit_price)]
	refresh_all()

func _appliquer_consos(res: Dictionary) -> void:
	if res["suivi_reserve"]:
		ship.radix_pc = int(round(res["reserve"]))
	_appliquer_sante_voyage(res)
	var pieces_used: int = res["resume"].get("pieces_used", 0)
	if pieces_used > 0:
		var dispo: int = int(ship.cargaison.get("Pièces détachées (1 kg)", 0))
		ship.cargaison["Pièces détachées (1 kg)"] = maxi(0, dispo - pieces_used)
		if int(ship.cargaison["Pièces détachées (1 kg)"]) == 0:
			ship.cargaison.erase("Pièces détachées (1 kg)")
	for deg in res["resume"]["degats"]:
		if str(deg).contains("PC"):
			continue
		ship.subir_degats(str(deg))

func _resume_inter(res: Dictionary, nom_dep: String, di: Dictionary) -> String:
	var T: Dictionary = res["resume"]
	var bb := "[b]Départ de %s vers la limite de saut[/b] : %s US (tableau des distances : 1d6 = %d%s) · %d jour(s) en subluminal.\n" % [nom_dep, MAUtils.fmt_num(di["dist"]), int(di["de"]), ", autre côté du soleil" if di["autre_cote"] else "", int(res["jours_count"])]
	bb += "Périls interplanétaires : %d (%d évités, %d subis) · Pannes : %d (%d réparées) · Relevés : %d\n" % [T["perils"].size(), T["evites"], T["subis"], T["pannes"], T["reparees"], T["releves"]]
	if T["degats"].size() > 0:
		bb += "Dégâts subis : " + " ; ".join(T["degats"]) + "\n"
	bb += "Radix consommé : %s PC · Rations consommées : %d\n" % [MAUtils.fmt_num(T["radix_pc"]), int(T["rations"])]
	if res["a_sec"]:
		bb += "[color=ff5544]Panne sèche pendant le trajet vers la limite de saut.[/color]\n"
	return bb

func _on_calc_voyage() -> void:
	if destination.x < 0 or not can_travel():
		return
	_check_voyage_gal()

func _check_voyage_gal() -> void:
	if ship.radix_pc <= 0:
		_info_popup("Voyage impossible : pas de Radix en réserve (0 / %s PC)." % MAUtils.fmt_int(ship.autonomie_pc))
		return
	var besoin_r: int = rations_necessaires()
	if rations_dispo() < besoin_r:
		_ask_voyage_confirm("Rations insuffisantes (%d en soute pour %d nécessaires) — êtes-vous sûr de vouloir faire cela ?" % [rations_dispo(), besoin_r], _check_radix_gal)
		return
	_check_radix_gal()

func _check_radix_gal() -> void:
	if ship.radix_pc < distance:
		_ask_voyage_confirm("Réserve de Radix insuffisante (%s PC en réserve pour %s PC de trajet) — êtes-vous sûr de vouloir faire cela ?" % [MAUtils.fmt_int(ship.radix_pc), MAUtils.fmt_int(distance)], _do_calc_voyage)
		return
	_do_calc_voyage()

func _do_calc_voyage() -> void:
	calc_button.disabled = true
	var sk := _post_skills()
	var dest_sys := get_system(destination)
	var route_key := "g" if dest_sys.route == "Route galactique" else ("c" if dest_sys.route == "Route commerciale" else "x")
	var prelude := ""
	var jours_total := 0
	if ship_body != null and current_system != null:
		var body_dep: Dictionary = ship_body
		var di := StarSystem.distance_inter(ship_orbite_us, float(current_system.limite))
		var rk0 := "g" if current_system.route == "Route galactique" else ("c" if current_system.route == "Route commerciale" else "x")
		var cfg0 := {
			"mode": "inter",
			"distance": di["dist"],
			"vitesse": ship.vitesse_croisiere_us_j,
			"route_key": rk0,
			"dep_orbite": ship_orbite_us,
			"arr_orbite": float(current_system.limite),
			"arr_nom": "limite de saut",
			"p1pi": sk["pi"], "p1na": sk["na"], "p2pi": sk["pi"], "p2na": sk["na"],
			"v1se": sk["se"], "v1ss": sk["ss"], "v2se": sk["se"], "v2ss": sk["ss"],
			"cae": sk["cae"], "ing": sk["ing"], "carto": sk["carto"],
			"dpi": sk["dpi"], "mpi": sk["mpi"], "dna": sk["dna"], "mna": sk["mna"],
			"dse": sk["dse"], "mse": sk["mse"], "dss": sk["dss"], "mss": sk["mss"],
			"dae": sk["dae"], "mae": sk["mae"], "ding": sk["ding"], "ming": sk["ming"],
			"dca": sk["dca"], "mca": sk["mca"],
			"equip": characters.size(),
			"passagers": 0,
			"tonnage": ship.tonnage,
			"radix_reserve": ship.radix_pc,
			"myst": false,
			"pieces": int(ship.cargaison.get("Pièces détachées (1 kg)", 0)),
		}
		var res0 := TravelSim.simulate(cfg0)
		_appliquer_consos(res0)
		jours_total += int(res0["jours_count"])
		prelude = _resume_inter(res0, str(body_dep.get("nom", "?")), di)
		ship_body = null
		ship_orbite_us = float(current_system.limite)
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
		"dpi": sk["dpi"], "mpi": sk["mpi"], "dna": sk["dna"], "mna": sk["mna"],
		"dse": sk["dse"], "mse": sk["mse"], "dss": sk["dss"], "mss": sk["mss"],
		"dae": sk["dae"], "mae": sk["mae"], "ding": sk["ding"], "ming": sk["ming"],
		"dca": sk["dca"], "mca": sk["mca"],
		"equip": characters.size(),
		"passagers": 0,
		"tonnage": ship.tonnage,
		"radix_reserve": ship.radix_pc,
		"myst": dest_sys.route == "Mystérieux",
		"pieces": int(ship.cargaison.get("Pièces détachées (1 kg)", 0)),
	}
	var res := TravelSim.simulate(cfg)
	_appliquer_consos(res)
	jours_total += int(res["jours_count"])
	avancer_jours(jours_total)
	articles_trouves.clear()
	corps_recherche = null
	var sal: int = salaire_jour() * jours_total
	credits = maxi(0, credits - sal)
	_render_journal(res, dest_sys, sal, prelude)
	if res["arrivee"]:
		var old := current_pos
		var pd := galaxy_map.cell_center(old.x, old.y)
		var pa := galaxy_map.cell_center(destination.x, destination.y)
		ship_angle = atan2(pa.y - pd.y, pa.x - pd.x)
		current_pos = destination
		current_system = dest_sys
		ship_body = null
		ship_orbite_us = float(dest_sys.limite)
		if not galaxy_map.explored.has(destination):
			galaxy_map.explored.append(destination)
		msg_label.text = "Arrivé à %s (%s)." % [dest_sys.nom, GalaxyData.coord_label(destination.x, destination.y)]
	elif res["a_sec"] and res["case_finale"] != null:
		var old := current_pos
		var cf: Vector2i = res["case_finale"]
		var pd := galaxy_map.cell_center(old.x, old.y)
		var pa := galaxy_map.cell_center(cf.x, cf.y)
		ship_angle = atan2(pa.y - pd.y, pa.x - pd.x)
		current_pos = cf
		current_system = get_system(current_pos)
		ship_body = null
		ship_orbite_us = float(current_system.limite)
		msg_label.text = "Panne sèche — position relevée : %s." % GalaxyData.coord_label(current_pos.x, current_pos.y)
	for c in res["resume"]["cases_relees"]:
		if not galaxy_map.explored.has(c):
			galaxy_map.explored.append(c)
	destination = Vector2i(-1, -1)
	galaxy_map.destination = destination
	refresh_all()

func _on_voyage_inter(body: Dictionary) -> void:
	if body == null or current_system == null:
		return
	if system_map.sys != current_system:
		var col := GalaxyData.col_of(system_map.sys.quad_x)
		var row := int(system_map.sys.quad_y)
		if col > 0:
			var cell := Vector2i(col, row)
			galaxy_map.selected_cell = cell
			destination = cell
			distance = GalaxyData.distance_pc(current_pos, destination)
			galaxy_map.destination = destination
			galaxy_map.queue_redraw()
			tabs.current_tab = 0
			msg_label.text = "Itinéraire calculé vers %s (%s) — cliquez sur « Voyager »." % [system_map.sys.nom, GalaxyData.coord_label(col, row)]
			system_map.set_message("Système %s : itinéraire tracé sur la carte galactique." % system_map.sys.nom)
			_update_info_label()
			_update_buttons()
			_update_system_tab()
		return
	if not can_travel():
		system_map.set_message("Voyage interplanétaire impossible : il faut un Pilote ET une Vigie à leur poste.")
		return
	var dep_o := ship_orbite_us
	var arr_o := float(body["orbite"])
	var di: Variant = system_map.selected_dist
	if di == null or system_map.selected_body != body:
		di = StarSystem.distance_inter(dep_o, arr_o)
	var dist: float = di["dist"]
	if dist < 0.0001:
		system_map.set_message("Le vaisseau est déjà à la hauteur de %s." % str(body.get("nom", "?")))
		return
	_check_voyage_inter(body, dist)

func _check_voyage_inter(body: Dictionary, dist: float) -> void:
	if ship.radix_pc <= 0:
		_info_popup("Voyage impossible : pas de Radix en réserve (0 PC).")
		return
	var jours_est := dist / float(maxi(1, ship.vitesse_croisiere_us_j))
	var besoin_r := int(ceil(jours_est)) * characters.size()
	if rations_dispo() < besoin_r:
		_ask_voyage_confirm("Rations insuffisantes (%d en soute pour %d nécessaires) — êtes-vous sûr de vouloir faire cela ?" % [rations_dispo(), besoin_r], func() -> void: _do_voyage_inter(body, dist))
		return
	_do_voyage_inter(body, dist)

func _do_voyage_inter(body: Dictionary, dist: float) -> void:
	var dep_o := ship_orbite_us
	var arr_o := float(body["orbite"])
	var sk := _post_skills()
	var route_key := "g" if current_system.route == "Route galactique" else ("c" if current_system.route == "Route commerciale" else "x")
	var cfg := {
		"mode": "inter",
		"distance": dist,
		"vitesse": ship.vitesse_croisiere_us_j,
		"route_key": route_key,
		"dep_orbite": dep_o,
		"arr_orbite": arr_o,
		"arr_nom": str(body.get("nom", "?")),
		"p1pi": sk["pi"], "p1na": sk["na"], "p2pi": sk["pi"], "p2na": sk["na"],
		"v1se": sk["se"], "v1ss": sk["ss"], "v2se": sk["se"], "v2ss": sk["ss"],
		"cae": sk["cae"], "ing": sk["ing"], "carto": sk["carto"],
		"dpi": sk["dpi"], "mpi": sk["mpi"], "dna": sk["dna"], "mna": sk["mna"],
		"dse": sk["dse"], "mse": sk["mse"], "dss": sk["dss"], "mss": sk["mss"],
		"dae": sk["dae"], "mae": sk["mae"], "ding": sk["ding"], "ming": sk["ming"],
		"dca": sk["dca"], "mca": sk["mca"],
		"equip": characters.size(),
		"passagers": 0,
		"tonnage": ship.tonnage,
		"radix_reserve": ship.radix_pc,
		"myst": false,
		"pieces": int(ship.cargaison.get("Pièces détachées (1 kg)", 0)),
	}
	var res := TravelSim.simulate(cfg)
	_appliquer_consos(res)
	avancer_jours(int(res["jours_count"]))
	articles_trouves.clear()
	corps_recherche = null
	var sal: int = salaire_jour() * int(res["jours_count"])
	credits = maxi(0, credits - sal)
	if res["arrivee"]:
		ship_body = body
		ship_orbite_us = arr_o
		ship_angle = current_system.angle_corps(body)
		if tabs.current_tab == 1:
			system_map.select_body(body)
		system_map.set_message("Arrivé à %s (orbite %d US)." % [str(body.get("nom", "?")), int(arr_o)])
	elif res["a_sec"]:
		var parc := dist - float(res["restant"])
		var signe := 1.0 if arr_o >= dep_o else -1.0
		ship_orbite_us = dep_o + signe * parc
		ship_body = null
		res["orbite_finale"] = ship_orbite_us
		system_map.set_message("Panne sèche à l'orbite %s US (reste %s US)." % [MAUtils.fmt_num(ship_orbite_us), MAUtils.fmt_num(float(res["restant"]))])
	else:
		system_map.set_message("Voyage interrompu (reste %s US)." % MAUtils.fmt_num(float(res["restant"])))
	_render_journal(res, current_system, sal)
	refresh_all()

func _render_journal(res: Dictionary, dest_sys: StarSystem, sal_total: int, prelude := "") -> void:
	var geo: bool = res["cfg"].get("dep", null) != null
	var hyper: bool = res["cfg"].get("mode", "hyper") == "hyper"
	var unite := "PC" if hyper else "US"
	var bb := ""
	if geo:
		var dep: Vector2i = res["cfg"]["dep"]
		var arr: Vector2i = res["cfg"]["arr"]
		bb = "[b][color=gold]Voyage : %s → %s[/color][/b]\n" % [GalaxyData.coord_label(dep.x, dep.y), GalaxyData.coord_label(arr.x, arr.y)]
	else:
		bb = "[b][color=gold]Voyage interplanétaire : orbite %s US → %s (orbite %s US)[/color][/b]\n" % [MAUtils.fmt_num(float(res["cfg"].get("dep_orbite", 0.0))), str(res["cfg"].get("arr_nom", "?")), MAUtils.fmt_num(float(res["cfg"].get("arr_orbite", 0.0)))]
	bb += "Distance : %s %s · Vitesse : %d %s/j · Route : %s (péril %s/jour)\n" % [MAUtils.fmt_num(float(res["cfg"]["distance"])), unite, int(res["cfg"]["vitesse"]), unite, dest_sys.route, {"g": "1/8", "c": "1/4"}.get(res["cfg"]["route_key"], "1/2")]
	if hyper and res["saut"] != null:
		var s = res["saut"]
		bb += "Calcul du saut : Pilote %d, Navigation +%d (%s) : %d tentative(s) = %s, %d succès excédentaire(s) retranché(s) du premier jet de péril.\n" % [s["pilote"], s["na"], "TD" if s["mode"] == "TD" else "normal", s["essais"], TravelSim.heure_txt(s["heures"]), s["exc"]]
	elif hyper:
		bb += "Calcul du saut : aucun Pilote avec Navigation à bord — saut non simulé.\n"
	if prelude != "":
		bb += "[color=cyan]" + prelude + "[/color]\n"
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
		if geo and res["case_finale"] != null:
			bb += "[color=ff5544]Panne sèche le jour %d[/color] — position relevée : %s.\n" % [res["jour_sec"], GalaxyData.coord_label(res["case_finale"].x, res["case_finale"].y)]
		else:
			bb += "[color=ff5544]Panne sèche le jour %d[/color] — arrêt à l'orbite %s US.\n" % [res["jour_sec"], MAUtils.fmt_num(float(res.get("orbite_finale", 0.0)))]
	else:
		bb += "Voyage interrompu après %d jour(s), reste %s %s.\n" % [res["jours_count"], MAUtils.fmt_num(res["restant"]), unite]
	bb += "Périls : %d (%d évités, %d subis) · Pannes : %d (%d réparées) · Retards : %d · Relevés : %d\n" % [T["perils"].size(), T["evites"], T["subis"], T["pannes"], T["reparees"], T["retards"], T["releves"]]
	if T["degats"].size() > 0:
		bb += "Dégâts subis : " + " ; ".join(T["degats"]) + "\n"
	if T["majeurs"].size() > 0:
		bb += "Événements majeurs : " + " ; ".join(T["majeurs"]) + "\n"
	bb += "Radix consommé : %s PC (réserve restante : %s / %s PC) · Rations consommées : %d (reste %d)\n" % [MAUtils.fmt_num(T["radix_pc"]), MAUtils.fmt_int(ship.radix_pc), MAUtils.fmt_int(ship.autonomie_pc), T["rations"], ship.rations]
	if int(T.get("repas_utilises", 0)) > 0:
		bb += "Repas consommés en priorité comme rations : %d (reste %s).\n" % [int(T["repas_utilises"]), MAUtils.fmt_int(int(ship.cargaison.get("Repas", 0)))]
	if T["rations"] > 0 and ship.rations == 0:
		bb += "[color=ff5544]Famine à bord : les rations sont épuisées ![/color]\n"
	if int(T.get("famine_jours", 0)) > 0:
		bb += "[color=ff5544]Privation : %d jour(s) sans manger — 3L par personne et par jour (ignore la protection).[/color]\n" % int(T["famine_jours"])
		for s in T.get("sante_famine", []):
			bb += "  %s : %d → %d PV\n" % [s["nom"], s["avant"], s["apres"]]
	var soins: Array = T.get("sante_soins", [])
	if soins.size() > 0:
		bb += "[color=7bed9f]Guérison naturelle (personnages sans poste, test d'Athlétisme) :[/color]\n"
		for s in soins:
			bb += "  %s : %d → %d PV\n" % [s["nom"], s["avant"], s["apres"]]
	bb += "Salaires de l'équipage : %d €/jour × %d jour(s) = %s € — crédits restants : %s €\n" % [salaire_jour(), res["jours_count"], MAUtils.fmt_int(sal_total), MAUtils.fmt_int(credits)]
	if int(T.get("pieces_used", 0)) > 0:
		bb += "Pièces détachées consommées (réparations) : %d — reste en soute : %s\n" % [int(T["pieces_used"]), MAUtils.fmt_int(int(ship.cargaison.get("Pièces détachées (1 kg)", 0)))]
	bb += "Bonus de pilotage gagnés : +%s PC\n" % MAUtils.fmt_num(T["bonus"])
	if geo:
		journal.text = bb
	else:
		system_map.set_journal(bb)

func _on_recruit_found(c: Character) -> void:
	avancer_heure(1)
	recruit_panel.show_recrue(c)
	refresh_all()
	recruit_panel.set_message("Recrue trouvée (action de 1 h) — calendrier : %s, %d h · %d jour(s) écoulé(s)." % [MAUtils.galdate(jours_ecoules), heure_jour, jours_ecoules])

func _on_recruit_hired(c: Character) -> void:
	if not peut_recruter():
		recruit_panel.set_message("Recrutement impossible ici : scannez le corps (astroport détecté requis) — planète habitée ou station.")
		return
	if characters.size() >= ship.passagers_max:
		recruit_panel.set_message("Le vaisseau est plein (%d/%d)." % [characters.size(), ship.passagers_max])
		return
	if credits < c.prix_recrutement:
		recruit_panel.set_message("Crédits insuffisants (%s € requis)." % MAUtils.fmt_int(c.prix_recrutement))
		return
	credits -= c.prix_recrutement
	c.post_index = -1
	characters.append(c)
	make_token(c)
	if captain == null:
		captain = c
	recruit_panel.clear_recrue()
	recruit_panel.set_message("%s rejoint l'équipage pour %s € (salaire %d €/jour). Premier personnage = capitaine." % [c.nom, MAUtils.fmt_int(c.prix_recrutement), c.prix_journalier])
	refresh_all()

func refresh_all() -> void:
	calendar_label.text = "Calendrier galactique : %s · %d h · année %s" % [MAUtils.galdate(jours_ecoules), heure_jour, MAUtils.fmt_int(MAUtils.annee_galactique(jours_ecoules))]
	jours_label.text = "Jours écoulés depuis le premier jour : %d" % jours_ecoules
	ship_name_label.text = "Vaisseau : %s (%s)" % [ship.nom, ship.modele]
	pos_label.text = "Position : %s (%s)" % [GalaxyData.coord_label(current_pos.x, current_pos.y), GalaxyData.coord_text(current_pos.x, current_pos.y)]
	refresh_ship_health()
	radix_label.text = "Radix : %s / %s PC" % [MAUtils.fmt_int(ship.radix_pc), MAUtils.fmt_int(ship.autonomie_pc)]
	var rd: int = rations_dispo()
	var besoin: int = rations_necessaires()
	rations_label.text = "Rations en soute : %d (besoin : %d)" % [rd, besoin]
	if rd <= 0:
		rations_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	elif rd < besoin:
		rations_label.add_theme_color_override("font_color", Color(1.0, 0.65, 0.3))
	else:
		rations_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	credits_label.text = "Crédits : %s €" % MAUtils.fmt_int(credits)
	captain_label.text = "Capitaine : %s" % (captain.nom if captain != null else "—")
	for c in characters:
		if char_tokens.has(c):
			char_tokens[c].is_captain = c == captain
			char_tokens[c].refresh_name()
			char_tokens[c].refresh_health()
	rebuild_posts()
	crew_panel.set_characters(characters, captain)
	ship_panel.set_ship(ship)
	_update_system_tab()
	galaxy_map.current_pos = current_pos
	galaxy_map.queue_redraw()
	travel_info_label.text = "Radix : %s / %s PC · Vitesse : %d PC/j" % [MAUtils.fmt_int(ship.radix_pc), MAUtils.fmt_int(ship.autonomie_pc), ship.vitesse_hyper_pc_j]
	var dk := docked()
	var pc := peut_commercer()
	if corps_recherche != null and corps_recherche != ship_body:
		articles_trouves.clear()
		corps_recherche = null
	var est_rel: bool = current_system != null and current_system.est_relais
	var items: Array
	var titre: String
	var sys_nom: String = current_system.nom if current_system != null else "?"
	if est_rel and pc:
		items = ShopTables.STATION_RELAIS
		titre = "Commerce — station-relais %s (tarifs du comptoir OCG, GdM p125)" % sys_nom
	elif pc:
		items = []
		for nom in articles_trouves.keys():
			var it: Variant = ShopTables.find_catalogue(nom)
			if it == null:
				it = ShopTables.find_marchandise(nom)
			if it != null:
				items.append(it)
		titre = "Commerce — planète %s (catalogue MdJ p234-243 + marchandises p233 ; %d article(s) trouvé(s))" % [sys_nom, articles_trouves.size()]
	else:
		items = []
		titre = "Commerce — %s (scannez le corps pour détecter un astroport)" % sys_nom
	_update_info_label()
	_update_buttons()
	shop_panel.set_catalog(items, titre, credits, soute_used(), ship.soute, pc, cours_txt(), cours_actuel(), est_rel, ship.cargaison)
	ship_panel.set_context(cours_actuel(), pc, radix_unit_price())
