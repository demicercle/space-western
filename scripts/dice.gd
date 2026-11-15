class_name Dice

static func d6() -> int:
	return randi() % 6 + 1

static func d66() -> int:
	return d6() + d6()

static func test(nd: int, diff: int, mode := "normal") -> Dictionary:
	var dice: Array = []
	var succ := 0
	for i in range(nd):
		var d := d6()
		dice.append(d)
		match mode:
			"TD":
				if d == 6:
					succ += 1
			"TF":
				if d != 1:
					succ += 1
			"dead":
				pass
			_:
				if d >= 4:
					succ += 1
	return {"ok": succ > 0 and succ >= diff, "succ": succ, "extra": maxi(0, succ - diff), "dice": dice, "mode": mode}

static func fmt_jet(r: Dictionary) -> String:
	var ds := ""
	for d in r["dice"]:
		ds += (", " if ds != "" else "") + str(d)
	var s := "%dd [%s] = %d succès" % [r["dice"].size(), ds, r["succ"]]
	if r["mode"] == "TD":
		s += " (TD : seuls les 6)"
	elif r["mode"] == "TF":
		s += " (TF)"
	return s
