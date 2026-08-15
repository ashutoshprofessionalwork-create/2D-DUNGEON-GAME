class_name snake
extends CharacterBody2D

@export var speed: float = 80.0
@export var detection_range: float = 180.0
@export var attack_range: float = 35.0
@export var max_health: int = 30
@export var attack_damage: int = 10
@export var collision_offset: float = 6.0
@export var hit_effect_scene: PackedScene
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@export var friction: float =1800
@export var attack_cooldown=0.1
@export var attack_duration=1
var current_health: int
var player: Node2D = null
var is_dead: bool = false
var is_attacking: bool = false
var is_hurt: bool = false
var current_attack_id: int = 0
var knockback_velocity: Vector2 = Vector2.ZERO
enum State { IDLE, WALK, ATTACK, HURT, DEATH, KNOCKOUT }
var state = State.IDLE

func _ready():
	var level_name = get_parent().name # Gets "Level1", "Level2", etc.
	
	if level_name == "jungle":
		scale=Vector2(6,6)
		detection_range=1000000
		attack_range=170
		speed=150
		
		
	elif level_name=="level2":
		scale=Vector2(1,1)
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
		# Apply friction so they slide to a stop smoothly
		knockback_velocity.x = move_toward(knockback_velocity.x, 0, friction * delta)
	elif state == State.HURT or state == State.KNOCKOUT or is_attacking:
		velocity.x = 0
	
	# Rest of your movement logic...
	if not (is_attacking or state == State.HURT or state == State.KNOCKOUT or is_dead):
		player = get_tree().get_first_node_in_group("player")
		if player:
			var dist = global_position.distance_to(player.global_position)
			var direction_x = player.global_position.x - global_position.x
			if direction_x != 0: update_facing(direction_x)
			
			if dist < attack_range:
				velocity.x = 0
				attack()
			elif dist < detection_range:
				velocity.x = sign(direction_x) * speed
				state = State.WALK
		else:
			velocity.x = 0
			state = State.IDLE

	move_and_slide()
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



func attack():
	if is_attacking or is_dead:
		return
	is_attacking = true
	state = State.ATTACK
	anim.play("attack")
	anim.animation_finished
	
	# Generate a unique ID for this specific attack attempt
	current_attack_id += 1
	var this_attack_id = current_attack_id

	# Wait for the startup frames before dealing damage
	await get_tree().create_timer(attack_cooldown).timeout
	
	# INTERRUPT CHECK: If the attack ID changed during the timer, stop immediately!
	if this_attack_id != current_attack_id or is_dead or is_hurt:
		is_attacking = false
		return

	# Deal damage if player is still in range
	if player and global_position.distance_to(player.global_position) < attack_range + 10:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)

	var remaining = max(attack_duration - attack_cooldown, 0.0)
	await get_tree().create_timer(remaining).timeout
	
	if this_attack_id != current_attack_id or is_dead or is_hurt:
		return 
	is_attacking=false
	state=State.IDLE
	
	
func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO, force: float = 0.0):
	if is_dead:
		return
		
	current_attack_id += 1 
	is_attacking = false 
	current_health -= amount
	
	# Calculate direction away from the source of the attack
	if source_position != Vector2.ZERO and force > 0:
		var knockback_dir = sign(global_position.x - source_position.x)
		if knockback_dir == 0:
			knockback_dir = 1
		knockback_velocity = Vector2(knockback_dir * force, -force * 0.4)

	trigger_hitstop(0.08)

	if hit_effect_scene:
		var effect = hit_effect_scene.instantiate()
		effect.global_position = global_position
		get_parent().add_child(effect)

	if current_health <= 0:
		die()
	else:
		if force >= 400.0:
			state = State.KNOCKOUT
			# TO THIS:
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
	set_collision_layer_value(3,false)
	set_collision_mask_value(2,false)
	anim.play("death")
	await anim.animation_finished
	ScoreManager.add_score(20)
	queue_free()
