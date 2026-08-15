extends State

func enter():
	set_physics_process(true)
	
	if owner.direction.length() > 900:
		anim.play("taunt")
		
		var dash_dir = (player.position - owner.position).normalized()
		owner.velocity.x = dash_dir.x * 500 
		
		await anim.animation_finished
		
		# 1. DYNAMIC FRAME FIX: Counter-steer the sprite offset so it stays glued to the hitbox
		# Change 60.0 to whatever pixel distance your sprite drifts in the animation sheet
		var drift_distance = 60.0
		anim.offset.x = -drift_distance if anim.flip_h else drift_distance
		
		anim.play("dash")
		await anim.animation_finished
		
		# 2. RESET OFFSET: Clean it up instantly so your follow/walk animations aren't broken
		anim.offset.x = 0
		
		# FORCE KILL MOVEMENT: This breaks the animation loop trap instantly
		owner.velocity = Vector2.ZERO
		owner.global_position = owner.global_position
		
	else:
		get_parent().change_state("follow")

func transition():
	if abs(owner.velocity.x) > 0:
		return
		
	if owner.direction.length() > 450:
		get_parent().change_state("follow")
