extends Control
@export_file("*.json") var d_file
signal dialog_finished

var dialog=[]
var current_dialog_id=0
var d_active=false
# Called when the node enters the scene tree for the first time.
func _ready():
	$NinePatchRect.visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func start():
	if d_active:
		return
	d_active=true
	$NinePatchRect.visible=true
	dialog=load_dialogue()
	current_dialog_id=-1
	next_script()

func load_dialogue():
	var file=FileAccess.open("res://dialogue/queen_dailog1.json",FileAccess.READ)
	var content=JSON.parse_string(file.get_as_text())
	return content
	
func _input(event):
	if !d_active:
		return
	if event.is_action_pressed("interact"):
		next_script()
	
func next_script():
	current_dialog_id+=1
	if current_dialog_id>=len(dialog):
		d_active=false
		$NinePatchRect.visible=false
		emit_signal("dialog_finished")
		return
	$NinePatchRect/Name.text=dialog[current_dialog_id]["name"]
	$NinePatchRect/Text.text=dialog[current_dialog_id]["text"]
	
