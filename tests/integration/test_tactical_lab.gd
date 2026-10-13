extends SceneTree

var lab: Node2D
var failures: Array[String] = []
var count: int = 0

func check(ok: bool, name: String) -> void:
	count+=1
	if not ok:
		failures.append(name)

func frames(n: int) -> void:
	for index: int in n:
		await physics_frame

func fresh() -> void:
	if is_instance_valid(lab):
		lab.queue_free()
		await process_frame
	lab = load("res://scenes/battle/tactical_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	await frames(20)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	await fresh()
	check(lab.hero.hp==12 and lab.enemies.size()==2,"one warrior and two enemies")
	check(lab.intents.size()==2,"both enemies telegraph before input")
	check(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/battle/tactical_lab.tscn","tactical encounter is the playable entry point")
	check(lab.hero.is_on_floor(),"warrior has actual floor collision")
	lab.select_skill("shield")
	check(not lab.attack(lab.enemies[0]),"out of range attack rejected")
	check(lab.phase==lab.Phase.PLAN and lab.attack_id==0,"invalid attack spends no turn")
	check(not lab.attack(lab.hero),"unsupported target rejected")
	lab.hero.position.x = 550
	await frames(2)
	check(lab.attack(lab.enemies[0]),"nearby basic shield accepted")
	check(lab.enemies[0].hp==4,"one hit causes exactly two direct damage")
	check(not lab.attack(lab.enemies[0]),"double click during resolution rejected")
	check(lab.enemies[0].hp==4,"double input never repeats damage")
	await frames(180)
	check(lab.turn==2 and lab.phase==lab.Phase.PLAN,"physics settles then enemy response then next turn")
	check(lab.hero.hp==12,"knockback interrupts dangerous sweep")
	await fresh()
	lab.hero.axis=1
	lab.hero.enabled=true
	# Continuous physical travel is accumulated, not final displacement.
	lab.set_physics_process(false)
	await frames(100)
	check(lab.hero.budget<=0.1,"finite movement budget exhausts")
	check(lab.hero.position.x<=591,"movement cannot exceed 240px allowance")
	lab.hero.axis=-1
	await frames(20)
	check(lab.hero.position.x>=589,"reversing does not refund movement")
	await fresh()
	lab.hero.position.x=680
	await frames(2)
	lab.select_skill("charge")
	check(lab.attack(lab.bridge),"charge can destroy bridge from near lip")
	check(lab.bridge.broken,"bridge destruction changes module state")
	await frames(150)
	check(lab.enemies[1].hp==0,"enemy physically falls into exposed pit")
	check(lab.hero.hp>0 and lab.hero.position.y<600,"bridge attack does not relocate warrior into pit")
	check(lab.turn==2,"bridge destruction still advances one turn")
	await fresh()
	lab.hero.position.x=530
	await frames(2)
	lab.end_turn()
	await frames(120)
	check(lab.hero.hp==10,"standing in forecast takes announced two damage")
	await fresh()
	lab.set_roll(17)
	check(lab.raw==17,"fixed comparison roll can change before moving")
	lab.hero.budget=100
	lab.set_roll(20)
	check(lab.raw==17,"cannot change comparison roll after moving")
	lab.select_skill("shield")
	lab.select_skill("move")
	check(lab.attack_id==0,"cancel never commits action")
	lab.toggle_motion()
	check(lab.reduced and lab.hero.hp==12 and lab.attack_id==0,"reduced motion preserves rules")
	await fresh()
	lab.hero.hp=0
	await frames(2)
	check(lab.phase==lab.Phase.DEFEAT,"player death blocks turn progression")
	lab.enemies[0].hp=0
	lab.enemies[1].hp=0
	await frames(2)
	check(lab.phase==lab.Phase.DEFEAT,"simultaneous defeat does not become victory")
	if failures.is_empty():
		print("TACT01_SCENE_PASS count=",count)
		quit(0)
	else:
		printerr("TACT01_SCENE_FAIL ",failures)
		quit(1)
