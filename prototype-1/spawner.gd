extends Node2D

@export var spawn_list: Array[EnemySpawnInfo] = []

@export var base_spawn_time: float = 3.0   
@export var minimum_spawn_time: float = 0.5 

@onready var timer: Timer = $Timer
@onready var player: Node2D = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	if timer:
		timer.wait_time = base_spawn_time
		timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if not is_instance_valid(player) or spawn_list.is_empty():
		return
	
	# Spawn side & offset
	var dir = 1 if randf() > 0.5 else -1
	var spawn_pos = player.global_position + Vector2(dir * 1000.0, 0)
	
	# Get random enemy info based on Inspector weights
	var selected_info = _get_weighted_enemy()
	if selected_info and selected_info.enemy_scene:
		var enemy = selected_info.enemy_scene.instantiate()
		enemy.global_position = spawn_pos
		
		# Override enemy hit effect if set in spawner
		if selected_info.hit_effect_scene and "hit_effect_scene" in enemy:
			enemy.hit_effect_scene = selected_info.hit_effect_scene
			
		get_tree().current_scene.add_child(enemy)
	
	# Speed up spawn based on score
	var new_time = base_spawn_time - (ScoreManager.score * 0.05)
	timer.wait_time = max(new_time, minimum_spawn_time)

func _get_weighted_enemy() -> EnemySpawnInfo:
	var total_weight: float = 0.0
	for info in spawn_list:
		if info:
			total_weight += info.weight
		
	var roll = randf_range(0.0, total_weight)
	var current_sum: float = 0.0
	
	for info in spawn_list:
		if info:
			current_sum += info.weight
			if roll <= current_sum:
				return info
			
	return null
