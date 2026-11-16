class_name MAUtils

static func pick(a: Array) -> Variant:
	return a[randi() % a.size()]

static func wpick(list: Array) -> Variant:
	var tot := 0
	for x in list:
		tot += x[1]
	var r := randf() * tot
	for x in list:
		r -= x[1]
		if r < 0.0:
			return x[0]
	return list[list.size() - 1][0]

static func shuffled(a: Array) -> Array:
	var b := a.duplicate()
	b.shuffle()
	return b

static func fmt_int(n: float) -> String:
	var neg := n < 0.0
	var s := str(int(round(abs(n))))
	var out := ""
	while s.length() > 3:
		out = " " + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	out = s + out
	return ("-" if neg else "") + out

static func fmt_num(n: float) -> String:
	var v := snappedf(n, 0.01)
	if v == floor(v):
		return fmt_int(v)
	return ("%.2f" % v).replace(".", ",")

static func hex_color(s: String) -> Color:
	if s.begins_with("#"):
		return Color.html(s)
	return Color(0.65, 0.75, 0.85)

static func galdate(jours_ecoules: int) -> String:
	var n := maxi(0, jours_ecoules) % 250
	var m := n / 25 + 1
	var rem := n % 25
	var w := rem / 5 + 1
	var d := rem % 5 + 1
	return "%02d%02d.%02d" % [m, w, d]

static func annee_galactique(jours_ecoules: int) -> int:
	return 50000 + maxi(0, jours_ecoules) / 250
