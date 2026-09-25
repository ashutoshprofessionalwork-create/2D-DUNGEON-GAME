extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
var is_attacking: bool = false
var indicator: Polygon2D = null

func enter():
	super.enter()
	if not anim:
		anim = owner.get_node_or_null("AnimatedSprite2D")
	is_attacking = true
	owner.velocity.x = 0
	owner.heavy_attack_timer = owner.heavy_attack_cooldown
	if "is_casting" in owner:
		owner.is_casting = true

	var direction = -1.0 if owner.facing_left else 1.0
	var range_width = owner.heavy_attack_range if "heavy_attack_range" in owner else 200.0

	create_warning_indicator(owner.global_position, direction, range_width)
	if anim:
		# Changed red to warning orange/gold tint (Color(1.5, 0.7, 0.2, 1.0))
		anim.modulate = Color(1.5, 0.7, 0.2, 1.0)

	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.65).timeout
	
	if "is_casting" in owner:
		owner.is_casting = false

	var is_staggered = owner.is_staggered if "is_staggered" in owner else false
	if owner.health <= 0 or not owner.is_inside_tree() or is_staggered:
		remove_warning_indicator()
		return

	if anim and not is_staggered:
		anim.modulate = Color(1.0, 1.0, 1.0, 1.0)

	var target_anim = "attack1"
	if anim and anim.sprite_frames:
		if anim.sprite_frames.has_animation("attack1"):
			target_anim = "attack1"
		elif anim.sprite_frames.has_animation("attack"):
			target_anim = "attack"

	if anim:
		anim.play(target_anim)

	if anim:
		while is_attacking and owner.is_inside_tree() and owner.get_tree() and anim.animation == target_anim and anim.frame < 6:
			await owner.get_tree().process_frame
	
	is_staggered = owner.is_staggered if "is_staggered" in owner else false
	if not is_attacking or owner.health <= 0 or not owner.is_inside_tree() or is_staggered:
		remove_warning_indicator()
		return

	remove_warning_indicator()

	if owner.has_method("screen_shake"):
		owner.screen_shake(18.0, 0.45)

	# Directional Frontal Cone Check (Roll behind vulnerability)
	if owner.health > 0 and owner.player and is_instance_valid(owner.player):
		var diff_x = owner.player.global_position.x - owner.global_position.x
		var facing_left = anim.flip_h if anim else owner.facing_left
		var player_in_front = (facing_left and diff_x <= 0) or (not facing_left and diff_x >= 0)

		if player_in_front and abs(diff_x) <= owner.heavy_attack_range + 40.0:
			if owner.player.has_method("take_damage"):
				owner.player.take_damage(owner.heavy_attack_damage)

	if anim and anim.is_playing():
		await anim.animation_finished

	is_attacking = false

func create_warning_indicator(boss_pos: Vector2, dir: float, attack_dist: float):
	remove_warning_indicator()
	indicator = Polygon2D.new()
	indicator.color = Color(1.0, 0.45, 0.0, 0.5) # Warning orange/gold ground indicator
	
	# Create ground zone box right in front of boss where the attack lands
	var start_x = 0.0
	var end_x = dir * (attack_dist + 40.0)
	var ground_y = 35.0 # Height offset to project on ground under boss
	var zone_height = 24.0

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

func exit():
	super.exit()
	remove_warning_indicator()
	if "is_casting" in owner:
		owner.is_casting = false
	var is_staggered = owner.is_staggered if "is_staggered" in owner else false
	if anim and not is_staggered:
		anim.modulate = Color(1.0, 1.0, 1.0, 1.0)

func transition():
	if owner.health <= 0:
		return
	var is_staggered = owner.is_staggered if "is_staggered" in owner else false
	if not is_attacking or is_staggered:
		get_parent().change_state("follow")
