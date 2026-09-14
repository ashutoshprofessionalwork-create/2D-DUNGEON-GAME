extends Node2D

@onready var bg: AudioStreamPlayer2D = $bg
@onready var bgpress: AudioStreamPlayer2D = $bgpress

func _ready() -> void:
	bg.play()

func _on_restart_pressed() -> void:
	bg.stop()
	bgpress.play()
	await bgpress.finished
	
	if SceneTransition:
		SceneTransition.change_scene_file("res://loading.tscn", 0.5)
	else:
		var error = get_tree().change_scene_to_file("res://loading.tscn")
		if error != OK:
			print(error)
