class_name PlayerBody
extends CharacterBody2D

var movement_allowed: bool = true
var facing: float = 1.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = Vector2(34, 48)
	shape.shape = rectangle
	add_child(shape)

func _physics_process(delta: float) -> void:
	var axis: float = 0.0
	if movement_allowed:
		axis = float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
		if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
			velocity.y = -390
	velocity.x = axis * 210
	if axis != 0:
		facing = axis
	velocity.y = minf(velocity.y + ShotRules.GRAVITY * delta, 1000)
	move_and_slide()
	position.x = clampf(position.x, 42, 530)
	if position.y > 760:
		position = Vector2(160, 575)
		velocity = Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-17, -24, 34, 48), Color("9ad7df"))
	draw_rect(Rect2(-17, -24, 34, 48), Color("253342"), false, 3)
	draw_rect(Rect2(-13, -17, 26, 8), Color("253342"))
	draw_line(Vector2(18 * facing, -2), Vector2(28 * facing, -2), Color("ecf3ef"), 5)
