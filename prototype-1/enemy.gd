extends CharacterBody2D

@export var speed: float = 100.0
@onready var anim = $AnimatedSprite2D

var player: Node2D

func _ready():
	# Automatically find the player so the Inspector doesn't break the clones
	player = get_tree().current_scene.get_node_or_null("player")

func _physics_process(delta):
	# If the player isn't in the scene yet, do nothing
	if not is_instance_valid(player):
		return 

	# Add gravity so it doesn't float like a ghost
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Move toward player on X axis
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * speed
	
	# Flip sprite to face player
	if direction != 0:
		anim.flip_h = direction < 0

	move_and_slide()

	# Check for collisions with the player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == player:
			anim.play("enemy attack2")
			player.take_damage(10.0) # Deals 10 damage to player
			return 
			
	anim.play("enemy run2")
