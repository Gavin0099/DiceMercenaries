class_name ProjectileBody
extends Node2D

signal finished(reason: String)
var shot_id: int
var initial_velocity: Vector2
var velocity: Vector2
var origin: Vector2
var elapsed: float = 0.0
var spent: bool = false
var trail: Array[Vector2] = []

func _ready() -> void:
	origin = position
	velocity = initial_velocity

func _physics_process(delta: float) -> void:
	if spent:
		return
	elapsed += delta
	var destination: Vector2 = ShotRules.point(origin, initial_velocity, elapsed)
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(position, destination, 1 | 2)
	var contact: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	velocity = initial_velocity + Vector2(0, ShotRules.GRAVITY * elapsed)
	if not contact.is_empty():
		position = contact.position
		var collider: Object = contact.collider
		if collider is TargetBody:
			(collider as TargetBody).receive_hit(shot_id, velocity)
			_finish("target")
		elif collider is BreakableTerrain:
			(collider as BreakableTerrain).receive_hit(shot_id)
			_finish("breakable")
		else:
			_finish("terrain")
		return
	position = destination
	trail.append(position)
	if trail.size() > 12:
		trail.pop_front()
	if elapsed >= 3.0 or position.y > 740 or position.x < -60 or position.x > 1340:
		_finish("miss")
	queue_redraw()

func _finish(reason: String) -> void:
	if spent:
		return
	spent = true
	finished.emit(reason)
	queue_free()

func _draw() -> void:
	for index: int in range(1, trail.size()):
		draw_line(trail[index - 1] - position, trail[index] - position, Color(0.97, 0.72, 0.36, float(index) / 16.0), 3)
	draw_circle(Vector2.ZERO, 7, Color("ffd68a"))
	draw_circle(Vector2.ZERO, 7, Color("fff0c4"), false, 2)
