extends State

@onready var animation_player = owner.find_child("AnimationPlayer")

func enter():
	super.enter()
	animation_player.play("walk")

func physics_update(_delta: float):
	# Make sure owner (the Boss) calculates direction towards player
	if owner.player:
		var direction = (owner.player.global_position - owner.global_position).normalized()
		owner.velocity = direction * owner.speed
		owner.move_and_slide()

func transition():
	if owner.global_position.distance_to(owner.player.global_position) < 40:
		get_parent().change_state("attack")
