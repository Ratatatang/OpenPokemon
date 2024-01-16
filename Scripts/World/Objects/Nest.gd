class_name Nest
extends WorldFeature

@export var objectSpawns = {100:[""]}
@export var alphaSpawns = {100:[""]}

var dominantPokemon

enum {
	RANDOMSPAWNS,
	ESTABLISHEDNEST
}

func _ready():
	if(runReady):
		maxObjects = 1
		
		var keys = objectSpawns.keys()
		var pokeList = objectSpawns.get(keys.pick_random())
			
		for i in maxObjects:
			while(!spawnObjectRandPos("res://Scenes/World/Entities/WildPokemon/%s.tscn" % pokeList.pick_random(), 0.6, 0.6)):
				pass
