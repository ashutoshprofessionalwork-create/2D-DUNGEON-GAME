extends Node2D

# Option 1: If AnimationPlayer is named "AnimationPlayer" inside fadetransition


# Option 2: If the child node itself is named "fadetransition" or something else, 
# point directly to the AnimationPlayer child node:
# @onready var anim = $fadetransition/$YourAnimationPlayerNodeName

func _ready() -> void:
	$fadetransition/AnimationPlayer.play("fade_out")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	await get_tree().create_timer(5).timeout
	$fadetransition/AnimationPlayer.play("fade_in")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://level_1_prolog.tscn")
