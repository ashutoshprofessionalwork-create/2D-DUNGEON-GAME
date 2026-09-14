extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
var is_attacking: bool = false
var indicator: Polygon2D = null

func enter():
	super.enter()
	is_attacking = true
	owner.velocity.x = 0
	owner.heavy_attack_timer = owner.heavy_attack_cooldown

	var direction = -1.0 if owner.facing_left else 1.0

	# 1. Spawn warning indicator & flash boss RED to signal heavy incoming attack
	create_warning_indicator(owner.global_position + Vector2(direction * 100, 20))
	if anim:
		anim.modulate = Color(3.0, 0.2, 0.2, 1.0) # Flash bright red warning glow

	# Windup delay so player has time to react / dodge
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.4).timeout
	if owner.health <= 0:
		return

	if anim:
		anim.modulate = Color(1.0, 1.0, 1.0, 1.0) # Reset color

	# 2. Play heavy attack animation (attack1)
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("attack1"):
		anim.play("attack1")
	elif anim:
		anim.play("attack")

	# Heavy Attack strike timing
	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.35).timeout
	if owner.health <= 0:
		return

	remove_warning_indicator()

	# Deal heavy damage
	if owner.health > 0 and owner.player and is_instance_valid(owner.player):
		var dist = abs(owner.player.global_position.x - owner.global_position.x)
		if dist <= owner.heavy_attack_range:
			if owner.player.has_method("take_damage"):
				owner.player.take_damage(owner.heavy_attack_damage)

	if owner.is_inside_tree() and owner.get_tree():
		await owner.get_tree().create_timer(0.4).timeout
	if owner.health <= 0:
		return

	is_attacking = false

func create_warning_indicator(pos: Vector2):
	remove_warning_indicator()
	indicator = Polygon2D.new()
	indicator.color = Color(1.0, 0.0, 0.0, 0.7) # Bright red warning zone
	indicator.polygon = PackedVector2Array([
		Vector2(-60, -12),
		Vector2(60, -12),
		Vector2(60, 12),
		Vector2(-60, 12)
	])
	indicator.global_position = pos
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
	if anim:
		anim.modulate = Color(1.0, 1.0, 1.0, 1.0)

func transition():
	if owner.health <= 0:
		return
	if not is_attacking:
		get_parent().change_state("follow")
