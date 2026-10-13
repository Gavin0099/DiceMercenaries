extends SceneTree

var lab: Node2D

func _initialize() -> void:
	call_deferred("capture")

func frames(n: int) -> void:
	for index: int in n:
		await physics_frame

func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	var error: int = root.get_texture().get_image().save_png("res://artifacts/evidence/tact-02/"+name+".png")
	if error!=OK:
		quit(1)

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/evidence/tact-02")
	lab = load("res://scenes/battle/counterplay_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	await frames(30)
	await snap("ready")
	lab.destination = 430
	await frames(90)
	lab.defend()
	await frames(180)
	await snap("cover-recovery")
	print("TACT02_CAPTURE_PASS")
	quit(0)
