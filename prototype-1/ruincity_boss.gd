class_name RuinCityBoss
extends CharacterBody2D

signal boss_died

@export var max_health: int = 500
@export var speed: float = 200.0
@export var attack_damage: int = 25
@export var attack_range: float = 180.0
@export var detection_range: float = 2500.0

@export var heavy_attack_damage: int = 50
@export var heavy_attack_range: float = 200.0
@export var heavy_attack_cooldown: float = 6.0

@export var rock_throw_cooldown: float = 5.0
@export var rock_scene: PackedScene = preload("res://rock_projectile.tscn")

@export var hit_effect_scene: PackedScene = preload("res://hit_effect_boss.tscn")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var fsm = $FiniteStateMachine
@onready var progress_bar = $UI/ProgressBar if has_node("UI/ProgressBar") else null

var player: Node2D = null
var direction: Vector2 = Vector2.ZERO
var facing_left: bool = false

var heavy_attack_timer: float = 0.0
var rock_throw_timer: float = 0.0

var health: int = 500:
	set(value):
		health = clamp(value, 0, max_health)
		if progress_bar:
			progress_bar.max_value = max_health
			progress_bar.value = health
		if health <= 0:
			die()

func _ready():
	add_to_group("enemy")
	if has_node("HIT_AREA_LH"):
		$HIT_AREA_LH.add_to_group("enemy")
	if has_node("HIT_AREA_RH"):
		$HIT_AREA_RH.add_to_group("enemy")
	health = max_health
	if progress_bar:
		progress_bar.max_value = max_health
		progress_bar.value = health

	if has_node("HIT_AREA_LH"):
		var area_lh = $HIT_AREA_LH
		if not area_lh.has_method("take_damage"):
			area_lh.set_script(preload("res://hit_area_lh.gd"))
	if has_node("HIT_AREA_RH"):
		var area_rh = $HIT_AREA_RH
		if not area_rh.has_method("take_damage"):
			area_rh.set_script(preload("res://hit_area_lh.gd"))

func _physics_process(delta: float):
	if heavy_attack_timer > 0.0:
		heavy_attack_timer -= delta
	if rock_throw_timer > 0.0:
		rock_throw_timer -= delta

	if not is_on_floor():
		velocity.y += 1200.0 * delta

	if not player or not is_instance_valid(player):
		player = get_parent().find_child("player") if get_parent() else null
		if not player and get_tree():
			player = get_tree().get_first_node_in_group("player")

	if player and is_instance_valid(player):
		direction = player.global_position - global_position
		if abs(direction.x) > 5.0 and fsm and fsm.current_state and (fsm.current_state.name == "idle" or fsm.current_state.name == "follow"):
			facing_left = (direction.x < 0)
			if anim:
				anim.flip_h = not facing_left

func safe_move_and_slide():
	if health <= 0:
		return
	if is_nan(velocity.x) or is_nan(velocity.y):
		velocity = Vector2.ZERO
	up_direction = Vector2.UP
	move_and_slide()

func take_damage(amount: int = 10, source_position: Vector2 = Vector2.ZERO, force: float = 0.0):
	if health <= 0:
		return
	health -= amount

	if source_position != Vector2.ZERO and force > 0:
		var knockback_dir = sign(global_position.x - source_position.x)
		if knockback_dir == 0:
			knockback_dir = 1
		velocity.x = knockback_dir * force * 0.3

	if hit_effect_scene and get_tree() and get_tree().current_scene:
		var effect = hit_effect_scene.instantiate()
		effect.global_position = global_position
		get_tree().current_scene.add_child(effect)

	if anim and get_tree():
		anim.modulate = Color(4.0, 0.4, 0.4, 1.0)
		var timer = get_tree().create_timer(0.12)
		timer.timeout.connect(func(): if is_instance_valid(anim): anim.modulate = Color(1, 1, 1, 1))

func screen_shake(intensity: float = 10.0, duration: float = 0.3):
	var cam: Camera2D = null
	if player and is_instance_valid(player):
		cam = player.get_node_or_null("Camera2D") if player.has_node("Camera2D") else player.get_node_or_null("Camera2D2")
	if not cam and get_viewport():
		cam = get_viewport().get_camera_2d()
	
	if not cam:
		return
		
	var orig_offset = cam.offset
	var elapsed = 0.0
	while elapsed < duration and is_instance_valid(cam):
		cam.offset = orig_offset + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	if is_instance_valid(cam):
		cam.offset = orig_offset

func die():
	if progress_bar:
		progress_bar.visible = false
	var state_machine = fsm if fsm else get_node_or_null("FiniteStateMachine")
	if state_machine:
		state_machine.change_state("death")
	else:
		boss_died.emit()
		queue_free()
