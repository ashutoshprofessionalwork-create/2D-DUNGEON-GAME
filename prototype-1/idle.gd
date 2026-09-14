extends State

@onready var anim = owner.find_child("AnimatedSprite2D")

func enter():
	super.enter()
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("idle"):
		anim.play("idle")

func physics_update(_delta: float):
	if not owner.is_on_floor():
		owner.velocity.y += 1200.0 * _delta
	owner.velocity.x = move_toward(owner.velocity.x, 0, owner.speed)
	owner.move_and_slide()

func transition():
	if owner.player and is_instance_valid(owner.player):
		var dist = abs(owner.player.global_position.x - owner.global_position.x)
		if dist <= owner.detection_range:
			get_parent().change_state("follow")
