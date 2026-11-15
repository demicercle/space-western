class_name PostSlot
extends PanelContainer

signal token_dropped(slot: PostSlot, token: CharacterToken)

var post_name := ""
var post_index := -1
var is_hamac := false
var token: CharacterToken = null
var label: Label
var content: VBoxContainer

func _ready() -> void:
	custom_minimum_size = Vector2(270, 74)
	var vb := VBoxContainer.new()
	add_child(vb)
	label = Label.new()
	label.text = post_name
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45) if not is_hamac else Color(0.7, 0.8, 0.9))
	vb.add_child(label)
	content = VBoxContainer.new()
	content.custom_minimum_size = Vector2(0, 46)
	vb.add_child(content)
	refresh()

func refresh() -> void:
	for ch in content.get_children():
		content.remove_child(ch)
	if token != null:
		if token.get_parent() != null and token.get_parent() != content:
			token.get_parent().remove_child(token)
		content.add_child(token)
	else:
		var l := Label.new()
		l.text = "— vide —" if not is_hamac else "— aucun personnage au repos —"
		l.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
		l.add_theme_font_size_override("font_size", 11)
		content.add_child(l)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("token") and data["token"] is CharacterToken

func _drop_data(at_position: Vector2, data: Variant) -> void:
	token_dropped.emit(self, data["token"])
