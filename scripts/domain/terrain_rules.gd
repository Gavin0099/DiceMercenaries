class_name TerrainRules
extends RefCounted

# Pure fixed-module and fall rules; callers supply measured fall distance.
static func strike(hp: int, shot_id: int, seen: Array[int]) -> Dictionary:
	if hp <= 0 or shot_id <= 0 or shot_id in seen:
		return {"hp": hp, "accepted": false, "destroyed": false}
	var next_hp: int = maxi(0, hp - 2)
	return {"hp": next_hp, "accepted": true, "destroyed": next_hp == 0}

static func fall_damage(hp: int, distance: float, deep: bool = false, boss: bool = false) -> int:
	if hp <= 0 or not is_finite(distance) or distance < 0:
		return 0
	if deep:
		return mini(hp, 2) if boss else hp
	if distance <= 80.0:
		return 0
	return mini(hp, 2 if distance >= 160.0 else 1)
