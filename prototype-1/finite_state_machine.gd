extends Node2D

var current_state
var previous_state

func _ready() -> void:
	current_state = get_child(0)
	previous_state = current_state
	if current_state:
		current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
		current_state.transition()

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func change_state(state_name: String):
	if current_state and current_state.name.to_lower() == "death":
		return

	var new_state = find_child(state_name)
	if not new_state:
		for child in get_children():
			if child.name.to_lower() == state_name.to_lower():
				new_state = child
				break

	if new_state:
		if current_state and current_state.has_method("exit"):
			current_state.exit()
		previous_state = current_state
		current_state = new_state
		current_state.enter()
	else:
		push_warning("FSM: no state node found named '%s'" % state_name)
