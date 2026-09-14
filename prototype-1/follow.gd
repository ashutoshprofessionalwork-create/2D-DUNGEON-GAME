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
		if abs(dir_x) > 5.0:
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
	
	if owner.heavy_attack_timer <= 0.0 and horiz_dist <= owner.heavy_attack_range:
		get_parent().change_state("heavy_attack")
	elif horiz_dist <= owner.attack_range:
		get_parent().change_state("attack")
	elif owner.taunt_timer <= 0.0 and horiz_dist >= 300.0 and owner.is_on_floor():
		get_parent().change_state("taunt")
	elif horiz_dist > owner.detection_range:
		get_parent().change_state("idle")
