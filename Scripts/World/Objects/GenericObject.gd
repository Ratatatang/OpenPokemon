extends StaticBody3D
class_name GenericObject

@export var textureVariations: Array[String] = []
@export var objectName: String = ""
@export var alwaysCenter: bool = false

var runReady = true

func _ready():
	pass

func startTimer():
	pass

func getName():
	return objectName

func getType():
	return "Object"
