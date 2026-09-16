extends State

@onready var anim = owner.find_child("AnimatedSprite2D")

func enter():
	super.enter()
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("walk"):
		anim.play("walk")

func physics_update(_delta: float):
	if not owner.is_on_floor():
		owner.velocity.y += 1200.0 * _delta

	if owner.player and is_instance_valid(owner.player):
		var dir_x = owner.player.global_position.x - owner.global_position.x
		var horiz_dist = abs(dir_x)
		
		# Tactical spacing behavior: Wizard tries to maintain spacing instead of blindly rushing
		if horiz_dist < owner.attack_range - 20.0:
			# Too close! Back away slowly
			owner.facing_left = (dir_x < 0)
			if anim:
				anim.flip_h = owner.facing_left
			owner.velocity.x = (owner.speed * 0.8 if owner.facing_left else -owner.speed * 0.8)
		elif abs(dir_x) > 5.0:
			owner.facing_left = (dir_x < 0)
			if anim:
				anim.flip_h = owner.facing_left
			owner.velocity.x = (-owner.speed if owner.facing_left else owner.speed)
	
	owner.move_and_slide()

func transition():
	if not owner.player or not is_instance_valid(owner.player):
		get_parent().change_state("idle")
		return

	var horiz_dist = abs(owner.player.global_position.x - owner.global_position.x)
	
	# Teleport away if player gets too close and teleport is off cooldown
	if horiz_dist < 90.0 and owner.teleport_timer <= 0.0:
		perform_teleport()
		return

	if owner.heavy_attack_timer <= 0.0 and horiz_dist <= owner.heavy_attack_range:
		get_parent().change_state("heavy_attack")
	elif horiz_dist <= owner.attack_range:
		get_parent().change_state("attack")
	elif owner.taunt_timer <= 0.0 and horiz_dist >= 300.0 and owner.is_on_floor():
		get_parent().change_state("taunt")
	elif horiz_dist > owner.detection_range:
		get_parent().change_state("idle")

func perform_teleport():
	owner.teleport_timer = owner.teleport_cooldown
	if anim:
		anim.modulate = Color(0.8, 0.2, 1.0, 0.3) # Purple fade out
	
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.2).timeout
	
	if owner and is_instance_valid(owner) and owner.player and is_instance_valid(owner.player):
		# Teleport behind or away from player
		var flip_side = -1.0 if owner.facing_left else 1.0
		var target_x = owner.player.global_position.x + (flip_side * 220.0)
		owner.global_position.x = target_x
		
	if anim:
		anim.modulate = Color(1.0, 1.0, 1.0, 1.0)
