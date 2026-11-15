class_name CharacterToken
extends PanelContainer

signal left_clicked(token: CharacterToken)
signal right_clicked(token: CharacterToken, global_pos: Vector2)

var character: Character
var is_captain := false
var _press_pos := Vector2.ZERO

func setup(c: Character) -> void:
	character = c
	custom_minimum_size = Vector2(230, 58)
	for ch in get_children():
		remove_child(ch)
		ch.queue_free()
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)
	add_child(hb)
	var port := Portrait.new()
	port.custom_minimum_size = Vector2(48, 48)
	port.seed = character.nom.hash()
	hb.add_child(port)
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = SIZE_EXPAND_FILL
	hb.add_child(vb)
	var nl := Label.new()
	refresh_name()
	nl.add_theme_font_size_override("font_size", 12)
	nl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	vb.add_child(nl)
	var hl := Label.new()
	refresh_health()
	hl.add_theme_font_size_override("font_size", 11)
	vb.add_child(hl)
	var pb := ProgressBar.new()
	pb.min_value = 0
	pb.max_value = maxf(1.0, float(character.pv_max))
	pb.value = character.pv
	pb.show_percentage = false
	pb.custom_minimum_size = Vector2(160, 8)
	vb.add_child(pb)

func refresh_name() -> void:
	if character == null:
		return
	for ch in get_children():
		if ch is HBoxContainer:
			var vb := ch.get_child(1) as VBoxContainer
			if vb != null and vb.get_child_count() > 0 and vb.get_child(0) is Label:
				var nl := vb.get_child(0) as Label
				nl.text = ("♛ " if is_captain else "") + character.nom
				nl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if is_captain else Color(0.9, 0.92, 1.0))

func refresh_health() -> void:
	if character == null:
		return
	for ch in get_children():
		if ch is HBoxContainer:
			var vb := ch.get_child(1) as VBoxContainer
			if vb != null and vb.get_child_count() > 1 and vb.get_child(1) is Label:
				var hl := vb.get_child(1) as Label
				hl.text = "PV %d/%d · %s" % [character.pv, character.pv_max, character.sante_txt()]
				hl.add_theme_color_override("font_color", Color(0.55, 0.9, 0.55) if character.pv > 0 else Color(1.0, 0.3, 0.3))
			if vb.get_child_count() > 2 and vb.get_child(2) is ProgressBar:
				var pb := vb.get_child(2) as ProgressBar
				pb.max_value = maxf(1.0, float(character.pv_max))
				pb.value = character.pv

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_press_pos = event.position
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			right_clicked.emit(self, get_global_mouse_position())
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not get_viewport().gui_is_dragging() and event.position.distance_to(_press_pos) < 8.0:
			left_clicked.emit(self)
			get_viewport().set_input_as_handled()

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview := CharacterToken.new()
	preview.setup(character)
	preview.custom_minimum_size = Vector2(210, 52)
	preview.modulate.a = 0.85
	set_drag_preview(preview)
	return {"token": self}
