extends Node2D
@export var next_level: PackedScene

@onready var boss = $Boss1
@onready var exit_area = $DetectionArea if has_node("DetectionArea") else null

var boss_defeated: bool = false

func _ready() -> void:
	if exit_area:
		exit_area.monitoring = false
		exit_area.visible = false
	if boss:
		boss.boss_died.connect(_on_boss_died)

func _on_boss_died() -> void:
	print("Boss1 defeated! Transitioning to next level in 5 seconds...")
	boss_defeated = true
	if exit_area:
		exit_area.monitoring = true
		exit_area.visible = true
	
	var timer = get_tree().create_timer(5.0)
	await timer.timeout
	
	if next_level:
		if SceneTransition:
			SceneTransition.change_scene_packed(next_level, 0.5)
		else:
			get_tree().change_scene_to_packed.call_deferred(next_level)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if next_level:
		if SceneTransition:
			SceneTransition.change_scene_packed(next_level, 0.5)
		else:
			get_tree().change_scene_to_packed.call_deferred(next_level)

func _on_detection_area_body_exited(_body: Node2D) -> void:
	print("area exited")
