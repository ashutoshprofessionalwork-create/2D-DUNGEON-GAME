extends CharacterBody2D

var SPEED = 220.0
var JUMP_VELOCITY = -600.0
var ROLL_SPEED = 900
const COMBO_COOLDOWN_TIME = 1.5
var attack_damage = 10
var attack_range = 80.0
var health = 100
@onready var sfx_death: AudioStreamPlayer2D = $sfx_death
@onready var sfx_attack: AudioStreamPlayer2D = $sfx_attack
@onready var sfx_attack_2: AudioStreamPlayer2D = $sfx_attack2
@onready var sfx_walk: AudioStreamPlayer2D = $sfx_walk
@onready var sfx_jump: AudioStreamPlayer2D = $sfx_jump
 
@onready var health_bar = get_parent().get_node("UI/HeartsUI")
var gravity = 1300
@export var void_dist=100

@onready var anim = $AnimatedSprite2D

enum State { IDLE, MOVE, JUMP, ROLL, ATTACK, DEATH }
var current_state = State.IDLE
var facing_direction = 1

var combo_cooldown_timer = 0.0

func _ready():
	up_direction = Vector2.UP
	await get_tree().process_frame
	health_bar.update_hearts(health, 100)
	
	var level_name = get_parent().name
	
	if level_name == "jungle":
		SPEED = 600
		JUMP_VELOCITY = -500.0
		ROLL_SPEED = 900
		attack_damage = 10
		attack_range = 290
		
	elif level_name=="ruincity":
		scale=Vector2(2,2)
		SPEED=600
		JUMP_VELOCITY = -600.0
		ROLL_SPEED = 900
		attack_damage = 10
		attack_range = 290
		gravity=2000
	
	elif level_name == "jungle_night":
		SPEED = 300
		JUMP_VELOCITY = -333
		ROLL_SPEED = 333
		attack_range = 130
		attack_damage = 10
		
	elif level_name == "level1prolog":
		SPEED = 600
		JUMP_VELOCITY = -300.0
		ROLL_SPEED = 900
		attack_damage = 10
		attack_range = 200.0
	
	elif level_name == "level1":
		SPEED = 800
		JUMP_VELOCITY = -500
		ROLL_SPEED = 1200
		attack_damage = 10
		attack_range = 80.0
		
	elif level_name == "level2":
		attack_range = 80.0
		SPEED = 200
		JUMP_VELOCITY = -300.0
		ROLL_SPEED = 220
		void_dist=200

	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func _physics_process(delta):
	if position.y > 1000:
		get_tree().change_scene_to_file("res://deathmenu.tscn")
		return

	if current_state == State.DEATH:
		velocity = Vector2.ZERO
		return

	if combo_cooldown_timer > 0.0:
		combo_cooldown_timer -= delta

	match current_state:
		State.IDLE, State.MOVE, State.JUMP:
			handle_movement(delta)
			handle_actions()
		State.ROLL:
			handle_roll(delta)
		State.ATTACK:
			handle_attack(delta)

	safe_move_and_slide()
	update_animations()

func safe_move_and_slide():
	up_direction = Vector2.UP
	if is_nan(velocity.x) or is_nan(velocity.y):
		velocity = Vector2.ZERO
	move_and_slide()

func handle_movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		current_state = State.JUMP

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		facing_direction = sign(direction)
		anim.flip_h = direction < 0
		if is_on_floor():
			current_state = State.MOVE
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and velocity.x == 0:
			current_state = State.IDLE

func handle_actions():
	if Input.is_action_just_pressed("roll") and is_on_floor():
		current_state = State.ROLL
		anim.play("roll")
		roll()
		
	elif Input.is_action_just_pressed("attack1") and is_on_floor():
		current_state = State.ATTACK
		var random_attack = "attack1" if randf() > 0.5 else "attack2"
		anim.play(random_attack, 1.5)
		sfx_attack.play()
		deal_damage_to_enemies(200.0, attack_damage)
		
	elif Input.is_action_just_pressed("attack2") and is_on_floor():
		if combo_cooldown_timer <= 0.0:
			current_state = State.ATTACK
			combo_cooldown_timer = COMBO_COOLDOWN_TIME
			var random_combo = "combo1" if randf() > 0.5 else "combo2"
			anim.play(random_combo, 6)
			sfx_attack_2.play()
			deal_damage_to_enemies(550.0, attack_damage * 3)
		else:
			print("Combo is on cooldown!")

func handle_roll(delta):
	velocity.y += gravity * delta
	velocity.x = facing_direction * ROLL_SPEED

func roll():
	set_collision_mask_value(3, false)
	set_collision_layer_value(2, false)
	await get_tree().create_timer(0.5).timeout
	set_collision_layer_value(2, false)
	set_collision_mask_value(3, true)

func handle_attack(delta):
	velocity.y += gravity * delta
	velocity.x = 0

func update_animations():
	if current_state == State.IDLE:
		anim.play("idle")
	elif current_state == State.MOVE:
		anim.play("movement")
		if velocity.x != 0:
			if not sfx_walk.playing:
				sfx_walk.play()
		else:
			sfx_walk.stop()
	elif current_state == State.JUMP:
		anim.play("jump")
		if not sfx_jump.playing:
			sfx_jump.play()

func _on_animated_sprite_2d_animation_finished():
	if current_state == State.ROLL or current_state == State.ATTACK:
		velocity.x = 0
		current_state = State.IDLE

func deal_damage_to_enemies(force: float = 200.0, damage_to_deal: int = 10):
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		var dir_to_enemy = sign(enemy.global_position.x - global_position.x)
		
		if dir_to_enemy == 0:
			dir_to_enemy = facing_direction
		
		if dist <= attack_range and dir_to_enemy == facing_direction:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage_to_deal, global_position, force*2)

func take_damage(amount):
	if current_state == State.DEATH or current_state == State.ROLL:
		return

	health -= amount
	health_bar.update_hearts(health, 100)
	
	anim.modulate = Color(5.0, 0.3, 0.3, 1.0)
	var flash_timer = get_tree().create_timer(0.15)
	flash_timer.timeout.connect(func(): anim.modulate = Color(1, 1, 1, 1))

	print("Player took damage! HP left: ", health)
	if health <= 0:
		current_state = State.DEATH
		velocity = Vector2.ZERO
		collision_layer = 0
		collision_mask = 0
		anim.play("death")
		sfx_death.play()
		
		await anim.animation_finished
		get_tree().change_scene_to_file("res://deathmenu.tscn")

func heal(amount: float) -> void:
	health = min(health + amount, 100)
	if health_bar:
		health_bar.update_hearts(health, 100)
	print("Healed! Current HP: ", health)
	
func check_out_of_bounds():
	if position.y > void_dist:
		get_tree().change_scene_to_file("res://deathmenu.tscn") # Put your scene path here
