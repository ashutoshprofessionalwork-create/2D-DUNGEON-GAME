extends SceneTree

func _init():
	print("--- TESTING RUINCITY BOSS REGION DAMAGE ---")
	
	# Load scenes
	var boss_scene = load("res://ruincity_boss.tscn")
	var player_scene = load("res://player.tscn")
	
	var boss = boss_scene.instantiate()
	var player = player_scene.instantiate()
	
	root.add_child(boss)
	root.add_child(player)
	
	# Wait for node tree initialization
	await process_frame
	
	var area_lh = boss.get_node_or_null("HIT_AREA_LH")
	var area_rh = boss.get_node_or_null("HIT_AREA_RH")
	
	var initial_health = boss.health
	print("Initial boss health: ", initial_health)
	
	assert(area_lh != null, "HIT_AREA_LH should exist")
	assert(area_rh != null, "HIT_AREA_RH should exist")
	
	print("LH is in 'enemy' group: ", area_lh.is_in_group("enemy"))
	print("RH is in 'enemy' group: ", area_rh.is_in_group("enemy"))
	
	# Position player near HIT_AREA_LH shape center
	var shape_lh = area_lh.get_node("CollisionShape2D")
	var lh_global_pos = area_lh.to_global(shape_lh.position)
	player.global_position = lh_global_pos
	player.facing_direction = -1 # look left if boss center is to right
	player.attack_range = 5000.0
	
	# Test player deal_damage_to_enemies hitting area_lh
	player.deal_damage_to_enemies(200.0, 15)
	print("Boss health after attack near LH: ", boss.health)
	
	# Test direct take_damage on area_rh
	if area_rh.has_method("take_damage"):
		area_rh.take_damage(20)
		print("Boss health after direct take_damage on RH: ", boss.health)
		
	if boss.health == initial_health - 35:
		print("TEST PASSED!")
	else:
		print("TEST FAILED! Health remaining: ", boss.health)
		
	quit()








