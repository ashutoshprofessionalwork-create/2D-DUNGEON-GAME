@tool
extends SceneTree

func _init():
	print("--- TESTING ALL DEFENSE-IN-DEPTH GUARDS ---")
	var b1_scene = load("res://boss_1.tscn")
	var boss = b1_scene.instantiate()
	root.add_child(boss)
	
	boss.take_damage(400)
	print("[PASS] Boss took 400 damage, die() triggered!")

	var fsm = boss.get_node("FiniteStateMachine")
	assert(fsm.current_state != null and fsm.current_state.name.to_lower() == "death", "FSM must be locked in death state!")
	
	fsm.change_state("attack")
	assert(fsm.current_state.name.to_lower() == "death", "FSM transition out of death must be blocked!")

	print("[PASS] All defense-in-depth checks passed!")
	boss.free()
	quit()
