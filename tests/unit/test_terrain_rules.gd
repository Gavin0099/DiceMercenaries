extends SceneTree

var failures: Array[String] = []
var count: int = 0

func check(value: bool, label: String) -> void:
	count += 1
	if not value:
		failures.append(label)

func _initialize() -> void:
	check(TerrainRules.strike(2, 1, []).destroyed, "two-HP module destroyed by one hit")
	check(TerrainRules.strike(4, 1, []).hp == 2, "module HP change bounded")
	var seen: Array[int] = [1]
	check(not TerrainRules.strike(2, 1, seen).accepted, "duplicate hit rejected")
	check(TerrainRules.strike(2, 2, seen).destroyed, "distinct shot accepted")
	check(not TerrainRules.strike(0, 2, []).accepted, "broken module does not retrigger")
	check(not TerrainRules.strike(2, 0, []).accepted, "invalid shot rejected")
	check(TerrainRules.fall_damage(6, 80) == 0, "safe fall boundary")
	check(TerrainRules.fall_damage(6, 80.01) == 1, "shallow damage starts after safe boundary")
	check(TerrainRules.fall_damage(6, 159.99) == 1, "below strong-fall boundary")
	check(TerrainRules.fall_damage(6, 160) == 2, "strong-fall boundary")
	check(TerrainRules.fall_damage(6, 10000) == 2, "normal fall capped at two")
	check(TerrainRules.fall_damage(1, 200) == 1, "damage clamped to remaining HP")
	check(TerrainRules.fall_damage(6, 200, true) == 6, "ordinary enemy deep pit defeats")
	check(TerrainRules.fall_damage(6, 200, true, true) == 2, "Boss deep pit policy capped")
	check(TerrainRules.fall_damage(0, 200, true) == 0, "dead enemy does not take damage")
	check(TerrainRules.fall_damage(6, -1) == 0, "negative distance rejected")
	check(TerrainRules.fall_damage(6, INF) == 0, "non-finite distance rejected")
	if failures.is_empty():
		print("DM02_RULES_PASS count=", count)
		quit(0)
	else:
		printerr("DM02_RULES_FAIL: ", failures)
		quit(1)
