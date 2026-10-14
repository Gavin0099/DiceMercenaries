extends Node2D

enum Phase { READY, AIMING, RESOLVING, CLEAR }
var phase: Phase = Phase.READY
var player: PlayerBody
var targets: Array[TargetBody] = []
var projectile: ProjectileBody
var pointer: Vector2 = Vector2(720, 320)
var preview: PackedVector2Array = PackedVector2Array()
var terrain: Array[Rect2] = []
var shot_count: int = 0
var resolution_time: float = 0.0
var message: String = "Hold left mouse, aim, release. Try a low shot and a high arc."
var status: Label
var detail: Label
var hit_position: Vector2 = Vector2.ZERO
var hit_time: float = 0.0

func _ready() -> void:
	_build_terrain(Rect2(24, 600, 1232, 60))
	_build_terrain(Rect2(575, 500, 30, 100))
	_build_terrain(Rect2(985, 510, 160, 90))
	_build_terrain(Rect2(1210, 380, 26, 220))
	player = PlayerBody.new()
	player.position = Vector2(160, 575)
	add_child(player)
	for index: int in 2:
		var target: TargetBody = TargetBody.new()
		target.target_id = index + 1
		target.position = Vector2(820, 575) if index == 0 else Vector2(1080, 485)
		target.resolved.connect(_on_damage)
		targets.append(target)
		add_child(target)
	_build_hud()
	_update_hud()

func _build_terrain(rectangle: Rect2) -> void:
	terrain.append(rectangle)
	var body: StaticBody2D = StaticBody2D.new()
	body.position = rectangle.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	var collider: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = rectangle.size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func _label(text: String, at: Vector2, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _build_hud() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	layer.add_child(_label("DICE MERCENARIES", Vector2(40, 26), 30, Color("edf0e7")))
	layer.add_child(_label("DM-01  /  PHYSICS LAB", Vector2(42, 65), 14, Color("a4b2c3")))
	status = _label("", Vector2(40, 112), 22, Color("ffd68a"))
	status.size = Vector2(1160, 44)
	layer.add_child(status)
	detail = _label("", Vector2(40, 153), 17, Color("d1d9e3"))
	layer.add_child(detail)
	layer.add_child(_label("A / D  MOVE     SPACE  JUMP     HOLD + RELEASE  FIRE     ESC  CANCEL", Vector2(40, 657), 17, Color("d1d9e3")))
	layer.add_child(_label("Fixed terrain. No D20 or enemy turns in this slice.", Vector2(40, 687), 14, Color("91a0b3")))
	var reset: Button = Button.new()
	reset.text = "RESET  [R]"
	reset.position = Vector2(1070, 34)
	reset.size = Vector2(165, 42)
	reset.pressed.connect(reset_lab)
	layer.add_child(reset)

func muzzle() -> Vector2:
	return player.position + Vector2(26, -7)

func begin_aim(at: Vector2) -> void:
	if phase != Phase.READY or not player.is_on_floor():
		return
	pointer = at
	phase = Phase.AIMING
	player.movement_allowed = false

func cancel_aim() -> void:
	if phase == Phase.AIMING:
		phase = Phase.READY
		player.movement_allowed = true
		message = "Aim cancelled. No shot spent."

func release_aim(at: Vector2) -> void:
	if phase != Phase.AIMING:
		return
	pointer = at
	var prepared: Dictionary = ShotRules.prepare(muzzle(), at)
	if not bool(prepared.valid):
		cancel_aim()
		message = "Aim farther from the player (at least 24 px)."
		return
	shot_count += 1
	projectile = ProjectileBody.new()
	projectile.position = muzzle()
	projectile.shot_id = shot_count
	projectile.initial_velocity = prepared.velocity
	projectile.finished.connect(_on_projectile_finished)
	add_child(projectile)
	phase = Phase.RESOLVING
	resolution_time = 0
	message = "Shot in flight..."

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			cancel_aim()
		if event.keycode == KEY_R:
			reset_lab()
	if event is InputEventMouseMotion:
		pointer = get_global_transform_with_canvas().affine_inverse() * event.position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var at: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
		if event.pressed:
			begin_aim(at)
		else:
			release_aim(at)

func reset_lab() -> void:
	get_tree().reload_current_scene()

func _on_damage(target_id: int, kind: String, amount: int) -> void:
	message = "Target %d: %s  -%d HP" % [target_id, "direct hit" if kind == "direct" else "wall impact", amount]
	hit_position = targets[target_id - 1].position
	hit_time = 0.28

func _on_projectile_finished(reason: String) -> void:
	if reason == "terrain":
		message = "Blocked by terrain. Try a higher angle or move closer."
	elif reason == "miss":
		message = "Miss. Adjust angle or power; R resets the lab."

func _physics_process(delta: float) -> void:
	hit_time = maxf(0, hit_time - delta)
	if phase == Phase.RESOLVING:
		resolution_time += delta
		var settled: bool = true
		for target: TargetBody in targets:
			if not target.is_on_floor() or target.velocity.length() > 30:
				settled = false
		if not is_instance_valid(projectile) and (settled or resolution_time >= 4.0):
			phase = Phase.READY
			player.movement_allowed = true
			if targets[0].hp == 0 and targets[1].hp == 0:
				phase = Phase.CLEAR
				message = "LAB CLEAR — try another angle. Press R to replay."
	_build_preview()
	_update_hud()
	queue_redraw()

func _build_preview() -> void:
	preview.clear()
	if phase not in [Phase.READY, Phase.AIMING]:
		return
	var prepared: Dictionary = ShotRules.prepare(muzzle(), pointer)
	if not bool(prepared.valid):
		return
	var previous: Vector2 = muzzle()
	preview.append(previous)
	for index: int in range(1, 71):
		var next: Vector2 = ShotRules.point(muzzle(), prepared.velocity, index * 0.04)
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(previous, next, 1 | 2)
		var contact: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
		if not contact.is_empty():
			preview.append(contact.position)
			break
		preview.append(next)
		previous = next

func _update_hud() -> void:
	status.text = message
	var prepared: Dictionary = ShotRules.prepare(muzzle(), pointer)
	var power: int = roundi(float(prepared.get("strength", 0.0)) * 100)
	var angle: int = roundi(rad_to_deg(-(pointer - muzzle()).angle()))
	detail.text = "%s  |  ANGLE %d deg  |  POWER %d%%  |  SHOTS %d  |  TARGETS %d / 6   %d / 6" % [Phase.keys()[phase], angle, power, shot_count, targets[0].hp, targets[1].hp]

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("152333"))
	draw_rect(Rect2(24, 220, 1232, 414), Color("1b2c3d"))
	for x: int in range(40, 1260, 40):
		draw_line(Vector2(x, 225), Vector2(x, 632), Color("223649"), 1)
	for y: int in range(240, 632, 40):
		draw_line(Vector2(28, y), Vector2(1250, y), Color("223649"), 1)
	for rectangle: Rect2 in terrain:
		draw_rect(rectangle, Color("536274"))
		draw_rect(rectangle, Color("8391a0"), false, 2)
		draw_line(rectangle.position, rectangle.position + Vector2(rectangle.size.x, 0), Color("bac3c5"), 3)
	for index: int in range(1, preview.size()):
		if index % 2 == 1:
			draw_line(preview[index - 1], preview[index], Color("bcebe4"), 2)
	if preview.size() > 1:
		draw_circle(preview[-1], 9, Color("ffd68a"), false, 2)
	if phase == Phase.AIMING:
		draw_line(muzzle(), pointer, Color(0.7, 0.9, 0.9, 0.3), 1)
		draw_circle(pointer, 12, Color("bcebe4"), false, 2)
	if hit_time > 0:
		draw_circle(hit_position, 27 + (0.28 - hit_time) * 90, Color(1, 0.82, 0.5, hit_time / 0.28), false, 3)
