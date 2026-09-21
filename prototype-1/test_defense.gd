@tool
extends SceneTree

func _init():
	print("--- RUNNING SUITE OF ALL REGRESSION & DEFENSE TESTS ---")
	
	# Test 1: Ruin City Boss Instantiate & FSM Death Lock
	var rcb_scene = load("res://ruincity_boss.tscn")
	var rcb_boss = rcb_scene.instantiate()
	root.add_child(rcb_boss)
	
	var rcb_fsm = rcb_boss.get_node("FiniteStateMachine")
	rcb_fsm._ready()
	for state in rcb_fsm.get_children():
		state.owner = rcb_boss
		
	rcb_boss.die()
	print("[PASS] RuinCityBoss die() executed cleanly without errors!")
	assert(rcb_fsm.current_state != null and rcb_fsm.current_state.name.to_lower() == "death", "FSM must be locked in death state!")
	
	rcb_fsm.change_state("attack")
	assert(rcb_fsm.current_state.name.to_lower() == "death", "FSM transition out of death must be blocked!")
	print("[PASS] RuinCityBoss FSM death state locked successfully!")
	rcb_boss.free()

	# Test 2: Level RuinCity Boss integration
	var ruincity_scene = load("res://ruincity.tscn")
	var ruincity_level = ruincity_scene.instantiate()
	root.add_child(ruincity_level)
	
	var boss_node = ruincity_level.get_node_or_null("ruincity_boss")
	assert(boss_node != null, "RuinCity level must contain ruincity_boss node!")
	assert(boss_node.has_signal("boss_died"), "RuinCity boss must emit boss_died signal!")
	print("[PASS] RuinCity level correctly references boss and handles boss_died event!")
	ruincity_level.free()

	print("--- ALL REGRESSION TESTS PASSED SUCCESSFULLY ---")
	quit()
