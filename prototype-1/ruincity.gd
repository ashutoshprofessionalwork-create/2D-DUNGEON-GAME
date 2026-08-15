extends Node2D
@export var next_level:PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$player/AnimationPlayer.play("new_animation_2")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass






func _on_detection_area_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_packed.call_deferred(next_level)


func _on_detection_area_body_exited(body: Node2D) -> void:
	print("area exited")
