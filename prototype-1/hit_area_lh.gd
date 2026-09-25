extends Area2D

func _ready() -> void:
	add_to_group("enemy")
	monitoring = true
	monitorable = true
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack") or area.name.contains("attack") or area.name.contains("hitbox") or area.name.contains("Hitbox"):
		var damage = 10
		if "damage" in area:
			damage = area.damage
		elif "attack_damage" in area:
			damage = area.attack_damage
		take_damage(damage, area.global_position)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_attack") or body.name.contains("bullet"):
		var damage = 10
		if "damage" in body:
			damage = body.damage
		take_damage(damage, body.global_position)

func get_global_position_override() -> Vector2:
	# If this Area2D has a CollisionShape2D child, return its true global position
	if has_node("CollisionShape2D"):
		return $CollisionShape2D.global_position
	return global_position

func take_damage(amount: int = 10, source_position: Vector2 = Vector2.ZERO, force: float = 0.0):
	var boss = get_parent()
	if boss and boss.has_method("take_damage"):
		boss.take_damage(amount, source_position, force)
