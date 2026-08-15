extends Node2D

@export var enemy_scene: PackedScene

var player: Node2D

func _ready() -> void:
	player = get_tree().current_scene.get_node_or_null("player")
	
	var timer = $Timer
	if timer:
		timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if not is_instance_valid(player) or not enemy_scene:
		return
		
	var enemy = enemy_scene.instantiate()
	
	var screen_width = get_viewport_rect().size.x
	var spawn_offset = (screen_width / 2.0) + 150.0
	
	var dir = 1 if randi() % 2 == 0 else -1
	
	var spawn_pos = player.global_position
	spawn_pos.x += dir * spawn_offset
	spawn_pos.y -= 200.0
	
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)
