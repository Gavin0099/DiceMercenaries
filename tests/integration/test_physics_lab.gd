extends SceneTree

var failures: Array[String] = []
var count: int = 0
var lab: Node2D

func check(condition: bool, label: String) -> void:
	count += 1
	if not condition:
		failures.append(label)

func frames(number: int) -> void:
	for index: int in number:
		await physics_frame

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	# Retained DM-01 fixture; the DM-02 test verifies the current shipped entry.
	var path: String = "res://scenes/battle/physics_lab.tscn"
	check(ResourceLoader.exists(path), "retained DM01 fixture exists")
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		printerr("DM01_PHYSICS_FAIL: cannot load lab")
		quit(1)
		return
	lab = packed.instantiate()
	root.add_child(lab)
	await frames(40)
	check(lab.targets.size() == 2, "two targets")
	check(lab.player.is_on_floor(), "player landed")
	check(lab.targets[0].is_on_floor() and lab.targets[1].is_on_floor(), "targets landed")
	lab.begin_aim(Vector2(800, 380))
	check(lab.phase == lab.Phase.AIMING, "aim locks phase")
	check(not lab.player.movement_allowed, "aim locks movement")
	var cancel: InputEventKey = InputEventKey.new()
	cancel.keycode = KEY_ESCAPE
	cancel.pressed = true
	lab._unhandled_input(cancel)
	check(lab.phase == lab.Phase.READY and lab.shot_count == 0, "escape cancels without shot")
	lab.release_aim(Vector2(800, 380))
	check(lab.shot_count == 0, "release after cancel does not fire")
	lab.begin_aim(lab.muzzle())
	lab.release_aim(lab.muzzle())
	check(lab.phase == lab.Phase.READY and lab.shot_count == 0, "invalid aim remains usable")
	# Real projectile/terrain collision: low horizontal shot is stopped by wall.
	var press: InputEventMouseButton = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = lab.muzzle() + Vector2(500, 0)
	press.pressed = true
	Input.parse_input_event(press)
	await frames(2)
	check(lab.phase == lab.Phase.AIMING, "mouse input begins aim")
	var release: InputEventMouseButton = press.duplicate() as InputEventMouseButton
	release.pressed = false
	Input.parse_input_event(release)
	await frames(2)
	check(lab.shot_count == 1, "shot counted once")
	lab.release_aim(Vector2(800, 380))
	check(lab.shot_count == 1, "cannot fire during resolution")
	await frames(260)
	check(lab.phase == lab.Phase.READY, "terrain shot returns to ready")
	check(lab.targets[0].hp == 6 and lab.targets[1].hp == 6, "terrain blocks damage")
	# A fixed high-arc player shot must clear the central wall and hit target one.
	lab.begin_aim(lab.muzzle() + Vector2(190, -462))
	lab.release_aim(lab.muzzle() + Vector2(190, -462))
	await frames(250)
	check(lab.targets[0].hp >= 3 and lab.targets[0].hp <= 4, "player high arc clears wall and hits target")
	# Place a real projectile beside the target to isolate swept collision.
	var target: TargetBody = lab.targets[0]
	target.hp = 6
	target.consumed.clear()
	target.position = target.spawn_position
	target.velocity = Vector2.ZERO
	await frames(10)
	var start_x: float = target.position.x
	var bullet: ProjectileBody = ProjectileBody.new()
	bullet.position = target.position + Vector2(-70, -5)
	bullet.initial_velocity = Vector2(900, 0)
	bullet.shot_id = 99
	lab.add_child(bullet)
	await frames(12)
	check(target.hp == 4, "swept target hit resolves direct damage")
	check(target.position.x > start_x + 10, "impact moves target")
	await frames(160)
	check(target.hp >= 3, "one shot cannot exceed direct plus wall damage")
	# Controlled real wall impact; it must not retrigger while touching the wall.
	target.hp = 6
	target.consumed.clear()
	target.position = Vector2(1180, 572)
	target.receive_hit(100, Vector2(900, 0))
	await frames(70)
	check(target.hp == 3, "direct plus wall damage in isolated fixture")
	await frames(100)
	check(target.hp == 3, "wall contact does not repeat damage")
	check(target.is_on_floor(), "target settles on floor")
	# Out-of-bounds projectile terminates, preventing permanent resolution lock.
	var miss: ProjectileBody = ProjectileBody.new()
	miss.position = Vector2(50, 250)
	miss.initial_velocity = Vector2(-900, -100)
	miss.shot_id = 101
	lab.add_child(miss)
	await frames(30)
	check(not is_instance_valid(miss), "out-of-bounds projectile expires")
	current_scene = lab
	lab.begin_aim(lab.muzzle() + Vector2(190, -462))
	lab.release_aim(lab.muzzle() + Vector2(190, -462))
	var reset: InputEventKey = InputEventKey.new()
	reset.keycode = KEY_R
	reset.pressed = true
	lab._unhandled_input(reset)
	await frames(45)
	lab = current_scene as Node2D
	check(lab.shot_count == 0 and lab.targets[0].hp == 6 and lab.targets[1].hp == 6, "R resets HP and shots mid-flight")
	check(lab.phase == lab.Phase.READY and not is_instance_valid(lab.projectile), "reset frees old projectile and restores input")
	if failures.is_empty():
		print("DM01_PHYSICS_PASS count=", count)
		quit(0)
	else:
		printerr("DM01_PHYSICS_FAIL: ", failures)
		quit(1)
