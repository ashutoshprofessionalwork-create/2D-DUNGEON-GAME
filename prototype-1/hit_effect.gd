extends CPUParticles2D

func _ready() -> void:
	# Multiply scale_amount by node scale if set
	if scale != Vector2.ONE:
		scale_amount_min *= scale.x
		scale_amount_max *= scale.x
		scale = Vector2.ONE
	emitting = true # Start blasting instantly
	# Wait for the lifetime to finish, then wipe it from memory
	await get_tree().create_timer(lifetime).timeout
	queue_free()
