class_name Portrait
extends Control

var seed := 0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var r := Rect2(Vector2.ZERO, size)
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return
	var bg := Color.from_hsv(rng.randf(), 0.45, 0.28)
	draw_rect(r, bg)
	var cx := size.x * 0.5
	var cy := size.y * 0.44
	var u: float = min(size.x, size.y)
	var clothes := Color.from_hsv(rng.randf(), 0.5, 0.35)
	draw_circle(Vector2(cx, size.y * 1.15), u * 0.62, clothes)
	var hair := Color.from_hsv(rng.randf(), 0.55, 0.18 + rng.randf() * 0.35)
	draw_circle(Vector2(cx, cy - u * 0.10), u * 0.34, hair)
	var skin := Color.from_hsv(0.08, 0.45, 0.68 + rng.randf() * 0.27)
	draw_circle(Vector2(cx, cy), u * 0.27, skin)
	var dark := Color(0.08, 0.08, 0.1)
	draw_circle(Vector2(cx - u * 0.095, cy - u * 0.02), u * 0.032, dark)
	draw_circle(Vector2(cx + u * 0.095, cy - u * 0.02), u * 0.032, dark)
	draw_line(Vector2(cx - u * 0.07, cy + u * 0.12), Vector2(cx + u * 0.07, cy + u * 0.12), Color(0.45, 0.18, 0.18), maxf(1.0, u * 0.02))
	if rng.randf() < 0.4:
		draw_arc(Vector2(cx, cy), u * 0.27, 0.0, PI, 16, hair, u * 0.06)
