class_name WarriorBody
extends CharacterBody2D

var hp: int = TacticalRules.PLAYER_HP
var budget: float = TacticalRules.MOVE_BUDGET
var axis: float = 0.0
var enabled: bool = true
var facing: float = 1.0
var attack_pose: float = 0.0
var flash: float = 0.0
var reduced: bool = false

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var collider: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(34, 60)
	collider.shape = shape
	add_child(collider)

func _physics_process(delta: float) -> void:
	var before: Vector2 = position
	velocity.x = axis * minf(230.0, budget / maxf(delta, 0.001)) if enabled and hp > 0 else 0.0
	velocity.y = minf(velocity.y + ShotRules.GRAVITY * delta, 1000.0)
	move_and_slide()
	if enabled:
		budget = maxf(0.0, budget - absf(position.x - before.x))
	if axis != 0 and enabled:
		facing = signf(axis)
	attack_pose = maxf(0, attack_pose - delta)
	flash = maxf(0, flash - delta)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	draw_circle(Vector2(0, 28), 23, Color(0, 0, 0, 0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(-16,-16),Vector2(-27,24),Vector2(12,22),Vector2(12,-15)]), Color("b04d42"))
	draw_line(Vector2(-8, 8), Vector2(-11, 28), Color("352e32"), 10)
	draw_line(Vector2(8, 8), Vector2(12, 28), Color("352e32"), 10)
	draw_rect(Rect2(-16, -13, 32, 29), Color.WHITE if flash > 0 and not reduced else Color("789aa6"))
	draw_line(Vector2(-15, -4), Vector2(15, -4), Color("bfd1cb"), 5)
	draw_circle(Vector2(0, -25), 14, Color("d5c7a3"))
	draw_rect(Rect2(-15,-37,30,14), Color("a7b9b6"))
	draw_rect(Rect2(1,-25,10,4), Color("2a3439"))
	var extension: float = 10 if attack_pose > 0 and not reduced else 0
	draw_line(Vector2(12,-5),Vector2(29+extension,-12),Color("e0b977"),6)
	draw_rect(Rect2(23+extension,-24,17,19),Color("aebdb5"))
	draw_colored_polygon(PackedVector2Array([Vector2(-23,-13),Vector2(-7,-10),Vector2(-7,9),Vector2(-15,19),Vector2(-25,8)]),Color("c39b58"))
	draw_line(Vector2(-17,-10),Vector2(-17,12),Color("f1d99d"),3)
	draw_set_transform(Vector2.ZERO)
