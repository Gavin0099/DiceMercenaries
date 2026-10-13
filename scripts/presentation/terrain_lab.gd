extends "res://scripts/presentation/physics_lab.gd"

var mode: int = 0
var modules: Array[BreakableTerrain] = []
var reduced_motion: bool = false
var motion_status: Label
const PIT: Rect2 = Rect2(600, 650, 400, 110)
const TITLES: Array[String] = ["1  /  BREAK THE WALL", "2  /  DROP TO A LOWER FLOOR", "3  /  BREAK THE BRIDGE"]

func _ready() -> void:
	mode = int(get_tree().root.get_meta("dm02_mode", 0))
	if mode not in [0, 1, 2]:
		mode = 0
	slice_caption = "DM-02  /  TERRAIN LAB"
	footer_caption = "Breakable modules. No D20 or enemy turns. M toggles decorative effects."
	reduced_motion = bool(get_tree().root.get_meta("dm02_reduce", false))
	if mode == 2:
		_build_terrain(Rect2(24, 600, 576, 60))
		_build_terrain(Rect2(1000, 600, 256, 60))
		_build_module("bridge", Rect2(600, 430, 400, 22))
	else:
		_build_terrain(Rect2(24, 600, 1232, 60))
		if mode == 0:
			_build_module("thin wall", Rect2(575, 500, 30, 100))
		else:
			_build_module("platform", Rect2(730, 400, 180, 22))
		_build_terrain(Rect2(985, 510, 160, 90))
	_build_terrain(Rect2(1210, 380, 26, 220))
	player = PlayerBody.new()
	player.position = Vector2(160, 575)
	add_child(player)
	for index: int in 2:
		var target: TargetBody = TargetBody.new()
		target.target_id = index + 1
		target.fall_damage_enabled = true
		target.reduced_motion = reduced_motion
		target.position = Vector2(820, 575) if mode == 0 else Vector2(820, 375 if mode == 1 else 405)
		if index == 1:
			target.position = Vector2(1080, 575 if mode == 2 else 485)
		if mode == 2:
			target.deep_pit = PIT
		target.resolved.connect(_on_damage)
		targets.append(target)
		add_child(target)
	_build_hud()
	_build_selector()
	message = ["Break the amber wall, then fire through the opening.", "Break the amber platform: the target falls for up to 2 HP.", "DANGER: break the bridge to drop ordinary enemies into the deep pit."][mode]
	_update_hud()

func _build_module(id: String, rectangle: Rect2) -> void:
	var module: BreakableTerrain = BreakableTerrain.new()
	module.module_id = id
	module.position = rectangle.get_center()
	module.size = rectangle.size
	module.reduced_motion = reduced_motion
	module.destroyed.connect(_on_module_destroyed)
	modules.append(module)
	add_child(module)

func _build_selector() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	for index: int in 3:
		var button: Button = Button.new()
		button.text = ["1  WALL", "2  PLATFORM", "3  DEEP PIT"][index]
		button.position = Vector2(570 + index * 160, 34)
		button.size = Vector2(150, 42)
		button.pressed.connect(select_mode.bind(index))
		layer.add_child(button)
	layer.add_child(_label("M  REDUCE EFFECTS  |  " + TITLES[mode], Vector2(42, 198), 14, Color("f1cd91")))
	motion_status = _label("", Vector2(1040, 198), 14, Color("f1cd91"))
	layer.add_child(motion_status)

func _update_hud() -> void:
	super._update_hud()
	if is_instance_valid(motion_status):
		motion_status.text = "EFFECTS: " + ("REDUCED" if reduced_motion else "ON")

func select_mode(index: int) -> void:
	if index not in [0, 1, 2]:
		return
	get_tree().root.set_meta("dm02_mode", index)
	reset_lab()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_1, KEY_2, KEY_3]:
			select_mode(int(event.keycode) - int(KEY_1))
			return
		if event.keycode == KEY_M:
			set_reduced_motion(not reduced_motion)
			return
	super._unhandled_input(event)

func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	get_tree().root.set_meta("dm02_reduce", enabled)
	hit_time = 0
	for module: BreakableTerrain in modules:
		module.reduced_motion = enabled
	for target: TargetBody in targets:
		target.reduced_motion = enabled
	message = "Decorative effects " + ("reduced" if enabled else "enabled") + ". Physics and damage are unchanged."

func _on_module_destroyed(id: String, _shot_id: int) -> void:
	message = id.capitalize() + " destroyed — collision removed."

func _on_damage(target_id: int, kind: String, amount: int) -> void:
	message = "Target %d: %s  -%d HP" % [target_id, kind, amount]
	if not reduced_motion:
		hit_position = targets[target_id - 1].position
		hit_time = 0.28

func _draw() -> void:
	super._draw()
	if mode == 2:
		draw_rect(PIT, Color("5e2938"))
		for x: int in range(600, 1000, 28):
			draw_line(Vector2(x, 650), Vector2(x + 20, 668), Color("f1aa91"), 3)
