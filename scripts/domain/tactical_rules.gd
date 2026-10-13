class_name TacticalRules
extends RefCounted

const MOVE_BUDGET: float = 240.0
const PLAYER_HP: int = 12
const SHIELD_RANGE: float = 130.0
const INTENT_DAMAGE: int = 2
const DISRUPT_DISTANCE: float = 80.0

static func profile(raw: int) -> Dictionary:
	if raw < 1 or raw > 20:
		return {}
	var tier: int = 0 if raw <= 5 else (1 if raw <= 14 else (3 if raw == 20 else 2))
	return {"tier": tier, "natural": raw == 20,
		"name": ["BASIC", "GUARDED", "SHOCKWAVE", "LEGENDARY"][tier],
		"charge_range": [220.0, 260.0, 300.0, 300.0][tier],
		"impulse": [340.0, 390.0, 440.0, 480.0][tier],
		"guard": 0 if tier == 0 else 1,
		"shock_radius": [0.0, 0.0, 90.0, 160.0][tier]}

static func can_attack(distance: float, skill: String, raw: int) -> bool:
	var spec: Dictionary = profile(raw)
	if spec.is_empty() or not is_finite(distance) or distance < 0:
		return false
	if skill == "shield":
		return distance <= SHIELD_RANGE
	if skill == "charge":
		return distance <= float(spec.charge_range)
	return false

static func incoming_damage(hp: int, guard: int, hits: int) -> int:
	return mini(maxi(hp, 0), maxi(0, INTENT_DAMAGE - clampi(guard, 0, 1)) * maxi(hits, 0))

static func intent_active(hp: int, displacement: float) -> bool:
	return hp > 0 and is_finite(displacement) and absf(displacement) <= DISRUPT_DISTANCE
