extends Node2D

@onready var bg: AudioStreamPlayer2D = $bg
@onready var bgpress: AudioStreamPlayer2D = $bgpress
@onready var static_sprite: Sprite2D = $buttonmanager/Sprite2D
@onready var animated_sprite: AnimatedSprite2D = $buttonmanager/AnimatedSprite2D
var button_type = null

func _ready() -> void:
	bg.play()
	animated_sprite.visible = false
	
	# Keep only the hover connections (since they aren't connected via Editor)
	for button in [$buttonmanager/START, $buttonmanager/QUIT]:
		button.mouse_entered.connect(_on_button_hover)
		button.mouse_exited.connect(_on_button_exit)
func _on_button_hover() -> void:
	static_sprite.visible = false
	animated_sprite.visible = true
	animated_sprite.play("default")

func _on_button_exit() -> void:
	animated_sprite.stop()
	animated_sprite.visible = false
	static_sprite.visible = true

func _on_start_pressed() -> void:
	bg.stop()
	bgpress.play()
	await bgpress.finished
	
	button_type = "start"
	$fadetransition.show()
	$fadetransition/Timer.start()
	
	# Use safer node check for your AnimationPlayer child
	if $fadetransition.has_node("AnimationPlayer"):
		$fadetransition/AnimationPlayer.play("fade_in")

func _on_quit_pressed() -> void:
	button_type = "quit"
	$fadetransition.show()
	$fadetransition/Timer.start()
	
	if $fadetransition.has_node("AnimationPlayer"):
		$fadetransition/AnimationPlayer.play("fade_in")

func _on_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://loading.tscn")
	elif button_type == "quit":
		get_tree().quit()
