extends CPUParticles2D

func _ready() -> void:
	emitting = true # Start blasting instantly
	# Wait for the lifetime to finish, then wipe it from memory
	await get_tree().create_timer(lifetime).timeout
	queue_free()
