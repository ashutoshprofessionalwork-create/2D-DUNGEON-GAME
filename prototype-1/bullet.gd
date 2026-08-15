extends Area2D
var direction=Vector2.RIGHT
var speed=300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	position+=direction*speed*delta


func _on_body_entered(body: Node2D) -> void:
	body.take_damage() # Replace with function body.



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Replace with function body.
