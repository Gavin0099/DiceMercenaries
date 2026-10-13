extends SceneTree

var failures: Array[String] = []
var count: int = 0
var lab: Node2D
var events: Array[String] = []

func check(value: bool, label: String) -> void:
	count += 1
	if not value:
		failures.append(label)

func frames(number: int) -> void:
	for index: int in number:
		await physics_frame

func load_mode(mode: int) -> void:
	if is_instance_valid(lab):
		lab.queue_free()
		await process_frame
	root.set_meta("dm02_mode", mode)
	root.set_meta("dm02_reduce", false)
	lab = load("res://scenes/battle/terrain_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	events.clear()
	lab.targets[0].resolved.connect(record)
	await frames(40)

func record(_id: int, kind: String, amount: int) -> void:
	events.append(kind + ":" + str(amount))

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/battle/terrain_lab.tscn", "DM02 is actual main scene")
	await load_mode(0)
	lab.select_mode(-1)
	check(lab.mode == 0, "invalid mode selector preserves current case")
	var wall: BreakableTerrain = lab.modules[0]
	var ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(Vector2(550, 540), Vector2(630, 540), 1)
	check(not lab.get_world_2d().direct_space_state.intersect_ray(ray).is_empty(), "intact wall blocks ray")
	var projectile: ProjectileBody = ProjectileBody.new()
	projectile.position = Vector2(550, 540)
	projectile.initial_velocity = Vector2(600, 0)
	projectile.shot_id = 1
	lab.add_child(projectile)
	await frames(10)
	check(wall.broken and wall.hp == 0, "real projectile breaks wall")
	check(wall.shape_node.disabled and wall.collision_layer == 0, "broken collider disabled")
	check(lab.get_world_2d().direct_space_state.intersect_ray(ray).is_empty(), "ray passes former wall")
	wall.receive_hit(1)
	wall.receive_hit(2)
	check(wall.seen.size() == 1, "duplicate and later hits cannot repeat break")
	check(wall.get_child_count() == 1, "decorative debris adds no physics children")
	# Re-use normal player fire through a broken wall and reach an enemy.
	lab.player.position = Vector2(450, 575)
	await frames(3)
	lab.begin_aim(lab.muzzle() + Vector2(490, -98))
	lab.release_aim(lab.muzzle() + Vector2(490, -98))
	await frames(250)
	check(lab.targets[0].hp < 6, "player projectile can use destroyed-wall opening")
	await load_mode(1)
	var target: TargetBody = lab.targets[0]
	check(target.is_on_floor() and target.hp == 6, "platform initially supports target")
	var platform: BreakableTerrain = lab.modules[0]
	platform.receive_hit(11)
	await frames(120)
	check(target.position.y > 550 and target.is_on_floor(), "platform removal causes real fall to floor")
	check(target.hp == 4, "200px shallow landing deals two")
	check(events.count("fall:2") == 1, "one fall event per landing")
	await frames(120)
	check(target.hp == 4, "resting contact never repeats fall damage")
	# A later fall is a new landing, not permanently suppressed.
	target.position = Vector2(820, 375)
	target.velocity = Vector2.ZERO
	await frames(120)
	check(target.hp == 2 and events.count("fall:2") == 2, "distinct later landing can damage again")
	await load_mode(2)
	var bridge: BreakableTerrain = lab.modules[0]
	target = lab.targets[0]
	bridge.receive_hit(21)
	await frames(130)
	check(target.hp == 0 and not target.visible, "ordinary enemy deep pit defeated once")
	check(events.count("deep pit:6") == 1, "deep-pit event exactly once")
	check(lab.targets[1].hp == 6, "unaffected target survives")
	# Static danger remains; reduced effects must preserve exactly the same result.
	await load_mode(2)
	lab.set_reduced_motion(true)
	bridge = lab.modules[0]
	bridge.receive_hit(22)
	await frames(130)
	check(lab.targets[0].hp == 0 and lab.targets[1].hp == 6, "reduced motion has same HP result")
	check(bridge.reduced_motion and bridge.shape_node.disabled, "reduced effects do not defer collision removal")
	# Policy adapter prevents a healthy Boss from disappearing after one deep drop.
	await load_mode(2)
	lab.targets[0].is_boss = true
	lab.modules[0].receive_hit(31)
	await frames(160)
	check(lab.targets[0].hp == 4 and lab.targets[0].visible, "Boss adapter preserves living target")
	check(lab.targets[0].position.x < 600 and lab.targets[0].is_on_floor(), "Boss adapter recovers to safe floor")
	# Selector/reset cancels old flight and rebuilds all modules.
	lab.set_reduced_motion(true)
	lab.begin_aim(lab.muzzle() + Vector2(190, -462))
	lab.release_aim(lab.muzzle() + Vector2(190, -462))
	lab.select_mode(1)
	await frames(45)
	lab = current_scene as Node2D
	check(lab.mode == 1 and lab.shot_count == 0 and not lab.modules[0].broken, "mode switch resets flight and module state")
	check(lab.targets[0].hp == 6 and lab.reduced_motion, "reset preserves effects preference, resets HP")
	if failures.is_empty():
		print("DM02_PHYSICS_PASS count=", count)
		quit(0)
	else:
		printerr("DM02_PHYSICS_FAIL: ", failures)
		quit(1)
