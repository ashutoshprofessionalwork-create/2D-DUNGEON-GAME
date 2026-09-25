extends Control

@export_file("*.json") var d_file: String = "res://dialogue/queen_dailog1.json"
@export var text_speed: float = 0.03

signal dialog_finished

var dialog = []
var current_dialog_id = 0
var d_active = false
var is_typing = false
var current_tween: Tween #?what is this use 

@onready var box_node = $NinePatchRect
@onready var name_label = $NinePatchRect/Name
@onready var text_label = $NinePatchRect/Text
@onready var prompt_label = $NinePatchRect/Prompt

func _ready():
	visible = false

func start():
	if d_active:
		return
	d_active = true
	visible = true
	box_node.visible = true
	dialog = load_dialogue()
	current_dialog_id = -1
	next_script()

func load_dialogue():
	var path = d_file if d_file != "" else "res://dialogue/queen_dailog1.json"
	if not FileAccess.file_exists(path):
		return []
	var file = FileAccess.open(path, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content if content != null else []

func _input(event):
	if !d_active:
		return
	if event.is_action_pressed("interact"):
		if is_typing:
			# Skip typewriter effect and show full text immediately
			if current_tween:
				current_tween.kill()
			text_label.visible_ratio = 1.0
			is_typing = false
			prompt_label.visible = true
		else:
			next_script()

func next_script():
	current_dialog_id += 1
	if current_dialog_id >= len(dialog):
		d_active = false
		visible = false
		box_node.visible = false
		emit_signal("dialog_finished")
		return
	
	var cur_data = dialog[current_dialog_id]
	var speaker_name = cur_data.get("name", "")
	var full_text = cur_data.get("text", "")
	
	name_label.text = speaker_name
	text_label.text = full_text
	
	# Typewriter effect
	text_label.visible_ratio = 0.0
	is_typing = true
	prompt_label.visible = false
	
	if current_tween:
		current_tween.kill()
	
	var duration = len(full_text) * text_speed
	current_tween = create_tween()
	current_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	current_tween.finished.connect(_on_typing_finished)

func _on_typing_finished():
	is_typing = false
	prompt_label.visible = true


	
