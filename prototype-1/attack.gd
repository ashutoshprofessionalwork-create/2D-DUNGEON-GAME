extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
var is_attacking: bool = false

func enter():
	super.enter()
	is_attacking = true
	owner.velocity.x = 0
	
	# First Hit: Primary attack animation
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("attack"):
		anim.play("attack")
		
	# First Strike damage timing
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.25).timeout
	if owner.health <= 0:
		return
	deal_damage_if_in_range()

	# Pause briefly between consecutive hits
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.3).timeout
	if owner.health <= 0:
		return

	# Second Hit: Follow-up spin attack animation
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("spin_attack"):
		anim.play("spin_attack")
	elif anim:
		anim.play("attack")

	# Second Strike damage timing
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.3).timeout
	if owner.health <= 0:
		return
	deal_damage_if_in_range()

	# End combo recovery time
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.3).timeout
	if owner.health <= 0:
		return

	is_attacking = false

func deal_damage_if_in_range():
	if owner.health <= 0:
		return
	if owner.player and is_instance_valid(owner.player):
		var dist = abs(owner.player.global_position.x - owner.global_position.x)
		if dist <= owner.attack_range + 50.0:
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
 
