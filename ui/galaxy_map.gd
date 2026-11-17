class_name GalaxyMap
extends Control

signal cell_clicked(col: int, row: int)
signal cell_right_clicked(col: int, row: int)
signal cell_double_clicked(col: int, row: int)

var map_tex: Texture2D
var current_pos := GalaxyData.EXXALIA
var destination := Vector2i(-1, -1)
var selected_cell := Vector2i(-1, -1)
var explored: Array = []
var hover := Vector2i(-1, -1)
var _origin := Vector2.ZERO
var _scale := 1.0

func _ready() -> void:
	map_tex = load("res://assets/carte_galactique.jpg")
	mouse_filter = MOUSE_FILTER_STOP
	clip_contents = true

func _layout() -> void:
	var margin_l := 36.0
	var margin_t := 28.0
	var margin_r := 10.0
	var margin_b := 10.0
	var avail := Vector2(size.x - margin_l - margin_r, size.y - margin_t - margin_b)
	_scale = min(avail.x / _geo_f("img_w"), avail.y / _geo_f("img_h"))
	if _scale <= 0.0:
		_scale = 1.0
	_origin = Vector2(margin_l, margin_t)

func _geo_f(key: String) -> float:
	return float(GalaxyData.MAP_GEO[key])

func _geo_n() -> int:
	return int(GalaxyData.MAP_GEO["n"])

func cell_center(col: int, row: int) -> Vector2:
	return _cell_center(col, row)

func _cell_center(col: int, row: int) -> Vector2:
	var n: int = _geo_n()
	var ix := (_geo_f("x0") + (col - 0.5) * _geo_f("pas_x")) * _scale + _origin.x
	var iy := (_geo_f("y0") + (n - row + 0.5) * _geo_f("pas_y")) * _scale + _origin.y
	return Vector2(ix, iy)

func _cell_at(pos: Vector2) -> Vector2i:
	var n: int = _geo_n()
	var ix := (pos.x - _origin.x) / _scale
	var iy := (pos.y - _origin.y) / _scale
	var col := int(floor((ix - _geo_f("x0")) / _geo_f("pas_x"))) + 1
	var row := n - int(floor((iy - _geo_f("y0")) / _geo_f("pas_y")))
	col = clampi(col, 1, n)
	row = clampi(row, 1, n)
	return Vector2i(col, row)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		_layout()
		var c := _cell_at(event.position)
		cell_double_clicked.emit(c.x, c.y)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_layout()
		var c := _cell_at(event.position)
		cell_clicked.emit(c.x, c.y)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_layout()
		var c := _cell_at(event.position)
		cell_right_clicked.emit(c.x, c.y)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var c := _cell_at(event.position)
		if c != hover:
			hover = c
			queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	_layout()
	var n: int = _geo_n()
	var img_size := Vector2(_geo_f("img_w") * _scale, _geo_f("img_h") * _scale)
	if map_tex != null:
		draw_texture_rect(map_tex, Rect2(_origin, img_size), false)
	else:
		draw_rect(Rect2(_origin, img_size), Color(0.05, 0.07, 0.12))
	var grid_color := Color(1, 1, 1, 0.10)
	for i in range(n + 1):
		var gx := _origin.x + (_geo_f("x0") + i * _geo_f("pas_x")) * _scale
		draw_line(Vector2(gx, _origin.y + _geo_f("y0") * _scale), Vector2(gx, _origin.y + (_geo_f("y0") + n * _geo_f("pas_y")) * _scale), grid_color)
		var gy := _origin.y + (_geo_f("y0") + i * _geo_f("pas_y")) * _scale
		draw_line(Vector2(_origin.x + _geo_f("x0") * _scale, gy), Vector2(_origin.x + (_geo_f("x0") + n * _geo_f("pas_x")) * _scale, gy), grid_color)
	var f := ThemeDB.fallback_font
	var axis_color := Color(0.75, 0.8, 0.9, 0.9)
	for c in range(1, n + 1):
		var cx := _origin.x + (_geo_f("x0") + (c - 0.5) * _geo_f("pas_x")) * _scale
		draw_string(f, Vector2(cx, _origin.y + _geo_f("y0") * _scale - 5), GalaxyData.letter_symbol(c), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, axis_color)
	for r in range(1, n + 1):
		var cy := _origin.y + (_geo_f("y0") + (n - r + 0.5) * _geo_f("pas_y")) * _scale
		draw_string(f, Vector2(_origin.x + _geo_f("x0") * _scale - 6, cy + 3), str(r), HORIZONTAL_ALIGNMENT_RIGHT, 26, 9, axis_color)
	for c in explored:
		draw_circle(_cell_center(c.x, c.y), 2.2, Color(0.45, 0.8, 1.0, 0.85))
	for s in GalaxyData.NAMED_SYSTEMS:
		var p := _cell_center(s["col"], s["row"])
		var col := Color(1.0, 0.85, 0.3) if s["type"] == "système" else Color(0.9, 0.4, 0.4)
		draw_circle(p, 3.0, col)
		draw_string(f, p + Vector2(5, -5), s["nom"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.92, 0.65, 0.95))
	if hover.x > 0:
		var hp := _cell_center(hover.x, hover.y)
		var cell := _scale * _geo_f("pas_x")
		draw_rect(Rect2(hp - Vector2(cell * 0.5, cell * 0.5), Vector2(cell, cell)), Color(1, 1, 1, 0.12), true)
	if selected_cell.x > 0:
		var ps := _cell_center(selected_cell.x, selected_cell.y)
		var cell_s := _scale * _geo_f("pas_x")
		draw_rect(Rect2(ps - Vector2(cell_s * 0.5, cell_s * 0.5), Vector2(cell_s, cell_s)), Color(1.0, 0.85, 0.3, 0.16), true)
		draw_rect(Rect2(ps - Vector2(cell_s * 0.5, cell_s * 0.5), Vector2(cell_s, cell_s)), Color(1.0, 0.85, 0.3, 0.95), false, 2.0)
	if destination.x > 0:
		var pd := _cell_center(destination.x, destination.y)
		var cell := _scale * _geo_f("pas_x")
		draw_rect(Rect2(pd - Vector2(cell * 0.5, cell * 0.5), Vector2(cell, cell)), Color(0.5, 1.0, 0.6, 0.22), true)
		draw_rect(Rect2(pd - Vector2(cell * 0.5, cell * 0.5), Vector2(cell, cell)), Color(0.5, 1.0, 0.6, 0.9), false, 1.5)
		var pc := _cell_center(current_pos.x, current_pos.y)
		draw_dashed_line(pc, pd, Color(1.0, 0.85, 0.3, 0.9), 2.0, 5.0)
	if current_pos.x > 0:
		var pc := _cell_center(current_pos.x, current_pos.y)
		var arm: float = max(7.0, _scale * _geo_f("pas_x") * 0.55)
		draw_line(pc - Vector2(arm, 0), pc + Vector2(arm, 0), Color(1.0, 0.25, 0.2), 2.5)
		draw_line(pc - Vector2(0, arm), pc + Vector2(0, arm), Color(1.0, 0.25, 0.2), 2.5)
		draw_circle(pc, 3.0, Color(1.0, 0.25, 0.2))
		draw_string(f, pc + Vector2(arm + 3, -arm - 3), GalaxyData.coord_label(current_pos.x, current_pos.y), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.5, 0.45))
