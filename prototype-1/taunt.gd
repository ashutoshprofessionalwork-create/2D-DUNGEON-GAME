extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
var is_taunting: bool = false

func enter():
	super.enter()
	if not anim:
		anim = owner.get_node_or_null("AnimatedSprite2D")
	is_taunting = true
	owner.taunt_timer = owner.taunt_cooldown
	owner.velocity.x = 0

	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("taunt"):
		anim.play("taunt")

	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(1.2).timeout
	elif anim and anim.is_playing():
		await anim.animation_finished

	if owner.health <= 0:
		return

	is_taunting = false

func physics_update(_delta: float):
	if not owner.is_on_floor():
		owner.velocity.y += 1200.0 * _delta
	owner.velocity.x = 0
	owner.move_and_slide()

func transition():
	if owner.health <= 0:
		return
	if not is_taunting:
		get_parent().change_state("follow")
