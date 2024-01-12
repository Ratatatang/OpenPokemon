extends Node3D

@export var wander_range: float = 0.5

@onready var start_position = get_parent().global_position
@onready var target_position = get_parent().global_position

@onready var timer = $Timer
@onready var emote = $EmoteTimer

func update_target_position():
	while(true):
		var target_vector = Vector3(randf_range(-wander_range, wander_range), 0, randf_range(-wander_range, wander_range))
	
		if(MasterInfo.worldGenNode.waterTileGlobal(start_position + target_vector)):
			pass
		else:
			target_position = start_position + target_vector
			break
	
func get_time_left():
	return timer.time_left
	
func start_wander_timer(duration):
	timer.start(duration)

func start_emote_timer(duration):
	emote.start(duration)

func _on_Timer_timeout():
	update_target_position()
