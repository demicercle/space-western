class_name ShopPanel
extends ScrollContainer

signal buy_requested(item: Dictionary)

var title_label: Label
var info_label: Label
var list_box: VBoxContainer
var msg_label: Label
var items: Array = []
var credits := 0
var soute_used := 0.0
var soute_max := 25.0
var docked := false

func _ready() -> void:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	vb.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(vb)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 15)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	vb.add_child(title_label)
	info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_size_override("font_size", 12)
	info_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	vb.add_child(info_label)
	msg_label = Label.new()
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_label.add_theme_font_size_override("font_size", 12)
	msg_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	vb.add_child(msg_label)
	list_box = VBoxContainer.new()
	list_box.add_theme_constant_override("separation", 4)
	list_box.size_flags_horizontal = SIZE_EXPAND_FILL
	vb.add_child(list_box)

func set_catalog(p_items: Array, titre: String, p_credits: int, p_soute_used: float, p_soute_max: float, p_docked: bool, cours_txt: String) -> void:
	items = p_items
	credits = p_credits
	soute_used = p_soute_used
	soute_max = p_soute_max
	docked = p_docked
	title_label.text = titre
	info_label.text = "Crédits : %s ¤ · Soute : %s / %s UC%s%s" % [MAUtils.fmt_int(credits), MAUtils.fmt_num(soute_used), MAUtils.fmt_num(soute_max), (" · Cours : " + cours_txt) if cours_txt != "" else "", "" if docked else " · (commerce indisponible hors planète/station-relais)"]
	for ch in list_box.get_children():
		list_box.remove_child(ch)
		ch.queue_free()
	for it in items:
		var row := PanelContainer.new()
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 10)
		row.add_child(hb)
		var txt := Label.new()
		txt.size_flags_horizontal = SIZE_EXPAND_FILL
		txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		txt.text = "%s — %s ¤ (dispo %s, %s UC)%s" % [it["nom"], MAUtils.fmt_int(it["prix"]), it["dispo"], MAUtils.fmt_num(it["place"]), ("\n" + it["note"]) if str(it.get("note", "")) != "" else ""]
		txt.add_theme_font_size_override("font_size", 12)
		hb.add_child(txt)
		var btn := Button.new()
		btn.text = "Acheter"
		var trop_cher := credits < int(it["prix"])
		var plus_de_place := soute_used + float(it["place"]) > soute_max + 0.0001
		btn.disabled = not docked or trop_cher or plus_de_place
		if trop_cher:
			btn.tooltip_text = "Crédits insuffisants"
		elif plus_de_place:
			btn.tooltip_text = "Plus de place en soute"
		btn.pressed.connect(_on_buy.bind(it))
		hb.add_child(btn)
		list_box.add_child(row)

func _on_buy(it: Dictionary) -> void:
	buy_requested.emit(it)

func set_message(t: String) -> void:
	msg_label.text = t
