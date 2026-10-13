extends SceneTree

var lab: Node2D
var failures: Array[String] = []
var count: int = 0

func check(ok: bool, description: String) -> void:
	count+=1
	if not ok:
		failures.append(description)

func frames(n: int) -> void:
	for index: int in n:
		await physics_frame

func fresh() -> void:
	if is_instance_valid(lab):
		lab.queue_free()
		await process_frame
	lab = load("res://scenes/battle/counterplay_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	await frames(25)

func walk_to(x: float) -> void:
	lab.select_skill("move")
	lab.destination = x
	await frames(90)
	lab.destination = -1
	lab.hero.axis = 0

func finish_route() -> void:
	# No teleport, injected HP, high roll or equipment: only legal movement/skills.
	for iteration: int in 20:
		if lab.phase==lab.Phase.VICTORY or lab.phase==lab.Phase.DEFEAT:
			break
		var target: TacticalEnemy = lab.enemies[1] if lab.enemies[1].hp>0 else lab.enemies[0]
		var desired: float = target.position.x-100 if lab.hero.position.x<target.position.x else target.position.x+100
		await walk_to(desired)
		lab.select_skill("shield")
		if not lab.attack(target):
			lab.defend()
		await frames(180)
	check(lab.phase==lab.Phase.VICTORY and lab.hero.hp>0,"低骰路線可通關")
	check(lab.raw==3,"全程保持低骰")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	await fresh()
	check(lab.enemies[1].caster and lab.raw==3,"法師與低骰起始")
	check(lab.intents[1].casting,"首回合預告施法")
	lab.end_turn()
	await frames(180)
	check(lab.hero.hp==9,"法術在掩體外造成預告的三傷害")
	check(lab.turn==2 and not lab.intents[1].casting,"第二回合法師恢復")
	lab.end_turn()
	await frames(180)
	check(lab.hero.hp==9,"恢复回合不施法")
	check(lab.intents[1].casting,"第三回合重新預告")
	await fresh()
	await walk_to(430)
	check(lab.COVER.has_point(lab.hero.position),"正常移動進掩體")
	lab.defend()
	await frames(180)
	check(lab.hero.hp==12,"掩體避法術、格擋護衛")
	check(lab.turn==2 and lab.guard==0,"格擋消耗回合並於下一回合解除")
	await finish_route()
	await fresh()
	lab.defend()
	await frames(180)
	check(lab.hero.hp==11,"掩體外格擋減傷但不完全免疫法術")
	await fresh()
	await walk_to(550)
	check(lab.hero.budget<=7,"突進路線實際消耗移動額度")
	lab.select_skill("charge")
	check(lab.attack(lab.enemies[1]),"低骰衝鋒能接近法師")
	check(lab.mage_interrupted,"命中打斷施法")
	check(not lab.attack(lab.enemies[1]),"結算時拒絕重複攻擊")
	await frames(180)
	check(lab.hero.hp==12,"打斷避免法術傷害")
	check(lab.turn==2 and lab.charge_ready_turn==3,"衝鋒下一回合冷卻")
	lab.select_skill("charge")
	check(not lab.attack(lab.enemies[1]) and lab.phase==lab.Phase.PLAN,"冷卻拒絕不消耗行動")
	await finish_route()
	await fresh()
	lab.select_skill("shield")
	check(not lab.attack(lab.enemies[1]),"射程外不能打斷")
	check(not lab.mage_interrupted and lab.phase==lab.Phase.PLAN,"非法打斷不改變回合")
	lab.hero.hp=0
	await frames(2)
	lab.defend()
	check(lab.phase==lab.Phase.DEFEAT,"死亡後不能格擋")
	if failures.is_empty():
		print("TACT02_SCENE_PASS count=",count)
		quit(0)
	else:
		printerr("TACT02_SCENE_FAIL ",failures)
		quit(1)
