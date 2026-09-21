extends State

@onready var anim = owner.find_child("AnimatedSprite2D")

func enter():
	super.enter()
	if not anim:
		anim = owner.get_node_or_null("AnimatedSprite2D")
	owner.velocity = Vector2.ZERO
	if owner.progress_bar:
		owner.progress_bar.visible = false
	
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("death"):
		anim.play("death")

	owner.boss_died.emit()

func physics_update(_delta: float):
	if not owner.is_on_floor():
		owner.velocity.y += 1200.0 * _delta
	owner.velocity.x = 0
	owner.move_and_slide()

func transition():
	pass
