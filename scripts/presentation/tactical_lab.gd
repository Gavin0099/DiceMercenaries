extends Node2D

enum Phase { PLAN, RESOLVE, ENEMY, VICTORY, DEFEAT }
var phase: Phase = Phase.PLAN
var hero: WarriorBody
var enemies: Array[TacticalEnemy] = []
var bridge: BreakableTerrain
var wall: BreakableTerrain
var intents: Array[Dictionary] = []
var raw: int = 3
var skill: String = "move"
var turn: int = 1
var attack_id: int = 0
var guard: int = 0
var clock: float = 0
var destination: float = -1
var reduced: bool = false
var message: String = "Read the red attack zones. Move, flank, then choose a skill."
var heading: Label
var status: Label
var hint: Label
var intent_label: Label
var buttons: Dictionary = {}
var last_contact: Vector2 = Vector2.ZERO
var contact_time: float = 0
const PIT: Rect2 = Rect2(720, 620, 300, 160)

func _ready() -> void:
	_build_floor(Rect2(24,570,696,110))
	_build_floor(Rect2(1020,570,236,110))
	bridge = _module("bridge",Rect2(720,570,300,20))
	wall = _module("wall",Rect2(1170,435,28,135))
	hero = WarriorBody.new()
	hero.position = Vector2(350,540)
	add_child(hero)
	for index: int in 2:
		var enemy: TacticalEnemy = TacticalEnemy.new()
		enemy.position = Vector2(650 if index==0 else 905,548)
		enemy.target_id = index+1
		enemy.fall_damage_enabled = true
		enemy.deep_pit = PIT
		enemy.resolved.connect(_on_damage)
		enemies.append(enemy)
		add_child(enemy)
	_build_ui()
	forecast()
	refresh()

func _build_floor(rect: Rect2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	var shape: CollisionShape2D = CollisionShape2D.new()
	var box: RectangleShape2D = RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.add_child(shape)
	add_child(body)

func _module(id: String, rect: Rect2) -> BreakableTerrain:
	var module: BreakableTerrain = BreakableTerrain.new()
	module.module_id = id
	module.position = rect.get_center()
	module.size = rect.size
	module.destroyed.connect(_on_break)
	add_child(module)
	return module

func label(text: String, pos: Vector2, size: int, color: Color) -> Label:
	var node: Label = Label.new()
	node.text = text
	node.position = pos
	node.add_theme_font_size_override("font_size",size)
	node.add_theme_color_override("font_color",color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

func button(text: String, pos: Vector2, width: float, callback: Callable) -> Button:
	var node: Button = Button.new()
	node.text = text
	node.position = pos
	node.size = Vector2(width,44)
	node.pressed.connect(callback)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("302d29")
	style.border_color = Color("786346")
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	node.add_theme_stylebox_override("normal",style)
	node.add_theme_font_size_override("font_size",17)
	return node

func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	layer.add_child(label("DICE MERCENARIES",Vector2(36,24),18,Color("c6a578")))
	layer.add_child(label("THE FRACTURED MINE",Vector2(36,49),30,Color("eee0c4")))
	layer.add_child(label("WARRIOR / TACTICAL PROTOTYPE",Vector2(38,90),14,Color("ab9b82")))
	heading = label("",Vector2(38,132),22,Color("e6c48c"))
	layer.add_child(heading)
	status = label("",Vector2(38,166),16,Color("dbd9c6"))
	layer.add_child(status)
	intent_label = label("",Vector2(38,203),16,Color("efac8e"))
	layer.add_child(intent_label)
	layer.add_child(label("FIXED ROLL / COMPARISON ONLY",Vector2(760,30),13,Color("ab9b82")))
	for index: int in 4:
		var roll: int = [3,10,17,20][index]
		var roll_button: Button = button(str(roll),Vector2(760+index*65,52),55,set_roll.bind(roll))
		buttons["roll"+str(roll)] = roll_button
		layer.add_child(roll_button)
	layer.add_child(button("RESET [R]",Vector2(1060,52),174,reset))
	var titles: Array[String] = ["MOVE [1]", "SHIELD BASH [2]", "CHARGE [3]"]
	var skills: Array[String] = ["move","shield","charge"]
	for index: int in 3:
		var action: Button = button(titles[index],Vector2(38+index*210,622),198,select_skill.bind(skills[index]))
		buttons[skills[index]] = action
		layer.add_child(action)
	buttons["end"] = button("END TURN [E]",Vector2(680,622),185,end_turn)
	layer.add_child(buttons["end"])
	layer.add_child(button("REDUCE MOTION [M]",Vector2(888,622),346,toggle_motion))
	hint = label("",Vector2(38,676),16,Color("d9c8ab"))
	layer.add_child(hint)

func forecast() -> void:
	intents.clear()
	for enemy: TacticalEnemy in enemies:
		if enemy.hp<=0:
			continue
		var direction: float = signf(hero.position.x-enemy.position.x)
		enemy.facing = direction
		var center: Vector2 = enemy.position + Vector2(direction*120,0)
		intents.append({"enemy":enemy,"origin":enemy.position,"zone":Rect2(center-Vector2(115,55),Vector2(230,110))})

func refresh() -> void:
	var spec: Dictionary = TacticalRules.profile(raw)
	heading.text = "TURN %d  /  %s" % [turn,["YOUR MOVE","ATTACK RESOLVING","ENEMY RESPONSE","VICTORY","DEFEAT"][phase]]
	status.text = "HP %d / 12     MOVE %dm     D20 %d: %s     GUARD %d" % [hero.hp,ceili(hero.budget/80.0),raw,spec.name,guard]
	intent_label.text = "Red zones: club sweep (2 HP). Push an enemy >80px to interrupt its wind-up."
	hint.text = message
	for key: String in ["move","shield","charge","end"]:
		buttons[key].disabled = phase!=Phase.PLAN
	for roll: int in [3,10,17,20]:
		buttons["roll"+str(roll)].disabled = phase!=Phase.PLAN or hero.budget<TacticalRules.MOVE_BUDGET-0.1
	buttons[skill].modulate = Color("f1ca86")
	queue_redraw()

func select_skill(value: String) -> void:
	if phase!=Phase.PLAN or value not in ["move","shield","charge"]:
		return
	buttons[skill].modulate = Color.WHITE
	skill = value
	destination = -1
	message = {"move":"A/D or click ground to reposition. Your movement budget includes the whole path.","shield":"Click an enemy within 130px: 2 damage + directional knockback. Stand on the other side to reverse it.","charge":"Click an enemy or amber terrain in range. Fixed reach, no angle or power slider."}[skill]
	refresh()

func set_roll(value: int) -> void:
	if value not in [3,10,17,20] or phase!=Phase.PLAN or hero.budget<TacticalRules.MOVE_BUDGET-0.1:
		return
	raw = value
	message = "Fixed roll %d: %s. Every roll keeps both basic skills available." % [raw,TacticalRules.profile(raw).name]
	refresh()

func toggle_motion() -> void:
	reduced = not reduced
	hero.reduced = reduced
	bridge.reduced_motion = reduced
	wall.reduced_motion = reduced
	for enemy: TacticalEnemy in enemies:
		enemy.reduced_motion = reduced
	contact_time = 0
	queue_redraw()

func reset() -> void:
	get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_R: reset()
			KEY_M: toggle_motion()
			KEY_1: select_skill("move")
			KEY_2: select_skill("shield")
			KEY_3: select_skill("charge")
			KEY_E: end_turn()
			KEY_ESCAPE: select_skill("move")
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and phase==Phase.PLAN:
		var cursor: Vector2 = get_global_mouse_position()
		if cursor.y<270 or cursor.y>610 or cursor.x<42 or cursor.x>1238:
			return
		if skill=="move":
			destination = cursor.x
		else:
			for enemy: TacticalEnemy in enemies:
				if enemy.hp>0 and cursor.distance_to(enemy.position)<55:
					attack(enemy)
					return
			for module: BreakableTerrain in [bridge,wall]:
				if not module.broken and Rect2(module.position-module.size/2,module.size).grow(20).has_point(cursor):
					attack(module)
					return
			message = "No target selected. Click an enemy or amber terrain."
			refresh()

func attack(target: Node2D) -> bool:
	if phase!=Phase.PLAN or not is_instance_valid(target) or skill=="move" or not hero.is_on_floor():
		return false
	if not (target is TacticalEnemy or target is BreakableTerrain):
		return false
	var contact: Vector2 = target.position
	if target is BreakableTerrain:
		contact.x = clampf(hero.position.x,target.position.x-target.size.x/2,target.position.x+target.size.x/2)
		contact.y = clampf(hero.position.y,target.position.y-target.size.y/2,target.position.y+target.size.y/2)
	var distance: float = hero.position.distance_to(contact)
	if not TacticalRules.can_attack(distance,skill,raw):
		message = "Out of range. Reposition first; no action spent."
		refresh()
		return false
	if target is BreakableTerrain and (skill!="charge" or target.broken):
		message = "Use CHARGE to break terrain."
		refresh()
		return false
	if target is TacticalEnemy and target.hp<=0:
		return false
	# Reject attacks through the solid wall. A charge against it is legal.
	var ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(hero.position,Vector2(contact.x,hero.position.y),1)
	var obstacle: Dictionary = get_world_2d().direct_space_state.intersect_ray(ray)
	if not obstacle.is_empty() and obstacle.collider!=target:
		message = "Blocked by terrain. Break it or approach from the other side."
		refresh()
		return false
	phase = Phase.RESOLVE
	clock = 0
	destination = -1
	hero.axis = 0
	hero.enabled = false
	hero.facing = 1 if target.position.x>=hero.position.x else -1
	hero.attack_pose = 0.3
	attack_id += 1
	guard = int(TacticalRules.profile(raw).guard)
	if skill=="charge":
		# Actual collision sweep, not a decorative Tween relocation.
		var gap: float = absf(contact.x-hero.position.x)
		hero.move_and_collide(Vector2(hero.facing*maxf(0,gap-65),0))
	if target is BreakableTerrain:
		target.receive_hit(attack_id)
	else:
		target.receive_hit(attack_id,Vector2(hero.facing*float(TacticalRules.profile(raw).impulse),0))
		if skill=="charge":
			var radius: float = float(TacticalRules.profile(raw).shock_radius)
			for enemy: TacticalEnemy in enemies:
				if enemy!=target and enemy.hp>0 and enemy.position.distance_to(target.position)<=radius:
					enemy.receive_hit(attack_id,Vector2(hero.facing*float(TacticalRules.profile(raw).impulse),0))
	last_contact = contact
	contact_time = 0.35
	message = "Attack committed. Knockback can interrupt the red forecast."
	refresh()
	return true

func end_turn() -> void:
	if phase!=Phase.PLAN:
		return
	phase = Phase.RESOLVE
	hero.enabled = false
	hero.axis = 0
	destination = -1
	clock = 0
	message = "Holding position. Enemy forecast will resolve."
	refresh()

func resolve_enemies() -> void:
	if phase!=Phase.RESOLVE:
		return
	phase = Phase.ENEMY
	var hits: int = 0
	var disrupted: int = 0
	for intent: Dictionary in intents:
		var enemy: TacticalEnemy = intent.enemy
		if not TacticalRules.intent_active(enemy.hp,enemy.position.distance_to(intent.origin)):
			disrupted+=1
			continue
		if intent.zone.has_point(hero.position):
			hits+=1
	var damage: int = TacticalRules.incoming_damage(hero.hp,guard,hits)
	hero.hp-=damage
	hero.flash = 0.25 if damage>0 else 0
	message = "Enemy response: %d hit(s), %d HP lost, %d wind-up(s) interrupted." % [hits,damage,disrupted]
	clock = 0
	refresh()

func _physics_process(delta: float) -> void:
	contact_time = maxf(0,contact_time-delta)
	if hero.position.y>640:
		hero.hp = 0
	if hero.hp<=0:
		phase = Phase.DEFEAT
		hero.enabled = false
		hero.axis = 0
		message = "Defeated. Avoid red zones and the open pit. R to retry."
	elif enemies.all(func(enemy: TacticalEnemy) -> bool: return enemy.hp<=0):
		phase = Phase.VICTORY
		hero.enabled = false
		hero.axis = 0
		message = "Mine cleared. Try another fixed roll and compare your route. R to retry."
	elif phase==Phase.PLAN:
		var axis: float = float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A))
		if axis!=0:
			destination = -1
		elif destination>=0:
			axis = signf(destination-hero.position.x) if absf(destination-hero.position.x)>6 else 0.0
			if axis==0:
				destination = -1
		hero.axis = axis
		if hero.position.x<45 and axis<0 or hero.position.x>1235 and axis>0:
			hero.axis = 0
	elif phase==Phase.RESOLVE:
		clock+=delta
		var settled: bool = enemies.all(func(enemy: TacticalEnemy) -> bool: return enemy.hp<=0 or (enemy.is_on_floor() and enemy.velocity.length()<12))
		if clock>=0.5 and settled:
			resolve_enemies()
		elif clock>4:
			# No premature turn advance while a body is still unresolved.
			message = "Physics did not settle. Reset [R] to retry; turn remains locked."
	elif phase==Phase.ENEMY:
		clock+=delta
		if clock>=0.75:
			turn+=1
			guard = 0
			hero.budget = TacticalRules.MOVE_BUDGET
			hero.enabled = true
			phase = Phase.PLAN
			forecast()
	refresh()

func _on_damage(_id: int, kind: String, amount: int) -> void:
	message = "%s: %d HP damage." % [kind,amount]

func _on_break(_id: String, _shot_id: int) -> void:
	message = "Terrain broken. The pit is now open: do not walk across."

func _draw() -> void:
	draw_rect(Rect2(0,0,1280,720),Color("191d20"))
	draw_rect(Rect2(24,255,1232,350),Color("272b2c"))
	for index: int in 12:
		var x: float = index*115
		draw_colored_polygon(PackedVector2Array([Vector2(x,255),Vector2(x+110,255),Vector2(x+95,330+(index%3)*40),Vector2(x+25,300)]),Color("343b3b"))
	for x: int in [100,450,1070]:
		draw_line(Vector2(x,300),Vector2(x,562),Color("574638"),16)
		draw_line(Vector2(x-60,302),Vector2(x+60,302),Color("67503b"),12)
		draw_circle(Vector2(x,354),28,Color(0.95,0.65,0.25,0.07))
		draw_rect(Rect2(x-6,345,12,18),Color("dfb76a"))
	draw_rect(Rect2(24,570,696,50),Color("726650"))
	draw_rect(Rect2(1020,570,236,50),Color("726650"))
	for index: int in 15:
		var x: float = 30+index*82
		if x<720 or x>1020:
			draw_line(Vector2(x,577),Vector2(x+55,584+(index%3)*7),Color("918066"),3)
	draw_rect(Rect2(720,592,300,24),Color("2c2523"))
	draw_string(ThemeDB.fallback_font,Vector2(788,608),"DEEP PIT / LETHAL",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("e4a188"))
	if is_instance_valid(bridge) and not bridge.broken:
		for index: int in 10:
			draw_line(Vector2(728+index*29,569),Vector2(728+index*29,589),Color("d2b483"),3)
	for intent: Dictionary in intents:
		var enemy: TacticalEnemy = intent.enemy
		var active: bool = TacticalRules.intent_active(enemy.hp,enemy.position.distance_to(intent.origin))
		if not active:
			continue
		var zone: Rect2 = intent.zone
		draw_rect(Rect2(zone.position.x,539,zone.size.x,29),Color(0.85,0.3,0.22,0.18))
		draw_line(Vector2(zone.position.x,564),Vector2(zone.end.x,564),Color("d57c63"),3)
		draw_string(ThemeDB.fallback_font,Vector2(zone.position.x+8,532),"INCOMING SWEEP",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e7a38a"))
	if is_instance_valid(hero) and phase==Phase.PLAN:
		draw_arc(hero.position,36,0,TAU,32,Color("e3c384"),2,true)
		if skill!="move":
			var reach: float = TacticalRules.SHIELD_RANGE if skill=="shield" else float(TacticalRules.profile(raw).charge_range)
			draw_line(Vector2(hero.position.x-reach,600),Vector2(hero.position.x+reach,600),Color("bba67e"),2)
			draw_string(ThemeDB.fallback_font,Vector2(hero.position.x-45,hero.position.y-72),skill.to_upper(),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("e3c384"))
	if contact_time>0 and not reduced:
		draw_arc(last_contact,18+(0.35-contact_time)*70,0,TAU,24,Color("e5c68a"),3,true)
