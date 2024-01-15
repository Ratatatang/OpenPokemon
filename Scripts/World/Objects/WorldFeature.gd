class_name WorldFeature
extends Node3D

var runReady : bool = true
@export var maxObjects = 1

#Entities and Static Object
var connectedObjects = []

#Areas that spawn objects
var connectedFeatures = []

func decideObjects(objects):
	var objectsList = []
	
	var keys = objects.keys()
	keys.sort()
	
	for i in range(round(randf_range(1, maxObjects))):
		var num = randf_range(0, 100)
		
		for j in keys:
			if(j == keys[keys.size()-1]):
				objectsList.append(objects.get(j))
				break
			if(j >= num):
				objectsList.append(objects.get(j))
				break
			else:
				continue
		
	return objectsList

func spawnObjectRandPos(object, boundsX, boundsZ):
	while(true):
		var x = randf_range(-(boundsX), boundsX)
		var z = randf_range(-(boundsZ), boundsZ)

		var pos = to_global(Vector3(x, 0, z))

		if(get_parent().get_parent().groundTileGlobal(pos)):
			get_parent().get_parent().placeForeignObject(load(object), pos)
			return
