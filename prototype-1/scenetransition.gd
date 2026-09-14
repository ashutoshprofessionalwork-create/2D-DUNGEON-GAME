extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

var _target_packed: PackedScene = null
var _target_file: String = ""
var _tween: Tween

func _ready() -> void:
	layer = 128
	if color_rect:
		color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		color_rect.color = Color(0, 0, 0, 0)
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene_packed(packed_scene: PackedScene, fade_duration: float = 0.5) -> void:
	if not packed_scene:
		return
	_target_packed = packed_scene
	_target_file = ""
	_start_transition(fade_duration)

func change_scene_file(file_path: String, fade_duration: float = 0.5) -> void:
	if file_path.is_empty():
		return
	_target_file = file_path
	_target_packed = null
	_start_transition(fade_duration)

# Backward compatibility alias
func change_to_load(scene_path: String) -> void:
	change_scene_file(scene_path, 0.4)

func _start_transition(fade_duration: float) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	
	if color_rect:
		color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(color_rect, "color:a", 1.0, fade_duration)
	_tween.tween_callback(_perform_scene_change)
	_tween.tween_property(color_rect, "color:a", 0.0, fade_duration)
	_tween.tween_callback(func():
		if color_rect:
			color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)

func _perform_scene_change() -> void:
	if _target_packed:
		get_tree().change_scene_to_packed(_target_packed)
	elif not _target_file.is_empty():
		get_tree().change_scene_to_file(_target_file)
