extends Node2D

@export var next_level: PackedScene

@onready var boss = $ruincity_boss if has_node("ruincity_boss") else find_child("ruincity_boss")
@onready var exit_area = $DetectionArea if has_node("DetectionArea") else null

var boss_defeated: bool = false

func _ready() -> void:
	if has_node("player/AnimationPlayer"):
		$player/AnimationPlayer.play("new_animation_2")

	if exit_area:
		exit_area.monitoring = false
		exit_area.visible = false

	if boss:
		if not boss.boss_died.is_connected(_on_boss_died):
			boss.boss_died.connect(_on_boss_died)

func _process(_delta: float) -> void:
	pass

func _on_boss_died() -> void:
	print("Ruin City Boss defeated! Level exit unlocked.")
	boss_defeated = true
	if exit_area:
		exit_area.monitoring = true
		exit_area.visible = true

func _on_detection_area_body_entered(body: Node2D) -> void:
	if boss_defeated and next_level:
		var st = get_node_or_null("/root/SceneTransition")
		if st:
			st.change_scene_packed(next_level, 0.5)
		else:
			get_tree().change_scene_to_packed.call_deferred(next_level)

func _on_detection_area_body_exited(_body: Node2D) -> void:
	print("area exited")
