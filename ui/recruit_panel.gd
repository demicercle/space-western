class_name RecruitPanel
extends ScrollContainer

signal recruit_found(recrue: Character)
signal recruit_hired(recrue: Character)

const NIVEAUX := ["Normal", "Élite", "Héros", "Boss", "Big Boss"]

var niveau_opt: OptionButton
var profession_opt: OptionButton
var trouver_btn: Button
var recruter_btn: Button
var card_holder: VBoxContainer
var msg_label: Label
var recrue: Character = null

func _ready() -> void:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	vb.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(vb)
	var head := Label.new()
	head.text = "Recruter un membre d'équipage (possible uniquement sur une planète ou une station-relais) :"
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.add_theme_font_size_override("font_size", 13)
	head.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	vb.add_child(head)
	var opts := HBoxContainer.new()
	opts.add_theme_constant_override("separation", 8)
	vb.add_child(opts)
	opts.add_child(_mk_label("Niveau :"))
	niveau_opt = OptionButton.new()
	for n in NIVEAUX:
		niveau_opt.add_item(n)
	niveau_opt.select(2)
	opts.add_child(niveau_opt)
	opts.add_child(_mk_label("Profession :"))
	profession_opt = OptionButton.new()
	profession_opt.add_item("Aléatoire")
	for p in NPCTables.PROFESSIONS.keys():
		profession_opt.add_item(p)
	opts.add_child(profession_opt)
	trouver_btn = Button.new()
	trouver_btn.text = "Trouver une recrue"
	trouver_btn.pressed.connect(_on_trouver)
	vb.add_child(trouver_btn)
	msg_label = Label.new()
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	vb.add_child(msg_label)
	card_holder = VBoxContainer.new()
	card_holder.add_theme_constant_override("separation", 8)
	card_holder.size_flags_horizontal = SIZE_EXPAND_FILL
	vb.add_child(card_holder)
	recruter_btn = Button.new()
	recruter_btn.text = "Recruter"
	recruter_btn.disabled = true
	recruter_btn.pressed.connect(_on_recruter)
	vb.add_child(recruter_btn)

func _mk_label(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", 13)
	return l

func role_for(puissance: String) -> String:
	if puissance == "Normal" or puissance == "Élite":
		return "Second rôle"
	return "Premier rôle"

func _on_trouver() -> void:
	var puissance: String = NIVEAUX[niveau_opt.selected]
	var prof: String = ""
	if profession_opt.selected > 0:
		prof = profession_opt.get_item_text(profession_opt.selected)
	recruit_found.emit(Character.generate(puissance, role_for(puissance), prof))

func _on_recruter() -> void:
	if recrue != null:
		recruit_hired.emit(recrue)

func show_recrue(c: Character) -> void:
	recrue = c
	for ch in card_holder.get_children():
		card_holder.remove_child(ch)
		ch.queue_free()
	card_holder.add_child(CrewPanel.make_card(c, false))
	var price := Label.new()
	price.text = "Prix de recrutement : %s € (5 × salaire journalier de %s €/jour)" % [MAUtils.fmt_int(c.prix_recrutement), MAUtils.fmt_int(c.prix_journalier)]
	price.add_theme_font_size_override("font_size", 13)
	price.add_theme_color_override("font_color", Color(0.95, 0.8, 0.4))
	card_holder.add_child(price)
	recruter_btn.disabled = false
	msg_label.text = ""

func clear_recrue() -> void:
	recrue = null
	recruter_btn.disabled = true
	for ch in card_holder.get_children():
		card_holder.remove_child(ch)
		ch.queue_free()

func set_message(t: String) -> void:
	msg_label.text = t

func set_enabled_state(docked: bool, credits: int, crew_size: int, crew_max: int) -> void:
	trouver_btn.disabled = not docked
	recruter_btn.disabled = not docked or recrue == null or credits < (recrue.prix_recrutement if recrue != null else 0) or crew_size >= crew_max
	if not docked:
		set_message("Recrutement impossible, trouvez une station-relais ou une planète habitée.")
	elif crew_size >= crew_max:
		set_message("Le vaisseau est plein (%d/%d)." % [crew_size, crew_max])
	elif recrue != null and credits < recrue.prix_recrutement:
		set_message("Crédits insuffisants pour recruter %s (%s € requis)." % [recrue.nom, MAUtils.fmt_int(recrue.prix_recrutement)])
	else:
		set_message("")
