extends "res://scripts/presentation/tactical_lab.gd"

# 獨立候選：單一戰士以低骰處理護衛與施法者。
const COVER := Rect2(390, 480, 95, 90)
var mage_interrupted: bool = false
var charge_ready_turn: int = 1
var combat_font: SystemFont = SystemFont.new()

func _ready() -> void:
	combat_font.font_names = PackedStringArray(["Microsoft JhengHei", "Noto Sans CJK TC", "sans-serif"])
	super._ready()
	_build_floor(Rect2(720,570,300,110))
	bridge.visible = false
	wall.visible = false
	hero.position.x = 310
	enemies[0].position.x = 550
	enemies[1].position.x = 740
	for enemy: TacticalEnemy in enemies:
		enemy.fall_damage_enabled = false
	enemies[1].caster = true
	message = "選一條路：衝鋒打斷施法，或進入藍色掩體等待法師空檔。"
	forecast()
	refresh()

func label(value: String, pos: Vector2, size: int, color: Color) -> Label:
	var node: Label = super.label(value, pos, size, color)
	node.add_theme_font_override("font", combat_font)
	return node

func button(value: String, pos: Vector2, width: float, callback: Callable) -> Button:
	var node: Button = super.button(value, pos, width, callback)
	node.add_theme_font_override("font", combat_font)
	return node

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(label("骰子傭兵團｜單職業通關測試",Vector2(36,24),28,Color("eee0c4")))
	layer.add_child(label("戰士對護衛與法師　／　低骰也有解法",Vector2(38,65),18,Color("c6a578")))
	heading = label("",Vector2(38,110),24,Color("e6c48c"))
	status = label("",Vector2(38,148),18,Color("dbd9c6"))
	intent_label = label("",Vector2(38,190),18,Color("efac8e"))
	for node: Label in [heading,status,intent_label]:
		layer.add_child(node)
	layer.add_child(label("固定骰點比較（尚非隨機擲骰）",Vector2(760,25),16,Color("ab9b82")))
	for index: int in 4:
		var roll: int = [3,10,17,20][index]
		buttons["roll"+str(roll)] = button(str(roll),Vector2(760+index*65,52),55,set_roll.bind(roll))
		layer.add_child(buttons["roll"+str(roll)])
	layer.add_child(button("重新開始［R］",Vector2(1050,52),190,reset))
	var keys: Array[String] = ["move","shield","charge"]
	var titles: Array[String] = ["移動［1］","盾擊［2］","衝鋒［3］"]
	for index: int in 3:
		buttons[keys[index]] = button(titles[index],Vector2(38+index*180,622),168,select_skill.bind(keys[index]))
		layer.add_child(buttons[keys[index]])
	buttons["defend"] = button("格擋［4］",Vector2(578,622),168,defend)
	buttons["end"] = button("結束回合［E］",Vector2(758,622),188,end_turn)
	layer.add_child(buttons["defend"])
	layer.add_child(buttons["end"])
	layer.add_child(button("減少動態［M］",Vector2(960,622),274,toggle_motion))
	hint = label("",Vector2(38,677),17,Color("d9c8ab"))
	layer.add_child(hint)

func forecast() -> void:
	intents.clear()
	mage_interrupted = false
	for index: int in enemies.size():
		var enemy: TacticalEnemy = enemies[index]
		if enemy.hp <= 0:
			continue
		enemy.facing = signf(hero.position.x-enemy.position.x)
		var zone := Rect2(45,485,1190,85) if index==1 else Rect2(enemy.position+Vector2(enemy.facing*120-115,-55),Vector2(230,110))
		intents.append({"enemy":enemy,"origin":enemy.position,"zone":zone,"mage":index==1,"casting":index==1 and turn%2==1})

func refresh() -> void:
	if not is_instance_valid(hero) or not is_instance_valid(heading):
		return
	heading.text = "第 %d 回合｜%s" % [turn,["你的行動","攻擊結算","敵人回應","勝利","戰敗"][phase]]
	var tier: int = int(TacticalRules.profile(raw).tier)
	status.text = "生命 %d／12　移動剩餘 %d　骰點 %d（%s）　衝鋒：%s" % [hero.hp,ceili(hero.budget),raw,["基本","強化","震波","傳奇"][tier],"可用" if turn>=charge_ready_turn else "冷卻中"]
	intent_label.text = "護衛：紅區揮擊 2 傷害｜法師：%s" % ("紫區施法 3 傷害；藍色掩體可躲避" if turn%2==1 else "恢復中，本回合不施法；可以接近")
	hint.text = message
	for key: String in ["move","shield","charge","end","defend"]:
		buttons[key].disabled = phase!=Phase.PLAN or (key=="charge" and turn<charge_ready_turn)
	for roll: int in [3,10,17,20]:
		buttons["roll"+str(roll)].disabled = phase!=Phase.PLAN or hero.budget<TacticalRules.MOVE_BUDGET-0.1
	queue_redraw()

func select_skill(value: String) -> void:
	if phase!=Phase.PLAN or value not in ["move","shield","charge"]:
		return
	skill = value
	destination = -1
	message = {"move":"按 A／D 或點地面移動；整段路程共用 240 移動額度。","shield":"點近處敵人：傷害 2 並擊退；蓄力中的法師受擊會中斷施法。","charge":"點敵人衝鋒：傷害 2 並打斷施法；使用後下一回合無法再衝鋒。"}[value]
	refresh()

func set_roll(value: int) -> void:
	if value in [3,10,17,20] and phase==Phase.PLAN and hero.budget>=TacticalRules.MOVE_BUDGET-0.1:
		raw = value
		message = "已選固定骰點 %d；低骰仍可盾擊、衝鋒、格擋與利用掩體。" % value
		refresh()

func attack(target: Node2D) -> bool:
	if not target is TacticalEnemy or (skill=="charge" and turn<charge_ready_turn):
		message = "此關請選敵人；衝鋒冷卻時可盾擊、格擋或移動。"
		refresh()
		return false
	var mage_hp_before: int = enemies[1].hp
	var accepted: bool = super.attack(target)
	if accepted:
		if skill=="charge":
			charge_ready_turn = turn+2
		if enemies[1].hp<mage_hp_before and turn%2==1:
			mage_interrupted = true
		message = "法師施法已打斷！注意攻擊後的站位。" if mage_interrupted else "攻擊已出手；位移超過 80 可打斷護衛揮擊。"
	else:
		message = "目前無法攻擊：請確認距離、站穩地面與回合狀態；沒有消耗行動。"
	refresh()
	return accepted

func defend() -> void:
	if phase!=Phase.PLAN:
		return
	guard = 2
	end_turn()
	message = "架盾格擋：本次每個敵人的傷害減少 2；會消耗本回合攻擊。"
	refresh()

func end_turn() -> void:
	super.end_turn()
	message = "等待敵人回應；藍色掩體只阻擋法術，不阻擋護衛。"
	refresh()

func resolve_enemies() -> void:
	if phase!=Phase.RESOLVE:
		return
	phase = Phase.ENEMY
	var damage: int = 0
	var interrupted: int = 0
	for intent: Dictionary in intents:
		var enemy: TacticalEnemy = intent.enemy
		if enemy.hp<=0:
			continue
		if intent.mage:
			if not intent.casting:
				continue
			if mage_interrupted:
				interrupted+=1
			elif intent.zone.has_point(hero.position) and not COVER.has_point(hero.position):
				damage+=maxi(0,3-guard)
		elif not TacticalRules.intent_active(enemy.hp,enemy.position.distance_to(intent.origin)):
			interrupted+=1
		elif intent.zone.has_point(hero.position):
			damage+=maxi(0,2-guard)
	hero.hp = maxi(0,hero.hp-damage)
	hero.flash = 0.25 if damage>0 else 0
	message = "敵人回應：失去 %d 生命，打斷 %d 次；下一回合注意法師狀態。" % [damage,interrupted]
	clock = 0
	refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_4:
		defend()
	else:
		super._unhandled_input(event)
		if message=="No target selected. Click an enemy or amber terrain.":
			message = "請點選敵人，或按 1 切換移動。"
			refresh()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if phase==Phase.VICTORY:
		message = "勝利！試試另一條路：衝鋒打斷，或掩體等待。按 R 再試。"
	elif phase==Phase.DEFEAT:
		message = "戰敗。留意紫色法術、紅色揮擊；按 R 重新開始。"
	elif phase==Phase.RESOLVE and clock>4:
		message = "物理尚未穩定，回合保持鎖定；按 R 重新開始。"
	refresh()

func _draw() -> void:
	draw_rect(Rect2(0,0,1280,720),Color("191d20"))
	draw_rect(Rect2(24,255,1232,350),Color("272b2c"))
	draw_rect(Rect2(24,570,1232,48),Color("726650"))
	if turn%2==1 and is_instance_valid(hero):
		draw_rect(Rect2(45,558,1190,12),Color("80578c"))
	draw_rect(COVER,Color(0.25,0.55,0.7,0.35))
	draw_rect(COVER,Color("8dcad5"),false,2)
	draw_string(combat_font,Vector2(390,465),"法術掩體",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("8dcad5"))
	for intent: Dictionary in intents:
		if not intent.mage and TacticalRules.intent_active(intent.enemy.hp,intent.enemy.position.distance_to(intent.origin)):
			var zone: Rect2 = intent.zone
			draw_rect(Rect2(zone.position.x,540,zone.size.x,28),Color(0.85,0.3,0.22,0.35))
	if is_instance_valid(hero):
		draw_string(combat_font,hero.position+Vector2(-25,-80),"戰士",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("e3c384"))
		if phase==Phase.PLAN and skill!="move":
			var reach: float = TacticalRules.SHIELD_RANGE if skill=="shield" else float(TacticalRules.profile(raw).charge_range)
			draw_line(Vector2(hero.position.x-reach,598),Vector2(hero.position.x+reach,598),Color("e3c384"),2)
	for index: int in enemies.size():
		var enemy: TacticalEnemy = enemies[index]
		draw_string(combat_font,enemy.position+Vector2(-30,-80),"護衛" if index==0 else "法師",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("dbb4e3") if index==1 else Color("e3c384"))
