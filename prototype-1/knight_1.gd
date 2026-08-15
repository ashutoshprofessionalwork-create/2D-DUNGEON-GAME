extends CharacterBody2D

const SPEED = 150.0
const ATTACK_RANGE = 50.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = $AnimatedSprite2D

enum State { IDLE, CHASE, ATTACK, DEAD }
var current_state = State.IDLE
var player: CharacterBody2D = null

func _ready():
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	# Safely looks for the player group in your scene
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	if current_state == State.DEAD:
		return

	# Apply basic gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	if player and current_state != State.ATTACK:
		var distance = global_position.distance_to(player.global_position)
		
		if distance <= ATTACK_RANGE:
			trigger_random_attack()
		else:
			current_state = State.CHASE
			# Move towards player position
			var direction = sign(player.global_position.x - global_position.x)
			velocity.x = direction * SPEED
			
			# Flip sprite to face player accurately
			if direction != 0:
				anim.flip_h = direction < 0
	else:
		if current_state != State.ATTACK:
			current_state = State.IDLE
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animations()

func trigger_random_attack():
	current_state = State.ATTACK
	velocity.x = 0 # Full stop so he doesn't slide during hit
	
	# Randomly picks between your knight1_attack1, attack2, or attack3 animations
	var attack_choice = randi_range(1, 3)
	anim.play("knight1_attack" + str(attack_choice))

func update_animations():
	match current_state:
		State.IDLE:
			anim.play("knight1_idle")
		State.CHASE:
			anim.play("knight1_run")

func _on_animated_sprite_2d_animation_finished():
	# Resets to idle state right after the swing finishes
	if current_state == State.ATTACK:
		current_state = State.IDLE
