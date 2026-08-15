extends Area2D

@export_file("*.tscn") var next_scene: String

func _on_area_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)
	if body.is_in_group("player"):
			TransitionManager.change_to_load(next_scene)
	# Replace 'TransitionManager' with whatever you named your Autoload in Project Settings
