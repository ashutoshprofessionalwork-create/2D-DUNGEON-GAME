# ScoreLabel.gd
extends Label

func _ready():
	# Connect to global score updates and display starting score
	ScoreManager.score_updated.connect(_on_score_updated)
	text=" :  "+str(ScoreManager.score)

func _on_score_updated(new_score: int):
	text = "Score: " + str(new_score)
