
extends Control

@onready var health_bar = $HealthBar
@onready var damage_bar = $DamageBar
@onready var health_label = $HealthLabel

var damage_tween: Tween

func update_hearts(current_health: int, max_health: int):
	var target_pct = clamp(float(current_health) / float(max_health) * 100.0, 0.0, 100.0)
	
	if health_bar:
		health_bar.value = target_pct
		
	if health_label:
		health_label.text = "HP %d / %d" % [max(0, current_health), max_health]
		
	if damage_bar:
		if damage_tween:
			damage_tween.kill()
		damage_tween = create_tween()
		damage_tween.tween_interval(0.2)
		damage_tween.tween_property(damage_bar, "value", target_pct, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

