extends Node2D

func get_player():
	return get_child(0).get_node("Player")

func get_screen():
	return get_node("Screen")
