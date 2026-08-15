extends CharacterBody2D

var current_state = IDLE
var is_chatting = false
var player_in_chat_zone = false
var start_pos

enum {IDLE}

func _ready():
	start_pos = position

func _process(_delta):
	if current_state == 0 or current_state == 1:
		$AnimatedSprite2D.play("idle")
		
	# ONLY allow interaction if the player is actually in the zone
	if Input.is_action_just_pressed("interact") and player_in_chat_zone:
		$dialogchat.visible=true
		$dialogchat.start()
		is_chatting = true
		$AnimatedSprite2D.play("chat")

# Fix 1: Set this to TRUE when they enter
func _on_chat_detection_area_body_entered(body: Node2D) -> void:
		player_in_chat_zone = true
		print(body)
	
# Fix 2: Add the body_exited signal to set it back to FALSE
func _on_chat_detection_area_body_exited(body: Node2D) -> void:
		player_in_chat_zone = false
	
func _on_dialogchat_dialog_finished() -> void:
	is_chatting = false
	$dialogchat.visible=false
