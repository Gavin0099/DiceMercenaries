extends SceneTree

var failures: Array[String] = []
var count: int = 0

func check(ok: bool, name: String) -> void:
	count+=1
	if not ok:
		failures.append(name)

func _initialize() -> void:
	check(TacticalRules.profile(0).is_empty(),"zero roll rejected")
	check(TacticalRules.profile(21).is_empty(),"above D20 rejected")
	check(TacticalRules.profile(5).tier==0,"basic upper boundary")
	check(TacticalRules.profile(6).tier==1,"guarded lower boundary")
	check(TacticalRules.profile(14).tier==1,"guarded upper boundary")
	check(TacticalRules.profile(15).tier==2,"shockwave lower boundary")
	check(not TacticalRules.profile(19).natural,"19 is not natural20")
	check(TacticalRules.profile(20).natural,"raw20 is natural20")
	for raw: int in [3,10,17,20]:
		check(TacticalRules.can_attack(130,"shield",raw),"basic shield available at every tier")
		check(TacticalRules.can_attack(220,"charge",raw),"basic charge available at every tier")
	check(not TacticalRules.can_attack(130.01,"shield",3),"shield range boundary")
	check(not TacticalRules.can_attack(-1,"shield",3),"negative range rejected")
	check(not TacticalRules.can_attack(INF,"charge",20),"infinite range rejected")
	check(not TacticalRules.can_attack(0,"unknown",3),"unknown skill rejected")
	check(TacticalRules.can_attack(300,"charge",17),"high roll adds tactical reach")
	check(not TacticalRules.can_attack(300,"charge",3),"low roll retains shorter reach")
	check(TacticalRules.incoming_damage(12,0,2)==4,"two sweeps cause four damage")
	check(TacticalRules.incoming_damage(12,1,2)==2,"guard reduces each sweep by one")
	check(TacticalRules.incoming_damage(1,0,2)==1,"damage clamps to remaining HP")
	check(TacticalRules.incoming_damage(12,0,-1)==0,"negative hit count ignored")
	check(TacticalRules.intent_active(6,80),"exact disruption boundary remains active")
	check(not TacticalRules.intent_active(6,80.01),"movement beyond boundary interrupts")
	check(not TacticalRules.intent_active(0,0),"dead enemy cannot attack")
	check(not TacticalRules.intent_active(6,NAN),"nonfinite intent rejected")
	if failures.is_empty():
		print("TACT01_RULES_PASS count=",count)
		quit(0)
	else:
		printerr("TACT01_RULES_FAIL ",failures)
		quit(1)
