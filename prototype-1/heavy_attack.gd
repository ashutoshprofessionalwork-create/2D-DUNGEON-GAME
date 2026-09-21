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

	create_warning_indicator(owner.global_position + Vector2(direction * 50, 20))
	if anim:
		anim.modulate = Color(3.0, 0.2, 0.2, 1.0)

	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.5).timeout
	
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
		while is_attacking and owner.is_inside_tree() and owner.get_tree() and anim.animation == target_anim and anim.frame < 4:
			await owner.get_tree().process_frame
	
	is_staggered = owner.is_staggered if "is_staggered" in owner else false
	if not is_attacking or owner.health <= 0 or not owner.is_inside_tree() or is_staggered:
		remove_warning_indicator()
		return

	remove_warning_indicator()

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

func create_warning_indicator(pos: Vector2):
	remove_warning_indicator()
	indicator = Polygon2D.new()
	indicator.color = Color(1.0, 0.0, 0.0, 0.7)
	indicator.polygon = PackedVector2Array([
		Vector2(-40, -12),
		Vector2(40, -12),
		Vector2(40, 12),
		Vector2(-40, 12)
	])
	indicator.global_position = pos
	if owner.get_parent():
		owner.get_parent().add_child(indicator)

func remove_warning_indicator():
	if indicator and is_instance_valid(indicator):
		indicator.queue_free()
		indicator = null

func physics_update(_delta: float):
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
