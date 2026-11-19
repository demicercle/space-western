class_name SellBuyPopup
extends AcceptDialog

signal confirmed_quantity(q: float)

var slider: HSlider
var edit: LineEdit
var price_label: Label
var pop_mode := ""
var unite := "kg"
var prix_unitaire := 0.0
var item_nom := ""

func _ready() -> void:
	get_ok_button().text = "OK"
	add_cancel_button("Annuler")
	unresizable = true
	min_size = Vector2i(256, 256)
	size = Vector2i(256, 256)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)
	add_child(hb)
	slider = HSlider.new()
	slider.min_value = 1.0
	slider.max_value = 999999.0
	slider.step = 1.0
	slider.custom_minimum_size = Vector2(120, 0)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(slider)
	edit = LineEdit.new()
	edit.custom_minimum_size = Vector2(80, 0)
	edit.placeholder_text = "quantité"
	hb.add_child(edit)
	price_label = Label.new()
	price_label.add_theme_font_size_override("font_size", 13)
	add_child(price_label)
	slider.value_changed.connect(_on_slider_changed)
	edit.text_changed.connect(_on_edit_changed)
	confirmed.connect(_on_ok)

func open_popup(p_mode: String, p_nom: String, p_unite: String, p_prix_unitaire: float, p_q_max: float, p_contexte: String) -> void:
	pop_mode = p_mode
	item_nom = p_nom
	unite = p_unite
	prix_unitaire = p_prix_unitaire
	title = "Vendre" if p_mode == "vente" else "Acheter"
	dialog_text = "%s — en %s. %s" % [ShopTables.nom_affiche(p_nom), p_unite, p_contexte]
	slider.min_value = 1.0
	slider.max_value = maxf(1.0, minf(p_q_max, 999999.0))
	slider.step = 1.0
	slider.value = 1.0
	edit.text = "1"
	popup_centered()
	_update_price()

func _filtre(t: String) -> String:
	var clean := ""
	for ch in t:
		if ch >= "0" and ch <= "9":
			clean += ch
	if clean.length() > 6:
		clean = clean.substr(0, 6)
	return clean

func _on_slider_changed(v: float) -> void:
	var t := str(int(v))
	if edit.text != t:
		edit.text = t
	_update_price()

func _on_edit_changed(t: String) -> void:
	var clean := _filtre(t)
	if clean != t:
		edit.text = clean
		edit.caret_column = clean.length()
	var v := edit.text.to_float()
	if v < slider.min_value:
		v = slider.min_value
	if v > slider.max_value:
		v = slider.max_value
	if slider.value != v:
		slider.value = v
	_update_price()

func _update_price() -> void:
	var total := int(round(prix_unitaire * slider.value))
	var prix_txt := "%s €/%s" % [MAUtils.fmt_num(prix_unitaire), unite]
	if pop_mode == "vente":
		price_label.text = "prix de vente : %s ; total : %s €" % [prix_txt, MAUtils.fmt_int(total)]
	else:
		price_label.text = "prix d'achat: %s ; total : %s €" % [prix_txt, MAUtils.fmt_int(total)]

func _on_ok() -> void:
	confirmed_quantity.emit(slider.value)
