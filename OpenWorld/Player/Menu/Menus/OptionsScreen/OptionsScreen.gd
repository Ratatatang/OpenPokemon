extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]


func _on_Host_pressed():
	$Connect/ErrorSpace.text = "Invalid name!"
	return


func _on_Join_pressed():
	$Connect/ErrorSpace.text = "Invalid IP!"
	return
