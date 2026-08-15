extends Label

func _ready() -> void:
	# FORCE POSITION: Puts the text inside the screen bounds automatically
	global_position = Vector2(100, 50)
	
	Global.score_changed.connect(_on_score_changed)
	text = "SCORE: " + str(Global.score)

func _on_score_changed(new_score: int) -> void:
	text = "SCORE: " + str(new_score)
