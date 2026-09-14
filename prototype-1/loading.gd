extends Node2D

var _transitioning: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if _transitioning:
		return
	_transitioning = true
	await get_tree().create_timer(4.0).timeout
	if SceneTransition:
		SceneTransition.change_scene_file("res://level_1_prolog.tscn", 0.5)
	else:
		get_tree().change_scene_to_file("res://level_1_prolog.tscn")
