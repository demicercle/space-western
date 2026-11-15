class_name CharacterToken
extends PanelContainer

var character: Character

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
	nl.text = character.nom
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

func refresh_health() -> void:
	if character == null:
		return
	for ch in get_children():
		if ch is VBoxContainer:
			var vb := ch as VBoxContainer
			if vb.get_child_count() > 1 and vb.get_child(1) is Label:
				var hl := vb.get_child(1) as Label
				hl.text = "PV %d/%d · %s" % [character.pv, character.pv_max, character.sante_txt()]
				hl.add_theme_color_override("font_color", Color(0.55, 0.9, 0.55) if character.pv > 0 else Color(1.0, 0.3, 0.3))
			if vb.get_child_count() > 2 and vb.get_child(2) is ProgressBar:
				var pb := vb.get_child(2) as ProgressBar
				pb.max_value = maxf(1.0, float(character.pv_max))
				pb.value = character.pv

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview := CharacterToken.new()
	preview.setup(character)
	preview.custom_minimum_size = Vector2(210, 52)
	preview.modulate.a = 0.85
	set_drag_preview(preview)
	return {"token": self}
