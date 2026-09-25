extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
var is_attacking: bool = false
var attack_count = 0
var indicator: Polygon2D = null

func enter():
	super.enter()
	if not anim:
		anim = owner.get_node_or_null("AnimatedSprite2D")
	is_attacking = true
	owner.velocity.x = 0
	
	face_target()

	var direction = -1.0 if owner.facing_left else 1.0
	var range_width = owner.attack_range if "attack_range" in owner else 180.0
	create_warning_indicator(owner.global_position, direction, range_width)

	# Windup telegraph warning before attack
	if anim:
		anim.modulate = Color(1.2, 0.9, 0.4, 1.0) # Slight warm amber tint for standard attack windup
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.35).timeout
	if anim and is_instance_valid(anim):
		anim.modulate = Color(1.0, 1.0, 1.0, 1.0)

	if not is_attacking or owner.health <= 0 or not owner.is_inside_tree():
		remove_warning_indicator()
		return

	# 1. First Attack Animation ("attack")
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("attack"):
		anim.play("attack")

	# Wait until impact frame (e.g. frame 6/7)
	if anim and anim.is_playing() and anim.animation == "attack":
		while is_attacking and owner.is_inside_tree() and owner.get_tree() and anim.animation == "attack" and anim.frame < 6:
			await owner.get_tree().process_frame
	if not is_attacking or owner.health <= 0 or not owner.is_inside_tree():
		remove_warning_indicator()
		return
	if owner.has_method("screen_shake"):
		owner.screen_shake(8.0, 0.25)
	deal_damage_if_in_range()

	# Wait for first attack animation to finish
	if anim and anim.is_playing() and anim.animation == "attack":
		await anim.animation_finished
	if owner.health <= 0 or not owner.is_inside_tree():
		remove_warning_indicator()
		return

	# 2. Second Follow-up Attack ("attack1" or "spin_attack")
	var second_anim = "attack1"
	if anim and anim.sprite_frames:
		if anim.sprite_frames.has_animation("spin_attack"):
			second_anim = "spin_attack"
		elif anim.sprite_frames.has_animation("attack1"):
			second_anim = "attack1"

	if anim and anim.sprite_frames and anim.sprite_frames.has_animation(second_anim):
		anim.play(second_anim)

		while is_attacking and owner.is_inside_tree() and owner.get_tree() and anim.animation == second_anim and anim.frame < 6:
			await owner.get_tree().process_frame
		if not is_attacking or owner.health <= 0 or not owner.is_inside_tree():
			remove_warning_indicator()
			return
		deal_damage_if_in_range()

		if anim and anim.is_playing():
			await anim.animation_finished

	remove_warning_indicator()

	if owner.health <= 0 or not owner.is_inside_tree():
		return

	# Cooldown gap before returning to follow state
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.4).timeout
	if owner.health <= 0:
		return

	is_attacking = false

func create_warning_indicator(boss_pos: Vector2, dir: float, attack_dist: float):
	remove_warning_indicator()
	indicator = Polygon2D.new()
	indicator.color = Color(1.0, 0.8, 0.2, 0.4) # Soft yellow/gold ground warning zone
	
	var start_x = 0.0
	var end_x = dir * (attack_dist + 30.0)
	var ground_y = 35.0
	var zone_height = 20.0

	indicator.polygon = PackedVector2Array([
		Vector2(start_x, ground_y - zone_height * 0.5),
		Vector2(end_x, ground_y - zone_height * 0.5),
		Vector2(end_x, ground_y + zone_height * 0.5),
		Vector2(start_x, ground_y + zone_height * 0.5)
	])
	indicator.global_position = boss_pos
	if owner.get_parent():
		owner.get_parent().add_child(indicator)

func remove_warning_indicator():
	if indicator and is_instance_valid(indicator):
		indicator.queue_free()
		indicator = null

func exit():
	super.exit()
	is_attacking = false
	remove_warning_indicator()
	if anim and is_instance_valid(anim):
		anim.modulate = Color(1.0, 1.0, 1.0, 1.0)

func face_target():
	if owner.player and is_instance_valid(owner.player):
		var diff = owner.player.global_position.x - owner.global_position.x
		if diff != 0:
			if anim:
				var facing_left = diff < 0
				anim.flip_h = not facing_left if owner is RuinCityBoss else facing_left

func deal_damage_if_in_range():
	if owner.health <= 0:
		return
	if owner.player and is_instance_valid(owner.player):
		var diff_x = owner.player.global_position.x - owner.global_position.x
		var facing_left = (not anim.flip_h) if (owner is RuinCityBoss and anim) else (anim.flip_h if anim else owner.facing_left)
		var player_in_front = (facing_left and diff_x <= 0) or (not facing_left and diff_x >= 0)
		
		if player_in_front and abs(diff_x) <= owner.attack_range + 50.0:
			if owner.player.has_method("take_damage"):
				owner.player.take_damage(owner.attack_damage)

func physics_update(_delta: float):
	if owner.has_method("safe_move_and_slide"):
		if not owner.is_on_floor():
			owner.velocity.y += 1200.0 * _delta
		owner.velocity.x = 0
		owner.safe_move_and_slide()
	else:
		if not owner.is_on_floor():
			owner.velocity.y += 1200.0 * _delta
		owner.velocity.x = 0
		owner.move_and_slide()

func transition():
	if owner.health <= 0:
		return
	if not is_attacking:
		get_parent().change_state("follow")
