class_name Nest
extends WorldFeature

@export var objectSpawns = {100:[""]}
@export var alphaSpawns = {100:[""]}

var dominantPokemon

@onready var NestZone = $Nest_Zone

enum {
	RANDOMSPAWMS,
	ESTABLISHEDNEST
}

func _ready():
	if(runReady):
		maxObjects = 1
	#$Nest_Zone/CollisionShape.scale.x = round(rand_range(1, 6))
	#$Nest_Zone/CollisionShape.scale.z = round(rand_range(1, 6))
		if(NestZone.has_overlapping_areas()):
			#0 = They merge into an established nest
			#1 = Deletes this node
			#var pick = [0, 0, 1].pick_random()
			var pick = 0
			if(pick == 0):
				var nests = NestZone.get_overlapping_areas()
				pass
			#elif(pick == 1):
				#queue_free()
		else:
			var pokeList = decideObjects(objectSpawns)
			
			for p in pokeList:
				var num = randf_range(0, p.size()-1)
				spawnObjectRandPos("res://Scenes/World/Entities/WildPokemon/%s.tscn" % p[num], 1, 1)
