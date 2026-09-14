extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
var is_attacking: bool = false
var attack_count = 0

func enter():
	super.enter()
	is_attacking = true
	owner.velocity.x = 0
	
	# --- ADDED: Face the player before starting swings ---
	face_target()

	# First Hit: Primary attack animation
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("attack"):
		anim.play("attack")
		attack_count += 1
		if attack_count >= 3:
			attack_count = 0
			anim.play("taunt")
			await anim.animation_finished
			anim.play("taunt")
			await anim.animation_finished
			anim.play("taunt")
			await anim.animation_finished

	# Wait until frame 6 (First slash impact frame in "attack" animation)
	if anim:
		while is_attacking and anim.animation == "attack" and anim.frame < 6:
			await owner.get_tree().process_frame
	if not is_attacking or owner.health <= 0:
		return
	deal_damage_if_in_range()

	# Wait until frame 18 (Second slash impact frame in "attack" animation)
	if anim:
		while is_attacking and anim.animation == "attack" and anim.frame < 18:
			await owner.get_tree().process_frame
	if not is_attacking or owner.health <= 0:
		return
	deal_damage_if_in_range()

	# Wait for primary attack animation to finish
	if anim and anim.is_playing() and anim.animation == "attack":
		await anim.animation_finished
	if owner.health <= 0:
		return

	# Second Hit: Follow-up spin attack animation
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("spin_attack"):
		anim.play("spin_attack")
	elif anim:
		anim.play("attack")

	# Wait until frame 10 (when the spin attack swing visually impacts)
	if anim:
		var target_anim = "spin_attack" if anim.sprite_frames and anim.sprite_frames.has_animation("spin_attack") else "attack"
		while is_attacking and anim.animation == target_anim and anim.frame < 10:
			await owner.get_tree().process_frame
	if not is_attacking or owner.health <= 0:
		return
	deal_damage_if_in_range()

	# Wait for second attack animation to finish
	if anim and anim.is_playing():
		await anim.animation_finished
	if owner.health <= 0:
		return

	# --- ADDED: 0.5s cooldown gap before returning to follow ---
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.5).timeout
	if owner.health <= 0:
		return

	is_attacking = false

# --- ADDED: Helper to lock boss facing towards player ---
func face_target():
	if owner.player and is_instance_valid(owner.player):
		var diff = owner.player.global_position.x - owner.global_position.x
		if diff != 0:
			if anim:
				anim.flip_h = diff < 0
			# If you flip the whole boss scale instead:
			# owner.scale.x = -abs(owner.scale.x) if diff < 0 else abs(owner.scale.x)

func deal_damage_if_in_range():
	if owner.health <= 0:
		return
	if owner.player and is_instance_valid(owner.player):
		var diff_x = owner.player.global_position.x - owner.global_position.x
		# Check if player is on the side the boss is currently facing:
		# If facing left (flip_h == true), player should be on negative x side (diff_x < 0).
		# If facing right (flip_h == false), player should be on positive x side (diff_x > 0).
		var facing_left = anim.flip_h if anim else owner.facing_left
		var player_in_front = (facing_left and diff_x <= 0) or (not facing_left and diff_x >= 0)
		
		if player_in_front and abs(diff_x) <= owner.attack_range + 50.0:
			if owner.player.has_method("take_damage"):
				owner.player.take_damage(owner.attack_damage)

func physics_update(_delta: float):
	if not owner.is_on_floor():
		owner.velocity.y += 1200.0 * _delta
	owner.velocity.x = 0
	owner.move_and_slide()

func transition():
	if owner.health <= 0:
		return
	if not is_attacking:
		get_parent().change_state("follow")
