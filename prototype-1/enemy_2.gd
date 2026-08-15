extends CharacterBody2D

## --- Tuning values, adjust in the Inspector ---
@export var speed: float = 80.0
@export var chase_range: float = 200.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_hitbox: Area2D = $EnemyHitbox

enum State { IDLE, CHASE, ATTACK }
var current_state: State = State.IDLE

var player: Node2D = null
var attack_timer: float = 0.0
var player_in_hitbox: bool = false

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		push_warning("Zombie: No node found in group 'player'. Make sure your Player is added to that group.")

	enemy_hitbox.body_entered.connect(_on_hitbox_body_entered)
	enemy_hitbox.body_exited.connect(_on_hitbox_body_exited)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_hitbox = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_hitbox = false

func _physics_process(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta

	if player == null:
		_set_state(State.IDLE)
		move_and_slide()
		return

	var distance_to_player: float = global_position.distance_to(player.global_position)

	# --- State decision ---
	if player_in_hitbox:
		_set_state(State.ATTACK)
	elif distance_to_player <= chase_range:
		_set_state(State.CHASE)
	else:
		_set_state(State.IDLE)

	# --- State behavior ---
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
			animated_sprite.play("enemy idle2")
		State.CHASE:
			animated_sprite.play("enemy run2")
		State.ATTACK:
			animated_sprite.play("enemy attack2")

func _try_attack() -> void:
	if attack_timer <= 0.0:
		attack_timer = attack_cooldown
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
			animated_sprite.play("enemy eating2")
		else:
			push_warning("Zombie: Player has no 'take_damage' method.")

func _flip_towards(direction: Vector2) -> void:
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
