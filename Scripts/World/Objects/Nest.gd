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
		var pokeList = decideObjects(objectSpawns)
			
		for p in pokeList:
			var num = randf_range(0, p.size()-1)
			while(!spawnObjectRandPos("res://Scenes/World/Entities/WildPokemon/%s.tscn" % p[num], 0.6, 0.6)):
				pass
