extends SceneTree

# Scripted native capture, not human play/fun acceptance.
var lab: Node2D

func _initialize() -> void:
	call_deferred("capture")

func frames(number: int) -> void:
	for index: int in number:
		await physics_frame

func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	var error: Error = root.get_texture().get_image().save_png("res://artifacts/evidence/dm-01/" + name + ".png")
	if error != OK:
		printerr("DM01_CAPTURE_FAIL ", error)
		quit(1)

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/evidence/dm-01")
	lab = load("res://scenes/battle/physics_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	await frames(45)
	await snap("ready")
	lab.begin_aim(lab.muzzle() + Vector2(190, -462))
	await frames(30)
	await snap("aiming")
	lab.release_aim(lab.muzzle() + Vector2(190, -462))
	await frames(112)
	await snap("impact")
	await frames(190)
	await snap("settled")
	print("DM01_CAPTURE_PASS target1_hp=", lab.targets[0].hp)
	quit(0)
