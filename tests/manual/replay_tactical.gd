extends SceneTree

var lab: Node2D
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("capture")

func frames(n: int) -> void:
	for index: int in n:
		await physics_frame

func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png("res://artifacts/evidence/tact-01/"+name+".png")!=OK:
		failures.append("screenshot "+name)

func fresh() -> void:
	if is_instance_valid(lab):
		lab.queue_free()
		await process_frame
	lab=load("res://scenes/battle/tactical_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene=lab
	await frames(30)

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/evidence/tact-01")
	await fresh()
	await snap("ready")
	lab.hero.position.x=550
	await frames(2)
	lab.select_skill("shield")
	await snap("shield-preview")
	if not lab.attack(lab.enemies[0]):
		failures.append("shield rejected")
	await frames(7)
	await snap("shield-impact")
	await frames(170)
	await snap("response")
	await fresh()
	lab.hero.position.x=680
	await frames(2)
	lab.select_skill("charge")
	await snap("bridge-before")
	if not lab.attack(lab.bridge):
		failures.append("bridge attack rejected")
	await frames(100)
	await snap("bridge-after")
	if not lab.bridge.broken or lab.enemies[1].hp!=0 or lab.hero.hp<=0:
		failures.append("bridge outcome")
	# Same inputs under reduced motion must produce the same gameplay state.
	var normal: Array = [lab.hero.hp,lab.enemies[0].hp,lab.enemies[1].hp,lab.turn,lab.bridge.broken]
	await fresh()
	lab.toggle_motion()
	lab.hero.position.x=680
	await frames(2)
	lab.select_skill("charge")
	lab.attack(lab.bridge)
	await frames(100)
	var reduced: Array = [lab.hero.hp,lab.enemies[0].hp,lab.enemies[1].hp,lab.turn,lab.bridge.broken]
	if normal!=reduced:
		failures.append("reduced motion changed rules")
	await snap("bridge-reduced")
	if failures.is_empty():
		print("TACT01_CAPTURE_PASS")
		quit(0)
	else:
		printerr("TACT01_CAPTURE_FAIL ",failures)
		quit(1)
