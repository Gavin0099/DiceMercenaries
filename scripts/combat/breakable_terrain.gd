class_name BreakableTerrain
extends StaticBody2D

signal destroyed(module_id: String, shot_id: int)
var module_id: String = "wall"
var size: Vector2 = Vector2(30, 100)
var hp: int = 2
var seen: Array[int] = []
var broken: bool = false
var reduced_motion: bool = false
var break_time: float = 0.0
var shape_node: CollisionShape2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	shape_node = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape
	add_child(shape_node)

func receive_hit(shot_id: int) -> void:
	var result: Dictionary = TerrainRules.strike(hp, shot_id, seen)
	if not bool(result.accepted):
		return
	seen.append(shot_id)
	hp = int(result.hp)
	if bool(result.destroyed):
		broken = true
		# Physics removal is not delayed by the decorative break animation.
		set_deferred("collision_layer", 0)
		shape_node.set_deferred("disabled", true)
		break_time = 0.24
		destroyed.emit(module_id, shot_id)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if broken:
		break_time = maxf(0, break_time - delta)
		queue_redraw()

func _draw() -> void:
	if not broken:
		draw_rect(Rect2(-size * 0.5, size), Color("c18b50"))
		draw_rect(Rect2(-size * 0.5, size), Color("ffe0a1"), false, 3)
		draw_line(Vector2(-size.x * 0.25, -size.y * 0.25), Vector2(size.x * 0.25, size.y * 0.25), Color("4a3429"), 3)
		draw_circle(Vector2.ZERO, 5, Color("ffe0a1"), false, 2)
	elif break_time > 0 and not reduced_motion:
		# No child physics bodies, no hit regions and no damage from debris.
		var progress: float = 1.0 - break_time / 0.24
		for index: int in 5:
			var offset: Vector2 = Vector2((index - 2) * (8 + progress * 30), progress * progress * 45)
			draw_rect(Rect2(offset - Vector2(4, 4), Vector2(8, 8)), Color(0.95, 0.73, 0.4, 1.0 - progress))
