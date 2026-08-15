extends State
@onready var animation_player = owner.find_child("AnimationPlayer") 
var can_transition: bool = false
 
func enter():
	super.enter()
	animation_player.play("skill")
	await animation_player.animation_finished
	can_transition = true
 
 
func teleport():
	owner.position = owner.player.position + Vector2.RIGHT * 40
 
 
func transition():
	if can_transition:
		get_parent().change_state("Attack")
		can_transition = false
