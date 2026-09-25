extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
var is_dashing: bool = false

func enter():
	super.enter()
	is_dashing = true
	owner.dash_timer = owner.dash_cooldown

	# Lock direction at the start of dash
	var dir_x = owner.player.global_position.x - owner.global_position.x if (owner.player and is_instance_valid(owner.player)) else (-1.0 if owner.facing_left else 1.0)
	var direction = -1.0 if dir_x < 0 else 1.0

	owner.facing_left = (direction < 0)
	if anim:
		anim.flip_h = owner.facing_left

	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("dash"):
		anim.play("dash")

	owner.velocity.x = direction * owner.dash_speed

	var duration = 0.45
	var elapsed = 0.0
	var hit_player = false

	while elapsed < duration and is_dashing:
		var delta_t = get_physics_process_delta_time()
		elapsed += delta_t
		if owner.player and is_instance_valid(owner.player) and not hit_player:
			var horiz_dist = abs(owner.player.global_position.x - owner.global_position.x)
			if horiz_dist <= 120.0:
				hit_player = true
				if owner.player.has_method("take_damage"):
					owner.player.take_damage(owner.dash_damage)
		await get_tree().process_frame

	owner.velocity.x = 0
	await get_tree().create_timer(0.25).timeout
	is_dashing = false

func physics_update(_delta: float):
	if not owner.is_on_floor():
		owner.velocity.y += 1200.0 * _delta
	if owner.has_method("safe_move_and_slide"):
		owner.safe_move_and_slide()
	else:
		owner.move_and_slide()

func transition():
	if not is_dashing:
		get_parent().change_state("follow")
