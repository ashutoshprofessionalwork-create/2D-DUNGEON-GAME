extends State

@onready var anim = owner.find_child("AnimatedSprite2D")
var is_throwing: bool = false

func enter():
	super.enter()
	if not anim:
		anim = owner.get_node_or_null("AnimatedSprite2D")
	is_throwing = true
	owner.velocity.x = 0
	
	if "rock_throw_timer" in owner:
		owner.rock_throw_timer = owner.rock_throw_cooldown

	# Play attack animation for rock throw telegraph
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("attack"):
		anim.play("attack")

	if anim:
		while is_throwing and owner.is_inside_tree() and owner.get_tree() and anim.animation == "attack" and anim.frame < 3:
			await owner.get_tree().process_frame

	if not is_throwing or owner.health <= 0 or not owner.is_inside_tree():
		return

	# Throw 3 rocks in a spread fan towards player
	spawn_rock_salvo()

	if anim and anim.is_playing():
		await anim.animation_finished

	is_throwing = false

func spawn_rock_salvo():
	if owner.health <= 0 or not owner.player or not is_instance_valid(owner.player):
		return

	var rock_scene = owner.rock_scene if ("rock_scene" in owner and owner.rock_scene) else load("res://rock_projectile.tscn")
	if not rock_scene:
		return

	var base_dir = (owner.player.global_position - owner.global_position).normalized()
	# Spread angles: -15 degrees, 0 degrees, +15 degrees
	var spread_angles = [-0.26, 0.0, 0.26]

	for angle in spread_angles:
		var dir = base_dir.rotated(angle)
		var rock = rock_scene.instantiate()
		rock.global_position = owner.global_position + Vector2(0, -20)
		rock.launch(dir, 450.0, 20)
		if owner.get_tree() and owner.get_tree().current_scene:
			owner.get_tree().current_scene.add_child(rock)

func physics_update(_delta: float):
	if not owner.is_on_floor():
		owner.velocity.y += 1200.0 * _delta
	owner.velocity.x = 0
	if owner.has_method("safe_move_and_slide"):
		owner.safe_move_and_slide()
	else:
		owner.move_and_slide()

func transition():
	if owner.health <= 0:
		return
	if not is_throwing:
		get_parent().change_state("follow")
