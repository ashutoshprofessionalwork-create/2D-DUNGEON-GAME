extends Node2D

@onready var bg: AudioStreamPlayer2D = $bg
@onready var bgpress: AudioStreamPlayer2D = $bgpress

func _ready() -> void:
	bg.play()

func _on_restart_pressed() -> void:
	bg.stop()
	bgpress.play()
	await bgpress.finished
	
	var restart_scene_path = Global.last_level_path if not Global.last_level_path.is_empty() else "res://level_1.tscn"
	
	if SceneTransition:
		SceneTransition.change_scene_file(restart_scene_path, 0.5)
	else:
		var error = get_tree().change_scene_to_file(restart_scene_path)
		if error != OK:
			print(error)
