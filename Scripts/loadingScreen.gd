extends Control

var progress = []
var sceneName = "res://Scenes/Master.tscn"
var sceneLoadStatus = 0

func _ready():
	ResourceLoader.load_threaded_request(sceneName)

func _process(delta):
	sceneLoadStatus = ResourceLoader.load_threaded_get_status(sceneName, progress)
	$ProgressLabel.text = str(floor(progress[0]*100)) + "%"
	if(sceneLoadStatus == ResourceLoader.THREAD_LOAD_LOADED):
		var newScene = ResourceLoader.load_threaded_get(sceneName)
		get_node("Temp").change_scene_to_packed(newScene)
