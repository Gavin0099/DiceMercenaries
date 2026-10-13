extends SceneTree

# Real Godot scripted capture: no claim of human play acceptance.
var lab: Node2D
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("capture")

func frames(number: int) -> void:
	for index: int in number:
		await physics_frame

func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	var result: Error = root.get_texture().get_image().save_png("res://artifacts/evidence/dm-02/" + name + ".png")
	if result != OK:
		failures.append("cannot save " + name)

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/evidence/dm-02")
	for mode: int in 3:
		if is_instance_valid(lab):
			lab.queue_free()
			await process_frame
		root.set_meta("dm02_mode", mode)
		lab = load("res://scenes/battle/terrain_lab.tscn").instantiate()
		root.add_child(lab)
		current_scene = lab
		await frames(45)
		if mode == 0:
			lab.player.position = Vector2(450, 575)
			await frames(4)
		var aim: Vector2 = [Vector2(490, -98), Vector2(383, -321), Vector2(410, -286)][mode]
		lab.begin_aim(lab.muzzle() + aim)
		await frames(25)
		await snap("case%d-before" % [mode + 1])
		lab.release_aim(lab.muzzle() + aim)
		await frames(160)
		await snap("case%d-after" % [mode + 1])
		if not lab.modules[0].broken:
			failures.append("player shot did not break case " + str(mode))
		var expected_hp: int = [6, 4, 0][mode]
		if lab.targets[0].hp != expected_hp:
			failures.append("case HP " + str(mode) + ": " + str(lab.targets[0].hp))
		print("DM02_CAPTURE_CASE mode=", mode, " broken=", lab.modules[0].broken, " target_hp=", lab.targets[0].hp)
	if failures.is_empty():
		print("DM02_CAPTURE_PASS")
		quit(0)
	else:
		printerr("DM02_CAPTURE_FAIL: ", failures)
		quit(1)
