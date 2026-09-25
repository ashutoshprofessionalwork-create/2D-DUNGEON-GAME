extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
@onready var col_shape = owner.find_child("CollisionShape2D")

var is_leaping: bool = false
var indicator: Polygon2D = null

func enter():
	super.enter()
	is_leaping = true
	owner.leap_timer = owner.leap_cooldown

	var dir_x = owner.player.global_position.x - owner.global_position.x if (owner.player and is_instance_valid(owner.player)) else (-1.0 if owner.facing_left else 1.0)
	var direction = -1.0 if dir_x < 0 else 1.0

	owner.facing_left = (direction < 0)
	if anim:
		anim.flip_h = owner.facing_left

	# Advance boss forward during the leap slam
	var offset_x = direction * 80.0
	var target_land_x = owner.global_position.x + offset_x

	# 1. Spawn Red Warning Indicator at target landing location
	create_red_indicator(Vector2(target_land_x, owner.global_position.y + 20))

	# 2. Play leap animation
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("leap"):
		anim.play("leap")
		
		# Wait until frame 20 (land / hammer slam impact frame)
		while is_leaping and anim.animation == "leap" and anim.frame < 20:
			var delta_t = get_physics_process_delta_time()
			# Progress movement towards target landing X
			owner.global_position.x = lerp(owner.global_position.x, target_land_x, delta_t * 8.0)
			await get_tree().process_frame

		if owner.health <= 0:
			return
		owner.global_position.x = target_land_x

	# Remove red indicator right as hammer lands
	remove_red_indicator()

	if owner.health <= 0:
		return

	# Deal damage at landing/hammer hit zone
	if owner.player and is_instance_valid(owner.player):
		var horiz_dist = abs(owner.player.global_position.x - owner.global_position.x)
		if horiz_dist <= 250.0:
			if owner.player.has_method("take_damage"):
				owner.player.take_damage(owner.leap_damage)

	if anim and anim.is_playing() and anim.animation == "leap":
		await anim.animation_finished
	if owner.health <= 0:
		return

	is_leaping = false

func create_red_indicator(pos: Vector2):
	remove_red_indicator()
	indicator = Polygon2D.new()
	indicator.color = Color(1.0, 0.0, 0.0, 0.6) # Semi-transparent red
	indicator.polygon = PackedVector2Array([
		Vector2(-40, -10),
		Vector2(40, -10),
		Vector2(40, 10),
		Vector2(-40, 10)
	])
	indicator.global_position = pos
	owner.get_parent().add_child(indicator)

func remove_red_indicator():
	if indicator and is_instance_valid(indicator):
		indicator.queue_free()
		indicator = null

func physics_update(_delta: float):
	if not owner.is_on_floor():
		owner.velocity.y += 1200.0 * _delta
	owner.velocity.x = 0
	if owner.has_method("safe_move_and_slide"):
		owner.safe_move_and_slide()
	else:
		owner.move_and_slide()

func exit():
	super.exit()
	remove_red_indicator()

func transition():
	if owner.health <= 0:
		return
	if not is_leaping:
		get_parent().change_state("follow")
