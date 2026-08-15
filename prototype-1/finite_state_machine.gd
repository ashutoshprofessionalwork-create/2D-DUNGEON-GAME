extends Node2D

var current_state
var previous_state

func _ready() -> void:
	current_state = get_child(0)
	previous_state = current_state
	current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
		current_state.transition()

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func change_state(state_name: String):
	var new_state = find_child(state_name)
	if new_state:
		current_state.exit()
		previous_state = current_state
		current_state = new_state
		current_state.enter()
