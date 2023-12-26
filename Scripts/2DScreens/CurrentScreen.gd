extends Node3D

func clearScreens():
	for child in get_children():
		child.queue_free()
