
extends Area2D

@export var health_restore: float = 20.0
@export var magnet_speed: float = 0.0
@export var pickup_distance: float = 30.0 # Pixel radius to trigger the instavanish


var player: Node2D = null
var is_collected: bool = false

func _ready() -> void:
	player = get_tree().current_scene.get_node_or_null("player")
	var level_name = get_parent().name # Gets "Level1", "Level2", etc.
	if level_name == "jungle_night":
		scale=Vector2(0.5,0.5)

func _process(delta: float) -> void:
	if is_collected or not is_instance_valid(player) or player.get("is_dead"):
		return

	# 1. Magnetize smoothly towards the player
	global_position = global_position.move_toward(player.global_position, magnet_speed * delta)

	# 2. Hardcoded Distance Check bypasses broken collision signals completely
	if global_position.distance_to(player.global_position) <= pickup_distance:
		execute_pickup()

func execute_pickup() -> void:
	is_collected = true
	
	# Apply health
	if player.has_method("heal"):
		player.heal(health_restore)
	elif player.get("current_health") != null:
		var max_hp = player.get("max_health") if player.get("max_health") != null else 100.0
		player.current_health = min(player.current_health + health_restore, max_hp)

	_spawn_green_flash()
	queue_free()

func _spawn_green_flash() -> void:
	var flash = CPUParticles2D.new()
	get_tree().current_scene.add_child(flash)
	flash.global_position = global_position
	flash.scale=Vector2(1,1)
	
	flash.emitting = true
	flash.one_shot = true
	flash.amount = 160
	flash.lifetime = 0.3
	flash.explosiveness = 1.0
	flash.spread = 180.0
	flash.gravity = Vector2.ZERO
	flash.initial_velocity_min = 100.0
	flash.initial_velocity_max = 200.0
	flash.color = Color(0.2, 1.0, 0.2, 1.0)
	
	get_tree().create_timer(0.4).timeout.connect(flash.queue_free)
