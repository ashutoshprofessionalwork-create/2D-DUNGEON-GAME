extends HBoxContainer

@export var full_heart: Texture2D
@export var half_heart: Texture2D
@export var empty_heart: Texture2D

const HP_PER_HEART = 10 

func update_hearts(current_health: int, max_health: int):
	for child in get_children():
		child.queue_free()
		
	var total_hearts = max_health / HP_PER_HEART
	
	for i in range(total_hearts):
		var heart = TextureRect.new()
		heart.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		
		var min_hp_for_full = (i + 1) * HP_PER_HEART
		var min_hp_for_half = min_hp_for_full - (HP_PER_HEART / 2)
		
		if current_health >= min_hp_for_full:
			heart.texture = full_heart
		elif current_health >= min_hp_for_half:
			heart.texture = half_heart
		else:
			heart.texture = empty_heart
			
		add_child(heart)
