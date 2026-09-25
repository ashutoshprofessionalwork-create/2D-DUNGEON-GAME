class_name RockProjectile
extends RigidBody2D

@export var speed: float = 400.0
@export var damage: int = 20

var velocity: Vector2 = Vector2.ZERO

func _ready():
	collision_layer = 0
	collision_mask = 2 # Player layer (layer 2)
	contact_monitor = true
	max_contacts_reported = 4
	
	body_entered.connect(_on_body_entered)
	
	# Auto despawn timer
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(func(): if is_instance_valid(self): queue_free())

func launch(direction: Vector2, custom_speed: float = 400.0, custom_damage: int = 20):
	velocity = direction.normalized() * custom_speed
	linear_velocity = velocity
	damage = custom_damage
	rotation = velocity.angle()

func _physics_process(delta: float):
	rotation += 5.0 * delta # Spin while flying

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") or body.has_method("take_damage"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif not body.is_in_group("enemy"):
		queue_free()
