extends Control

@onready var texture = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	#var greyMap = altitude
	var map = Image.new()
	map.fill(Color(79, 174, 288))
	texture.texture = map

