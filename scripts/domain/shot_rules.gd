class_name ShotRules
extends RefCounted

# Pure shot parameters. Coordinates and elapsed time are supplied by adapters.
const GRAVITY: float = 900.0
const MIN_SPEED: float = 250.0
const MAX_SPEED: float = 900.0
const DIRECT_DAMAGE: int = 2
const WALL_DAMAGE: int = 1
const MAX_HP: int = 6

static func prepare(origin: Vector2, pointer: Vector2) -> Dictionary:
	var offset: Vector2 = pointer - origin
	if not offset.is_finite() or offset.length() < 24.0:
		return {"valid": false}
	var strength: float = clampf((offset.length() - 80.0) / 420.0, 0.0, 1.0)
	return {"valid": true, "velocity": offset.normalized() * lerpf(MIN_SPEED, MAX_SPEED, strength), "strength": strength}

static func point(origin: Vector2, initial_velocity: Vector2, seconds: float) -> Vector2:
	return origin + initial_velocity * seconds + Vector2(0.0, 0.5 * GRAVITY * seconds * seconds)

static func damage(hp: int, kind: String, shot_id: int, consumed: Array[String]) -> Dictionary:
	var token: String = str(shot_id) + ":" + kind
	if shot_id <= 0 or hp <= 0 or kind not in ["direct", "wall"] or token in consumed:
		return {"hp": hp, "amount": 0, "token": ""}
	var amount: int = DIRECT_DAMAGE if kind == "direct" else WALL_DAMAGE
	return {"hp": maxi(0, hp - amount), "amount": mini(hp, amount), "token": token}
