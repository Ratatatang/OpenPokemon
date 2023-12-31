extends StaticBody3D
class_name GenericObject

@export var textureVariations: Array[String] = []
@export var objectName: String = ""

var runReady = true

func _ready():
	if(textureVariations.size() > 0):
		$Sprite3D.texture = load(textureVariations.pick_random())

func startTimer():
	pass

func getName():
	return objectName
