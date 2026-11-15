class_name PostSlot
extends PanelContainer

signal token_dropped(slot: PostSlot, token: CharacterToken)

var post_name := ""
var post_index := -1
var is_hamac := false
var hamac_max := 25
var tokens: Array = []
var label: Label
var flow: HFlowContainer
var count_label: Label
var normal_style: StyleBoxFlat
var highlight_style: StyleBoxFlat

func _ready() -> void:
	custom_minimum_size = Vector2(270, 74)
	highlight_style = StyleBoxFlat.new()
	highlight_style.bg_color = Color(0.25, 0.28, 0.4, 0.95)
	highlight_style.border_color = Color(1.0, 0.85, 0.3)
	highlight_style.set_border_width_all(2)
	highlight_style.set_corner_radius_all(6)
	highlight_style.set_content_margin_all(8)
	var vb := VBoxContainer.new()
	add_child(vb)
	label = Label.new()
	label.text = post_name
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45) if not is_hamac else Color(0.7, 0.8, 0.9))
	vb.add_child(label)
	flow = HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 6)
	flow.add_theme_constant_override("v_separation", 6)
	flow.custom_minimum_size = Vector2(0, 46)
	vb.add_child(flow)
	count_label = Label.new()
	count_label.add_theme_font_size_override("font_size", 10)
	count_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	vb.add_child(count_label)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	refresh()

func set_normal_style(s: StyleBoxFlat) -> void:
	normal_style = s
	add_theme_stylebox_override("panel", normal_style)

func _on_mouse_entered() -> void:
	if get_viewport().gui_is_dragging():
		add_theme_stylebox_override("panel", highlight_style)

func _on_mouse_exited() -> void:
	add_theme_stylebox_override("panel", normal_style)

func set_tokens(list: Array) -> void:
	tokens = list
	refresh()

func refresh() -> void:
	for ch in flow.get_children():
		flow.remove_child(ch)
	if tokens.size() > 0:
		for t in tokens:
			if t.get_parent() != null and t.get_parent() != flow:
				t.get_parent().remove_child(t)
			flow.add_child(t)
	else:
		var l := Label.new()
		l.text = "— vide —" if not is_hamac else "— aucun personnage au repos —"
		l.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
		l.add_theme_font_size_override("font_size", 11)
		flow.add_child(l)
	if is_hamac:
		count_label.text = "hamac : %d / %d personnage(s)" % [tokens.size(), hamac_max]
	else:
		count_label.text = ""

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("token") and data["token"] is CharacterToken

func _drop_data(at_position: Vector2, data: Variant) -> void:
	add_theme_stylebox_override("panel", normal_style)
	token_dropped.emit(self, data["token"])
