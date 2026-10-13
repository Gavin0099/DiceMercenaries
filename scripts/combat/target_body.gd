class_name TargetBody
extends CharacterBody2D

signal resolved(target_id: int, kind: String, amount: int)
var target_id: int = 0
var hp: int = ShotRules.MAX_HP
var last_shot: int = 0
var consumed: Array[String] = []
var hit_flash: float = 0.0
var spawn_position: Vector2
var knocked_out: bool = false
var fall_damage_enabled: bool = false
var airborne: bool = true
var air_peak_y: float = 0.0
var deep_pit: Rect2 = Rect2()
var is_boss: bool = false
var deep_recovery: Vector2 = Vector2(500, 575)
var reduced_motion: bool = false

func _ready() -> void:
	spawn_position = position
	air_peak_y = position.y
	collision_layer = 2
	collision_mask = 1 | 2
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = Vector2(32.0, 44.0)
	shape.shape = rectangle
	add_child(shape)

func receive_hit(shot_id: int, incoming: Vector2) -> void:
	if hp <= 0:
		return
	last_shot = shot_id
	_apply_damage("direct")
	velocity = Vector2(clampf(incoming.x * 0.7, -550.0, 550.0), -190.0)
	hit_flash = 0.22

func _apply_damage(kind: String) -> void:
	var result: Dictionary = ShotRules.damage(hp, kind, last_shot, consumed)
	if int(result.amount) == 0:
		return
	hp = int(result.hp)
	consumed.append(str(result.token))
	resolved.emit(target_id, kind, int(result.amount))
	if hp == 0:
		_disable_target()

func _disable_target() -> void:
	knocked_out = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 1)

func _fall_damage(distance: float, deep: bool) -> void:
	var amount: int = TerrainRules.fall_damage(hp, distance, deep, is_boss)
	if amount == 0:
		return
	hp -= amount
	resolved.emit(target_id, "deep pit" if deep else "fall", amount)
	hit_flash = 0.22
	if hp == 0:
		_disable_target()

func _physics_process(delta: float) -> void:
	if fall_damage_enabled and not is_on_floor():
		if not airborne:
			air_peak_y = position.y
			airborne = true
		air_peak_y = minf(air_peak_y, position.y)
	velocity.y = minf(velocity.y + ShotRules.GRAVITY * delta, 1000.0)
	var incoming: Vector2 = velocity
	move_and_slide()
	for index: int in get_slide_collision_count():
		var contact: KinematicCollision2D = get_slide_collision(index)
		if absf(contact.get_normal().x) > 0.7 and absf(incoming.x) > 160.0 and contact.get_collider() is StaticBody2D:
			_apply_damage("wall")
			hit_flash = 0.22
	if is_on_floor():
		if fall_damage_enabled and airborne:
			_fall_damage(maxf(0, position.y - air_peak_y), false)
		airborne = false
		air_peak_y = position.y
		velocity.x = move_toward(velocity.x, 0.0, 650.0 * delta)
	if fall_damage_enabled and deep_pit.has_point(position) and hp > 0:
		_fall_damage(maxf(0, position.y - air_peak_y), true)
		if hp > 0:
			# Only the policy adapter is provided; no Boss encounter in this slice.
			position = deep_recovery
			velocity = Vector2.ZERO
			air_peak_y = position.y
		else:
			visible = false
			set_physics_process(false)
	# DM-01 retains its safe containment; DM-02 deep pits resolve before this.
	if position.y > 760.0:
		position = spawn_position
		velocity = Vector2.ZERO
	hit_flash = maxf(0.0, hit_flash - delta)
	queue_redraw()

func _draw() -> void:
	var color: Color = Color("f3be65") if hp > 0 else Color("596777")
	if hit_flash > 0.0 and not reduced_motion:
		color = Color.WHITE
	draw_rect(Rect2(-16, -22, 32, 44), color)
	draw_rect(Rect2(-16, -22, 32, 44), Color("253342"), false, 3.0)
	draw_line(Vector2(-8, -7), Vector2(8, -7), Color("253342"), 3.0)
	for index: int in ShotRules.MAX_HP:
		draw_rect(Rect2(-21 + index * 7, -36, 5, 5), Color("8ce0b4") if index < hp else Color("3c4857"))
