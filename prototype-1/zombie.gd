extends CharacterBody2D

## --- Tuning values, adjust in the Inspector ---
@export var speed: float = 80.0
@export var chase_range: float = 200.0
@export var attack_range: float = 60.0   # <-- increase this number to give the zombie more reach
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum State { IDLE, CHASE, ATTACK }
var current_state: State = State.IDLE

var player: Node2D = null
var attack_timer: float = 0.0
var is_attacking: bool = false

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		push_warning("Zombie: No node found in group 'player'.")

func _physics_process(delta: float) -> void:
	if player:
		print("Distance to player: ", global_position.distance_to(player.global_position), " | attack_range: ", attack_range)

	if attack_timer > 0.0:
		attack_timer -= delta

		move_and_slide()
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance_to_player: float = global_position.distance_to(player.global_position)

	if distance_to_player <= attack_range:
		_set_state(State.ATTACK)
	elif distance_to_player <= chase_range:
		_set_state(State.CHASE)
	else:
		_set_state(State.IDLE)

	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.CHASE:
			var direction: Vector2 = (player.global_position - global_position).normalized()
			velocity = direction * speed
			_flip_towards(direction)
		State.ATTACK:
			velocity = Vector2.ZERO
			_flip_towards((player.global_position - global_position).normalized())
			_try_attack()

	move_and_slide()

func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state

	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.CHASE:
			animated_sprite.play("run")
		State.ATTACK:
			pass

func _try_attack() -> void:
	if attack_timer <= 0.0 and not is_attacking:
		attack_timer = attack_cooldown
		_play_attack_sequence()

func _play_attack_sequence() -> void:
	is_attacking = true
	animated_sprite.play("attack")
	await animated_sprite.animation_finished

	var distance_to_player: float = global_position.distance_to(player.global_position)
	if is_instance_valid(player) and distance_to_player <= attack_range:
		animated_sprite.play("bite")
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
		else:
			push_warning("Zombie: Player has no 'take_damage' method.")
		await animated_sprite.animation_finished

	is_attacking = false

func _flip_towards(direction: Vector2) -> void:
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
