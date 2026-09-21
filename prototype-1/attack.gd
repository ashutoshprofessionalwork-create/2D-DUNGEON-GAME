extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
var is_attacking: bool = false
var attack_count = 0

func enter():
	super.enter()
	if not anim:
		anim = owner.get_node_or_null("AnimatedSprite2D")
	is_attacking = true
	owner.velocity.x = 0
	
	face_target()

	# 1. First Attack Animation ("attack")
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("attack"):
		anim.play("attack")

	# Wait until frame 4 or animation completion
	if anim and anim.is_playing() and anim.animation == "attack":
		while is_attacking and owner.is_inside_tree() and owner.get_tree() and anim.animation == "attack" and anim.frame < 4:
			await owner.get_tree().process_frame
	if not is_attacking or owner.health <= 0 or not owner.is_inside_tree():
		return
	deal_damage_if_in_range()

	# Wait for first attack animation to finish
	if anim and anim.is_playing() and anim.animation == "attack":
		await anim.animation_finished
	if owner.health <= 0 or not owner.is_inside_tree():
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

		while is_attacking and owner.is_inside_tree() and owner.get_tree() and anim.animation == second_anim and anim.frame < 4:
			await owner.get_tree().process_frame
		if not is_attacking or owner.health <= 0 or not owner.is_inside_tree():
			return
		deal_damage_if_in_range()

		if anim and anim.is_playing():
			await anim.animation_finished

	if owner.health <= 0 or not owner.is_inside_tree():
		return

	# Cooldown gap before returning to follow state
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.4).timeout
	if owner.health <= 0:
		return

	is_attacking = false

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
	if not owner.is_on_floor():
		owner.velocity.y += 1200.0 * _delta
	owner.velocity.x = 0
	owner.move_and_slide()

func transition():
	if owner.health <= 0:
		return
	if not is_attacking:
		get_parent().change_state("follow")
