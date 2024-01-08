class_name WorldFeature
extends Node3D


var runReady : bool = true

#Entities and Static Object
var connectedObjects = []

#Areas that spawn objects
var connectedFeatures = []

func spawnObject(object):
	while(true):
		var x = randf_range(-1, 1)
		var z = randf_range(-1, 1)

		var pos = to_global(Vector3(x, 0, z))

		if(get_parent().get_parent().groundTileGlobal(pos)):
			get_parent().get_parent().placeForeignObject(object, pos)
			return
