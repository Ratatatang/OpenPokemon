extends Node3D

var player 

#Updates FPS counter every process
func _process(delta):
	$FPS.text = str(Engine.get_frames_per_second())
