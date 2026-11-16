class_name GalaxyData

const N := 40
const PC_PAR_CASE := 1000

const LETTERS := ["Α", "Β", "Γ", "Δ", "Ε", "Ζ", "Η", "Θ", "Ι", "Κ", "Λ", "Μ", "Ν", "Ξ", "Ο", "Π", "Ρ", "Σ", "Τ", "Υ", "Φ", "Χ", "Ψ", "Ω"]

const LETTER_NAMES := ["Alpha", "Bêta", "Gamma", "Delta", "Epsilon", "Dzéta", "Êta", "Thêta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rhô", "Sigma", "Tau", "Upsilon", "Phi", "Khi", "Psi", "Oméga"]

const MAP_GEO := {"img_w": 643.0, "img_h": 638.0, "x0": 22.0, "y0": 18.0, "pas_x": 15.04, "pas_y": 15.06, "n": 40}

const EXXALIA := Vector2i(5, 21)

const NAMED_SYSTEMS := [
	{"nom": "Exxalia", "col": 5, "row": 21, "type": "système"},
	{"nom": "Palace", "col": 12, "row": 15, "type": "système"},
	{"nom": "Fortune", "col": 7, "row": 18, "type": "système"},
	{"nom": "Bazaar", "col": 10, "row": 8, "type": "système"},
	{"nom": "Havana", "col": 13, "row": 33, "type": "système"},
	{"nom": "Sol Prime", "col": 21, "row": 23, "type": "système"},
	{"nom": "Destria", "col": 19, "row": 23, "type": "système"},
	{"nom": "Coralia", "col": 35, "row": 24, "type": "système"},
	{"nom": "Vardessa III", "col": 25, "row": 20, "type": "système"},
	{"nom": "Ilostia", "col": 28, "row": 17, "type": "système"},
	{"nom": "Khargall", "col": 24, "row": 7, "type": "système"},
	{"nom": "Darek", "col": 24, "row": 3, "type": "système"},
	{"nom": "Sulpira", "col": 6, "row": 25, "type": "système"},
	{"nom": "Station-relais", "col": 12, "row": 23, "type": "relais"},
	{"nom": "Station-relais", "col": 14, "row": 10, "type": "relais"},
	{"nom": "Station-relais", "col": 16, "row": 28, "type": "relais"},
	{"nom": "Station-relais", "col": 17, "row": 14, "type": "relais"},
	{"nom": "Station-relais", "col": 35, "row": 17, "type": "relais"},
]

static func letter_symbol(col: int) -> String:
	var l: String = LETTERS[(col - 1) % 24]
	return l + "′" if col > 24 else l

static func col_of(letter: String) -> int:
	var l := letter
	var primed := l.ends_with("′")
	if primed:
		l = l.substr(0, l.length() - 1)
	var i := LETTERS.find(l)
	if i < 0:
		return -1
	return i + 1 + (24 if primed else 0)

static func letter_name(col: int) -> String:
	var l: String = LETTER_NAMES[(col - 1) % 24]
	return l + "'" if col > 24 else l

static func coord_text(col: int, row: int) -> String:
	return "%s-%d" % [letter_symbol(col), row]

static func coord_label(col: int, row: int) -> String:
	return "%s-%d" % [letter_name(col), row]

static func distance_pc(dep: Vector2i, arr: Vector2i) -> int:
	return int(round(Vector2(dep).distance_to(Vector2(arr)) * float(PC_PAR_CASE)))

static func named_at(col: int, row: int):
	for s in NAMED_SYSTEMS:
		if s["col"] == col and s["row"] == row:
			return s
	return null
