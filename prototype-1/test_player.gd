extends CharacterBody2D
 
@export var bullet_node: PackedScene
 
func _physics_process(_delta):
	velocity = Input.get_vector("ui_left","ui_right","ui_up","ui_down") * 250
	move_and_slide()
 
func shoot():
	var bullet = bullet_node.instantiate()
 
	bullet.position = global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	get_tree().current_scene.call_deferred("add_child",bullet)
 
func _input(event):
	if event.is_action("shoot"):
		shoot()
