extends CharacterBody2D

@export var speed: float = 80.0
@export var detection_range: float = 180.0
@export var attack_range: float = 35.0
@export var max_health: int = 30
@export var attack_damage: int = 15
@export var collision_offset: float = 6.0
@export var hit_effect_scene: PackedScene
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@export var friction: float = 1800
@export var attack_cooldown = 0.1
@export var attack_duration = 1
var hit_effect=Vector2(1,1)

var current_health: int
var player: Node2D = null
var is_dead: bool = false
var is_attacking: bool = false
var is_hurt: bool = false
var current_attack_id: int = 0
var knockback_velocity: Vector2 = Vector2.ZERO
var player_in_hitbox: bool = false  # true while player overlaps the Area2D

enum State { IDLE, WALK, ATTACK, HURT, DEATH, KNOCKOUT }
var state = State.IDLE

@onready var sound_movement: AudioStreamPlayer2D = $sound_movement
@onready var sound_dead: AudioStreamPlayer2D = $sound_dead
@onready var sound_attack: AudioStreamPlayer2D = $sound_attack


func _ready():
	var level_name = get_parent().name # Gets "Level1", "Level2", etc.
	scale = Vector2(1, 1)

	if level_name == "jungle":
		detection_range = 1100
		attack_range = 130
		speed = 400
		scale = Vector2(5, 5)
		hit_effect=Vector2(5,5)
	
	elif level_name=="jungle_night":
		detection_range=1000
		attack_range=20
		speed=200
		scale=Vector2(2,2)
		
	elif level_name == "level2":
		scale = Vector2(1, 1)
		hit_effect=Vector2(1,1)

	current_health = max_health
	add_to_group("enemy")


func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0

	if is_dead:
		move_and_slide()
		return

	# Handle Knockback physics independently of states
	if knockback_velocity.length() > 10:
		velocity.x = knockback_velocity.x
		knockback_velocity.x = move_toward(knockback_velocity.x, 0, friction * delta)
	elif state == State.HURT or state == State.KNOCKOUT or is_attacking:
		velocity.x = 0

	# Movement / attack decision logic
	if not (is_attacking or state == State.HURT or state == State.KNOCKOUT or is_dead):
		player = get_tree().get_first_node_in_group("player")
		if player:
			# Use HORIZONTAL distance only. Using full 2D distance_to() breaks
			# down when the player stands on top of / above the enemy, since
			# vertical offset counts against the range and causes the enemy
			# to never enter attack range, and direction_x flip-flopping near
			# zero causes the left/right glitching.
			var direction_x = player.global_position.x - global_position.x
			var horiz_dist = abs(direction_x)

			if horiz_dist < attack_range or player_in_hitbox:
				velocity.x = 0
				attack()
			elif horiz_dist < detection_range:
				state = State.WALK
				if horiz_dist > 2.0:  # deadzone avoids facing/velocity jitter near x≈0
					update_facing(direction_x)
					velocity.x = sign(direction_x) * speed
				else:
					velocity.x = 0
			else:
				velocity.x = 0
				state = State.IDLE
		else:
			velocity.x = 0
			state = State.IDLE

	# --- Safety net: never let a NaN or exactly-zero velocity reach move_and_slide ---
	if is_nan(velocity.x) or is_nan(velocity.y):
		velocity = Vector2.ZERO
	if velocity.length() < 0.001 and is_on_floor():
		velocity.x = 0.001  # tiny nudge avoids the zero-vector slide() edge case

	safe_move_and_slide()
	update_animation()


func update_facing(direction_x: float):
	var facing_left = direction_x > 0
	anim.flip_h = facing_left
	collision.position.x = -collision_offset if facing_left else collision_offset


func update_animation():
	match state:
		State.IDLE:
			anim.play("idle")
		State.WALK:
			anim.play("walk")
			if not sound_attack.playing and randf() < 0.02:
				sound_movement.play()


func attack():
	if is_attacking or is_dead:
		return
	is_attacking = true
	state = State.ATTACK
	anim.play("attack")
	sound_attack.play()

	# Generate a unique ID for this specific attack attempt
	current_attack_id += 1
	var this_attack_id = current_attack_id

	# Wait for the startup frames before dealing damage
	await get_tree().create_timer(attack_cooldown).timeout

	# INTERRUPT CHECK: if the attack ID changed during the timer, stop immediately!
	if this_attack_id != current_attack_id or is_dead or is_hurt:
		is_attacking = false
		return

	# Deal damage if player is still in range (horizontal distance OR still in hitbox)
	if player and (abs(global_position.x - player.global_position.x) < attack_range + 10 or player_in_hitbox):
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)

	var remaining = max(attack_duration - attack_cooldown, 0.0)
	await get_tree().create_timer(remaining).timeout

	if this_attack_id != current_attack_id or is_dead or is_hurt:
		return
	is_attacking = false
	state = State.IDLE


func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO, force: float = 0.0):
	if is_dead:
		return

	current_attack_id += 1
	is_attacking = false
	current_health -= amount

	# Calculate direction away from the source of the attack
	if source_position != Vector2.ZERO and force > 0:
		var diff = global_position.x - source_position.x
		var knockback_dir = 1.0 if diff == 0 else sign(diff)
		knockback_velocity = Vector2(knockback_dir * force, -force * 0.4)
	trigger_hitstop(0.08)

	if hit_effect_scene:
		var effect = hit_effect_scene.instantiate()
		effect.global_position = global_position
		#var effect = hit_effect_scene.instantiate()
		#effect.global_position = global_position
		#effect.scale=hit_effect # behenchod chal na
		#get_parent().add_child(effect)
		effect.scale = hit_effect
		get_tree().current_scene.add_child(effect)
	if current_health <= 0:
		die()
	else:
		if force >= 400.0:
			state = State.KNOCKOUT
			if anim.sprite_frames.has_animation("knockout"):
				anim.play("knockout")
			else:
				anim.play("hurt")
			await get_tree().create_timer(0.8).timeout
		else:
			state = State.HURT
			anim.play("hurt")
			await anim.animation_finished

		if not is_dead:
			state = State.IDLE


func trigger_hitstop(duration: float):
	Engine.time_scale = 0.0 # Freeze the game clock
	# Use a real-time timer because the engine clock is frozen!
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0 # Unfreeze


func die():
	is_dead = true
	state = State.DEATH
	velocity = Vector2.ZERO
	# Only turn off collision with the player (e.g., layer 2), NOT the world floor
	set_collision_layer_value(3, false)
	set_collision_mask_value(2, false)
	anim.play("death")
	sound_dead.play()
	await anim.animation_finished
	ScoreManager.add_score(10) # Adds 10 points
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
	player = body
	player_in_hitbox = true
	velocity.x = 0
	attack()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_hitbox = false
		
func safe_move_and_slide():
	up_direction = Vector2.UP
	if is_nan(velocity.x) or is_nan(velocity.y):
		velocity = Vector2.ZERO
	move_and_slide()
