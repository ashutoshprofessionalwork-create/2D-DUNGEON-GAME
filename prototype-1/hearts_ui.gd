
extends Control

@onready var sprite = $HeartsSprite

func update_hearts(current_health: int, _max_health: int):
	if current_health >= 90:
		sprite.frame = 0 # 3 full hearts
	elif current_health >= 75:
		sprite.frame = 1 # 2.5 hearts
	elif current_health >= 60:
		sprite.frame = 2 # 2 hearts
	elif current_health >= 45:
		sprite.frame = 3 # 1.5 hearts
	elif current_health >= 30:
		sprite.frame = 4 # 1 heart
	elif current_health >= 15:
		sprite.frame = 5 # 0.5 heart
	else:
		sprite.frame = 6 # 0 hearts (Dead)
