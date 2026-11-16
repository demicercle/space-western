class_name ProfessionsCanvas
extends Control

const LINE_H := 15
const PAD := 8

func _ready() -> void:
	var nb := NPCTables.PROFESSIONS.size()
	custom_minimum_size = Vector2(460, PAD * 2 + 22 + nb * (LINE_H * 3 + 6))
	size_flags_horizontal = SIZE_EXPAND_FILL
	mouse_filter = MOUSE_FILTER_IGNORE

func _draw_wrapped(font: Font, x: float, y: float, text: String, fsize: int, color: Color, max_w: float) -> float:
	var words := text.split(" ")
	var line := ""
	for w in words:
		var try := (line + " " + w).strip_edges()
		if font.get_string_size(try, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x > max_w and line != "":
			draw_string(font, Vector2(x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, color)
			y += LINE_H
			line = w
		else:
			line = try
	if line != "":
		draw_string(font, Vector2(x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, color)
		y += LINE_H
	return y

func _draw() -> void:
	if size.x <= 0.0:
		return
	var font := ThemeDB.fallback_font
	var max_w := size.x - PAD * 2.0
	var y := float(PAD + 12)
	draw_string(font, Vector2(PAD, y), "Professions disponibles (domaines privilégiés · compétences) :", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.85, 0.45))
	y += 22
	for p in NPCTables.PROFESSIONS.keys():
		var d: Dictionary = NPCTables.PROFESSIONS[p]
		draw_string(font, Vector2(PAD, y), str(p), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.75, 0.9, 1.0))
		y += LINE_H
		y = _draw_wrapped(font, PAD + 14.0, y, "domaines : %s" % ", ".join(d["dom"]), 11, Color(0.95, 0.8, 0.4), max_w - 14.0)
		y = _draw_wrapped(font, PAD + 14.0, y, "compétences : %s" % ", ".join(d["comp"]), 11, Color(0.7, 0.72, 0.8), max_w - 14.0)
		y += 6
