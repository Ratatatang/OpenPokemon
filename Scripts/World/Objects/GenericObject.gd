extends StaticBody3D
class_name GenericObject

@export var textureVariations: Array[String] = []

var runReady = true

func _ready():
	if(textureVariations.size() > 0):
		$Sprite2D.texture = load(textureVariations.pick_random())

func startTimer():
	pass
