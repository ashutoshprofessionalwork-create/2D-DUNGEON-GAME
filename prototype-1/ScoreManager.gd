# ScoreManager.gd
extends Node

var score: int = 0

func add_score(amount: int):
	score += amount
	# Emit a signal so the UI updates automatically
	score_updated.emit(score)

signal score_updated(new_score)
