extends Spatial

export(int) var wander_range = 0.5

onready var start_position = get_parent().global_translation
onready var target_position = get_parent().global_translation

onready var timer = $Timer

func update_target_position():
	var target_vector = Vector3(rand_range(-wander_range, wander_range), start_position.y, rand_range(-wander_range, wander_range))
	target_position = start_position + target_vector
	
func get_time_left():
	return timer.time_left
	
func start_wander_timer(duration):
	timer.start(duration)

func _on_Timer_timeout():
	update_target_position()
