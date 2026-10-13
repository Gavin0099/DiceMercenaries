class_name TacticalEnemy
extends TargetBody

var facing: float = -1.0

func _draw() -> void:
	if hp <= 0:
		draw_rect(Rect2(-22, 14, 44, 12), Color("655f59"))
		return
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	draw_circle(Vector2(0, 20), 20, Color(0,0,0,0.25))
	draw_line(Vector2(-7,5),Vector2(-10,20),Color("353d37"),8)
	draw_line(Vector2(7,5),Vector2(11,20),Color("353d37"),8)
	draw_rect(Rect2(-14,-9,28,24),Color("a46b49"))
	draw_circle(Vector2(0,-20),15,Color.WHITE if hit_flash>0 and not reduced_motion else Color("91a376"))
	draw_colored_polygon(PackedVector2Array([Vector2(-11,-27),Vector2(-24,-29),Vector2(-14,-14)]),Color("91a376"))
	draw_colored_polygon(PackedVector2Array([Vector2(11,-27),Vector2(24,-29),Vector2(14,-14)]),Color("91a376"))
	draw_line(Vector2(3,-21),Vector2(11,-21),Color("283c31"),3)
	draw_line(Vector2(12,-4),Vector2(32,-17),Color("cab798"),4)
	draw_circle(Vector2(33,-19),9,Color("8b8272"))
	draw_set_transform(Vector2.ZERO)
	for index: int in ShotRules.MAX_HP:
		draw_rect(Rect2(-23 + index * 8,-48,6,5),Color("d9bb7c") if index<hp else Color("493c36"))
