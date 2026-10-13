extends SceneTree

var failures: Array[String] = []
var count: int = 0

func check(condition: bool, label: String) -> void:
	count += 1
	if not condition:
		failures.append(label)

func _initialize() -> void:
	check(not ShotRules.prepare(Vector2.ZERO, Vector2.ZERO).valid, "zero aim rejected")
	check(not ShotRules.prepare(Vector2.ZERO, Vector2(23.9, 0)).valid, "inside dead zone rejected")
	check(ShotRules.prepare(Vector2.ZERO, Vector2(24, 0)).valid, "dead zone boundary accepted")
	check(not ShotRules.prepare(Vector2.ZERO, Vector2(INF, 0)).valid, "non-finite aim rejected")
	check(is_equal_approx(ShotRules.prepare(Vector2.ZERO, Vector2(30, 0)).velocity.length(), 250), "minimum speed")
	check(is_equal_approx(ShotRules.prepare(Vector2.ZERO, Vector2(9000, 0)).velocity.length(), 900), "maximum speed")
	check(ShotRules.point(Vector2.ZERO, Vector2(100, -200), 1) == Vector2(100, 250), "independent ballistic fixture")
	var direct: Dictionary = ShotRules.damage(6, "direct", 1, [])
	check(direct.hp == 4 and direct.amount == 2, "direct damage fixed at two")
	var tokens: Array[String] = ["1:direct"]
	check(ShotRules.damage(4, "direct", 1, tokens).amount == 0, "same-shot direct duplicate rejected")
	check(ShotRules.damage(4, "direct", 2, tokens).hp == 2, "next shot still damages")
	var wall: Dictionary = ShotRules.damage(4, "wall", 1, tokens)
	check(wall.hp == 3 and wall.amount == 1, "wall adds only one")
	tokens.append("1:wall")
	check(ShotRules.damage(3, "wall", 1, tokens).amount == 0, "repeated wall damage blocked")
	check(ShotRules.damage(1, "direct", 3, []).hp == 0, "health clamped to zero")
	check(ShotRules.damage(0, "direct", 3, []).amount == 0, "dead target unaffected")
	check(ShotRules.damage(6, "unknown", 1, []).amount == 0, "unknown event ignored")
	check(ShotRules.damage(6, "direct", 0, []).amount == 0, "invalid shot ignored")
	if failures.is_empty():
		print("DM01_RULES_PASS count=", count)
		quit(0)
	else:
		printerr("DM01_RULES_FAIL: ", failures)
		quit(1)
