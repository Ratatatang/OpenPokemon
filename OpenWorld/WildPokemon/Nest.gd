extends Spatial

var validSpawns = {1: "Bulbasaur"}
var wildPokemonPath = load("res://OpenWorld/WildPokemon/WildPokemon.tscn")

func _ready():
	#$Nest_Zone/CollisionShape.scale.x = round(rand_range(1, 6))
	#$Nest_Zone/CollisionShape.scale.z = round(rand_range(1, 6))
	spawnPokemon()
	
func spawnPokemon():
	var x = rand_range(-1, 1)
	var z = rand_range(-1, 1)

	var pos = to_global(Vector3(x, 0, z))

	if(get_parent().groundTileGlobal(pos)):
		get_parent().placeForeignObject(wildPokemonPath, pos)
