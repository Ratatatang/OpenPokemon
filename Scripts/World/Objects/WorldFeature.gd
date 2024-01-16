class_name WorldFeature
extends Node3D

var runReady : bool = true
@export var maxObjects = 1

#Entities and Static Object
var connectedObjects = []

#Areas that spawn objects
var connectedFeatures = []

func spawnObjectRandPos(object, boundsX, boundsZ, biome = null):
	var x = randf_range(-(boundsX), boundsX)
	var z = randf_range(-(boundsZ), boundsZ)

	var pos = to_global(Vector3(x, 0, z))
		
	var world = MasterInfo.worldGenNode

	if(world.groundTileGlobal(pos)):
		if(biome == null):
			world.placeForeignObject(load(object), pos)
			return true
		elif(biome.has(world.getBiomeGlobal(pos))):
			world.placeForeignObject(load(object), pos)
			return true
	return false

func spawnObjectExactPos(object, x, z, biome = null):
	var pos = to_global(Vector3(x, 0, z))
		
	var world = MasterInfo.worldGenNode

	if(world.groundTileGlobal(pos)):
		if(biome == null):
			world.placeForeignObject(load(object), pos)
			return true
		elif(biome.has(world.getBiomeGlobal(pos))):
			world.placeForeignObject(load(object), pos)
			return true
	return false
